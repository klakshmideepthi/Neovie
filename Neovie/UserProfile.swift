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
    
    init(name: String = "", heightCm: Int = 170, heightFt: Int = 5, heightIn: Int = 7, weight: Double = 0, targetWeight: Double = 0, gender: String = "", dateOfBirth: Date = Date(), medicationName: String = "", dosage: String = "",age: Int = 0) {
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
    }
    
    mutating func updateAge() {
            let newAge = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
            if newAge != age {
                age = newAge
            }
        }
}

struct WeightEntry: Identifiable {
    let id = UUID()
    let date: Date
    let weight: Double
}
