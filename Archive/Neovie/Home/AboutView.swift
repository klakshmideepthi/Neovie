import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Version 1.0")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
                
                Text("Neovie is your personalized weight loss companion, designed to help you achieve your health goals with ease and support.")
                    .font(.body)
                    .foregroundColor(AppColors.textColor)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key Features:")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    
                    bulletPoint("Track your weight loss progress")
                    bulletPoint("Log daily metrics and experiences")
                    bulletPoint("Receive personalized tips and insights")
                    bulletPoint("AI-powered chatbot for support and advice")
                    bulletPoint("Medication reminders and dosage tracking")
                }
                
                Text("Developed by [Your Company Name]")
                    .font(.caption)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
                
                Text("For support, please contact: support@neovie.com")
                    .font(.caption)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
            }
            .padding()
        }
        .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("About")
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
                .foregroundColor(AppColors.accentColor)
            Text(text)
                .foregroundColor(AppColors.textColor)
        }
    }
}
