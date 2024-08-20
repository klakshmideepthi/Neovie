import SwiftUI

struct BMIView: View {
    @ObservedObject var viewModel: HomePageViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 15) {
                Text("BMI")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                Text(String(format: "%.1f", viewModel.bmi))
                    .font(.title2)
                    .foregroundColor(AppColors.textColor)
                
                Text(bmiCategory)
                    .font(.caption)
                    .foregroundColor(AppColors.textColor.opacity(0.7))
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.2), lineWidth: 5)
                    .frame(width: 65, height: 65)
                
                Circle()
                    .trim(from: 0, to: CGFloat(min(viewModel.bmi / 40, 1.0))) // Assuming max BMI of 40
                    .stroke(bmiColor, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 65, height: 65)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: "figure.stand")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(bmiColor)
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(15)
    }
    
    private var bmiCategory: String {
        switch viewModel.bmi {
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
    
    private var bmiColor: Color {
        switch viewModel.bmi {
        case ..<18.5:
            return .blue
        case 18.5..<24.9:
            return .green
        case 25..<29.9:
            return .orange
        default:
            return .red
        }
    }
}
