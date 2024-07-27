import SwiftUI

struct LogsView: View {
    @ObservedObject var viewModel: HomePageViewModel
    
    var body: some View {
        List {
            ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                Section(header: Text(formatDate(date))) {
                    ForEach(groupedLogs[date]!, id: \.id) { log in
                        LogEntryRow(log: log)
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Logs")
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
                    .foregroundColor(.gray)
                Text(formatTime(log.date))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Image(systemName: "scalemass")
                    .foregroundColor(.blue)
                Text("Weight: \(log.weight, specifier: "%.1f") kg")
                    .font(.headline)
            }
            
            if log.sideEffectType != "None" {
                HStack {
                    Image(systemName: "bandage")
                        .foregroundColor(.red)
                    Text("Side Effect: \(log.sideEffectType)")
                }
            }
            
            if log.emotionType != "None" {
                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.pink)
                    Text("Emotion: \(log.emotionType)")
                }
            }
            if log.sideEffectType != "None" {
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.red)
                    Text("Food Noise: \(log.foodNoise)")
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

