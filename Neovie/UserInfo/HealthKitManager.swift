import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.yourapp", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            weightType,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        ]
        
        healthStore.requestAuthorization(toShare: [weightType], read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func fetchLatestWeight(completion: @escaping (Double?, Error?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let weightInKilograms = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
            completion(weightInKilograms, nil)
        }
        
        healthStore.execute(query)
    }
    
    func saveWeight(_ weight: Double, completion: @escaping (Bool, Error?) -> Void) {
        let quantity = HKQuantity(unit: HKUnit.gramUnit(with: .kilo), doubleValue: weight)
        let sample = HKQuantitySample(type: weightType, quantity: quantity, start: Date(), end: Date())
        
        healthStore.save(sample) { (success, error) in
            completion(success, error)
        }
    }
    
    func fetchUserInfo(completion: @escaping (Int?, String?, Double?) -> Void) {
            var age: Int?
            var sex: String?
            var weight: Double?
            
            let dispatchGroup = DispatchGroup()
            
            // Fetch age
            dispatchGroup.enter()
            do {
                let birthDate = try healthStore.dateOfBirthComponents()
                let ageComponents = Calendar.current.dateComponents([.year], from: birthDate.date ?? Date(), to: Date())
                age = ageComponents.year
                dispatchGroup.leave()
            } catch {
                print("Error fetching date of birth: \(error.localizedDescription)")
                dispatchGroup.leave()
            }
            
            // Fetch biological sex
            dispatchGroup.enter()
            do {
                sex = try healthStore.biologicalSex().biologicalSex.stringRepresentation
                dispatchGroup.leave()
            } catch {
                print("Error fetching biological sex: \(error.localizedDescription)")
                dispatchGroup.leave()
            }
            
            // Fetch weight
            dispatchGroup.enter()
            fetchLatestWeight { fetchedWeight, error in
                weight = fetchedWeight
                dispatchGroup.leave()
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(age, sex, weight)
            }
        }
    }

    extension HKBiologicalSex {
        var stringRepresentation: String? {
            switch self {
            case .female: return "Female"
            case .male: return "Male"
            case .other: return "Other"
            default: return nil
            }
        }
    }

