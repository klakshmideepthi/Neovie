import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Last updated: [Insert Date]")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
                
                Text("At Neovie, we take your privacy seriously. This Privacy Policy describes how we collect, use, and share your personal information.")
                    .font(.body)
                    .foregroundColor(AppColors.textColor)
                
                privacySection(title: "Information We Collect",
                               content: "We collect information you provide directly to us, such as your name, email address, date of birth, gender, height, weight, and medication details.")
                
                privacySection(title: "How We Use Your Information",
                               content: "We use your information to provide and improve our services, personalize your experience, and communicate with you about our products and services.")
                
                privacySection(title: "Data Security",
                               content: "We implement appropriate technical and organizational measures to protect your personal information against unauthorized or unlawful processing, accidental loss, destruction, or damage.")
                
                privacySection(title: "Your Rights",
                               content: "You have the right to access, correct, or delete your personal information. You can also object to or restrict certain processing of your data.")
                
                privacySection(title: "Changes to This Policy",
                               content: "We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.")
                
                Text("If you have any questions about this Privacy Policy, please contact us at: privacy@neovie.com")
                    .font(.caption)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
            }
            .padding()
        }
        .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        .navigationTitle("Privacy Policy")
    }
    
    private func privacySection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            Text(content)
                .font(.body)
                .foregroundColor(AppColors.textColor.opacity(0.8))
        }
    }
} 
