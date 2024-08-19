import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseFirestore
import FirebaseFunctions

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("Firebase configured")
        return true
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
}

@main
struct NeovieApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
