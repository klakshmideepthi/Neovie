import Foundation

struct UserProfile {
    var name: String
    var height: Double
    var weight: Double
    
    init(name: String = "", height: Double = 0, weight: Double = 0) {
        self.name = name
        self.height = height
        self.weight = weight
    }
}
