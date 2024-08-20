import SwiftUI
import HealthKit

struct UserInfoWeight: View {
    @Binding var userProfile: UserProfile
    @State private var weightUnit: WeightUnit = .lbs
    @State private var weightWhole: Int = 192
    @State private var weightFraction: Int = 8
    @State private var weight: Double = 0
    @State private var isHealthKitAuthorized = false
    @State private var sliderWeight: Double = 192.8
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    
    let healthStore = HKHealthStore()

    enum WeightUnit: String, CaseIterable {
        case kg, lbs
    }


    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("What is your weight?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        weightUnitPicker
                        
                        weightPicker
                    }
                }
                .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoTargetWeight(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
            .onAppear(perform: requestHealthKitAuthorization)
        }
        .navigationBarHidden(true)
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 5 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
            HStack {
                backButton
                Spacer()
                progressView
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.accentColor.opacity(0.1))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(AppColors.accentColor)
        }
        .padding(.leading)
    }
    
    private var weightUnitPicker: some View {
            HStack(spacing:20) {
                ForEach(WeightUnit.allCases, id: \.self) { unit in
                    Button(action: {
                        weightUnit = unit
                        convertWeight()
                    }) {
                        Text(unit.rawValue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(weightUnit == unit ? AppColors.accentColor : Color.gray.opacity(0.2))
                            )
                            .foregroundColor(weightUnit == unit ? .white : .gray)
                    }
                }
            }
        }
       
       
    private var weightPicker: some View {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    HStack(spacing: 0) {
                        Picker("Whole", selection: $weightWhole) {
                            ForEach(weightWholeRange, id: \.self) { whole in
                                Text("\(whole)").tag(whole)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Picker("Fraction", selection: $weightFraction) {
                            ForEach(0...9, id: \.self) { fraction in
                                Text(".\(fraction)").tag(fraction)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Text(weightUnit.rawValue)
                            .font(.headline)
                            .frame(width: 40)
                    }
                }
                .frame(height: 150)
            }
            .frame(height: 200)
            .padding(.vertical, 10)
        }
        
        private var weightWholeRange: Range<Int> {
            weightUnit == .kg ? 20..<201 : 44..<441
        }
    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05) // 5% of screen height for bottom padding
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isHealthKitAuthorized = success
                if success {
                    self.fetchHealthKitData()
                }
            }
        }
    }
    
    private func fetchHealthKitData() {
        fetchWeight()    }
    
    private func fetchWeight() {
            guard let weightType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
            
            let query = HKSampleQuery(sampleType: weightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
                if let sample = results?.first as? HKQuantitySample {
                    let weightInKg = sample.quantity.doubleValue(for: HKUnit.gramUnit(with: .kilo))
                    DispatchQueue.main.async {
                        let weight = self.weightUnit == .kg ? weightInKg : weightInKg * 2.20462
                        self.weightWhole = Int(weight)
                        self.weightFraction = Int((weight - Double(self.weightWhole)) * 10)
                    }
                }
            }
            
            healthStore.execute(query)
        }
    
    private func convertWeight() {
            let oldWeight = Double(weightWhole) + Double(weightFraction) / 10.0
            if weightUnit == .kg {
                let newWeight = oldWeight / 2.20462
                weightWhole = Int(newWeight)
                weightFraction = Int((newWeight - Double(weightWhole)) * 10)
            } else {
                let newWeight = oldWeight * 2.20462
                weightWhole = Int(newWeight)
                weightFraction = Int((newWeight - Double(weightWhole)) * 10)
            }
        }
    
    private func saveUserProfile() {
        let weight = Double(weightWhole) + Double(weightFraction) / 10.0
        userProfile.weight = weightUnit == .kg ? weight : weight / 2.20462 // Always save in kg
        
        FirestoreManager.shared.saveUserProfile(userProfile) { result in
            switch result {
            case .success:
                print("User profile saved successfully")
                self.navigateToNextView = true
            case .failure(let error):
                print("Failed to save user profile: \(error.localizedDescription)")
            }
        }
    }
}
