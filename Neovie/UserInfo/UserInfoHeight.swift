import SwiftUI
import HealthKit

struct UserInfoHeight: View {
    @Binding var userProfile: UserProfile
    @State private var heightUnit: HeightUnit = .cm
    @State private var isDataLoaded = false
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
                        
                        if isDataLoaded {
                            heightPicker
                        } else {
                            ProgressView()
                        }
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
            .onAppear(perform: fetchUserProfile)
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
                    convertHeight()
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
                    HStack(spacing: 0) {
                        Picker("Height (cm)", selection: Binding(
                            get: { Int(self.userProfile.heightCm) },
                            set: { self.userProfile.heightCm = Double($0) }
                        )) {
                            ForEach(50...250, id: \.self) { cm in
                                Text("\(cm)").tag(cm)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(maxWidth: .infinity)
                        .clipped()
                        
                        Picker("Decimal", selection: Binding(
                            get: { Int((self.userProfile.heightCm.truncatingRemainder(dividingBy: 1)) * 10) },
                            set: { self.userProfile.heightCm = Double(Int(self.userProfile.heightCm)) + Double($0) / 10.0 }
                        )) {
                            ForEach(0...9, id: \.self) { decimal in
                                Text(".\(decimal)").tag(decimal)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 60)
                        .clipped()

                        Text("cm")
                            .font(.headline)
                            .frame(width: 40)
                    }
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
            .onChange(of: userProfile.heightCm) { _ in convertHeight() }
            .onChange(of: userProfile.heightFt) { _ in convertHeight() }
            .onChange(of: userProfile.heightIn) { _ in convertHeight() }
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
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func fetchUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let fetchedProfile):
                DispatchQueue.main.async {
                    if fetchedProfile.heightCm != 0 {
                        self.userProfile.heightCm = fetchedProfile.heightCm
                        self.userProfile.heightFt = fetchedProfile.heightFt
                        self.userProfile.heightIn = fetchedProfile.heightIn
                        self.convertHeight() // Ensure all units are in sync
                        print("Height loaded from Firestore: \(fetchedProfile.heightCm) cm")
                        self.isDataLoaded = true
                    } else {
                        print("No height found in Firestore, fetching from HealthKit")
                        self.fetchHealthKitData()
                    }
                }
            case .failure(let error):
                print("Failed to fetch user profile: \(error.localizedDescription)")
                print("Attempting to fetch from HealthKit")
                self.fetchHealthKitData()
            }
        }
    }
    
    private func fetchHealthKitData() {
            guard let heightType = HKObjectType.quantityType(forIdentifier: .height) else { return }

            healthStore.requestAuthorization(toShare: [], read: [heightType]) { (success, error) in
                if success {
                    let query = HKSampleQuery(sampleType: heightType, predicate: nil, limit: 1, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]) { (query, results, error) in
                        if let sample = results?.first as? HKQuantitySample {
                            let heightInCm = sample.quantity.doubleValue(for: HKUnit.meterUnit(with: .centi))
                            DispatchQueue.main.async {
                                self.userProfile.heightCm = heightInCm
                                self.convertHeight()
                                self.heightUnit = .cm // Set default unit to cm when data is loaded from HealthKit
                                print("Height loaded from HealthKit: \(heightInCm) cm")
                                self.isDataLoaded = true
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.isDataLoaded = true
                            }
                        }
                    }

                    self.healthStore.execute(query)
                } else {
                    DispatchQueue.main.async {
                        self.isDataLoaded = true
                    }
                    print("HealthKit authorization failed")
                }
            }
        }

    
    private func convertHeight() {
        if heightUnit == .cm {
            let totalInches = Int(userProfile.heightCm / 2.54)
            userProfile.heightFt = totalInches / 12
            userProfile.heightIn = totalInches % 12
        } else {
            // Convert feet and inches to cm
            let totalInches = (userProfile.heightFt * 12) + userProfile.heightIn
            userProfile.heightCm = Double(totalInches) * 2.54
        }
    }
    
    private func saveUserProfile() {
//        let oldHeight = userProfile.heightCm
        convertHeight() // Ensure all height values are up to date
        
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
