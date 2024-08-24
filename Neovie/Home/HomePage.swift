import SwiftUI
import Charts
import Firebase
import Combine


struct HomePage: View {
    @StateObject private var viewModel = HomePageViewModel()
    @State private var showingSettingsHome = false
    @State private var selectedTab = 0
    @State private var showingNewLog = false
    @State private var showingWeightLossAdvice = false
    @State private var showingSideEffects = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavigationBar(
                    title: getTitle(for: selectedTab),
                    showSettingsButton: true,
                    settingsAction: { showingSettingsHome = true }
                )
                
                TabView(selection: $selectedTab) {
                    HomeTabContent(viewModel: viewModel, showingSettingsHome: $showingSettingsHome, showingNewLog: $showingNewLog, showingWeightLossAdvice: $showingWeightLossAdvice,showingSideEffects: $showingSideEffects)
                        .tag(0)
                    
                    LogsView(viewModel: viewModel)
                        .tag(1)
                    
                    ExploreView()
                        .tag(2)
                    
                    if let userProfile = viewModel.userProfile, userProfile.hasSeenChatbotWelcome {
                        ChatbotHomeView()
                            .tag(3)
                    } else {
                        ChatbotWelcomeView(onCompletion: {
                            updateUserProfileAfterWelcome()
                        })
                        .tag(3)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                CustomTabBar(selectedTab: $selectedTab, showingNewLog: $showingNewLog, viewModel: viewModel)            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .background(AppColors.backgroundColor.ignoresSafeArea())
        .sheet(isPresented: $showingSettingsHome) {
                    if let userProfile = viewModel.userProfile {
                        SettingsHomeView(userProfile: Binding(
                            get: { userProfile },
                            set: { newValue in
                                viewModel.userProfile = newValue
                            }
                        ))
                    }
                }
        .sheet(isPresented: $showingNewLog) {
            NewLogView(viewModel: viewModel).background(Color(hex: 0xEDEDED))
        }
        .sheet(isPresented: $showingWeightLossAdvice) {
            WeightLossAdviceView()
        }
        .sheet(isPresented: $showingSideEffects) {
            if let userProfile = viewModel.userProfile {
                SideEffectsView(userProfile: .constant(userProfile))
            }
        }
        .onAppear {
            viewModel.fetchUserData()
            checkChatbotWelcomeStatus()
        }
    }

    
    private func getTitle(for tab: Int) -> String {
        switch tab {
        case 0:
            return "Home"
        case 1:
            return "Logs"
        case 2:
            return "Explore"
        case 3:
            return "Chatbot"
        default:
            return ""
        }
    }
    
    private func checkChatbotWelcomeStatus() {
            FirestoreManager.shared.getUserProfile { result in
                switch result {
                case .success(let profile):
                    DispatchQueue.main.async {
                        self.viewModel.userProfile = profile
                    }
                case .failure(let error):
                    print("Error fetching user profile: \(error.localizedDescription)")
                }
            }
        }
        
        private func updateUserProfileAfterWelcome() {
            if var userProfile = viewModel.userProfile {
                userProfile.hasSeenChatbotWelcome = true
                FirestoreManager.shared.saveUserProfile(userProfile) { result in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            self.viewModel.userProfile = userProfile
                        }
                        print("User profile updated after seeing ChatbotWelcomeView")
                    case .failure(let error):
                        print("Error updating user profile: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

class HomePageViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var currentWeight: Double = 0.0
    @Published var medicationInfo: MedicationInfo?
    @Published var nextDose: String = ""
    @Published var logs: [LogData.LogEntry] = []
    @Published var bannerContents: [BannerContent] = []
    @Published var showMedicationReminder: Bool = false
    private var cancellables = Set<AnyCancellable>()
    private var bmiListener: ListenerRegistration?
    @Published var bmi: Double = 0.0
    @Published var proteinManager: ProteinIntakeManager
    
    let sideEffects = ["Nausea", "Headache", "Fatigue", "Dizziness", "Other"]
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Frustrated", "Other"]
    
    init() {
        self.proteinManager = ProteinIntakeManager()
        setupBMIListener()
    }
    
    deinit {
        bmiListener?.remove()
    }
    
    private func setupBMIListener() {
        bmiListener = FirestoreManager.shared.setupBMIListener { [weak self] result in
            switch result {
            case .success(let bmi):
                DispatchQueue.main.async {
                    self?.bmi = bmi
                }
            case .failure(let error):
                print("Error in BMI listener: \(error.localizedDescription)")
            }
        }
    }
    
    func setupMedicationReminderListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId)
            .addSnapshotListener { [weak self] documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                if let showReminder = document.data()?["showMedicationReminder"] as? Bool {
                    DispatchQueue.main.async {
                        self?.showMedicationReminder = showReminder
                    }
                }
            }
    }
    
    func updateShowMedicationReminder(_ show: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData(["showMedicationReminder": show]) { [weak self] error in
            if let error = error {
                print("Error updating showMedicationReminder: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self?.showMedicationReminder = show
                }
            }
        }
    }
    
    func fetchBannerContents() {
        let db = Firestore.firestore()
        db.collection("banners").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let banners = querySnapshot?.documents.compactMap { document -> BannerContent? in
                    let data = document.data()
                    let colorHex = data["backgroundColor"] as? String ?? "000000"
                    return BannerContent(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        subtitle: data["subtitle"] as? String ?? "",
                        buttonText: data["buttonText"] as? String ?? "",
                        backgroundColor: Color(hex: colorHex),
                        imageName: data["imageName"] as? String ?? "default_image",
                        actionIdentifier: data["actionIdentifier"] as? String ?? ""
                    )
                } ?? []
                
                DispatchQueue.main.async {
                    self.bannerContents = banners
                }
            }
        }
    }
    
    func fetchUserData() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let fetchedProfile):
                DispatchQueue.main.async {
                    self.userProfile = fetchedProfile
                    self.currentWeight = fetchedProfile.weight
                    self.medicationInfo = fetchedProfile.medicationInfo// TODO: Calculate next dose based on medication schedule
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
        
        fetchBannerContents()
    }
    
    func logEntry(weight: Double, sideEffect: String, emotion: String, foodNoise: Int, proteinIntake: Double) {
        let newEntry = LogData.LogEntry(
            date: Date(),
            weight: weight,
            sideEffectType: sideEffect,
            emotionType: emotion,
            foodNoise: foodNoise,
            proteinIntake: proteinIntake 
        )
        
        FirestoreManager.shared.saveLog(newEntry) { [weak self] result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self?.currentWeight = weight
                    self?.logs.insert(newEntry, at: 0)
                    print("Log entry saved successfully")
//                    self?.proteinManager.addProtein(proteinIntake)
                }
            case .failure(let error):
                print("Error saving log entry: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteLog(_ log: LogData.LogEntry) {
            FirestoreManager.shared.deleteLog(log) { [weak self] result in
                switch result {
                case .success:
                    DispatchQueue.main.async {
                        self?.proteinManager.subProtein(log.proteinIntake)
                        self?.logs.removeAll { $0.id == log.id }
                    }
                case .failure(let error):
                    print("Error deleting log: \(error.localizedDescription)")
                    // You might want to show an alert to the user here
                }
            }
        }
}
