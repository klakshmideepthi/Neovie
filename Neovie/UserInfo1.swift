import SwiftUI

struct UserInfo1: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @State private var selectedGender: String = ""
    
    let genders = ["Male", "Female", "Other"]
    let genderImages = ["Icon1", "Icon2", "Icon3"]

    private var isFormValid: Bool {
        !userProfile.name.isEmpty && !selectedGender.isEmpty
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        headerText
                        nameInput
                        genderSelection
                        dateOfBirthPicker
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
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            HStack {
                Spacer()
                progressView
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0x394F56).opacity(0.1))
    }
    
    private var progressView: some View {
        HStack {
            ProgressView(value: min(1, max(0, progressState.progress)))
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("1/4")
                .font(.caption)
                .padding(.leading, 5)
        }
    }
    
    private var headerText: some View {
        Text("Tell us about you")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var nameInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Name").font(.headline)
            TextField("Name", text: $userProfile.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(label: Text("Enter your name"))
        }
    }
    
    private var genderSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gender")
                .font(.headline)

            HStack(spacing: 20) {
                ForEach(0..<genders.count, id: \.self) { index in
                    genderButton(index: index)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func genderButton(index: Int) -> some View {
        Button(action: {
            selectedGender = genders[index]
            userProfile.gender = genders[index]
        }) {
            VStack {
                Image(genderImages[index])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(selectedGender == genders[index] ? Color(hex: 0x394F56).opacity(0.2) : Color.clear))
                    .cornerRadius(15)
                Text(genders[index])
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 15)
                .stroke(selectedGender == genders[index] ? Color(hex: 0x394F56): Color.gray, lineWidth: 2))
        }
        .accessibility(label: Text("Select gender: \(genders[index])"))
    }
    
    private var dateOfBirthPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date of Birth")
                .font(.headline)
            DatePicker("Date of Birth", selection: $userProfile.dateOfBirth, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .accessibility(label: Text("Select your date of birth"))
                .onChange(of: userProfile.dateOfBirth) { newValue in
                    userProfile.age = calculateAge(from: newValue)
                }
        }
    }
    
    private func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo2(userProfile: $userProfile, progressState: $progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color(hex: 0x394F56) : Color(hex: 0x394F56).opacity(0.3))
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
        .padding(.vertical, 60)
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
