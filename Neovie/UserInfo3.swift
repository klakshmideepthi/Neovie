import SwiftUI

struct UserInfo3: View {
    @Binding var userProfile: UserProfile
    @ObservedObject var progressState: ProgressState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedMedication: String = ""
    
    let medications = ["Mounjaro", "Wegovy", "Ozempic", "Zepbound"]
    let medicationImages = ["Img1", "Img3", "Img4", "Img2"]
    
    var body: some View {
        NavigationStack {
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
        .background(Color.blue.opacity(0.1))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
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
        }
    }
    
    private var headerText: some View {
        Text("Medication Information")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
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
        NavigationLink(destination: UserInfo4(userProfile: $userProfile, progressState: progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedMedication.isEmpty ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(selectedMedication.isEmpty)
        .simultaneousGesture(TapGesture().onEnded {
            if !selectedMedication.isEmpty {
                progressState.progress += 0.25
                saveMedicationInfo()
            }
        })
        .padding(.vertical, 40)
    }
    
    private func saveMedicationInfo() {
        // Save the selected medication to Firestore
        FirestoreManager.shared.saveMedicationInfo(medication: selectedMedication) { result in
            switch result {
            case .success:
                print("Medication info saved successfully")
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
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
                    
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .padding(20)
                }
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 4)
                )
                
                Text(name)
                    .foregroundColor(.black)
                    .padding(.top, 5)
            }
        }
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(10)
    }
}
