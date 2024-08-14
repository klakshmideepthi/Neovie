import SwiftUI

struct UserInfo3: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMedication: String = ""
    
    let medications = ["Mounjaro", "Wegovy", "Ozempic", "Zepbound"]
    let medicationImages = ["Img1", "Img3", "Img4", "Img2"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack {
                        headerText
                        medicationGrid
                    }
                    .padding()
                }
                
                Spacer()
                
                nextButton
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 60)
            HStack {
                backButton
                Spacer()
                progressView
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: 0x394F56).opacity(0.1))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color(hex: 0x394F56))
        }
        .padding(.leading)
    }
    
    private var progressView: some View {
        HStack {
            ProgressView(value: 0.75)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("3/4")
                .font(.caption)
                .padding(.leading, 5)
                .foregroundColor(.customTextColor)
        }
    }
    
    private var headerText: some View {
        Text("Medication Information")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
            .foregroundColor(.customTextColor)
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
        }
        .padding(.horizontal)
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo4(userProfile: $userProfile, progressState: $progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedMedication.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!selectedMedication.isEmpty ? AppColors.backgroundColor : AppColors.backgroundColor.opacity(0.5))
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(selectedMedication.isEmpty)
        .simultaneousGesture(TapGesture().onEnded {
            if !selectedMedication.isEmpty {
                saveMedicationInfo()
            }
        })
        .padding(.bottom, 60)
    }
    
    private func saveMedicationInfo() {
        FirestoreManager.shared.saveMedicationInfo(medicationName: selectedMedication) { result in
            switch result {
            case .success:
                print("Medication info saved successfully")
                userProfile.medicationName = selectedMedication
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
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(height: 150)
                
                Text(name)
                    .foregroundColor(.black)
                    .font(.subheadline)
                    .padding(.bottom, 5)
            }
            .frame(height: 210)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color(hex: 0x394F56): Color.gray, lineWidth: 2)
            )
        }
        .background(isSelected ? Color(hex: 0x394F56).opacity(0.1) : Color.clear)
        .cornerRadius(10)
        .padding(5)
    }
}
