import SwiftUI
import Charts

struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showingSettingsHome = false
    @State private var selectedTab = 0
    @State private var showingNewLog = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationView {
                    HomeTabContent(viewModel: viewModel, showingSettingsHome: $showingSettingsHome, showingNewLog: $showingNewLog)
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
                
                NavigationView {
                                    LogsView(viewModel: viewModel)
                                }
                .tabItem {
                    Image(systemName: "list.bullet.clipboard")
                    Text("Logs")
                }
                .tag(1)
                
                NavigationView {
                    ChatbotView()
                }
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Chatbot")
                }
                .tag(2)
            }
        }
        .sheet(isPresented: $showingSettingsHome) {
            SettingsHomeView()
        }
        .sheet(isPresented: $showingNewLog) {
            NewLogView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchUserData()
        }
    }
}

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    @Binding var showingNewLog: Bool
    
    var body: some View {
        List {
            Section(header: Text("Today's Overview")) {
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
            
            Section(header: Text("Quick Actions")) {
                Button(action: {
                    showingNewLog = true
                }) {
                    Label("New Log Entry", systemImage: "plus.circle")
                }
            }
            
            Section(header: Text("Progress")) {
                WeightProgressChart(data: viewModel.logs)
                    .frame(height: 200)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettingsHome = true
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .overlay(
            Button(action: {
                showingNewLog = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.blue)
                    .cornerRadius(15)
                    .shadow(radius: 3)
            }
            .padding()
            , alignment: .bottomTrailing
        )
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
        Chart {
            ForEach(data) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weight)
                )
            }
        }
    }
}

struct ChatbotView: View {
    var body: some View {
        Text("Chatbot View")
            .font(.largeTitle)
    }
}

