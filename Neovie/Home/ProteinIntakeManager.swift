import Foundation
import Combine
import Firebase

class ProteinIntakeManager: ObservableObject {
    @Published var proteinIntake: Double = 0
    @Published var proteinGoal: Double = 0
    private var cancellables = Set<AnyCancellable>()
    private var listener: ListenerRegistration?
    
    init() {
        loadTodaysProteinIntake()
        loadProteinGoal()
        setupProteinGoalListener()
    }
    
    deinit {
        listener?.remove()
    }
    
    func loadTodaysProteinIntake() {
        FirestoreManager.shared.getProteinIntake(for: Date()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let intake):
                    self?.proteinIntake = intake
                case .failure(let error):
                    print("Error loading protein intake: \(error.localizedDescription)")
                    self?.proteinIntake = 0
                }
            }
        }
    }
    
    func loadProteinGoal() {
        FirestoreManager.shared.getUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userProfile):
                    self?.proteinGoal = userProfile.proteinGoal
                case .failure(let error):
                    print("Error loading protein goal: \(error.localizedDescription)")
                    self?.proteinGoal = 0
                }
            }
        }
    }
    
    func addProtein(_ amount: Double) {
        proteinIntake += amount
        saveProteinIntake()
    }
    
    func subProtein(_ amount: Double) {
        proteinIntake -= amount
        saveProteinIntake()
    }
    
    private func saveProteinIntake() {
        FirestoreManager.shared.saveProteinIntake(proteinIntake, for: Date()) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Protein intake saved successfully")
                    self?.objectWillChange.send()
                case .failure(let error):
                    print("Error saving protein intake: \(error.localizedDescription)")
                    self?.loadTodaysProteinIntake()
                }
            }
        }
    }
    
    private func setupProteinGoalListener() {
        listener = FirestoreManager.shared.setupProteinGoalListener { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newProteinGoal):
                    self?.proteinGoal = newProteinGoal
                case .failure(let error):
                    print("Error in protein goal listener: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateProteinGoal(_ newGoal: Double) {
        FirestoreManager.shared.saveUserProfile(UserProfile(proteinGoal: newGoal)) { result in
            switch result {
            case .success:
                print("Protein goal updated successfully")
            case .failure(let error):
                print("Error updating protein goal: \(error.localizedDescription)")
            }
        }
    }
}
