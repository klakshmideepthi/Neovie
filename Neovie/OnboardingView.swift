import SwiftUI

struct OnboardingView: View {
    @State var progressState = ProgressState()
    @State private var userProfile = UserProfile()
    @StateObject private var userStateManager = UserStateManager()
    @State private var navigateToHomePage = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    Spacer()
                    VStack(spacing: 20) {
                        if let uiImage = UIImage(named: "Icon4") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                        } else {
                            Text("Image not found")
                                .foregroundColor(.red)
                        }
                        
                        Text("Welcome to Neovie")
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                            .fontWeight(.bold)
                        
                        Text("Your personalized weight loss journey")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: destinationView) {
                            Text("Great!")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            userStateManager.checkUserInfoStatus()
        }
    }

    @ViewBuilder
    var destinationView: some View {
        if userStateManager.hasCompletedUserInfo {
            HomePage().navigationBarBackButtonHidden(true)
        } else {
            UserInfo1(userProfile: $userProfile, progressState: $progressState).navigationBarBackButtonHidden(true)
        }
    }
}

class UserStateManager: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
    @Published var hasCompletedUserInfo: Bool = false
    
    func checkOnboardingStatus() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.hasCompletedOnboarding = !userProfile.name.isEmpty && !userProfile.medicationName.isEmpty
                }
            case .failure:
                DispatchQueue.main.async {
                    self.hasCompletedOnboarding = false
                }
            }
        }
    }
    
    func checkUserInfoStatus() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.hasCompletedUserInfo = !userProfile.name.isEmpty &&
                                                !userProfile.gender.isEmpty &&
                                                userProfile.dateOfBirth != Date() &&
                                                userProfile.heightCm > 0 &&
                                                userProfile.weight > 0 &&
                                                userProfile.targetWeight > 0 &&
                                                !userProfile.medicationName.isEmpty &&
                                                !userProfile.dosage.isEmpty
                }
            case .failure:
                DispatchQueue.main.async {
                    self.hasCompletedUserInfo = false
                }
            }
        }
    }
}
