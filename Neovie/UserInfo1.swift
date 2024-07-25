import SwiftUI

struct UserInfo1: View {
    @Binding var userProfile: UserProfile
    @ObservedObject var progressState: ProgressState
    @State private var heightUnit: HeightUnit = .cm
    @State private var weightUnit: WeightUnit = .kg

    enum HeightUnit: String, CaseIterable {
        case cm, ft
    }

    enum WeightUnit: String, CaseIterable {
        case kg, lb
    }

    private var isFormValid: Bool {
        !userProfile.name.isEmpty &&
        userProfile.height > 0 &&
        userProfile.weight > 0
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Progress bar (unchanged)
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)
                        
                        HStack {
                            ProgressView(value: 0.25)
                                .progressViewStyle(LinearProgressViewStyle())
                                .frame(width: geometry.size.width * 0.6, height: 10)
                            Text("1/4")
                                .font(.caption)
                                .padding(.leading, 5)
                        }
                        .padding()
                    }
                    .frame(width: geometry.size.width)
                    .background(Color.blue.opacity(0.1))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Tell us more about you")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Name")
                                    .font(.headline)
                                TextField("Name", text: $userProfile.name)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal)
                            }

                            // Preferred Units section (unchanged)
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Preferred Units")
                                    .font(.headline)
                                
                                HStack(spacing: 20) {
                                    VStack(alignment: .leading) {
                                        Text("Height:")
                                        Picker("Height Unit", selection: $heightUnit) {
                                            ForEach(HeightUnit.allCases, id: \.self) { unit in
                                                Text(unit.rawValue.uppercased()).tag(unit)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                    .frame(maxWidth: .infinity)

                                    VStack(alignment: .leading) {
                                        Text("Weight:")
                                        Picker("Weight Unit", selection: $weightUnit) {
                                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                                Text(unit.rawValue.uppercased()).tag(unit)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Height (\(heightUnit.rawValue))")
                                    .font(.headline)
                                TextField("Enter height", value: $userProfile.height, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .padding(.horizontal)
                            }

                            VStack(alignment: .leading, spacing: 5) {
                                Text("Weight (\(weightUnit.rawValue))")
                                    .font(.headline)
                                TextField("Enter weight", value: $userProfile.weight, format: .number)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.decimalPad)
                                    .padding(.horizontal)
                            }
                        }
                        .padding()
                    }
                    
                    NavigationLink(destination: UserInfo2(userProfile: $userProfile, progressState: progressState)) {
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
                            progressState.progress = 0.25
                            saveUserProfile()
                        }
                    })
                    .padding(.vertical, 40)
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func saveUserProfile() {
        FirestoreManager.shared.saveUserProfile(userProfile) { result in
            switch result {
            case .success:
                print("User profile saved successfully")
            case .failure(let error):
                print("Failed to save user profile: \(error.localizedDescription)")
            }
        }
    }
}
