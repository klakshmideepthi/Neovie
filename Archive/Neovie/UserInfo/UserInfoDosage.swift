import SwiftUI
import UserNotifications

struct UserInfoDosage: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDosage: String = ""
    @State private var navigateToNextView = false
    
    var dosageOptions: [String] {
            userProfile.medicationInfo?.dosages ?? []
        }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Dosage Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        dosageGrid
                    }
                }
                .padding()
                
                Spacer()
                
                ContinueButton
                NavigationLink(destination: UserInfoMedicationDay(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
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
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 9 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var dosageGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(dosageOptions, id: \.self) { dosage in
                DosageButton(
                    dosage: dosage,
                    isSelected: selectedDosage == dosage
                ) {
                    selectedDosage = dosage
                }
            }
            .padding(5)
        }
    }
    
    private var ContinueButton: some View {
        Button(action: {
            if !selectedDosage.isEmpty {
                saveDosageInfo()
            }
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedDosage.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!selectedDosage.isEmpty ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedDosage.isEmpty)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func saveDosageInfo() {
        FirestoreManager.shared.saveDosageInfo(dosage: selectedDosage) { result in
            switch result {
            case .success:
                print("Dosage info saved successfully")
                userProfile.dosage = selectedDosage
                self.navigateToNextView = true
            case .failure(let error):
                print("Failed to save dosage info: \(error.localizedDescription)")
            }
        }
    }
        
}

struct DosageButton: View {
    let dosage: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(dosage)
                .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.6))
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppColors.accentColor.opacity(0.1) : AppColors.buttonBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.3), lineWidth: 4)
                )
        }
    }
}
