import SwiftUI

struct SignedOutView: View {
    @StateObject private var signInManager = GoogleSignInManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    LottieView(name: "network-fitness-app-and-healthy-lifestyle", play: true)
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.5)
                        .padding(.top, geometry.size.height * 0.05)
                    
                    VStack(spacing: 15) {
                        Text("Sign In to get started")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text("Create your account to keep your data safe, sync between devices, and start owning your day.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("By continuing, you agree to our Privacy Policy and Terms of Use")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            signInManager.signIn()
                        }) {
                            HStack {
                                Image("google_logo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Sign In with Google")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
