import SwiftUI
import HealthKit

struct UserInfoAge: View {
    @Binding var userProfile: UserProfile
    @State private var isHealthKitAuthorized = false
    @State private var navigateToNextView = false
    @State private var birthDate = Date()
    @Environment(\.presentationMode) var presentationMode
    
    let healthStore = HKHealthStore()


    var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    progressBar
                    
                    Text("Date Of Birth")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                    
                    DatePicker("Birth Date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .accentColor(AppColors.accentColor)
                        .padding()
                        .cornerRadius(10)
                    
                    Spacer()
                    
                    continueButton
                    
                    NavigationLink(destination: UserInfoGender(userProfile: $userProfile), isActive: $navigateToNextView) {
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
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 2 ? AppColors.accentColor : Color.gray.opacity(0.3))
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
                .background(AppColors.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .padding(.horizontal)
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
            let birthdayComponents = try healthStore.dateOfBirthComponents()
            
            if let birthday = birthdayComponents.date {
                birthDate = birthday
            }
        } catch {
            print("Error fetching HealthKit data: \(error.localizedDescription)")
        }
    }
    
    private func saveUserProfile() {
        userProfile.dateOfBirth = birthDate
        
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
