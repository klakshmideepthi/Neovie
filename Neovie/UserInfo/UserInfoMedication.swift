import SwiftUI

struct UserInfoMedication: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMedication: MedicationInfo?
    @State private var navigateToNextView = false
    @State private var navigateToBMIAndProtein = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Medication Information")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        medicationGrid
                    }
                }
                .padding()
                
                Spacer()
                
                MedicationDisclaimerView()
                
                noMedicationButton
                continueButton
                
                NavigationLink(destination: UserInfoDosage(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
                NavigationLink(destination: BMIAndProteinCalculationView(userProfile: $userProfile), isActive: $navigateToBMIAndProtein) {
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
                    .fill(index < 8 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var medicationGrid: some View {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(availableMedications, id: \.name) { medication in
                    MedicationButton(
                        name: medication.name,
                        imageName: "Med\(availableMedications.firstIndex(where: { $0.name == medication.name })! + 1)",
                        isSelected: selectedMedication?.name == medication.name
                    ) {
                        selectedMedication = medication
                    }
                }
                .padding(5)
            }
        }
    
    private var noMedicationButton: some View {
        Button(action: {
            userProfile.medicationInfo = nil
            userProfile.dosage = ""
            navigateToBMIAndProtein = true
        }) {
            Text("I do not take any medication")
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.secondaryBackgroundColor)
                .foregroundColor(AppColors.accentColor)
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.bottom, 10)
    }
    
    private var continueButton: some View {
        Button(action: {
            saveMedicationInfo()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedMedication != nil ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(selectedMedication != nil ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedMedication == nil)
        .simultaneousGesture(TapGesture().onEnded {
            if selectedMedication != nil {
                saveMedicationInfo()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func saveMedicationInfo() {
            guard let medication = selectedMedication else { return }
            FirestoreManager.shared.saveMedicationInfo(medicationInfo: medication) { result in
                switch result {
                case .success:
                    print("Medication info saved successfully")
                    userProfile.medicationInfo = medication
                    self.navigateToNextView = true
                case .failure(let error):
                    print("Failed to save medication info: \(error.localizedDescription)")
                }
            }
        }
    }

struct MedicationButton: View {
    let name: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isImagePressed = false
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isImagePressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isImagePressed = false
                    }
                }
                action()
            }) {
                VStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(10)
                        .frame(height: geometry.size.height * 0.7)
                        .scaleEffect(isImagePressed ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isImagePressed)
                    
                    Text(name)
                        .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.6))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(height: geometry.size.height * 0.3)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppColors.accentColor.opacity(0.1) : AppColors.buttonBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.3), lineWidth: 4)
                )
            }
            .background(isSelected ? AppColors.accentColor.opacity(0.1) : Color.clear)
            .cornerRadius(12)
        }
        .aspectRatio(0.9, contentMode: .fit)
    }
}

struct MedicationDisclaimerView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColors.accentColor)
                .font(.system(size: 12))

            Text("All medication names are trademarks of their owners.")
                .font(.system(size: 12))
                .foregroundColor(AppColors.textColor.opacity(0.8))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}
