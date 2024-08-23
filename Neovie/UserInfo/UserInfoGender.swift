import SwiftUI
import Lottie

struct GenderSelectionView: View {
    let gender: String
    let lottieName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(isSelected ? AppColors.accentColor.opacity(0.7) : Color("GenderButton"))
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? AppColors.accentColor : Color.gray.opacity(0.3), lineWidth: 4)
                
                LottieView(name: lottieName, play: isSelected)
                    .padding(15)
            }
            .aspectRatio(1, contentMode: .fit)
            .onTapGesture {
                action()
            }
            
            Text(gender)
                .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
    }
}

struct UserInfoGender: View {
    @Binding var userProfile: UserProfile
    @State private var selectedGender: String = ""
    @State private var navigateToNextView = false
    @State private var isDataLoaded = false
    @Environment(\.presentationMode) var presentationMode
    
    let genders = ["Female", "Male", "Other", "Prefer not to tell"]
    let genderLottie = ["Gender2", "Gender3", "Gender1", "Gender4"]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("How do you identify yourself?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        genderSelectionSection
                        
                        Spacer(minLength: 20)
                    }
                    .padding()
                }
                
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
        Group {
            if isDataLoaded {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(0..<4) { index in
                        GenderSelectionView(
                            gender: genders[index],
                            lottieName: genderLottie[index],
                            isSelected: selectedGender == genders[index]
                        ) {
                            selectedGender = genders[index]
                        }
                    }
                    .padding(20)
                }
            } else {
                ProgressView() // Show a loading indicator while fetching data
            }
        }
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 3 ? AppColors.accentColor : Color.gray.opacity(0.3))
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
    
    private var isGenderSelected: Bool {
        !selectedGender.isEmpty
    }
    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isGenderSelected ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(isGenderSelected ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(!isGenderSelected)
        .simultaneousGesture(TapGesture().onEnded {
            if isGenderSelected {
                saveUserProfile()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    private func fetchUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let fetchedProfile):
                DispatchQueue.main.async {
                    if !fetchedProfile.gender.isEmpty && fetchedProfile.gender != "Not Set" {
                        self.selectedGender = fetchedProfile.gender
                        print("Gender loaded from Firestore: \(fetchedProfile.gender)")
                    } else {
                        self.selectedGender = ""
                        print("No valid gender found in Firestore")
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
