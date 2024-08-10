import SwiftUI
import Charts

struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showingSettingsHome = false
    @State private var selectedTab = 0
    @State private var showingNewLog = false
    @State private var showingWeightLossAdvice = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: getTitle(for: selectedTab),
                    showSettingsButton: true,
                    settingsAction: { showingSettingsHome = true }
                )
                
                TabView(selection: $selectedTab) {
                    HomeTabContent(viewModel: viewModel, showingSettingsHome: $showingSettingsHome, showingNewLog: $showingNewLog, showingWeightLossAdvice: $showingWeightLossAdvice)
                        .tag(0)
                    
                    LogsView(viewModel: viewModel)
                        .tag(1)
                    
                    ChatbotWelcomeView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                CustomTabBar(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .sheet(isPresented: $showingSettingsHome) {
            SettingsHomeView()
        }
        .sheet(isPresented: $showingNewLog) {
            NewLogView(viewModel: viewModel).background(Color(hex: 0xEDEDED))
        }
        .sheet(isPresented: $showingWeightLossAdvice) {
            WeightLossAdviceView()
        }
        .onAppear {
            viewModel.fetchUserData()
        }
    }
    
    private func getTitle(for tab: Int) -> String {
        switch tab {
        case 0:
            return "Home"
        case 1:
            return "Logs"
        case 2:
            return "Chatbot"
        default:
            return ""
        }
    }
}

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    @Binding var showingNewLog: Bool
    @Binding var showingWeightLossAdvice: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                todaysOverviewSection
                quickActionsSection
                weightLossAdviceButton
                progressSection
                
            }
            .padding()
        }
        .background(Color(hex: 0xEDEDED))
        .overlay(newLogButton, alignment: .bottomTrailing)
    }
    
    private var todaysOverviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Overview")
                .font(.headline)
            
            HStack {
                Text("Current Weight:")
                Spacer()
                Text("\(viewModel.currentWeight, specifier: "%.1f") kg")
            }
            HStack {
                Text("Medication:")
                Spacer()
                Text(viewModel.medicationName)
            }
            HStack {
                Text("Next Dose:")
                Spacer()
                Text(viewModel.nextDose)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
            
            Button(action: {
                showingNewLog = true
            }) {
                Label("New Log Entry", systemImage: "plus.circle")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .foregroundColor(Color(hex: 0xC67C4E))
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.headline)
            
            WeightProgressChart(data: viewModel.logs)
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .foregroundColor(Color(hex: 0x394F56))
        }
    }
    
    private var weightLossAdviceButton: some View {
            Button(action: {
                showingWeightLossAdvice = true
            }) {
                Text("View Weight Management Advice")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: 0xC67C4E))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    
    private var newLogButton: some View {
        Button(action: {
            showingNewLog = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color(hex: 0xC67C4E))
                .cornerRadius(15)
                .shadow(radius: 3)
        }
        .padding()
    }
}

class HomePageViewModel: ObservableObject {
    @Published var currentWeight: Double = 0.0
    @Published var medicationName: String = ""
    @Published var nextDose: String = ""
    @Published var logs: [LogData.LogEntry] = []
    
    let sideEffects = ["Nausea", "Headache", "Fatigue", "Dizziness", "Other"]
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Frustrated", "Other"]
    
    func fetchUserData() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.currentWeight = userProfile.weight
                    self.medicationName = userProfile.medicationName
                    // TODO: Calculate next dose based on medication schedule
                    self.nextDose = "Calculate based on schedule"
                }
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
        
        FirestoreManager.shared.getLogs { result in
            switch result {
            case .success(let fetchedLogs):
                DispatchQueue.main.async {
                    self.logs = fetchedLogs
                    if let latestWeight = fetchedLogs.first?.weight {
                        self.currentWeight = latestWeight
                    }
                }
            case .failure(let error):
                print("Error fetching logs: \(error.localizedDescription)")
            }
        }
    }
    
    func logEntry(weight: Double, sideEffect: String, emotion: String, foodNoise: Int) {
        let newEntry = LogData.LogEntry(
            date: Date(),
            weight: weight,
            sideEffectType: sideEffect,
            emotionType: emotion,
            foodNoise: foodNoise
        )
        
        FirestoreManager.shared.saveLog(newEntry) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.currentWeight = weight
                    self.logs.insert(newEntry, at: 0)
                    print("Log entry saved successfully")
                }
            case .failure(let error):
                print("Error saving log entry: \(error.localizedDescription)")
            }
        }
    }
}

struct WeightProgressChart: View {
    let data: [LogData.LogEntry]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Y-axis
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                }
                .stroke(Color.gray, lineWidth: 1)
                
                // X-axis
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                }
                .stroke(Color.gray, lineWidth: 1)
                
                // Data points
                Path { path in
                    for (index, entry) in data.enumerated() {
                        let x = CGFloat(index) / CGFloat(data.count - 1) * geometry.size.width
                        let y = (1 - CGFloat(entry.weight - minWeight) / CGFloat(maxWeight - minWeight)) * geometry.size.height
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(Color.blue, lineWidth: 2)
            }
        }
    }
    
    private var minWeight: Double {
        data.map { $0.weight }.min() ?? 0
    }
    
    private var maxWeight: Double {
        data.map { $0.weight }.max() ?? 100
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
