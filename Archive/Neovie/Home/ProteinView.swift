import SwiftUI

struct ProteinView: View {
    @ObservedObject var proteinManager: ProteinIntakeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("Protein")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                Text("\(String(format: "%.1f", proteinManager.proteinIntake)) g of \(String(format: "%.1f", proteinManager.proteinGoal)) g")
                    .font(.title2)
                    .foregroundColor(AppColors.textColor)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.brown.opacity(0.2), lineWidth: 5)
                    .frame(width: 65, height: 65)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(proteinManager.proteinIntake / max(proteinManager.proteinGoal, 1), 1.0)))
                    .stroke(Color.brown, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 65, height: 65)
                    .rotationEffect(.degrees(-90))
                
                Image("muscle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color.blue)
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
    }
}
