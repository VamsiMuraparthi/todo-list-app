import Foundation
import UserNotifications

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Requests notification permissions from the system
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification Authorization Error: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Checks current authorization status
    func checkPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
    
    /// Schedules a local notification/alarm for a TaskItem
    func scheduleNotification(for task: TaskItem) {
        // Always cancel existing notification for this task first to avoid duplicates
        cancelNotification(for: task)
        
        // Alarms are only scheduled if enabled, not completed, and date is in the future
        guard task.hasAlarm, !task.isCompleted else { return }
        guard let id = task.id?.uuidString else { return }
        let date = task.wrappedDueDate
        
        guard date > Date() else {
            print("Skipped scheduling: due date \(date) is in the past.")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Task Alarm"
        content.subtitle = task.wrappedTitle
        content.body = task.wrappedDetails.isEmpty ? "Time to complete your task!" : task.wrappedDetails
        content.sound = UNNotificationSound.default
        content.badge = 1
        
        // Match specific date and time components
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification for \(id): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(id) at \(date)")
            }
        }
    }
    
    /// Cancels any scheduled notification for a TaskItem
    func cancelNotification(for task: TaskItem) {
        guard let id = task.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        print("Cancelled pending notification for \(id)")
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Shows the notification banner even if the app is currently in the foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
