import SwiftUI
import Lottie

struct OnboardingView: View {
    @State private var userProfile = UserProfile()
    @StateObject private var userStateManager = UserStateManager()
    @State private var navigateToHomePage = false

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        
                        VStack(spacing: geometry.size.height * 0.05) {
                            LottieView(name: "network-fitness-app-and-healthy-lifestyle",play: true)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.9)
                            
                            Text("Welcome to Neovie")
                                .font(.system(size: 34, weight: .bold))
                                .multilineTextAlignment(.center)
                                .foregroundColor(AppColors.textColor)
                            
                            Text("Your personalized weight loss journey")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .foregroundColor(AppColors.textColor)
                            
                            NavigationLink(destination: destinationView) {
                                Text("Great!")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.accentColor)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .padding()
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
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
            UserInfoName(userProfile: $userProfile).navigationBarBackButtonHidden(true)
        }
    }
}

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .loop
    var play: Bool
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView()
        let animation = LottieAnimation.named(name)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let animationView = uiView.subviews.first as? LottieAnimationView else { return }
        
        if play {
            animationView.play()
        } else {
            animationView.stop()
            animationView.currentProgress = 0
        }
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
