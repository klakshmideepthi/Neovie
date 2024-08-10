import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @StateObject private var userStateManager = UserStateManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingOnboarding = false
    @State private var isShowingHomePage = false
    
    var body: some View {
        Group {
            if signInManager.isSignedIn {
                if isShowingHomePage {
                    HomePage()
                } else if isShowingOnboarding {
                    OnboardingView()
                } else {
                    ProgressView("Loading...")
                        .onAppear(perform: checkUserStatus)
                }
            } else {
                signedOutView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            isShowingOnboarding = false
            isShowingHomePage = false
        }
        .onChange(of: signInManager.isSignedIn) { isSignedIn in
            if isSignedIn {
                checkUserStatus()
            }
        }
    }
    
    private var signedOutView: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("Icon4")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.top, 50)
                
                Text("Welcome to Neovie")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Sign in to start your personalized weight loss journey")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button(action: {
                    signInManager.signIn()
                }) {
                    HStack {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        Text("Sign In with Google")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func checkUserStatus() {
        userStateManager.checkUserInfoStatus { hasCompletedUserInfo in
            DispatchQueue.main.async {
                if hasCompletedUserInfo {
                    isShowingHomePage = true
                    isShowingOnboarding = false
                } else {
                    isShowingOnboarding = true
                    isShowingHomePage = false
                }
            }
        }
    }
}
