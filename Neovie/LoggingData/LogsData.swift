import Foundation

struct LogData {
    struct LogEntry: Identifiable, Codable {
        let id: String
        let date: Date
        let weight: Double
        let sideEffectType: String
        let emotionType: String
        let foodNoise: Int
        let proteinIntake: Double
        
        init(id: String = UUID().uuidString,
             date: Date,
             weight: Double,
             sideEffectType: String,
             emotionType: String,
             foodNoise: Int,
             proteinIntake: Double) {
            self.id = id
            self.date = date
            self.weight = weight
            self.sideEffectType = sideEffectType
            self.emotionType = emotionType
            self.foodNoise = foodNoise
            self.proteinIntake = proteinIntake
        }
    }
}
