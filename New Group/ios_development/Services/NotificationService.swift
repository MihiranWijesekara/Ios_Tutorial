import Foundation
import Combine
import UserNotifications

class NotificationService: ObservableObject {
    @Published var isAuthorized: Bool = false
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
        }
    }
    
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func scheduleDailyChallengeNotification(at date: Date) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyChallenge"])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Challenge"
        content.body = "Time to test your gaming skills! Complete your daily challenge now."
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "DailyChallenge", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelDailyChallengeNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["DailyChallenge"])
    }
}
