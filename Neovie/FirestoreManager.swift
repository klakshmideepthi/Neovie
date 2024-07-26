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
        
        print("Attempting to save user profile: \(data)")
        
        db.collection("users").document(uid).setData(data) { error in
            if let error = error {
                print("Error saving user profile: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User profile saved successfully")
                completion(.success(()))
            }
        }
    }
    
    func getUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        print("Attempting to retrieve user profile for UID: \(uid)")
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let error = error {
                print("Error retrieving user profile: \(error.localizedDescription)")
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
                    print("User profile retrieved successfully: \(userProfile)")
                    completion(.success(userProfile))
                } else {
                    print("Error: Invalid data format")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data format"])))
                }
            } else {
                print("Error: Document does not exist")
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
            }
        }
    }
    
    func saveAdditionalInfo(gender: String, dateOfBirth: Date, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "gender": gender,
            "dateOfBirth": Timestamp(date: dateOfBirth)
        ]
        
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
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
