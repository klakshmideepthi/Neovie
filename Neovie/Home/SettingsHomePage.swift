import SwiftUI
import Firebase

struct SettingsHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var signInManager = GoogleSignInManager.shared
    @Binding var userProfile: UserProfile
    @State private var isEditingProfile = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
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
            }.foregroundColor(AppColors.accentColor))
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
                .foregroundColor(AppColors.textColor.opacity(0.6))
            
            Button(action: {
                isEditingProfile = true
            }) {
                HStack {
                    Label("Edit Profile", systemImage: "person.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(AppColors.accentColor)
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            
            NavigationLink(destination: AboutView()) {
                HStack {
                    Label("About", systemImage: "info.circle")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(AppColors.accentColor)
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            
            NavigationLink(destination: PrivacyPolicyView()) {
                HStack {
                    Label("Privacy Policy", systemImage: "lock.shield")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(AppColors.accentColor)
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            
            Button(action: {
                showingSignOutAlert = true
            }) {
                HStack {
                    Label("Sign Out", systemImage: "arrow.right.square")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(AppColors.accentColor)
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
        }
    }
    
    private var profileInformationSection: some View {
        Group {
            VStack(alignment: .leading, spacing: 10) {
                Text("Profile Information")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor.opacity(0.6))
                
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
                .background(AppColors.secondaryBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(AppColors.textColor)
            }
        }
        
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(AppColors.textColor.opacity(0.6))
            Spacer()
            Text(value)
                .foregroundColor(AppColors.textColor)
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
                    DispatchQueue.main.async {
                        self.userProfile = profile
                    }
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
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
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
                            }.foregroundColor(AppColors.accentColor),
                            trailing: Button("Save") {
                                if !isNameEmpty {
                                    saveProfile()
                                }
                            }.foregroundColor(AppColors.accentColor)
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
                .foregroundColor(AppColors.textColor.opacity(0.6))
            
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Name")
                        .font(.caption)
                        .foregroundColor(AppColors.textColor.opacity(0.6))
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
                    .foregroundColor(AppColors.textColor.opacity(0.6))
                
                Picker("Gender", selection: $tempProfile.gender) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                DatePicker("Date of Birth", selection: $tempProfile.dateOfBirth, displayedComponents: .date)
                    .accentColor(AppColors.accentColor)
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
        }
    }
    
    private var bodyMeasurementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Body Measurements")
                .font(.headline)
                .foregroundColor(AppColors.textColor.opacity(0.6))
            
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
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            .foregroundColor(AppColors.textColor)
        }
    }
    
    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medication")
                .font(.headline)
                .foregroundColor(AppColors.textColor.opacity(0.6))
            
            VStack(spacing: 10) {
                TextField("Medication Name", text: $tempProfile.medicationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Dosage", text: $tempProfile.dosage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
        }
    }
    
    private func saveProfile() {
        let group = DispatchGroup()
        var overallSuccess = true
        var overallError: Error?

        // Update fields that require recalculation
        if tempProfile.weight != userProfile.weight {
            group.enter()
            FirestoreManager.shared.updateUserProfileWithRecalculation(field: "weight", value: tempProfile.weight) { result in
                switch result {
                case .success:
                    print("Weight updated and BMI/protein goal recalculated")
                case .failure(let error):
                    overallSuccess = false
                    overallError = error
                    print("Error updating weight: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        if tempProfile.heightCm != userProfile.heightCm {
            group.enter()
            FirestoreManager.shared.updateUserProfileWithRecalculation(field: "heightCm", value: tempProfile.heightCm) { result in
                switch result {
                case .success:
                    print("Height updated and BMI/protein goal recalculated")
                case .failure(let error):
                    overallSuccess = false
                    overallError = error
                    print("Error updating height: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        if tempProfile.activityLevel != userProfile.activityLevel {
            group.enter()
            FirestoreManager.shared.updateUserProfileWithRecalculation(field: "activityLevel", value: tempProfile.activityLevel) { result in
                switch result {
                case .success:
                    print("Activity level updated and protein goal recalculated")
                case .failure(let error):
                    overallSuccess = false
                    overallError = error
                    print("Error updating activity level: \(error.localizedDescription)")
                }
                group.leave()
            }
        }

        // Update other fields that don't require recalculation
        group.enter()
        FirestoreManager.shared.saveUserProfile(tempProfile) { result in
            switch result {
            case .success:
                print("Other profile fields updated successfully")
            case .failure(let error):
                overallSuccess = false
                overallError = error
                print("Error saving other profile fields: \(error.localizedDescription)")
            }
            group.leave()
        }

        group.notify(queue: .main) {
            if overallSuccess {
                self.userProfile = self.tempProfile  // Update the binding
                self.presentationMode.wrappedValue.dismiss()
            } else {
                // Handle the error, maybe show an alert to the user
                print("Error saving profile: \(overallError?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    }
