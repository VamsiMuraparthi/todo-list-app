import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Trigger an impact feedback (light, medium, heavy, soft, rigid)
    func triggerImpact(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    /// Trigger a notification success, warning, or error feedback
    func triggerNotification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
