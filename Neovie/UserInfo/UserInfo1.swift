import SwiftUI

struct UserInfo1: View {
    @Binding var userProfile: UserProfile
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
            .background(AppColors.backgroundColor)
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
        .background(AppColors.accentColor.opacity(0.1))
    }
    
    private var progressView: some View {
        HStack {
            ProgressView(value: 0.25)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
                .accentColor(AppColors.accentColor)
            Text("1/4")
                .font(.caption)
                .padding(.leading, 5)
                .foregroundColor(AppColors.textColor)
        }
    }
    
    private var headerText: some View {
        Text("Tell us about you")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(AppColors.textColor)
    }
    
    private var nameInput: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Name").font(.headline).foregroundColor(AppColors.textColor)
            TextField("Name", text: $userProfile.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .accessibility(label: Text("Enter your name"))
        }
    }
    
    private var genderSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gender")
                .font(.headline)
                .foregroundColor(AppColors.textColor)

            HStack(spacing: 20) {
                ForEach(0..<genders.count, id: \.self) { index in
                    genderButton(index: index)
                }
            }
            .frame(height: UIScreen.main.bounds.width * 0.3) // Adjust this multiplier as needed
        }
    }

    private func genderButton(index: Int) -> some View {
        GeometryReader { geometry in
            Button(action: {
                selectedGender = genders[index]
                userProfile.gender = genders[index]
            }) {
                VStack {
                    Image(genderImages[index])
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)

                    Text(genders[index])
                        .foregroundColor(AppColors.textColor)
                        .font(.system(size: geometry.size.width * 0.12))
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(selectedGender == genders[index] ? AppColors.accentColor : AppColors.textColor.opacity(0.3), lineWidth: 2)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(AppColors.backgroundColor.opacity(selectedGender == genders[index] ? 0 : 0.3))
                )
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibility(label: Text("Select gender: \(genders[index])"))
    }
    
    private var dateOfBirthPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date of Birth")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            DatePicker("", selection: $userProfile.dateOfBirth, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .accessibility(label: Text("Select your date of birth"))
                .onChange(of: userProfile.dateOfBirth) { newValue in
                    userProfile.age = calculateAge(from: newValue)
                }
                .accentColor(AppColors.accentColor)
        }
        .padding(.horizontal)
    }
    
    private func calculateAge(from dateOfBirth: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        return ageComponents.year ?? 0
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo2(userProfile: $userProfile)) {
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
