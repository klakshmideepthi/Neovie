import SwiftUI
import Firebase

struct SettingsHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var signInManager = GoogleSignInManager.shared
    @State private var userProfile = UserProfile()
    @State private var isEditingProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0xEDEDED).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        accountSection
                        profileInformationSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(Color(hex: 0xC67C4E)))
        }
        .sheet(isPresented: $isEditingProfile) {
            ProfileEditView(userProfile: $userProfile)
        }
        .alert(isPresented: $showingSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    signOut()
                },
                secondaryButton: .cancel()
            )
        }
        .onAppear {
            loadUserProfile()
        }
    }
    
    private var accountSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button(action: {
                isEditingProfile = true
            }) {
                HStack {
                    Label("Edit Profile", systemImage: "person.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color(hex: 0xC67C4E))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            
            Button(action: {
                showingSignOutAlert = true
            }) {
                HStack {
                    Label("Sign Out", systemImage: "arrow.right.square")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(Color(hex: 0xC67C4E))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private var profileInformationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Profile Information")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                infoRow(title: "Name", value: userProfile.name)
                infoRow(title: "Gender", value: userProfile.gender)
                infoRow(title: "Age", value: "\(userProfile.age)")
                infoRow(title: "Height", value: "\(userProfile.heightCm) cm")
                infoRow(title: "Current Weight", value: String(format: "%.1f kg", userProfile.weight))
                infoRow(title: "Target Weight", value: String(format: "%.1f kg", userProfile.targetWeight))
                infoRow(title: "Medication", value: userProfile.medicationName)
                infoRow(title: "Dosage", value: userProfile.dosage)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
    
    private func signOut() {
        signInManager.signOut()
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func loadUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let profile):
                self.userProfile = profile
            case .failure(let error):
                print("Error loading user profile: \(error.localizedDescription)")
            }
        }
    }
}

struct ProfileEditView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var tempProfile: UserProfile
    @State private var isNameEmpty: Bool = false
    
    init(userProfile: Binding<UserProfile>) {
        self._userProfile = userProfile
        self._tempProfile = State(initialValue: userProfile.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: 0xEDEDED).edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        personalInformationSection
                        bodyMeasurementsSection
                        medicationSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(Color(hex: 0xC67C4E)),
                trailing: Button("Save") {
                    if !isNameEmpty {
                        saveProfile()
                    }
                }.foregroundColor(Color(hex: 0xC67C4E))
                 .disabled(isNameEmpty)
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            isNameEmpty = tempProfile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private var personalInformationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Personal Information")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Enter your name", text: $tempProfile.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: tempProfile.name) { newValue in
                            isNameEmpty = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        }
                    if isNameEmpty {
                        Text("Name is required")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                
                Text("Gender")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("Gender", selection: $tempProfile.gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                DatePicker("Date of Birth", selection: $tempProfile.dateOfBirth, displayedComponents: .date)
                    .accentColor(Color(hex: 0xC67C4E))
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private var bodyMeasurementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Body Measurements")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                HStack {
                    Text("Height:")
                    Spacer()
                    TextField("cm", value: $tempProfile.heightCm, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    Text("cm")
                }
                
                HStack {
                    Text("Current Weight:")
                    Spacer()
                    TextField("kg", value: $tempProfile.weight, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("kg")
                }
                
                HStack {
                    Text("Target Weight:")
                    Spacer()
                    TextField("kg", value: $tempProfile.targetWeight, formatter: NumberFormatter())
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                    Text("kg")
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medication")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 10) {
                TextField("Medication Name", text: $tempProfile.medicationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Dosage", text: $tempProfile.dosage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
    
    private func saveProfile() {
        FirestoreManager.shared.saveUserProfile(tempProfile) { result in
            switch result {
            case .success:
                userProfile = tempProfile
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                print("Error saving user profile: \(error.localizedDescription)")
            }
        }
    }
}
