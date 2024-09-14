import SwiftUI
import Lottie


struct BMIAndProteinCalculationView: View {
    @Binding var userProfile: UserProfile
    @State private var navigateToNextView = false
    @State private var isNotificationPermissionGranted = false
    @State private var hasAcceptedDisclaimer = false
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                ScrollView {
                    VStack(alignment:.center,spacing: 30) {
                        Spacer()
                        if isLoading {
                            Text("Analyzing data to tailor your ideal health objectives")
                                .font(.system(size: 28, weight: .bold))
                                .padding(.top, 50)
                                .multilineTextAlignment(.center)
                            Spacer(minLength: 50)
                            BMILottieView(name: "loading", loopMode: .loop)
                                .frame(width: 200, height: 200)
                        } else {
                            Text("Your Health Metrics")
                                .font(.system(size: 28, weight: .bold))
                                .padding(.top, 50)
                            MetricCard(title: "BMI", value: String(format: "%.1f", userProfile.bmi), description: getBMIDescription())
                            
                            MetricCard(title: "Daily Protein Goal", value: String(format: "%.1f g", userProfile.proteinGoal), description: "Based on your weight and activity level")
                            
                            MetricCard(title: "Daily Water Intake", value: String(format: "%d ml", 2000), description: "Recommended average human consumption")
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                ContinueButton
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(destination: destinationView, isActive: $navigateToNextView) {
                    EmptyView()
                }
            )
        }
        .onAppear(perform: {
            updateMetrics()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                isLoading = false
            }
        })
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if isNotificationPermissionGranted {
            HomePage().navigationBarBackButtonHidden(true)
        } else {
            NotificationRequest().navigationBarBackButtonHidden(true)
        }
    }
    
    private var ContinueButton: some View {
        Button(action: {
            checkNotificationPermission()
        }) {
            Text("Let's go!")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isLoading ? AppColors.accentColor.opacity(0.5) : AppColors.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(isLoading)
        .padding(.horizontal)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationPermissionGranted = (settings.authorizationStatus == .authorized)
                self.navigateToNextView = true
            }
        }
    }

    private func updateMetrics() {
        userProfile.updateBMIAndProteinGoal()
    }
    
    private func getBMIDescription() -> String {
        switch userProfile.bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<24.9:
            return "Normal weight"
        case 25..<29.9:
            return "Overweight"
        default:
            return "Obese"
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let description: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.accentColor)
            
            Text(value)
                .font(.system(size: 36, weight: .bold))
            
            Text(description)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(AppColors.textColor.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 15).fill(AppColors.secondaryBackgroundColor))
        .shadow(color: Color.black.opacity(0.1), radius: 5)
    }
}


struct DisclaimerView: View {
    @Binding var isAccepted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: {
                isAccepted.toggle()
            }) {
                Image(systemName: isAccepted ? "checkmark.square.fill" : "square")
                    .foregroundColor(isAccepted ? AppColors.accentColor : .gray)
            }
            
            Text("I confirm that I have read, consent and agree to the use of generative AI and my personal information to provide personalized content in this app. I understand that I can change my preferences at any time in my Account Settings.")
                .font(.system(size: 10))
                .foregroundColor(AppColors.textColor.opacity(0.8))
                .lineLimit(nil)
        }
        .padding(.horizontal)
    }
}

struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? AppColors.accentColor : .gray)
                .onTapGesture { configuration.isOn.toggle() }
            configuration.label
        }
    }
}

// Rename LottieView to BMILottieView to avoid conflicts
struct BMILottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce

    func makeUIView(context: UIViewRepresentableContext<BMILottieView>) -> UIView {
        let view = UIView(frame: .zero)
        let animationView = LottieAnimationView()
        animationView.animation = LottieAnimation.named(name)
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

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BMILottieView>) {}
}
