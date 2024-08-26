import SwiftUI

struct LogsView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    var body: some View {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 20) {
                        stepsSection
                            .frame(width: geometry.size.width) // Ensure full width
                        Text("Logs ")
                            .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                        if viewModel.logs.isEmpty {
                            noLogsView
                        } else {
                            logsListView
                        }
                    }
                }
            }
            .onAppear {
                fetchData()
            }
            .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    
    private func fetchData() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                healthKitManager.fetchTodaySteps()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }
    
    private var noLogsView: some View {
            Text("No logs available")
                .font(.headline)
                .foregroundColor(AppColors.textColor.opacity(0.6))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        
        private var logsListView: some View {
            ForEach(groupedLogs.keys.sorted(by: >), id: \.self) { date in
                VStack(alignment: .leading, spacing: 10) {
                    Text(formatDate(date))
                        .font(.headline)
                        .padding(.leading)
                        .foregroundColor(AppColors.textColor.opacity(0.6))
                    
                    ForEach(groupedLogs[date]!, id: \.id) { log in
                        LogEntryRow(log: log, onDelete: {
                            viewModel.deleteLog(log)
                        })
                        .background(AppColors.secondaryBackgroundColor)
                        .cornerRadius(10)
                        .shadow(color: AppColors.textColor.opacity(0.05), radius: 5, x: 0, y: 2)
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    
    private var stepsSection: some View {
        VStack(alignment: .center) {
            Text("Today's Steps")
                .font(.title)
                .padding()
            
            Text("\(healthKitManager.steps)")
                .font(.system(size: 48, weight: .bold))
                .padding()
            
            Button("Refresh Steps") {
                healthKitManager.fetchTodaySteps()
            }
            .padding()
        }
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
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var deleteButtonWidth: CGFloat = 80
    private let closeThreshold: CGFloat = 20 // Threshold to automatically close the delete button
    private let dragThreshold: CGFloat = 50  // Threshold to determine a significant swipe
    
    var body: some View {
        ZStack(alignment: .trailing) {
            deleteButton
            
            contentView
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Limit the offset to within the delete button width
                            if gesture.translation.width < 0 {
                                // Swiping left
                                self.offset = max(gesture.translation.width, -deleteButtonWidth)
                            } else if self.offset != 0 {
                                // Swiping right when delete button is open
                                self.offset = min(0, self.offset + gesture.translation.width)
                            }
                        }
                        .onEnded { gesture in
                            withAnimation {
                                // If the swipe is less than closeThreshold, close the delete button
                                if abs(self.offset) < closeThreshold {
                                    self.offset = 0
                                } else if abs(self.offset) > dragThreshold {
                                    // If swipe was significant (greater than dragThreshold), keep it fully open
                                    self.offset = -deleteButtonWidth
                                } else {
                                    // Otherwise, reset to closed
                                    self.offset = 0
                                }
                            }
                        }
                )
        }
    }
    
    private var deleteButton: some View {
        GeometryReader { geometry in
            Button(action: {
                withAnimation {
                    self.offset = 0
                }
                onDelete()
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .frame(width: deleteButtonWidth, height: geometry.size.height)
                    .background(Color.red)
            }
        }
        .frame(width: deleteButtonWidth)
    }
    
    private var contentView: some View {
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
            
            if log.proteinIntake != 0 {
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(.green)
                    Text("Protein Intake: \(log.proteinIntake, specifier: "%.1f") g")
                        .foregroundColor(AppColors.textColor)
                    }
            }
            
            
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width * 0.9, alignment: .leading)
        .background(AppColors.secondaryBackgroundColor)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
