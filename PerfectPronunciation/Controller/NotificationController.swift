import Foundation
import UserNotifications

class NotificationController {
    
    func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotifications() {
        
        let content = UNMutableNotificationContent()
        content.title = "Perfect Pronunciation"
        content.subtitle = "Get your daily lesson in!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        
        dateComponents.hour = 14
        dateComponents.minute = 55
        dateComponents.second = 45
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func scheduleNotification(enabled: Bool) {
            if enabled {
                scheduleNotifications()
            } else {
                removeNotifications()
            }
        }
    
    func removeNotifications() {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    
}
