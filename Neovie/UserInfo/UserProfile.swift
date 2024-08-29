import Foundation

struct UserProfile {
    var name: String
    var heightCm: Double
    var heightFt: Int
    var heightIn: Int
    var weight: Double
    var targetWeight: Double
    var gender: String
    var dateOfBirth: Date
    var medicationInfo: MedicationInfo?
    var dosage: String
    var activityLevel: String
    var dosageDay: String
    var dosageTime: Date
    var showMedicationReminder: Bool
    var hasSeenChatbotWelcome: Bool
    var bmi: Double
    var proteinGoal: Double
    var preferredHeightUnit: HeightUnit
    var preferredWeightUnit: WeightUnit
    
    enum HeightUnit: String, Codable, CaseIterable {
        case cm, ft
    }
        
    enum WeightUnit: String, Codable, CaseIterable {
        case kg, lbs
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    init(name: String = "", heightCm: Double = 0, heightFt: Int = 0, heightIn: Int = 0, weight: Double = 0,targetWeight: Double = 0, gender: String = "", dateOfBirth: Date = Date(), medicationInfo: MedicationInfo? = nil, dosage: String = "", activityLevel: String = "Sedentary", dosageDay: String = "", dosageTime: Date = Date(), showMedicationReminder: Bool = false, hasSeenChatbotWelcome: Bool = false, bmi: Double = 0, proteinGoal: Double = 0, preferredHeightUnit: HeightUnit = .cm, preferredWeightUnit: WeightUnit = .kg) {
            self.name = name
            self.heightCm = heightCm
            self.heightFt = heightFt
            self.heightIn = heightIn
            self.weight = weight
            self.targetWeight = targetWeight
            self.gender = gender
            self.dateOfBirth = dateOfBirth
            self.medicationInfo = medicationInfo
            self.dosage = dosage
            self.activityLevel = activityLevel
            self.dosageDay = dosageDay
            self.dosageTime = dosageTime
            self.showMedicationReminder = showMedicationReminder
            self.hasSeenChatbotWelcome = hasSeenChatbotWelcome
            self.bmi = bmi
            self.proteinGoal = proteinGoal
            self.preferredHeightUnit = preferredHeightUnit
            self.preferredWeightUnit = preferredWeightUnit
            
            updateBMIAndProteinGoal()
        }
    
    mutating func updateBMIAndProteinGoal() {
        updateBMI()
        updateProteinGoal()
        updateFirestore()
    }
    
    private mutating func updateBMI() {
        let heightInMeters = Double(heightCm) / 100.0
        bmi = weight / (heightInMeters * heightInMeters)
    }
    
    private func updateFirestore() {
            FirestoreManager.shared.updateUserBMIAndProteinGoal(bmi: bmi, proteinGoal: proteinGoal) { result in
                switch result {
                case .success:
                    print("BMI and protein goal updated in Firestore")
                case .failure(let error):
                    print("Error updating BMI and protein goal in Firestore: \(error.localizedDescription)")
                }
            }
        }
    
    private mutating func updateProteinGoal() {
        var activityMultiplier: Double = 0.8 // Default to sedentary
        
        switch activityLevel {
        case "Sedentary":
            activityMultiplier = 0.8
        case "Light Activity":
            activityMultiplier = 1.0
        case "Moderately Active":
            activityMultiplier = 1.2
        case "Very Active":
            activityMultiplier = 1.4
        default:
            break
        }
        
        proteinGoal = weight * activityMultiplier
    }
}

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}

struct MedicationInfo: Equatable, Hashable {
    let name: String
    let dosages: [String]
}

let availableMedications = [
    MedicationInfo(name: "Mounjaro", dosages: ["2.5mg", "5mg", "7.5mg", "10mg", "12.5mg", "15mg"]),
    MedicationInfo(name: "Wegovy", dosages: ["0.25mg", "0.5mg", "1mg"]),
    MedicationInfo(name: "Ozempic", dosages: ["0.25mg", "0.5mg", "1mg"]),
    MedicationInfo(name: "Zepbound", dosages: ["2.5mg", "5mg", "7.5mg", "10mg", "12.5mg", "15mg"])
]
