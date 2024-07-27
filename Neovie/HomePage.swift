import SwiftUI
import Charts

struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showingSettingsHome = false
    @State private var selectedTab = 0
    @State private var showingNewLog = false
    
    var body: some View {
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
                ChatbotView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chatbot")
            }
            .tag(1)
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
                    viewModel.showWeightLoggingSheet = true
                }) {
                    Label("Log Weight", systemImage: "scale.3d")
                }
                
                Button(action: {
                    viewModel.showSideEffectLoggingSheet = true
                }) {
                    Label("Log Side Effect", systemImage: "bandage")
                }
                
                Button(action: {
                    viewModel.showEmotionLoggingSheet = true
                }) {
                    Label("Log Emotion", systemImage: "heart")
                }
            }
            
            Section(header: Text("Progress")) {
                WeightProgressChart(data: viewModel.weightData)
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
                    .cornerRadius(15)  // Adjust this value for more or less rounded corners
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
    @Published var weightData: [WeightEntry] = []
    @Published var showWeightLoggingSheet = false
    @Published var showSideEffectLoggingSheet = false
    @Published var showEmotionLoggingSheet = false
    
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
        
        FirestoreManager.shared.getWeightLogs { result in
            switch result {
            case .success(let weightLogs):
                DispatchQueue.main.async {
                    self.weightData = weightLogs
                }
            case .failure(let error):
                print("Error fetching weight logs: \(error.localizedDescription)")
            }
        }
    }
    
    func logWeight(_ weight: Double) {
        let newEntry = WeightEntry(date: Date(), weight: weight)
        FirestoreManager.shared.saveWeightLog(newEntry) { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.weightData.append(newEntry)
                    self.currentWeight = weight
                }
            case .failure(let error):
                print("Error saving weight log: \(error.localizedDescription)")
            }
        }
    }
    
    func logSideEffect(_ sideEffect: SideEffect) {
        FirestoreManager.shared.saveSideEffectLog(sideEffect) { result in
            switch result {
            case .success:
                print("Side effect logged successfully")
            case .failure(let error):
                print("Error saving side effect log: \(error.localizedDescription)")
            }
        }
    }
    
    func logEmotion(_ emotion: Emotion) {
        FirestoreManager.shared.saveEmotionLog(emotion) { result in
            switch result {
            case .success:
                print("Emotion logged successfully")
            case .failure(let error):
                print("Error saving emotion log: \(error.localizedDescription)")
            }
        }
    }
}

struct WeightProgressChart: View {
    let data: [WeightEntry]
    
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

// Note: WeightLoggingView, SideEffectLoggingView, and EmotionLoggingView
// should be defined in separate files or at the bottom of this file.
