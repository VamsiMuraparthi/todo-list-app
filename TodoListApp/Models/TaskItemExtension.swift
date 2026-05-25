import Foundation
import CoreData

extension TaskItem: Identifiable {
    // Provide safe, non-optional getters for Core Data optional fields
    var wrappedTitle: String {
        title ?? "Untitled Task"
    }
    
    var wrappedDetails: String {
        details ?? ""
    }
    
    var wrappedDueDate: Date {
        dueDate ?? Date()
    }
    
    // Status color helper for alarms
    var alarmColor: String {
        guard hasAlarm else { return "gray" }
        if isCompleted {
            return "green"
        }
        if wrappedDueDate < Date() {
            return "red"
        }
        return "accentColor"
    }
}
