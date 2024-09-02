import SwiftUI

struct WaterIntakeGraphView: View {
    var waterIntakes: [Date: Double]
    let maxIntake: Double = 2000.0 // Max intake is set to 2 liters
    
    private var weekDates: [Date] {
        let calendar = Calendar.current
        let today = Date()
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        return (0...6).map { calendar.date(byAdding: .day, value: $0, to: weekStart)! }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background grid lines
                VStack(spacing: 0) {
                    ForEach(0..<5) { i in
                        Divider()
                        Spacer()
                            .frame(height: geometry.size.height / 4)
                    }
                }

                // Graph
                Path { path in
                    // Sort the dates to ensure correct order
                    for (index, date) in weekDates.sorted().enumerated() {
                        if let intake = waterIntakes[date] {
                            let x = CGFloat(index) / 6 * geometry.size.width
                            let y = (1 - CGFloat(intake / maxIntake)) * geometry.size.height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                }
                .stroke(AppColors.accentColor, lineWidth: 2)

                // Data points
                ForEach(weekDates.sorted(), id: \.self) { date in // Sort dates here too
                    if let intake = waterIntakes[date] {
                        let index = weekDates.firstIndex(of: date)! // Get index of the date
                        let x = CGFloat(index) / 6 * geometry.size.width
                        let y = (1 - CGFloat(intake / maxIntake)) * geometry.size.height

                        Circle()
                            .fill(AppColors.accentColor)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }

                // Y-axis labels
                VStack {
                    ForEach(0..<5) { i in
                        Text("\(2 * (4.0-Double(i)) / 4.0, specifier: "%.1f")L") // Correct calculation
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
                .position(x: -20, y: geometry.size.height / 2)
                
                
                // X-axis labels
                HStack {
                    ForEach(weekDates, id: \.self) { date in
                        Text(formatWeekday(date))
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height + 15)
            }
        }
        .padding(.bottom)
        .padding(.horizontal)
    }
    
    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
