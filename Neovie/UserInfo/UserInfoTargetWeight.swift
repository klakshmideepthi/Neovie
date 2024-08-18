import SwiftUI
import Firebase

struct UserInfoTargetWeight: View {
    @Binding var userProfile: UserProfile
    @State private var weightUnit: WeightUnit = .lbs
    @State private var targetWeightWhole: Int = 190
    @State private var targetWeightFraction: Int = 0
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToNextView = false

    enum WeightUnit: String, CaseIterable {
        case kg, lbs
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("What is your target weight?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        weightUnitPicker
                        
                        targetWeightPicker
                    }
                }
                .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoActivity(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
            .onAppear(perform: fetchWeightFromFirebase)
        }
        .navigationBarHidden(true)
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<9) { index in
                Rectangle()
                    .fill(index < 6 ? AppColors.accentColor : Color.gray.opacity(0.3))
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
    
    private var targetWeightPicker: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                HStack(spacing: 0) {
                    Picker("Target Whole", selection: $targetWeightWhole) {
                        ForEach(weightWholeRange, id: \.self) { whole in
                            Text("\(whole)").tag(whole)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: .infinity)
                    .clipped()

                    Picker("Target Fraction", selection: $targetWeightFraction) {
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
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func fetchWeightFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { (document, error) in
            if let document = document, document.exists {
                if let weightInKg = document.data()?["weight"] as? Double {
                    let targetWeightInKg = weightInKg - 2.0
                    self.setTargetWeight(targetWeightInKg)
                }
            } else {
                print("Document does not exist or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    private func setTargetWeight(_ weightInKg: Double) {
        let weight = self.weightUnit == .kg ? weightInKg : weightInKg * 2.20462
        self.targetWeightWhole = Int(weight)
        self.targetWeightFraction = Int((weight - Double(self.targetWeightWhole)) * 10)
    }
    
    private func convertWeight() {
        let oldTargetWeight = Double(targetWeightWhole) + Double(targetWeightFraction) / 10.0
        
        if weightUnit == .kg {
            setTargetWeight(oldTargetWeight / 2.20462)
        } else {
            setTargetWeight(oldTargetWeight * 2.20462)
        }
    }
    
    private func saveUserProfile() {
        let targetWeight = Double(targetWeightWhole) + Double(targetWeightFraction) / 10.0
        
        userProfile.targetWeight = weightUnit == .kg ? targetWeight : targetWeight / 2.20462 // Always save in kg
        
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
