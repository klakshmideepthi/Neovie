import SwiftUI
import Combine
import FirebaseAuth

class WeightLossAdviceViewModel: ObservableObject {
    @Published var weightLossAdvice: String = ""
    @Published var isLoading: Bool = false
    @Published var error: String?
    
    private let weightLossAdviceService = WeightLossAdviceService()
    
    func fetchWeightLossAdvice() {
        isLoading = true
        error = nil
        
        guard let userId = Auth.auth().currentUser?.uid else {
            error = "User not authenticated"
            isLoading = false
            return
        }
        
        weightLossAdviceService.getWeightLossAdvice(for: userId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let advice):
                    self.weightLossAdvice = advice
                case .failure(let error):
                    self.error = "Failed to get weight loss advice: \(error.localizedDescription)"
                }
            }
        }
    }
}
