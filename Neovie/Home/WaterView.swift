import SwiftUI

struct WaterView: View {
    @State private var waterIntake: Double = 0
    let dailyGoal: Double = 2000 // 2 liters in ml
    let incrementValue: Double = 250 // 250ml per button press
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 15) {
                Text("Daily Water Intake")
                    .font(.title2)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(AppColors.textColor)
                
                HStack(spacing: 20) {
                    Button(action: {
                        if waterIntake > 0 {
                            waterIntake -= incrementValue
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.accentColor)
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 10)
                            .opacity(0.3)
                            .foregroundColor(AppColors.accentColor)
                        
                        Circle()
                            .trim(from: 0.0, to: CGFloat(min(waterIntake / dailyGoal, 1.0)))
                            .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                            .foregroundColor(Color.blue)
                            .rotationEffect(Angle(degrees: 270.0))
                            .animation(.linear, value: waterIntake)
                        
                        VStack(spacing: 5) {
                            Text("\(Int(waterIntake))ml")
                                .font(.title2)
                                .bold()
                            Text("of \(Int(dailyGoal))ml")
                                .font(.caption)
                        }
                        .foregroundColor(AppColors.textColor)
                    }
                    .frame(width: min(geometry.size.width * 0.4, 120), height: min(geometry.size.width * 0.4, 120))
                    
                    Button(action: {
                        waterIntake += incrementValue
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(AppColors.accentColor)
                    }
                }
                
                Text("Each button press is 250ml")
                    .font(.caption2)
                    .foregroundColor(AppColors.textColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(15)
        }
        .frame(height: 200)  // This sets a default height, but allows the view to grow if needed
    }
}
