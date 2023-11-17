//
//  Notifications.swift
//  SimpleNotifications
//
//  Created by Federico on 30/11/2021.
//

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
        content.subtitle = "Pls come back!"
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = 00
        dateComponents.minute = 57
        dateComponents.second = 30
        
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
