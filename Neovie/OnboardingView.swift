import SwiftUI
import Lottie

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
                    VStack(spacing: 18) {
                        LottieView(name: "network-fitness-app-and-healthy-lifestyle")
                            .frame(width: 400, height: 400)
                        
                        Text("Welcome to Neovie")
                            .font(.system(size: 34, weight: .bold))
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Your personalized weight loss journey")
                            .font(.title)
                            .multilineTextAlignment(.center)
                            .padding()

                        NavigationLink(destination: destinationView) {
                            Text("Great!")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: 0xC67C4E))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    Spacer()
                }
                .background(Color(hex: 0xEDEDED))
                .edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            userStateManager.checkUserInfoStatus { _ in
                // You can add any additional logic here if needed
            }
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

// LottieView component remains unchanged

// UserStateManager remains unchanged
// LottieView component
struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
}

// ... Rest of your code (UserStateManager) remains unchanged
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
                                       userProfile.targetWeight > 0 &&
                                       !userProfile.medicationName.isEmpty &&
                                       !userProfile.dosage.isEmpty
                
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
