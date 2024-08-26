import SwiftUI

struct WaterView: View {
    @StateObject private var waterManager = WaterIntakeManager()
    let dailyGoal: Double = 2000 // 2 liters in ml
    let incrementValue: Double = 250 // 250ml per button press
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("Water")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                Text("\(Int(waterManager.waterIntake)) mL of \(Int(dailyGoal)) mL")
                    .font(.title2)
                    .foregroundColor(AppColors.textColor)
                
                Text("Each button press is 250ml")
                    .font(.caption2)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(Color.blue.opacity(0.2), lineWidth: 5)
                        .frame(width: 65, height: 65)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(waterManager.waterIntake / dailyGoal, 1.0)))
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 65, height: 65)
                        .rotationEffect(.degrees(-90))
                    
                    Image("water")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.blue)
                }
                
                HStack(spacing: 15) {
                    Button(action: {
                        waterManager.subtractWater(incrementValue)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.accentColor)
                    }
                    
                    Button(action: {
                        waterManager.addWater(incrementValue)
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
            waterManager.loadTodaysWaterIntake()
        }
    }
}
