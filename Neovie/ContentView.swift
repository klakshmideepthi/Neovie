import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAnalytics

struct ContentView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @StateObject private var userStateManager = UserStateManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingUserInfo = false
    @State private var isShowingHomePage = false
    @State private var isLoading = true
    @StateObject private var waterReminderManager = WaterReminderManager()
    @StateObject private var notificationManager = NotificationManager()
    @State private var userProfile = UserProfile()
    
    var body: some View {
        Group {
            if waterReminderManager.shouldShowWaterReminder {
                WaterReminderView()
            } else if signInManager.isSignedIn {
                if isShowingHomePage {
                    HomePage()
                } else if isShowingUserInfo {
                    UserInfoName(userProfile: $userProfile).navigationBarBackButtonHidden(true)
                } else {
                    SplashScreenView()
                        .onAppear(perform: checkUserStatus)
                }
            } else {
                OnboardingView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            isShowingUserInfo = false
            isShowingHomePage = false
        }
        .onChange(of: signInManager.isSignedIn) { isSignedIn in
            if isSignedIn {
                checkUserStatus()
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    AnalyticsParameterMethod: "Google"
                ])
            }
        }
        .onAppear {
            userStateManager.checkUserInfoStatus { _ in
                // You can add any additional logic here if needed
            }
        }
    }
    
    var destinationView: some View {
        Group {
            if userStateManager.hasCompletedUserInfo {
                HomePage().navigationBarBackButtonHidden(true)
            } else {
                UserInfoName(userProfile: $userProfile).navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func checkUserStatus() {
        userStateManager.checkUserInfoStatus { hasCompletedUserInfo in
            DispatchQueue.main.async {
                if hasCompletedUserInfo {
                    isShowingHomePage = true
                    isShowingUserInfo = false
                } else {
                    isShowingUserInfo = true
                    isShowingHomePage = false
                }
                isLoading = false
            }
        }
    }
}


struct WaterReminderView: View {
    var body: some View {
        VStack {
            Text("Time to drink some water!")
            // Add more UI elements as needed
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

class UserStateManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var hasCompletedUserInfo: Bool = false
    
    func checkUserInfoStatus(completion: @escaping (Bool) -> Void) {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                let hasCompletedInfo = !userProfile.name.isEmpty &&
                                       !userProfile.gender.isEmpty &&
                                       userProfile.dateOfBirth != Date() &&
                                       userProfile.heightCm > 0 &&
                                       userProfile.weight > 0 &&
                                       userProfile.targetWeight > 0
                
                DispatchQueue.main.async {
                    self.hasCompletedUserInfo = hasCompletedInfo
                    completion(hasCompletedInfo)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.hasCompletedUserInfo = false
                    completion(false)
                }
            }
        }
    }
}
