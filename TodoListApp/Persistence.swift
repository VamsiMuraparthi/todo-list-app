import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let calendar = Calendar.current
        let today = Date()
        
        // Add sample tasks for preview
        for i in 0..<5 {
            let newItem = TaskItem(context: viewContext)
            newItem.id = UUID()
            newItem.title = "Task \(i + 1)"
            newItem.details = "Detailed explanation of what needs to be done for task number \(i + 1)."
            // Scatter dates around today
            newItem.dueDate = calendar.date(byAdding: .hour, value: (i - 2) * 4, to: today) ?? today
            newItem.isCompleted = i % 3 == 0
            newItem.hasAlarm = i % 2 == 0
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TaskModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
