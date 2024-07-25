import SwiftUI
import Firebase
import GoogleSignIn

struct ContentView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var verificationMessage: String = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(colorScheme == .dark ? .black : .white)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Logo
                    Image("Icon4") // Replace with your app's icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .padding(.top, 50)
                    
                    if signInManager.isSignedIn {
                        signedInView
                    } else {
                        signedOutView
                    }
                    
                    // Verification message
                    Text(verificationMessage)
                        .foregroundColor(.green)
                        .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private var signedInView: some View {
        VStack(spacing: 20) {
            Text("Welcome, \(signInManager.userProfile?.name ?? "User")!")
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            NavigationLink(destination: OnboardingView()) {
                Text("Continue to App")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: {
                signInManager.signOut()
            }) {
                Text("Sign Out")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Button(action: verifyDataStorage) {
                Text("Verify Data Storage")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .padding()
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
                    Image("google_logo") // Add a Google logo image to your assets
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
    
    private func verifyDataStorage() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                verificationMessage = "Data verified: \(userProfile.name), Height: \(userProfile.height), Weight: \(userProfile.weight)"
            case .failure(let error):
                verificationMessage = "Error verifying data: \(error.localizedDescription)"
            }
        }
    }
}
