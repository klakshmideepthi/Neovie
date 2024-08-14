import SwiftUI
import UserNotifications

struct UserInfo4: View {
    @Binding var userProfile: UserProfile
    @Binding var progressState: ProgressState
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDosage: String = ""
    @State private var navigateToNextView = false
    @State private var isNotificationPermissionGranted = false
    
    var dosageOptions: [String] {
        if userProfile.medicationName == "Wegovy" || userProfile.medicationName == "Ozempic" {
            return ["0.25mg", "0.5mg", "1mg"]
        } else {
            return ["2.5mg", "5mg", "7.5mg", "10mg", "12.5mg", "15mg"]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Progress bar and back button
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
                .frame(width: geometry.size.width)
                .background(Color(hex: 0x394F56).opacity(0.1))
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Additional Information")
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                            .foregroundColor(.customTextColor)

                        Text("Select Dosage")
                            .font(.headline)
                            .foregroundColor(.customTextColor)
                        
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
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: destinationView, isActive: $navigateToNextView) {
                EmptyView()
            }
        )
    }
    
    @ViewBuilder
    private var destinationView: some View {
        if isNotificationPermissionGranted {
            HomePage().navigationBarBackButtonHidden(true)
        } else {
            NotificationRequest().navigationBarBackButtonHidden(true)
        }
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
            ProgressView(value: 1)
                .progressViewStyle(LinearProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
            Text("4/4")
                .font(.caption)
                .padding(.leading, 5)
                .foregroundColor(.customTextColor)
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
                    .background(selectedDosage == dosage ? Color(hex: 0x394F56) : Color.gray.opacity(0.2))
                    .foregroundColor(selectedDosage == dosage ? .white : .black)
                    .cornerRadius(10)
            }
        }
    }
    
    private var doneButton: some View {
            Button(action: {
                if !selectedDosage.isEmpty {
                    saveDosageInfo()
                    checkNotificationPermission()
                }
            }) {
                Text("Done!")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(!selectedDosage.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                    .foregroundColor(!selectedDosage.isEmpty ? .white : .white.opacity(0.5))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(selectedDosage.isEmpty)
            .padding(.bottom, 60)
        }
    
        
        private func saveDosageInfo() {
            FirestoreManager.shared.saveDosageInfo(dosage: selectedDosage) { result in
                switch result {
                case .success:
                    print("Dosage info saved successfully")
                    userProfile.dosage = selectedDosage
                case .failure(let error):
                    print("Failed to save dosage info: \(error.localizedDescription)")
                }
            }
        }
        
        private func checkNotificationPermission() {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                DispatchQueue.main.async {
                    switch settings.authorizationStatus {
                    case .authorized, .provisional, .ephemeral:
                        self.isNotificationPermissionGranted = true
                        print("Notification permission is granted")
                    case .denied, .notDetermined:
                        self.isNotificationPermissionGranted = false
                        print("Notification permission is not granted")
                    @unknown default:
                        self.isNotificationPermissionGranted = false
                        print("Unknown notification permission status")
                    }
                    
                    // Add a small delay before navigating
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToNextView = true
                    }
                }
            }
        }
    }
