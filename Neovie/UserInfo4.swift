import SwiftUI

struct UserInfo4: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDosage: String = ""
    
    var dosageOptions: [String] {
        if userProfile.medicationName == "Wegovy" || userProfile.medicationName == "Ozempic" {
            return ["0.25mg", "0.5mg", "1mg"]
        } else {
            return ["2.5mg", "5mg", "7.5mg", "10mg", "12.5mg", "15mg"]
        }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Progress bar and back button
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 60)
                        
                        HStack {
                            backButton
                            Spacer()
                            progressView
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(width: geometry.size.width)
                    .background(Color.blue.opacity(0.1))
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("Additional Information")
                                .font(.title)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .padding()

                            Text("Select Dosage")
                                .font(.headline)
                            
                            dosageButtons
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    doneButton
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.all)
            }
        }
        .navigationBarHidden(true)
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
            ProgressView(value: min(1, max(0, progressState.progress)))
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("4/4")
                .font(.caption)
                .padding(.leading, 5)
        }
    }
    
    private var dosageButtons: some View {
        ForEach(dosageOptions, id: \.self) { dosage in
            Button(action: {
                selectedDosage = dosage
            }) {
                Text(dosage)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedDosage == dosage ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(selectedDosage == dosage ? .white : .black)
                    .cornerRadius(10)
            }
        }
    }
    
    private var doneButton: some View {
        NavigationLink(destination: NotificationRequest().navigationBarBackButtonHidden(true)) {
            Text("Done!")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedDosage.isEmpty ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(selectedDosage.isEmpty)
        .simultaneousGesture(TapGesture().onEnded {
            if !selectedDosage.isEmpty {
                progressState.progress = 1.0 // Set progress to 100%
                saveDosageInfo()
            }
        })
        .padding(.vertical, 40)
    }

    private func saveDosageInfo() {
        // Save the dosage information to Firestore
        FirestoreManager.shared.saveDosageInfo(dosage: selectedDosage) { result in
            switch result {
            case .success:
                print("Dosage info saved successfully")
                // Update local UserProfile
                userProfile.dosage = selectedDosage
            case .failure(let error):
                print("Failed to save dosage info: \(error.localizedDescription)")
            }
        }
    }
}
