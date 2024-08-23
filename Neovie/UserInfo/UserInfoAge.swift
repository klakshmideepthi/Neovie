import SwiftUI
import HealthKit

struct UserInfoAge: View {
    @Binding var userProfile: UserProfile
    @State private var isHealthKitAuthorized = false
    @State private var navigateToNextView = false
    @State private var birthDate = Date()
    @State private var showingAgeAlert = false
    @State private var isDataLoaded = false
    @Environment(\.presentationMode) var presentationMode
    
    let healthStore = HKHealthStore()

    private var isUserOverThirteen: Bool {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: birthDate, to: Date())
        let age = ageComponents.year ?? 0
        return age > 13
    }

    var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    progressBar
                    
                    Text("Date Of Birth")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    
                    Spacer()
                    
                if isDataLoaded {
                    DatePicker("Birth Date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .accentColor(AppColors.accentColor)
                        .padding()
                        .cornerRadius(10)
                } else {
                    ProgressView()
                }
                
                    Spacer()
                    
                    DisclaimerView()
                    
                    continueButton
                    
                    NavigationLink(destination: UserInfoGender(userProfile: $userProfile), isActive: $navigateToNextView) {
                        EmptyView()
                    }
                }
                .background(AppColors.backgroundColor)
                .foregroundColor(AppColors.textColor)
                .edgesIgnoringSafeArea(.all)
                .onAppear(perform: fetchUserProfile)
            .alert(isPresented: $showingAgeAlert) {
                Alert(
                    title: Text("Age Restriction"),
                    message: Text("You must be over 13 years old to use this app."),
                    dismissButton: .default(Text("OK"))
                )
            }
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
    
    struct DisclaimerView: View {
        var body: some View {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .foregroundColor(AppColors.accentColor)
                    .font(.system(size: 12))

                Text("You must be 13 years or older to use this app.")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.textColor.opacity(0.8))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            if isUserOverThirteen {
                saveUserProfile()
            } else {
                showingAgeAlert = true
            }
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isUserOverThirteen ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(isUserOverThirteen ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .disabled(!isUserOverThirteen)
        .padding(.horizontal)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func fetchUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let fetchedProfile):
                DispatchQueue.main.async {
                    if fetchedProfile.dateOfBirth != Date() {
                        self.birthDate = fetchedProfile.dateOfBirth
                        print("Date of Birth loaded from Firestore: \(fetchedProfile.dateOfBirth)")
                    } else {
                        print("No Date of Birth found in Firestore")
                        self.fetchHealthKitData()
                    }
                    self.isDataLoaded = true
                }
            case .failure(let error):
                print("Failed to fetch user profile: \(error.localizedDescription)")
                self.fetchHealthKitData()
                self.isDataLoaded = true
            }
        }
    }
    
    private func fetchHealthKitData() {
        do {
            let birthdayComponents = try healthStore.dateOfBirthComponents()
            
            if let birthday = birthdayComponents.date {
                birthDate = birthday
                print("Date of Birth loaded from HealthKit: \(birthday)")
            }
        } catch {
            print("Error fetching HealthKit data: \(error.localizedDescription)")
        }
    }
    
    private func saveUserProfile() {
        if userProfile.dateOfBirth != birthDate {
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
        } else {
            print("Date of Birth unchanged, skipping save")
            self.navigateToNextView = true
        }
    }
}
