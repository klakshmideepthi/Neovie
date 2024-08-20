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
                "activityLevel": userProfile.activityLevel,
                "dosageDay": userProfile.dosageDay,
                "dosageTime": Timestamp(date: userProfile.dosageTime),
                "showMedicationReminder": userProfile.showMedicationReminder,
                "hasSeenChatbotWelcome": userProfile.hasSeenChatbotWelcome,
                "bmi": userProfile.bmi,
                "proteinGoal": userProfile.proteinGoal
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
                       let age = data["age"] as? Int,
                       let activityLevel = data["activityLevel"] as? String,
                       let dosageDay = data["dosageDay"] as? String,
                       let dosageTime = (data["dosageTime"] as? Timestamp)?.dateValue(),
                       let showMedicationReminder = data["showMedicationReminder"] as? Bool,
                       let hasSeenChatbotWelcome = data["hasSeenChatbotWelcome"] as? Bool,
                       let bmi = data["bmi"] as? Double,
                       let proteinGoal = data["proteinGoal"] as? Double {
                        
                        var userProfile = UserProfile(
                            name: name,
                            heightCm: heightCm,
                            heightFt: heightFt,
                            heightIn: heightIn,
                            weight: weight,
                            targetWeight: targetWeight,
                            gender: gender,
                            dateOfBirth: dateOfBirth,
                            medicationName: medicationName,
                            dosage: dosage,
                            age: age,
                            activityLevel: activityLevel,
                            dosageDay: dosageDay,
                            dosageTime: dosageTime,
                            showMedicationReminder: showMedicationReminder,
                            hasSeenChatbotWelcome: hasSeenChatbotWelcome,
                            bmi: bmi,
                            proteinGoal: proteinGoal
                        )
                        
                        userProfile.updateAge()
                        userProfile.updateBMIAndProteinGoal()
                        
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
    
    func updateUserProfileWithRecalculation(field: String, value: Any, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }
        
        // First, get the current user profile
        getUserProfile { result in
            switch result {
            case .success(var userProfile):
                // Update the specified field
                switch field {
                case "weight":
                    if let weight = value as? Double {
                        userProfile.weight = weight
                    }
                case "heightCm":
                    if let height = value as? Int {
                        userProfile.heightCm = height
                    }
                case "activityLevel":
                    if let activityLevel = value as? String {
                        userProfile.activityLevel = activityLevel
                    }
                default:
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid field for recalculation"])))
                    return
                }
                
                // Recalculate BMI and protein goal
                userProfile.updateBMIAndProteinGoal()
                
                // Prepare the data to update
                let data: [String: Any] = [
                    field: value,
                    "bmi": userProfile.bmi,
                    "proteinGoal": userProfile.proteinGoal
                ]
                
                // Update Firestore
                self.db.collection("users").document(uid).updateData(data) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
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
    
    func saveWaterIntake(_ intake: Double, for date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            let dateString = Self.dateFormatter.string(from: date)
            let data: [String: Any] = ["waterIntake": intake]
            
            db.collection("users").document(uid).collection("waterIntake").document(dateString).setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    
    func getWaterIntake(for date: Date, completion: @escaping (Result<Double, Error>) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            let dateString = Self.dateFormatter.string(from: date)
            
            db.collection("users").document(uid).collection("waterIntake").document(dateString).getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let document = document, document.exists, let waterIntake = document.data()?["waterIntake"] as? Double {
                    completion(.success(waterIntake))
                } else {
                    completion(.success(0)) // Return 0 if no data exists for the day
                }
            }
        }
    func saveProteinIntake(_ intake: Double, for date: Date, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            let dateString = Self.dateFormatter.string(from: date)
            let data: [String: Any] = ["proteinIntake": intake]
            
            db.collection("users").document(uid).collection("proteinIntake").document(dateString).setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        
        func getProteinIntake(for date: Date, completion: @escaping (Result<Double, Error>) -> Void) {
            guard let uid = Auth.auth().currentUser?.uid else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return
            }
            
            let dateString = Self.dateFormatter.string(from: date)
            
            db.collection("users").document(uid).collection("proteinIntake").document(dateString).getDocument { (document, error) in
                if let error = error {
                    completion(.failure(error))
                } else if let document = document, document.exists, let proteinIntake = document.data()?["proteinIntake"] as? Double {
                    completion(.success(proteinIntake))
                } else {
                    completion(.success(0)) // Return 0 if no data exists for the day
                }
            }
        }
    
    func setupProteinGoalListener(completion: @escaping (Result<Double, Error>) -> Void) -> ListenerRegistration? {
            guard let uid = getCurrentUserID() else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
                return nil
            }
            
            return db.collection("users").document(uid)
                .addSnapshotListener { documentSnapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let document = documentSnapshot, document.exists else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                        return
                    }
                    
                    if let proteinGoal = document.data()?["proteinGoal"] as? Double {
                        completion(.success(proteinGoal))
                    } else {
                        completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Protein goal not found"])))
                    }
                }
        }
    
    func setupBMIListener(completion: @escaping (Result<Double, Error>) -> Void) -> ListenerRegistration? {
        guard let uid = getCurrentUserID() else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return nil
        }
        
        return db.collection("users").document(uid)
            .addSnapshotListener { documentSnapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Document does not exist"])))
                    return
                }
                
                if let bmi = document.data()?["bmi"] as? Double {
                    completion(.success(bmi))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "BMI not found"])))
                }
            }
    }
    
    private static let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
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
