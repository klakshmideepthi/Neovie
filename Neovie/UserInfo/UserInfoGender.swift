import SwiftUI
import HealthKit
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
                    .padding(20)
                    .opacity(isSelected ? 1 : 0.5)
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
    @State private var isHealthKitAuthorized = false
    @State private var navigateToNextView = false
    @Environment(\.presentationMode) var presentationMode
    
    let healthStore = HKHealthStore()
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
            .onAppear(perform: requestHealthKitAuthorization)
        }
        .navigationBarHidden(true)
    }
    
    private var genderSelectionSection: some View {
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
            .padding(5)
        }
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
        .simultaneousGesture(TapGesture().onEnded {
            if !selectedGender.isEmpty {
                saveUserProfile()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05) // 5% of screen height for bottom padding
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!
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
        do {
            let biologicalSex = try healthStore.biologicalSex()
            
            switch biologicalSex.biologicalSex {
            case .female:
                selectedGender = "Female"
            case .male:
                selectedGender = "Male"
            default:
                selectedGender = "Other"
            }
        } catch {
            print("Error fetching HealthKit data: \(error.localizedDescription)")
        }
    }
    
    private func saveUserProfile() {
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
    }
}
