import SwiftUI

struct WaterIntakeGraphView: View {
    var waterIntakes: [Date: Double]
    let maxIntake: Double = 2000.0 // Max intake is set to 2 liters
    
    private let yAxisValues = [2.0, 1.5, 1.0, 0.5, 0.0]
    
    // Fixed weekdays instead of dynamic dates
    private let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    // Convert date to weekday index (0 = Monday, 6 = Sunday)
    private func weekdayIndex(from date: Date) -> Int {
        let weekday = Calendar.current.component(.weekday, from: date)
        // Convert from Sunday=1 to Monday=0
        return (weekday + 5) % 7
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Overview")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack {
                    // Background
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                    
                    // Grid lines
                    VStack(spacing: 0) {
                        ForEach(yAxisValues, id: \.self) { value in
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            if value != 0.0 {  // Don't add spacer after last line
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 45)
                    .padding(.top, 20)
                    .padding(.bottom, 25)

                    // Y-axis labels
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(yAxisValues, id: \.self) { value in
                            Text("\(value, specifier: "%.1f")L")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            if value != 0.0 {  // Don't add spacer after last label
                                Spacer()
                            }
                        }
                    }
                    .frame(height: geometry.size.height - 45)
                    .padding(.top, 20)
                    .position(x: 35, y: geometry.size.height / 2)

                    // Bar chart - now using fixed weekday indices
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(0..<7) { index in
                            VStack {
                                let relevantIntakes = waterIntakes.filter { weekdayIndex(from: $0.key) == index }
                                let intake = relevantIntakes.values.first ?? 0.0
                                
                                Rectangle()
                                    .fill(Color.blue.opacity(0.7))
                                    .frame(width: 28, height: max(0, CGFloat(intake / maxIntake) * (geometry.size.height - 65)))
                                    .cornerRadius(6)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 45)
                    .padding(.bottom, 25)
                    .padding(.top, 20)
                    
                    // X-axis with fixed weekday labels
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { weekday in
                            Text(weekday)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 45)
                    .position(x: geometry.size.width / 2, y: geometry.size.height - 10)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
