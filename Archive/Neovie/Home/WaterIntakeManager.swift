import Foundation
import Combine

class WaterIntakeManager: ObservableObject {
    @Published var waterIntake: Double = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadTodaysWaterIntake()
    }
    
    func loadTodaysWaterIntake() {
        FirestoreManager.shared.getWaterIntake(for: Date()) { [weak self] result in
            switch result {
            case .success(let intake):
                DispatchQueue.main.async {
                    self?.waterIntake = intake
                }
            case .failure(let error):
                print("Error loading water intake: \(error.localizedDescription)")
            }
        }
    }
    
    func addWater(_ amount: Double) {
        waterIntake += amount
        saveWaterIntake()
    }
    
    func subtractWater(_ amount: Double) {
        waterIntake = max(0, waterIntake - amount)
        saveWaterIntake()
    }
    
    private func saveWaterIntake() {
        FirestoreManager.shared.saveWaterIntake(waterIntake, for: Date()) { result in
            switch result {
            case .success:
                print("Water intake saved successfully")
            case .failure(let error):
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }
}
