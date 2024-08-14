import SwiftUI

struct UserInfo2: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @State private var heightUnit: HeightUnit = .cm
    @State private var weightUnit: WeightUnit = .kg
    @State private var weightString: String = ""
    @State private var targetWeightString: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var keyboardHeight: CGFloat = 0

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
        NavigationView {
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
                .padding(.bottom, keyboardHeight)
                
                Spacer()
                
                nextButton
            }
            .background(AppColors.backgroundColor)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if userProfile.weight > 0 {
                weightString = String(format: "%.1f", userProfile.weight)
            }
            if userProfile.targetWeight > 0 {
                targetWeightString = String(format: "%.1f", userProfile.targetWeight)
            }
            
            // Add keyboard observers
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    keyboardHeight = keyboardRectangle.height
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
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
    
    private var progressView: some View {
        HStack {
            ProgressView(value: 0.5)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
                .accentColor(AppColors.accentColor)
            Text("2/4")
                .font(.caption)
                .padding(.leading, 5)
                .foregroundColor(AppColors.textColor)
        }
    }
    
    private var headerText: some View {
        Text("Your measurements")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(AppColors.textColor)
    }
    
    private var preferredUnitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferred Units").font(.headline).foregroundColor(AppColors.textColor)
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("Height:").foregroundColor(AppColors.textColor)
                    Picker("Height Unit", selection: $heightUnit) {
                        ForEach(HeightUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue.uppercased()).tag(unit)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }

                VStack(alignment: .leading) {
                    Text("Weight:").foregroundColor(AppColors.textColor)
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
                .foregroundColor(AppColors.textColor)
            
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
            Text("Weight (\(weightUnit.rawValue))").font(.headline).foregroundColor(AppColors.textColor)
            TextField("Enter weight", text: weightBinding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .foregroundColor(AppColors.textColor)
                .accentColor(AppColors.accentColor)
                .onSubmit {
                    hideKeyboard()
                }
        }
    }
    
    private var targetWeightInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Target Weight (\(weightUnit.rawValue))").font(.headline).foregroundColor(AppColors.textColor)
            TextField("Enter target weight", text: targetWeightBinding)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
                .foregroundColor(AppColors.textColor)
                .accentColor(AppColors.accentColor)
                .onSubmit {
                    hideKeyboard()
                }
        }
    }
    
    private var weightBinding: Binding<String> {
        Binding<String>(
            get: { self.weightString },
            set: {
                let filtered = $0.filter { "0123456789.".contains($0) }
                if let dotIndex = filtered.firstIndex(of: ".") {
                    let decimalPlaces = filtered.distance(from: dotIndex, to: filtered.endIndex) - 1
                    if decimalPlaces > 1 {
                        self.weightString = String(filtered.prefix(filtered.count - 1))
                    } else {
                        self.weightString = filtered
                    }
                } else {
                    self.weightString = filtered
                }
                if let weight = Float(self.weightString) {
                    self.userProfile.weight = Double(weight)
                }
            }
        )
    }
    
    private var targetWeightBinding: Binding<String> {
        Binding<String>(
            get: { self.targetWeightString },
            set: {
                let filtered = $0.filter { "0123456789.".contains($0) }
                if let dotIndex = filtered.firstIndex(of: ".") {
                    let decimalPlaces = filtered.distance(from: dotIndex, to: filtered.endIndex) - 1
                    if decimalPlaces > 1 {
                        self.targetWeightString = String(filtered.prefix(filtered.count - 1))
                    } else {
                        self.targetWeightString = filtered
                    }
                } else {
                    self.targetWeightString = filtered
                }
                if let targetWeight = Float(self.targetWeightString) {
                    self.userProfile.targetWeight = Double(targetWeight)
                }
            }
        )
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo3(userProfile: $userProfile, progressState: $progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(isFormValid ? .white : .white.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(!isFormValid)
        .simultaneousGesture(TapGesture().onEnded {
            if isFormValid {
                saveUserProfile()
            }
        })
        .padding(.bottom, 60)
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
