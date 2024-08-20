import Foundation

struct UserProfile {
    var name: String
    var heightCm: Int
    var heightFt: Int
    var heightIn: Int
    var weight: Double
    var targetWeight: Double
    var gender: String
    var dateOfBirth: Date
    var medicationName: String
    var dosage: String
    var age: Int
    var activityLevel: String
    var dosageDay: String
    var dosageTime: Date
    var showMedicationReminder: Bool
    var hasSeenChatbotWelcome: Bool
    var bmi: Double
    var proteinGoal: Double
    
    init(name: String = "", heightCm: Int = 170, heightFt: Int = 5, heightIn: Int = 7, weight: Double = 0, targetWeight: Double = 0, gender: String = "", dateOfBirth: Date = Date(), medicationName: String = "", dosage: String = "", age: Int = 0, activityLevel: String = "Sedentary", dosageDay: String = "", dosageTime: Date = Date(), showMedicationReminder: Bool = false, hasSeenChatbotWelcome: Bool = false, bmi: Double = 0, proteinGoal: Double = 0) {
        self.name = name
        self.heightCm = heightCm
        self.heightFt = heightFt
        self.heightIn = heightIn
        self.weight = weight
        self.targetWeight = targetWeight
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.medicationName = medicationName
        self.dosage = dosage
        self.age = age
        self.activityLevel = activityLevel
        self.dosageDay = dosageDay
        self.dosageTime = dosageTime
        self.showMedicationReminder = showMedicationReminder
        self.hasSeenChatbotWelcome = hasSeenChatbotWelcome
        self.bmi = bmi
        self.proteinGoal = proteinGoal
    }
    
    mutating func updateAge() {
        let newAge = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
        if newAge != age {
            age = newAge
        }
    }
    
    mutating func updateBMIAndProteinGoal() {
        updateBMI()
        updateProteinGoal()
    }
    
    private mutating func updateBMI() {
        let heightInMeters = Double(heightCm) / 100.0
        bmi = weight / (heightInMeters * heightInMeters)
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
