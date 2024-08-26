import SwiftUI

struct BMIView: View {
    @ObservedObject var viewModel: HomePageViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            bmiSection
            bmiDisplay
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .foregroundColor(AppColors.textColor)
        .cornerRadius(15)
    }
    
    private var bmiSection: some View {
        HStack {
            Text("Body Mass Index")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            Spacer()
            HStack() {
                Text(String(format: "%.1f", viewModel.bmi))
                    .font(.headline)
                    .foregroundColor(bmiColor)
                Text("(\(bmiCategory))")
                    .font(.subheadline)
                    .foregroundColor(bmiColor)
            }
            
        }
    }

    private var bmiDisplay: some View {
        VStack(alignment: .leading, spacing: 5) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background gradient
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: self.calculateOffset(for: 18.5, in: geometry.size.width))
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: self.calculateOffset(for: 25, in: geometry.size.width) - self.calculateOffset(for: 18.5, in: geometry.size.width))
                        Rectangle()
                            .fill(Color.orange)
                            .frame(width: self.calculateOffset(for: 30, in: geometry.size.width) - self.calculateOffset(for: 25, in: geometry.size.width))
                        Rectangle()
                            .fill(Color.red)
                    }
                    .frame(height: 5)
                    
                    // BMI indicator
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(bmiColor, lineWidth: 2))
                        .offset(x: self.calculateOffset(for: self.viewModel.bmi, in: geometry.size.width) - 7.5)
                    
                    // Markers with labels and line cuts
                    ForEach([18.5, 25, 30], id: \.self) { marker in
                            Text(String(format: "%.1f", marker))
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .offset(y: 15)
                                .offset(x: self.calculateLabelOffset(for: marker, in: geometry.size.width))
                    }
                }
            }
            .frame(height: 35)
            
//            // Category labels
//            HStack {
//                Text("Low")
//                Spacer()
//                Text("Standard")
//                Spacer()
//                Text("High")
//                Spacer()
//                Text("Too high")
//            }
//            .foregroundColor(.gray)
//            .font(.caption)
        }
    }
    
    private var bmiCategory: String {
        switch viewModel.bmi {
        case ..<15:
            return "Severely Underweight"
        case 15..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal weight"
        case 25..<30:
            return "Overweight"
        case 30..<35:
            return "Obese"
        default:
            return "Severely Obese"
        }
    }
    
    private var bmiColor: Color {
        switch viewModel.bmi {
        case ..<18.5:
            return .blue
        case 18.5..<25:
            return .green
        case 25..<30:
            return .orange
        default:
            return .red
        }
    }
    
    private func calculateLabelOffset(for marker: CGFloat, in width: CGFloat) -> CGFloat {
        let baseOffset = self.calculateOffset(for: marker, in: width)
        switch marker {
        case 18.5:
            return baseOffset - 20 // Move 18.5 label more to the left
        case 25:
            return baseOffset - 15 // Move 25 label slightly to the left
        case 30:
            return baseOffset - 10 // Move 30 label less to the left
        default:
            return baseOffset - 15
        }
    }
    
    private func calculateOffset(for value: CGFloat, in width: CGFloat) -> CGFloat {
        let clampedValue = max(15, min(35, value))
        let bmiRange: CGFloat = 35 - 15
        let proportion = (clampedValue - 15) / bmiRange
        return proportion * width
    }
}
