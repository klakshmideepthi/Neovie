import SwiftUI
import HealthKit

struct UserInfoHeight: View {
    @Binding var userProfile: UserProfile
    @State private var heightUnit: HeightUnit = .cm
    @State private var isHealthKitAuthorized = false
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false
    
    let healthStore = HKHealthStore()

    enum HeightUnit: String, CaseIterable {
        case cm, ft
    }
    

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("What is your height?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        heightUnitPicker
                        
                        heightPicker
                    }
                }
                .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoWeight(userProfile: $userProfile), isActive: $navigateToNextView) {
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
                    .fill(index < 4 ? AppColors.accentColor : Color.gray.opacity(0.3))
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
    
    private var heightUnitPicker: some View {
        
        HStack(spacing:20) {
            ForEach(HeightUnit.allCases, id: \.self) { unit in
                Button(action: {
                    heightUnit = unit
                }) {
                    Text(unit.rawValue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(heightUnit == unit ? AppColors.accentColor : Color.gray.opacity(0.2))
                        )
                        .foregroundColor(heightUnit == unit ? .white : .gray)
                }
            }
        }
    }
    
    private var heightPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                if heightUnit == .cm {
                    Picker("Height (cm)", selection: $userProfile.heightCm) {
                        ForEach(50...250, id: \.self) { cm in
                            Text("\(cm) cm").tag(cm)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                } else {
                    HStack(spacing: 0) {
                        Picker("Feet", selection: $userProfile.heightFt) {
                            ForEach(1...8, id: \.self) { ft in
                                Text("\(ft) ft").tag(ft)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        .clipped()

                        Picker("Inches", selection: $userProfile.heightIn) {
                            ForEach(0...11, id: \.self) { inch in
                                Text("\(inch) in").tag(inch)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        .clipped()
                    }
                }
            }
            .frame(height: 150)
        }
        .frame(height: 200)
        .padding(.vertical, 10)
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
        fetchHeight()
    }
    
    private func fetchHeight() {
        guard let heightType = HKObjectType.quantityType(forIdentifier: .height) else { return }
        
        let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
            if let sample = results?.first as? HKQuantitySample {
                let heightInCm = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                DispatchQueue.main.async {
                    if self.heightUnit == .cm {
                        self.userProfile.heightCm = Int(heightInCm)
                    } else {
                        let heightInInches = heightInCm / 2.54
                        self.userProfile.heightFt = Int(heightInInches / 12)
                        self.userProfile.heightIn = Int(heightInInches.truncatingRemainder(dividingBy: 12))
                    }
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    private func saveUserProfile() {
        
        if heightUnit == .cm {
            userProfile.heightFt = Int(Double(userProfile.heightCm) / 30.48)
            userProfile.heightIn = Int((Double(userProfile.heightCm) / 2.54).truncatingRemainder(dividingBy: 12))
        } else {
            userProfile.heightCm = Int((Double(userProfile.heightFt) * 30.48) + (Double(userProfile.heightIn) * 2.54))
        }
        
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
