import Firebase
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    private func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func saveUserProfile(_ userProfile: UserProfile, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "name": userProfile.name,
            "heightCm": userProfile.heightCm,
            "heightFt": userProfile.heightFt,
            "heightIn": userProfile.heightIn,
            "weight": userProfile.weight,
            "targetWeight": userProfile.targetWeight,
            "gender": userProfile.gender,
            "dateOfBirth": Timestamp(date: userProfile.dateOfBirth),
            "medicationName": userProfile.medicationName,
            "dosage": userProfile.dosage,
            "age": userProfile.age,
            "hasSeenChatbotWelcome": userProfile.hasSeenChatbotWelcome
        ]
        
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = document, document.exists {
                if let data = document.data(),
                   let name = data["name"] as? String,
                   let heightCm = data["heightCm"] as? Int,
                   let heightFt = data["heightFt"] as? Int,
                   let heightIn = data["heightIn"] as? Int,
                   let weight = data["weight"] as? Double,
                   let targetWeight = data["targetWeight"] as? Double,
                   let gender = data["gender"] as? String,
                   let dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue(),
                   let medicationName = data["medicationName"] as? String,
                   let dosage = data["dosage"] as? String,
                   let hasSeenChatbotWelcome = data["hasSeenChatbotWelcome"] as? Bool {
                    var userProfile = UserProfile(name: name, heightCm: heightCm, heightFt: heightFt, heightIn: heightIn, weight: weight, targetWeight: targetWeight, gender: gender, dateOfBirth: dateOfBirth, medicationName: medicationName, dosage: dosage,hasSeenChatbotWelcome: hasSeenChatbotWelcome)
                    
                    // Update age
                    userProfile.updateAge()
                    
                    // If the age has changed, update it in Firestore
                    if userProfile.age != (data["age"] as? Int ?? 0) {
                        self.updateUserAge(for: uid) { _ in }
                    }
                    
                    completion(.success(userProfile))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    func updateUserAge(for userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let userRef = db.collection("users").document(userId)
            
            userRef.getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists,
                      let data = document.data(),
                      let dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue() else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])))
                    return
                }
                
                let newAge = Calendar.current.dateComponents([.year], from: dateOfBirth, to: Date()).year ?? 0
                
                userRef.updateData(["age": newAge]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    
    func saveLog(_ log: LogData.LogEntry, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let uid = getCurrentUserID() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            let data: [String: Any] = [
                "date": Timestamp(date: log.date),
                "weight": log.weight,
                "sideEffectType": log.sideEffectType,
                "emotionType": log.emotionType,
                "foodNoise": log.foodNoise
            ]
            
            db.collection("users").document(uid).collection("logs").addDocument(data: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        func getLogs(completion: @escaping (Result<[LogData.LogEntry], Error>) -> Void) {
            guard let uid = getCurrentUserID() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            db.collection("users").document(uid).collection("logs")
                .order(by: "date", descending: true)
                .getDocuments { (snapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let documents = snapshot?.documents {
                    let logs = documents.compactMap { doc -> LogData.LogEntry? in
                        guard let date = (doc["date"] as? Timestamp)?.dateValue(),
                              let weight = doc["weight"] as? Double,
                              let sideEffectType = doc["sideEffectType"] as? String,
                              let emotionType = doc["emotionType"] as? String,
                              let foodNoise = doc["foodNoise"] as? Int else {
                            return nil
                        }
                        
                        return LogData.LogEntry(
                            id: doc.documentID,
                            date: date,
                            weight: weight,
                            sideEffectType: sideEffectType,
                            emotionType: emotionType,
                            foodNoise: foodNoise
                        )
                    }
                    completion(.success(logs))
                } else {
                    completion(.success([]))
                }
            }
        }
    
    
    
    
    func saveMedicationInfo(medicationName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "medicationName": medicationName
        ]
        
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func saveDosageInfo(dosage: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "dosage": dosage
        ]
        
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getMedicationSideEffects(medicationName: String, completion: @escaping (Result<MedicationSideEffects, Error>) -> Void) {
        print("Fetching side effects for medication: \(medicationName)")
        db.collection("medications").document(medicationName).getDocument { (document, error) in
            if let error = error {
                print("Error fetching document: \(error.localizedDescription)")
                completion(.failure(error))
            } else if let document = document, document.exists, let data = document.data()?["sideEffects"] as? [String: String] {
                let sideEffects = MedicationSideEffects(
                    common: data["common"] ?? "",
                    serious: data["serious"] ?? "",
                    warning: data["warning"] ?? "",
                    usage: data["usage"] ?? "",
                    note: data["note"] ?? ""
                )
                completion(.success(sideEffects))
            } else {
                print("Document does not exist or has unexpected format")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Side effects not found or in unexpected format"])))
            }
        }
    }
    
    func getWeightLossData(completion: @escaping (Result<WeightLossData, Error>) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            db.collection("users").document(uid).getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = document, document.exists else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                    return
                }
                
                guard let data = document.data() else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document data is empty"])))
                    return
                }
                
                var missingFields: [String] = []
                
                let name = data["name"] as? String ?? ""
                let height = data["heightCm"] as? Int ?? 0
                let weight = data["weight"] as? Double ?? 0.0
                let targetWeight = data["targetWeight"] as? Double ?? 0.0
                let gender = data["gender"] as? String ?? ""
                let dateOfBirth = (data["dateOfBirth"] as? Timestamp)?.dateValue() ?? Date()
                let activityLevel = data["activityLevel"] as? String ?? "Sedentary"
                let medicalConditions = data["medicalConditions"] as? [String] ?? []
                let dietaryPreferences = data["dietaryPreferences"] as? [String] ?? []
                
                if name.isEmpty { missingFields.append("name") }
                if height == 0 { missingFields.append("heightCm") }
                if weight == 0.0 { missingFields.append("weight") }
                if targetWeight == 0.0 { missingFields.append("targetWeight") }
                if gender.isEmpty { missingFields.append("gender") }
                if dateOfBirth == Date() { missingFields.append("dateOfBirth") }
                
                if !missingFields.isEmpty {
                    let errorMessage = "Missing or invalid fields: \(missingFields.joined(separator: ", "))"
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                
                let weightLossData = WeightLossData(
                    name: name,
                    height: height,
                    weight: weight,
                    targetWeight: targetWeight,
                    gender: gender,
                    dateOfBirth: dateOfBirth,
                    activityLevel: activityLevel,
                    medicalConditions: medicalConditions,
                    dietaryPreferences: dietaryPreferences
                )
                
                completion(.success(weightLossData))
            }
        }
}


struct WeightLossData {
    let name: String
    let height: Int
    let weight: Double
    let targetWeight: Double
    let gender: String
    let dateOfBirth: Date
    let activityLevel: String
    let medicalConditions: [String]
    let dietaryPreferences: [String]
}
