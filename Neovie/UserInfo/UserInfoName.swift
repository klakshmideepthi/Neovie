import SwiftUI
import UIKit
import HealthKit

struct UserInfoName: View {
    @Binding var userProfile: UserProfile
    @State private var name: String = ""
    @State private var navigateToNextView = false
    @State private var showHealthKitPermissionAlert = false
    @State private var healthKitAuthorized = false
    @State private var isHealthKitAuthorized = false
    
    let healthStore = HKHealthStore()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                Text("What is your name?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                
                nameInputField
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoAge(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .onAppear(perform: requestHealthKitAuthorization)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarHidden(true)
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 1 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
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
    
    private var nameInputField: some View {
        VStack(alignment: .leading, spacing: 5) {
            ZStack() {
                if name.isEmpty {
                    Text("Enter your name here")
                        .foregroundColor(AppColors.textColor.opacity(0.5))
                }
                CustomTextField(text: $name, placeholder: "", onCommit: {
                    if !name.isEmpty {
                        saveUserProfile()
                    }
                })
                .frame(height: 44)
            }
            .padding(.bottom, 8)
            .overlay(Rectangle().frame(height: 2).foregroundColor(AppColors.accentColor.opacity(0.2)), alignment: .bottom)
        }
        .padding(.horizontal)
    }

    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!name.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!name.isEmpty ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(name.isEmpty)
        .simultaneousGesture(TapGesture().onEnded {
            if !name.isEmpty {
                saveUserProfile()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func requestHealthKitAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        let readTypes: Set<HKObjectType> = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!,
            HKObjectType.characteristicType(forIdentifier: .biologicalSex)!,
            HKObjectType.quantityType(forIdentifier: .bodyMass)!,
            HKObjectType.quantityType(forIdentifier: .height)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            DispatchQueue.main.async {
                self.isHealthKitAuthorized = success
                if success {
                    self.fetchHealthKitData()
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func fetchHealthKitData() {
               HealthKitManager.shared.fetchUserInfo { dateOfBirth, biologicalSex, weight, height in
                   DispatchQueue.main.async {
                       if let dateOfBirth = dateOfBirth {
                           userProfile.dateOfBirth = dateOfBirth
                       }
                       if let biologicalSex = biologicalSex {
                           userProfile.gender = biologicalSex
                       }
                       if let weight = weight {
                           userProfile.weight = weight
                       }
                       if let height = height {
                           userProfile.heightCm = Int(height)
                       }
                   }
               }
           }
        
        private func saveUserProfile() {
            userProfile.name = name
            
            FirestoreManager.shared.saveUserProfile(userProfile) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        print("User profile saved successfully")
                        self.navigateToNextView = true
                    case .failure(let error):
                        print("Failed to save user profile: \(error.localizedDescription)")
                        // You might want to show an alert to the user here
                    }
                }
            }
        }
        

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
