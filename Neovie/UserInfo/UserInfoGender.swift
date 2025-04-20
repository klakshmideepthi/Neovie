import SwiftUI

struct UserInfoGender: View {
    @Binding var userProfile: UserProfile
    @State private var selectedGender: String = ""
    @State private var navigateToNextView = false
    @State private var isDataLoaded = false
    @Environment(\.presentationMode) var presentationMode
    
    let genders = ["Male", "Female", "Other"]
    let genderIcons = ["figure.stand", "figure.stand.dress", "person"]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                progressBar
                
                Text("How do you identify yourself?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Spacer()
                
                genderSelectionSection
                    .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoHeight(userProfile: $userProfile), isActive: $navigateToNextView) {
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
    
    private var genderSelectionSection: some View {
        VStack(spacing: 16) {
            ForEach(genders, id: \.self) { gender in
                GenderButton(
                    gender: gender,
                    icon: genderIcons[genders.firstIndex(of: gender) ?? 0],
                    isSelected: selectedGender == gender
                ) {
                    selectedGender = gender
                }
            }
        }
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
    
    private var progressView: some View {
        HStack {
            ForEach(0..<9) { index in
                Rectangle()
                    .fill(index < 3 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedGender.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!selectedGender.isEmpty ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedGender.isEmpty)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func fetchUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let fetchedProfile):
                DispatchQueue.main.async {
                    if !fetchedProfile.gender.isEmpty && fetchedProfile.gender != "Not Set" {
                        self.selectedGender = fetchedProfile.gender
                    } else {
                        self.selectedGender = ""
                    }
                    self.isDataLoaded = true
                }
            case .failure(let error):
                print("Failed to fetch user profile: \(error.localizedDescription)")
                self.isDataLoaded = true
            }
        }
    }
    
    private func saveUserProfile() {
        if userProfile.gender != selectedGender {
            userProfile.gender = selectedGender
            
            FirestoreManager.shared.saveUserProfile(userProfile) { result in
                switch result {
                case .success:
                    print("User profile saved successfully")
                    self.navigateToNextView = true
                case .failure(let error):
                    print("Failed to save user profile: \(error.localizedDescription)")
                }
            }
        } else {
            print("Gender unchanged, skipping save")
            self.navigateToNextView = true
        }
    }
}

struct GenderButton: View {
    let gender: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing : 16) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.6))
                    .frame(width: 40,height: 40)
                
                Text(gender)
                    .font(.headline)
                    .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(AppColors.accentColor)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? AppColors.accentColor.opacity(0.1) : AppColors.buttonBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accentColor : Color.gray.opacity(0.3), lineWidth: 4)
            )
            .cornerRadius(12) 
        }
    }
}
