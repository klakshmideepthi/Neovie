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
            "dosage": userProfile.dosage
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
                   let dosage = data["dosage"] as? String {
                    let userProfile = UserProfile(name: name, heightCm: heightCm, heightFt: heightFt, heightIn: heightIn, weight: weight, targetWeight: targetWeight, gender: gender, dateOfBirth: dateOfBirth, medicationName: medicationName, dosage: dosage)
                    completion(.success(userProfile))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                }
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
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
}
