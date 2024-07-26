import SwiftUI
import Charts

struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showingSettingsHome = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                HomeTabContent(viewModel: viewModel, showingSettingsHome: $showingSettingsHome)
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
        .onAppear {
            viewModel.fetchUserData()
        }
    }
}

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    
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
        .sheet(isPresented: $viewModel.showWeightLoggingSheet) {
            WeightLoggingView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showSideEffectLoggingSheet) {
            SideEffectLoggingView(viewModel: viewModel)
        }
        .sheet(isPresented: $viewModel.showEmotionLoggingSheet) {
            EmotionLoggingView(viewModel: viewModel)
        }
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

struct ChatbotView: View {
    var body: some View {
        Text("Chatbot View")
            .font(.largeTitle)
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

struct WeightLoggingView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @State private var weight: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Weight")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Button("Save") {
                    if let weightValue = Double(weight) {
                        viewModel.logWeight(weightValue)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SideEffectLoggingView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @State private var selectedSideEffect: String = ""
    @State private var severity: Int = 1
    @Environment(\.presentationMode) var presentationMode
    
    let sideEffects = ["Nausea", "Headache", "Fatigue", "Dizziness", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Side Effect")) {
                    Picker("Side Effect", selection: $selectedSideEffect) {
                        ForEach(sideEffects, id: \.self) { effect in
                            Text(effect)
                        }
                    }
                }
                
                Section(header: Text("Severity (1-5)")) {
                    Stepper(value: $severity, in: 1...5) {
                        Text("Severity: \(severity)")
                    }
                }
                
                Button("Save") {
                    let sideEffect = SideEffect(type: selectedSideEffect, severity: severity, date: Date())
                    viewModel.logSideEffect(sideEffect)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Log Side Effect")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct EmotionLoggingView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @State private var selectedEmotion: String = ""
    @State private var intensity: Int = 1
    @Environment(\.presentationMode) var presentationMode
    
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Frustrated", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Emotion")) {
                    Picker("Emotion", selection: $selectedEmotion) {
                        ForEach(emotions, id: \.self) { emotion in
                            Text(emotion)
                        }
                    }
                }
                
                Section(header: Text("Intensity (1-5)")) {
                    Stepper(value: $intensity, in: 1...5) {
                        Text("Intensity: \(intensity)")
                    }
                }
                
                Button("Save") {
                    let emotion = Emotion(type: selectedEmotion, intensity: intensity, date: Date())
                    viewModel.logEmotion(emotion)
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("Log Emotion")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
