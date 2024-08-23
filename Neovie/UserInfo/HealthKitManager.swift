import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    private let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass)!
    private let heightType = HKObjectType.quantityType(forIdentifier: .height)!
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, NSError(domain: "com.yourapp", code: 2, userInfo: [NSLocalizedDescriptionKey: "HealthKit is not available on this device"]))
            return
        }
        
        let typesToRead: Set<HKObjectType> = [
            weightType,
            heightType,
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
        ]
        
        let typesToShare: Set<HKSampleType> = [
            weightType,
            heightType
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func fetchUserInfo(completion: @escaping (Date?, String?, Double?, Double?) -> Void) {
        var dateOfBirth: Date?
        var biologicalSex: String?
        var weight: Double?
        var height: Double?
        
        let dispatchGroup = DispatchGroup()
        
        // Fetch date of birth
        dispatchGroup.enter()
        do {
            let birthDateComponents = try healthStore.dateOfBirthComponents()
            dateOfBirth = Calendar.current.date(from: birthDateComponents)
            dispatchGroup.leave()
        } catch {
            print("Error fetching date of birth: \(error.localizedDescription)")
            dispatchGroup.leave()
        }
        
        // Fetch biological sex
        dispatchGroup.enter()
        do {
            biologicalSex = try healthStore.biologicalSex().biologicalSex.stringRepresentation
            dispatchGroup.leave()
        } catch {
            print("Error fetching biological sex: \(error.localizedDescription)")
            dispatchGroup.leave()
        }
        
        // Fetch weight
        dispatchGroup.enter()
        fetchLatestMeasurement(for: weightType, unit: .gramUnit(with: .kilo)) { fetchedWeight, error in
            weight = fetchedWeight
            dispatchGroup.leave()
        }
        
        // Fetch height
        dispatchGroup.enter()
        fetchLatestMeasurement(for: heightType, unit: .meterUnit(with: .centi)) { fetchedHeight, error in
            height = fetchedHeight
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(dateOfBirth, biologicalSex, weight, height)
        }
    }
    
    private func fetchLatestMeasurement(for type: HKQuantityType, unit: HKUnit, completion: @escaping (Double?, Error?) -> Void) {
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            guard let sample = samples?.first as? HKQuantitySample else {
                completion(nil, error)
                return
            }
            
            let measurement = sample.quantity.doubleValue(for: unit)
            completion(measurement, nil)
        }
        
        healthStore.execute(query)
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
    
    }

extension HKBiologicalSex {
    var stringRepresentation: String {
        switch self {
        case .female: return "Female"
        case .male: return "Male"
        case .other: return "Other"
        case .notSet: return "Not Set"
        @unknown default: return "Unknown"
        }
    }
}

