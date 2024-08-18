import SwiftUI

struct WaterView: View {
    @State private var waterIntake: Double = 0
    let dailyGoal: Double = 2000 // 2 liters in ml
    let incrementValue: Double = 250 // 250ml per button press
    
    var body: some View {
        ZStack {
            AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Daily Water Intake")
                    .font(.title)
                    .foregroundColor(AppColors.textColor)
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(AppColors.accentColor)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(waterIntake / dailyGoal, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: waterIntake)
                    
                    VStack {
                        Text("\(Int(waterIntake))ml")
                            .font(.largeTitle)
                            .bold()
                        Text("of \(Int(dailyGoal))ml")
                    }
                    .foregroundColor(AppColors.textColor)
                }
                .frame(width: 200, height: 200)
                
                HStack(spacing: 30) {
                    Button(action: {
                        if waterIntake > 0 {
                            waterIntake -= incrementValue
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.accentColor)
                    }
                    
                    Button(action: {
                        waterIntake += incrementValue
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.accentColor)
                    }
                }
                
                Text("Each button press is worth 250ml")
                    .font(.caption)
                    .foregroundColor(AppColors.textColor)
            }
            .padding()
        }
    }
}
