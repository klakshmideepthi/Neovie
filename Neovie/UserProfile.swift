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
    
    init(name: String = "", heightCm: Int = 170, heightFt: Int = 5, heightIn: Int = 7, weight: Double = 0, targetWeight: Double = 0, gender: String = "", dateOfBirth: Date = Date(), medicationName: String = "", dosage: String = "") {
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
    }
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
}

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}
