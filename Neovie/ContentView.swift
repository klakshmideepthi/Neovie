import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var verificationMessage: String = ""
    @State private var isShowingOnboarding = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(colorScheme == .dark ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Image("Icon4")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 50)
                    
                    if signInManager.isSignedIn {
                        Text("Signed In")
                            .onAppear {
                                isShowingOnboarding = true
                            }
                    } else {
                        signedOutView
                    }
                    
                    Text(verificationMessage)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $isShowingOnboarding) {
                OnboardingView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .userDidSignOut)) { _ in
            isShowingOnboarding = false
            signInManager.isSignedIn = false
        }
    }
    
    private var signedOutView: some View {
        VStack(spacing: 20) {
            Text("Welcome to MedZen")
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
    }
}
