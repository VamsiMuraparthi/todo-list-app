import Foundation
import CoreData
import Combine

class TodoViewModel: ObservableObject {
    private let viewContext: NSManagedObjectContext
    
    @Published var allTasks: [TaskItem] = []
    @Published var selectedDate: Date = Date()
    @Published var hasNotificationPermission: Bool = false
    
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchTasks()
        checkNotificationPermission()
    }
    
    /// Fetches all tasks from Core Data, sorted chronologically by due date
    func fetchTasks() {
        let request: NSFetchRequest<TaskItem> = NSFetchRequest<TaskItem>(entityName: "TaskItem")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TaskItem.dueDate, ascending: true)]
        
        do {
            allTasks = try viewContext.fetch(request)
            print("Fetched \(allTasks.count) tasks.")
        } catch {
            print("Failed to fetch tasks: \(error.localizedDescription)")
        }
    }
    
    /// Computes the filtered list of tasks for the currently selected calendar date
    var filteredTasks: [TaskItem] {
        let calendar = Calendar.current
        return allTasks.filter { task in
            calendar.isDate(task.wrappedDueDate, inSameDayAs: selectedDate)
        }
    }
    
    /// Checks if a date has at least one scheduled task (used to draw dots in the calendar)
    func hasTasks(on date: Date) -> Bool {
        let calendar = Calendar.current
        return allTasks.contains { task in
            calendar.isDate(task.wrappedDueDate, inSameDayAs: date)
        }
    }
    
    /// Queries the device for notification permission
    func checkNotificationPermission() {
        NotificationManager.shared.checkPermission { granted in
            self.hasNotificationPermission = granted
        }
    }
    
    /// Requests notification permissions from the user
    func requestNotificationPermission() {
        NotificationManager.shared.requestAuthorization { granted in
            self.hasNotificationPermission = granted
        }
    }
    
    /// Inserts a new task, saves Core Data, and schedules alarm notification if enabled
    func addTask(title: String, details: String, dueDate: Date, hasAlarm: Bool) {
        let newTask = TaskItem(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.details = details.isEmpty ? nil : details
        newTask.dueDate = dueDate
        newTask.isCompleted = false
        newTask.hasAlarm = hasAlarm
        
        saveContext()
        
        if hasAlarm {
            NotificationManager.shared.scheduleNotification(for: newTask)
        }
        
        HapticManager.shared.triggerNotification(type: .success)
        fetchTasks()
    }
    
    /// Toggles the completion state of a task and manages alarm updates accordingly
    func toggleTaskCompletion(task: TaskItem) {
        task.isCompleted.toggle()
        saveContext()
        
        if task.isCompleted {
            // Cancel pending alarms for completed tasks
            NotificationManager.shared.cancelNotification(for: task)
            HapticManager.shared.triggerImpact(style: .medium)
        } else {
            // Re-schedule alarm if uncompleted and hasAlarm flag is true
            if task.hasAlarm {
                NotificationManager.shared.scheduleNotification(for: task)
            }
            HapticManager.shared.triggerImpact(style: .light)
        }
        
        fetchTasks()
    }
    
    /// Toggles alarm notification on/off for a specific task
    func toggleTaskAlarm(task: TaskItem) {
        task.hasAlarm.toggle()
        saveContext()
        
        if task.hasAlarm {
            NotificationManager.shared.scheduleNotification(for: task)
        } else {
            NotificationManager.shared.cancelNotification(for: task)
        }
        
        HapticManager.shared.triggerImpact(style: .light)
        fetchTasks()
    }
    
    /// Deletes a task from Core Data and cancels its scheduled alarm
    func deleteTask(task: TaskItem) {
        NotificationManager.shared.cancelNotification(for: task)
        viewContext.delete(task)
        saveContext()
        
        HapticManager.shared.triggerImpact(style: .medium)
        fetchTasks()
    }
    
    /// Deletes tasks from list index offset (for swipe-to-delete)
    func deleteTasks(at offsets: IndexSet) {
        let tasksToDelete = filteredTasks
        offsets.forEach { index in
            let task = tasksToDelete[index]
            deleteTask(task: task)
        }
    }
    
    /// Helper to save the managed object context
    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
                print("Core Data Context Saved Successfully.")
            } catch {
                let nsError = error as NSError
                print("Failed to save Core Data: \(nsError.localizedDescription), \(nsError.userInfo)")
            }
        }
    }
}
