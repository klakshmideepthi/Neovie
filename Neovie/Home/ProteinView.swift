import SwiftUI

struct ProteinView: View {
    @StateObject private var proteinManager = ProteinIntakeManager()
    let incrementValue: Double = 10 // 10 grams per button press
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("Protein")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                Text("\(Int(proteinManager.proteinIntake)) g of \(Int(proteinManager.proteinGoal)) g")
                    .font(.title2)
                    .foregroundColor(AppColors.textColor)
                
                Text("Each button press is 10g")
                    .font(.caption2)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
            }
            
            Spacer()
            
            VStack(spacing: 10) {
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
                
                HStack(spacing: 15) {
                    Button(action: {
                        proteinManager.subtractProtein(incrementValue)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.accentColor)
                    }
                    
                    Button(action: {
                        proteinManager.addProtein(incrementValue)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
        .onAppear {
            proteinManager.loadTodaysProteinIntake()
            proteinManager.loadProteinGoal()
        }
    }
}
