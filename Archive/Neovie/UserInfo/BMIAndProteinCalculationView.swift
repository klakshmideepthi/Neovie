import SwiftUI


struct BMIAndProteinCalculationView: View {
    @Binding var userProfile: UserProfile
    @State private var navigateToNextView = false
    @State private var isNotificationPermissionGranted = false
    @State private var hasAcceptedDisclaimer = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                
                ScrollView {
                    VStack(spacing: 30) {
                        Text("Your Health Metrics")
                            .font(.system(size: 28, weight: .bold))
                            .padding(.top, 50)
                        
                        MetricCard(title: "BMI", value: String(format: "%.1f", userProfile.bmi), description: getBMIDescription())
                        
                        MetricCard(title: "Daily Protein Goal", value: String(format: "%.1f g", userProfile.proteinGoal), description: "Based on your weight and activity level")
                    }
                }
                .padding()
                
                Spacer()
                
//                DisclaimerView(isAccepted: $hasAcceptedDisclaimer)
                
                ContinueButton
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
            .background(
                NavigationLink(destination: destinationView, isActive: $navigateToNextView) {
                    EmptyView()
                }
            )
        
        .onAppear(perform: updateMetrics)
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
                    .background(AppColors.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
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
