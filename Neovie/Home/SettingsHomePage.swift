import SwiftUI
import Firebase

struct SettingsHomeView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var signInManager = GoogleSignInManager.shared
    @Binding var userProfile: UserProfile
    @State private var isEditingProfile = false
    @State private var showingSignOutAlert = false
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
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
                
                if isDeleting {
                    ProgressView("Deleting data...")
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.accentColor))
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
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
        .alert("Delete My Data", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteUserData()
            }
        } message: {
            Text("Are you sure you want to delete all your data? This action cannot be undone.")
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
                print("Sign out button tapped") // Add this line for debugging

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
            
            Button(action: {
                showingDeleteAlert = true
            }) {
                HStack {
                    Label("Delete My Data", systemImage: "trash")
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
                    infoRow(title: "Height", value: "\(formatWeight(userProfile.heightCm)) cm")
                    infoRow(title: "Current Weight", value: "\(formatWeight(userProfile.weight)) kg")
                    infoRow(title: "Target Weight", value: "\(formatWeight(userProfile.targetWeight)) kg")
                    infoRow(title: "Medication", value: userProfile.medicationInfo?.name ?? "Not set")
                    if(userProfile.dosage != "") {
                        infoRow(title: "Dosage", value: userProfile.dosage)
                    }
                    
                }
                .padding()
                .background(AppColors.secondaryBackgroundColor)
                .cornerRadius(10)
                .foregroundColor(AppColors.textColor)
            }
        }
    }
    
    private func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: weight)) ?? String(format: "%.1f", weight)
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
    
    private func deleteUserData() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }
        isDeleting = true
        let db = Firestore.firestore()
        
        // Delete user's weight logs
        deleteCollection(db: db, path: "users/\(userId)/logs")
            
            // Delete user's water intake
        deleteCollection(db: db, path: "users/\(userId)/waterIntake")
            
            // Delete user's protein intake
        deleteCollection(db: db, path: "users/\(userId)/proteinIntake")
        
        // Delete user profile
        db.collection("users").document(userId).delete { error in
            if let error = error {
                print("Error deleting user profile: \(error.localizedDescription)")
            } else {
                print("User profile successfully deleted")
            }
        }
        
        // Delete user's chat history
        db.collection("chatHistory").whereField("userId", isEqualTo: userId).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching chat history: \(error.localizedDescription)")
            } else {
                for document in snapshot!.documents {
                    document.reference.delete()
                }
                print("Chat history successfully deleted")
            }
        }
        
        // After deleting all data, sign out the user
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Give some time for deletions to complete
            self.signInManager.signOut()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func deleteCollection(db: Firestore, path: String, batchSize: Int = 100) {
        let collectionRef = db.collection(path)
        
        // Get the first batch of documents in the collection
        collectionRef.limit(to: batchSize).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            guard !snapshot.isEmpty else {
                print("No documents to delete in \(path)")
                return
            }
            
            let batch = db.batch()
            
            // Add each document to the batch
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            // Commit the batch
            batch.commit { (batchError) in
                if let batchError = batchError {
                    print("Error deleting documents in \(path): \(batchError.localizedDescription)")
                } else {
                    print("Batch of documents in \(path) successfully deleted")
                    
                    // If there are more documents, recursively delete them
                    self.deleteCollection(db: db, path: path, batchSize: batchSize)
                }
            }
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
    @State private var selectedMedication: MedicationInfo? = nil
        @State private var selectedDosage: String = ""
    @State private var showCurrentWeightPicker = false
    @State private var showTargetWeightPicker = false
    @State private var currentWeightWhole: Int = 0
    @State private var currentWeightFraction: Int = 0
    @State private var targetWeightWhole: Int = 0
    @State private var targetWeightFraction: Int = 0
    
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
                
                if showCurrentWeightPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showCurrentWeightPicker = false
                        }
                    
                    WeightPickerView(
                        weight: $tempProfile.weight,
                        weightWhole: $currentWeightWhole,
                        weightFraction: $currentWeightFraction,
                        onSave: {
                            showCurrentWeightPicker = false
                        },
                        onCancel: {
                            // Reset to original values
                            currentWeightWhole = Int(tempProfile.weight)
                            currentWeightFraction = Int((tempProfile.weight - Double(currentWeightWhole)) * 10)
                            showCurrentWeightPicker = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.default, value: showCurrentWeightPicker)
                }
                
                if showTargetWeightPicker {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showTargetWeightPicker = false
                        }
                    
                    WeightPickerView(
                        weight: $tempProfile.targetWeight,
                        weightWhole: $targetWeightWhole,
                        weightFraction: $targetWeightFraction,
                        onSave: {
                            showTargetWeightPicker = false
                        },
                        onCancel: {
                            // Reset to original values
                            targetWeightWhole = Int(tempProfile.targetWeight)
                            targetWeightFraction = Int((tempProfile.targetWeight - Double(targetWeightWhole)) * 10)
                            showTargetWeightPicker = false
                        }
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.default, value: showTargetWeightPicker)
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
            selectedMedication = tempProfile.medicationInfo
            selectedDosage = tempProfile.dosage
            currentWeightWhole = Int(tempProfile.weight)
            currentWeightFraction = Int((tempProfile.weight - Double(currentWeightWhole)) * 10)
            targetWeightWhole = Int(tempProfile.targetWeight)
            targetWeightFraction = Int((tempProfile.targetWeight - Double(targetWeightWhole)) * 10)
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
                    TextField("cm", value: $tempProfile.heightCm, formatter: createWeightFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    Text("cm")
                }
                
                HStack {
                    Text("Current Weight:")
                    Spacer()
                    Button(action: {
                        currentWeightWhole = Int(tempProfile.weight)
                        currentWeightFraction = Int((tempProfile.weight - Double(currentWeightWhole)) * 10)
                        showCurrentWeightPicker = true
                    }) {
                        Text("\(formatWeight(tempProfile.weight))")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(AppColors.backgroundColor)
                            .cornerRadius(8)
                    }
                    Text("kg")
                }
                
                HStack {
                    Text("Target Weight:")
                    Spacer()
                    Button(action: {
                        targetWeightWhole = Int(tempProfile.targetWeight)
                        targetWeightFraction = Int((tempProfile.targetWeight - Double(targetWeightWhole)) * 10)
                        showTargetWeightPicker = true
                    }) {
                        Text("\(formatWeight(tempProfile.targetWeight))")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(AppColors.backgroundColor)
                            .cornerRadius(8)
                    }
                    Text("kg")
                }
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            .foregroundColor(AppColors.textColor)
        }
    }

    private func createWeightFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private var medicationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Medication")
                .font(.headline)
                .foregroundColor(AppColors.textColor.opacity(0.6))
            
            VStack(spacing: 15) {
                CustomPicker(
                    title: "Medication",
                    selection: $selectedMedication,
                    options: [nil] + availableMedications,
                    optionToString: { $0?.name ?? "None" }
                )
                .onChange(of: selectedMedication) { newValue in
                    if newValue == nil {
                        selectedDosage = ""
                    } else {
                        selectedDosage = newValue?.dosages.first ?? ""
                    }
                }
                
                if let medication = selectedMedication {
                    CustomPicker(
                        title: "Dosage",
                        selection: $selectedDosage,
                        options: medication.dosages,
                        optionToString: { $0 }
                    )
                }
            }
            .padding()
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
        }
    }

    struct CustomPicker<T: Hashable>: View {
        let title: String
        @Binding var selection: T
        let options: [T]
        let optionToString: (T) -> String
        
        var body: some View {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppColors.textColor.opacity(0.6))
                
                Menu {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selection = option
                        }) {
                            Text(optionToString(option))
                        }
                    }
                } label: {
                    HStack {
                        Text(optionToString(selection))
                            .foregroundColor(AppColors.textColor)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(AppColors.accentColor)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    private func saveProfile() {
        let group = DispatchGroup()
        var overallSuccess = true
        var overallError: Error?
        
        tempProfile.medicationInfo = selectedMedication
        tempProfile.dosage = selectedMedication == nil ? "" : selectedDosage

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
        
        tempProfile.medicationInfo = selectedMedication
        tempProfile.dosage = selectedDosage

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

    // Add this function to format the weight
    private func formatWeight(_ weight: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: weight)) ?? String(format: "%.1f", weight)
    }
}

struct WeightPickerView: View {
    @Binding var weight: Double
    @Binding var weightWhole: Int
    @Binding var weightFraction: Int
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack {
                HStack(spacing: 0) {
                    Picker("Whole", selection: $weightWhole) {
                        ForEach(20...200, id: \.self) { whole in
                            Text("\(whole)").tag(whole)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 100)
                    .clipped()

                    Text(".")
                        .font(.title)
                        .padding(.horizontal, 5)

                    Picker("Fraction", selection: $weightFraction) {
                        ForEach(0...9, id: \.self) { fraction in
                            Text("\(fraction)").tag(fraction)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(width: 60)
                    .clipped()

                    Text("kg")
                        .font(.headline)
                        .padding(.leading, 10)
                }
                .padding(.bottom)
                
                HStack {
                    Button("Cancel") {
                        onCancel()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(AppColors.accentColor)
                    
                    Button("Save") {
                        weight = Double(weightWhole) + Double(weightFraction) / 10.0
                        onSave()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(AppColors.accentColor)
                }
                .background(Color.gray.opacity(0.2))
            }
            .background(AppColors.secondaryBackgroundColor)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
