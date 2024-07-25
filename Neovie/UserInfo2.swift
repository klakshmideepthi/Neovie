import SwiftUI

struct UserInfo2: View {
    @Binding var userProfile: UserProfile
    @ObservedObject var progressState: ProgressState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedGender: String = ""
    @State private var dateOfBirth: Date = Date()
    
    let genders = ["Male", "Female", "Other"]
    let genderImages = ["Icon1", "Icon2", "Icon3"]

    private var isFormValid: Bool {
        !selectedGender.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 40) {
                        headerText
                        genderSelection
                        dateOfBirthPicker
                    }
                    .padding(.horizontal)
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
            ProgressView(value: 0.50)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("2/4")
                .font(.caption)
                .padding(.leading, 5)
        }
    }
    
    private var headerText: some View {
        Text("Tell us more about you")
            .font(.title)
            .fontWeight(.bold)
            .multilineTextAlignment(.center)
            .padding()
    }
    
    private var genderSelection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gender")
                .font(.headline)

            HStack(spacing: 20) {
                ForEach(0..<genders.count, id: \.self) { index in
                    genderButton(index: index)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func genderButton(index: Int) -> some View {
        Button(action: {
            selectedGender = genders[index]
        }) {
            VStack {
                Image(genderImages[index])
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
                    .background(RoundedRectangle(cornerRadius: 15)
                        .fill(selectedGender == genders[index] ? Color.blue.opacity(0.2) : Color.clear))
                    .cornerRadius(15)
                Text(genders[index])
                    .foregroundColor(.black)
            }
            .padding(10)
            .background(RoundedRectangle(cornerRadius: 15)
                .stroke(selectedGender == genders[index] ? Color.blue : Color.gray, lineWidth: 2))
        }
    }
    
    private var dateOfBirthPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Date of Birth")
                .font(.headline)
            DatePicker("", selection: $dateOfBirth, displayedComponents: .date)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
        }
    }
    
    private var nextButton: some View {
        NavigationLink(destination: UserInfo3(userProfile: $userProfile, progressState: progressState)) {
            Text("Next")
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.blue.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
        }
        .disabled(!isFormValid)
        .simultaneousGesture(TapGesture().onEnded {
            if isFormValid {
                progressState.progress += 0.25
                saveAdditionalInfo()
            }
        })
        .padding(.vertical, 40)
    }
    
    private func saveAdditionalInfo() {
        // Calculate age from date of birth
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = ageComponents.year ?? 0
        
        // Save additional info to Firestore
        FirestoreManager.shared.saveAdditionalInfo(gender: selectedGender, age: age) { result in
            switch result {
            case .success:
                print("Additional info saved successfully")
            case .failure(let error):
                print("Failed to save additional info: \(error.localizedDescription)")
            }
        }
    }
}
