import SwiftUI

struct BMIAndProteinCalculationView: View {
    @Binding var userProfile: UserProfile
    @State private var navigateToNextView = false
    @State private var isNotificationPermissionGranted = false

    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    Text("Your Health Metrics")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 50)
                    
                    MetricCard(title: "BMI", value: String(format: "%.1f", userProfile.bmi), description: getBMIDescription())
                    
                    MetricCard(title: "Daily Protein Goal", value: String(format: "%.1f g", userProfile.proteinGoal), description: "Based on your weight and activity level")
                    
                    Spacer()
                    
                    ContinueButton
                }
                .padding()
            }
            .foregroundColor(AppColors.textColor)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .background(
            NavigationLink(destination: destinationView, isActive: $navigateToNextView) {
                EmptyView()
            }
        )
        .onAppear(perform: updateMetrics)
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
            Text("Lets go!!")
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
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
