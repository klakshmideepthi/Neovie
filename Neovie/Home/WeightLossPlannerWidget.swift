import SwiftUI

struct WeightLossPlannerWidget: View {
    var onKnowMoreTapped: () -> Void
    
    private let snippets = [
        "Discover your personalized weight loss journey with expert guidance, tailored nutrition plans, and achievable fitness goals designed just for you...",
        "Unlock the secrets to sustainable weight management through balanced eating, regular exercise, and lifestyle changes that fit your unique needs and preferences...",
        "Transform your lifestyle with expert weight loss advice, covering everything from meal prep strategies to stress management techniques for holistic health improvement...",
        "Achieve your goals with a tailored weight loss plan that considers your medical history, dietary restrictions, and personal preferences for long-term success...",
        "Embark on a comprehensive weight loss program that combines cutting-edge nutritional science with personalized workout routines to maximize your results...",
        "Learn how to make lasting changes to your eating habits, activity levels, and mindset for effective and maintainable weight loss over time..."
    ]
    
    var body: some View {
        VStack(alignment:.leading,spacing: 10) {
            HStack{
                Text("Weight Loss Planner")
                    .font(.headline)
                    .foregroundColor(AppColors.accentColor)
                Spacer()
                Text("AI powered")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(AppColors.highlighter)
                    .cornerRadius(5)
                
            }
            
            Text(snippets.randomElement() ?? "")
                .font(.subheadline)
                .foregroundColor(AppColors.textColor)
//                .lineLimit(3)
                .truncationMode(.tail)
            
            Button(action: onKnowMoreTapped) {
                Text("Know More")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppColors.accentColor)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
    }
}
