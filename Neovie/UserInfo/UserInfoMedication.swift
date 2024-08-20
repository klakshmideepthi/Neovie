import SwiftUI

struct UserInfoMedication: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMedication: String = ""
    @State private var navigateToNextView = false
    
    let medications = ["Mounjaro", "Wegovy", "Ozempic", "Zepbound"]
    let medicationImages = ["Med1", "Med2", "Med3", "Med4"]
    
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
                
                continueButton
                
                NavigationLink(destination: UserInfoDosage(userProfile: $userProfile), isActive: $navigateToNextView) {
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
            ForEach(0..<medications.count, id: \.self) { index in
                MedicationButton(
                    name: medications[index],
                    imageName: medicationImages[index],
                    isSelected: selectedMedication == medications[index]
                ) {
                    selectedMedication = medications[index]
                }
            }
            .padding(5)
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            saveMedicationInfo()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedMedication.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!selectedMedication.isEmpty ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedMedication.isEmpty)
        .simultaneousGesture(TapGesture().onEnded {
            if !selectedMedication.isEmpty {
                saveMedicationInfo()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private func saveMedicationInfo() {
        FirestoreManager.shared.saveMedicationInfo(medicationName: selectedMedication) { result in
            switch result {
            case .success:
                print("Medication info saved successfully")
                userProfile.medicationName = selectedMedication
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
