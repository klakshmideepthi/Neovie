import SwiftUI

struct LogsView: View {
    @ObservedObject var viewModel = HomePageViewModel()
    
    var body: some View {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                            VStack(alignment: .leading, spacing: 10) {
                                Text(formatDate(date))
                                    .font(.headline)
                                    .padding(.leading)
                                    .foregroundColor(AppColors.textColor.opacity(0.6))
                                
                                ForEach(groupedLogs[date]!, id: \.id) { log in
                                    LogEntryRow(log: log)
                                        .background(AppColors.secondaryBackgroundColor)
                                        .cornerRadius(10)
                                        .shadow(color: AppColors.textColor.opacity(0.05), radius: 5, x: 0, y: 2)
                                        .frame(maxWidth: .infinity) // This makes the LogEntryRow take full width
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    private var groupedLogs: [Date: [LogData.LogEntry]] {
        Dictionary(grouping: viewModel.logs) { log in
            Calendar.current.startOfDay(for: log.date)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
}

struct LogEntryRow: View {
    let log: LogData.LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(AppColors.textColor.opacity(0.6))
                Text(formatTime(log.date))
                    .font(.subheadline)
                    .foregroundColor(AppColors.textColor.opacity(0.6))
            }
            
            HStack {
                Image(systemName: "scalemass")
                    .foregroundColor(.blue)
                Text("Weight: \(log.weight, specifier: "%.1f") kg")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
            }
            
            if log.sideEffectType != "None" {
                HStack {
                    Image(systemName: "bandage")
                        .foregroundColor(.red)
                    Text("Side Effect: \(log.sideEffectType)")
                        .foregroundColor(AppColors.textColor)
                }
            }
            
            if log.emotionType != "None" {
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.pink)
                    Text("Emotion: \(log.emotionType)")
                        .foregroundColor(AppColors.textColor)
                }
            }
            if log.foodNoise != 0 {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.orange)
                    Text("Food Noise: \(log.foodNoise)")
                        .foregroundColor(AppColors.textColor)
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.8, alignment: .leading)
        .padding()
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
