import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @StateObject private var userStateManager = UserStateManager()
    @Environment(\.colorScheme) var colorScheme
    @State private var isShowingOnboarding = false
    @State private var isShowingHomePage = false
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if signInManager.isSignedIn {
                if isShowingHomePage {
                    HomePage()
                } else if isShowingOnboarding {
                    OnboardingView()
                } else {
                    SplashScreenView()
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
        GeometryReader { geometry in
            NavigationView {
                ZStack {
                    AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image("Icon4")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                        
                        Text("Welcome to Neovie")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColors.textColor)
                        
                        Text("Sign in to start your personalized weight loss journey")
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(AppColors.textColor)
                        
                        Spacer()
                        
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
                            .background(AppColors.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    }
                    .padding()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
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
                    isLoading = false
                }
            }
        }
}
