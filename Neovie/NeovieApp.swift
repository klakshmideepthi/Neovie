import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseFirestore
import FirebaseFunctions
import UIKit
import FirebaseAnalytics
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    static var orientationLock = UIInterfaceOrientationMask.portrait
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured")
        Analytics.setAnalyticsCollectionEnabled(true)
        
        // Set up Firebase Messaging
        Messaging.messaging().delegate = self
        
        // Set up notifications
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        updateCurrentUserAge()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }

    private func updateCurrentUserAge() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        FirestoreManager.shared.updateUserAge(for: userId) { result in
            switch result {
            case .success:
                print("User age updated successfully")
            case .failure(let error):
                print("Failed to update user age: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - MessagingDelegate
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        handleNotification(userInfo: userInfo)
        
        completionHandler([[.banner, .sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        handleNotification(userInfo: userInfo)
        
        completionHandler()
    }
    
    private func handleNotification(userInfo: [AnyHashable: Any]) {
        if let campaignName = userInfo["campaignName"] as? String, campaignName == "Water" {
            NotificationCenter.default.post(name: .waterReminderReceived, object: nil)
        }
        
        print("Received notification: \(userInfo)")
    }
}

@main
struct NeovieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        setupOrientationLock()
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    
    private func setupOrientationLock() {
        AppDelegate.orientationLock = .portrait
    }
}
