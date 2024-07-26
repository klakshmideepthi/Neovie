import SwiftUI

struct UserInfo2: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @State private var heightUnit: HeightUnit = .cm
    @State private var weightUnit: WeightUnit = .kg
    @State private var weightString: String = ""
    @State private var targetWeightString: String = ""
    @Environment(\.presentationMode) var presentationMode

    enum HeightUnit: String, CaseIterable {
        case cm, ft
    }

    enum WeightUnit: String, CaseIterable {
        case kg, lb
    }

    private var isFormValid: Bool {
        (heightUnit == .cm ? userProfile.heightCm > 0 : (userProfile.heightFt > 0 || userProfile.heightIn > 0)) &&
        !weightString.isEmpty && Float(weightString) ?? 0 > 0 &&
        !targetWeightString.isEmpty && Float(targetWeightString) ?? 0 > 0
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerText
                        preferredUnitsSection
                        heightPicker
                        weightInput
                        targetWeightInput
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                nextButton
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .onAppear {
            if userProfile.weight > 0 {
                weightString = String(format: "%.1f", userProfile.weight)
            }
            if userProfile.targetWeight > 0 {
                targetWeightString = String(format: "%.1f", userProfile.targetWeight)
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            HStack {
                backButton
                Spacer()
                progressView
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
        }
        .padding(.leading)
    }
    
    private var progressView: some View {
        HStack {
            ProgressView(value: min(1, max(0, progressState.progress)))
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("2/4")
                .font(.caption)
                .padding(.leading, 5)
        }
    }
    
    private var headerText: some View {
        Text("Your measurements")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var preferredUnitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferred Units").font(.headline)
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Height:")
                    Picker("Height Unit", selection: $heightUnit) {
                        ForEach(HeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue.uppercased()).tag(unit)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Weight:")
                    Picker("Weight Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue.uppercased()).tag(unit)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
    
    private var heightPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Height (\(heightUnit.rawValue))")
                .font(.headline)
                .padding(.bottom, 5)
            
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
    
    private var weightInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Weight (\(weightUnit.rawValue))").font(.headline)
            TextField("Enter weight", text: $weightString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: weightString) { oldValue, newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if filtered != newValue {
                        weightString = filtered
                    }
                    if let dotIndex = filtered.firstIndex(of: ".") {
                        let decimalPlaces = filtered.distance(from: dotIndex, to: filtered.endIndex) - 1
                        if decimalPlaces > 1 {
                            weightString = String(filtered.prefix(filtered.count - 1))
                        }
                    }
                    if let weight = Float(filtered) {
                        userProfile.weight = Double(weight)
                    }
                }
        }
    }
    
    private var targetWeightInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Target Weight (\(weightUnit.rawValue))").font(.headline)
            TextField("Enter target weight", text: $targetWeightString)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .onChange(of: targetWeightString) { oldValue, newValue in
                    let filtered = newValue.filter { "0123456789.".contains($0) }
                    if filtered != newValue {
                        targetWeightString = filtered
                    }
                    if let dotIndex = filtered.firstIndex(of: ".") {
                        let decimalPlaces = filtered.distance(from: dotIndex, to: filtered.endIndex) - 1
                        if decimalPlaces > 1 {
                            targetWeightString = String(filtered.prefix(filtered.count - 1))
                        }
                    }
                    if let targetWeight = Float(filtered) {
                        userProfile.targetWeight = Double(targetWeight)
                    }
                }
        }
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo3(userProfile: $userProfile, progressState: $progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.blue.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(!isFormValid)
        .simultaneousGesture(TapGesture().onEnded {
            if isFormValid {
                progressState.progress += 0.25
                saveUserProfile()
            }
        })
        .padding(.vertical, 40)
    }
    
    private func saveUserProfile() {
        let (heightCm, heightFt, heightIn) = calculateHeightValues()

        userProfile.heightCm = heightCm
        userProfile.heightFt = heightFt
        userProfile.heightIn = heightIn

        FirestoreManager.shared.saveUserProfile(userProfile) { result in
            switch result {
            case .success:
                print("User profile saved successfully")
            case .failure(let error):
                print("Failed to save user profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func calculateHeightValues() -> (cm: Int, ft: Int, in: Int) {
        if heightUnit == .cm {
            let totalInches = Double(userProfile.heightCm) / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return (userProfile.heightCm, feet, inches)
        } else {
            let cm = Int((Double(userProfile.heightFt) * 30.48) + (Double(userProfile.heightIn) * 2.54))
            return (cm, userProfile.heightFt, userProfile.heightIn)
        }
    }
}
