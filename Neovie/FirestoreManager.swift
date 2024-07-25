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
            "height": userProfile.height,
            "weight": userProfile.weight
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
                   let height = data["height"] as? Double,
                   let weight = data["weight"] as? Double {
                    let userProfile = UserProfile(name: name, height: height, weight: weight)
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
    
    func saveAdditionalInfo(gender: String, age: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "gender": gender,
            "age": age
        ]
        
        db.collection("users").document(uid).setData(data, merge: true) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func saveMedicationInfo(medication: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        let data: [String: Any] = [
            "medication": medication
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
