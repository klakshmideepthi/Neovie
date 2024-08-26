import Foundation
import FirebaseMessaging
import UserNotifications

class NotificationManager: NSObject, ObservableObject {
    @Published var settings: UNNotificationSettings?
    
    override init() {
        super.init()
        getNotificationSettings()
    }
    
    func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, _  in
                self.getNotificationSettings()
                completion(granted)
            }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.settings = settings
            }
        }
    }
    
    func subscribeToTopic(_ topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let error = error {
                print("Error subscribing to topic: \(error.localizedDescription)")
            } else {
                print("Subscribed to topic: \(topic)")
            }
        }
    }
    
    func unsubscribeFromTopic(_ topic: String) {
        Messaging.messaging().unsubscribe(fromTopic: topic) { error in
            if let error = error {
                print("Error unsubscribing from topic: \(error.localizedDescription)")
            } else {
                print("Unsubscribed from topic: \(topic)")
            }
        }
    }
}
