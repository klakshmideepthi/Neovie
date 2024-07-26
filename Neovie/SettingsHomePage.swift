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
            List {
                Section(header: Text("Account")) {
                    Button(action: {
                        isEditingProfile = true
                    }) {
                        Label("Edit Profile", systemImage: "person.circle")
                    }
                    
                    Button(action: {
                        showingSignOutAlert = true
                    }) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
                
                Section(header: Text("Profile Information")) {
                    Text("Name: \(userProfile.name)")
                    Text("Gender: \(userProfile.gender)")
                    Text("Age: \(userProfile.age)")
                    Text("Height: \(userProfile.heightCm) cm")
                    Text("Current Weight: \(String(format: "%.1f", userProfile.weight)) kg")
                    Text("Target Weight: \(String(format: "%.1f", userProfile.targetWeight)) kg")
                    Text("Medication: \(userProfile.medicationName)")
                    Text("Dosage: \(userProfile.dosage)")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
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
        }
        .onAppear {
            loadUserProfile()
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
    
    init(userProfile: Binding<UserProfile>) {
        self._userProfile = userProfile
        self._tempProfile = State(initialValue: userProfile.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $tempProfile.name)
                    Picker("Gender", selection: $tempProfile.gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    DatePicker("Date of Birth", selection: $tempProfile.dateOfBirth, displayedComponents: .date)
                }
                
                Section(header: Text("Body Measurements")) {
                    HStack {
                        Text("Height:")
                        Spacer()
                        TextField("cm", value: $tempProfile.heightCm, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                        Text("cm")
                    }
                    HStack {
                        Text("Current Weight:")
                        Spacer()
                        TextField("kg", value: $tempProfile.weight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        Text("kg")
                    }
                    HStack {
                        Text("Target Weight:")
                        Spacer()
                        TextField("kg", value: $tempProfile.targetWeight, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                        Text("kg")
                    }
                }
                
                Section(header: Text("Medication")) {
                    TextField("Medication Name", text: $tempProfile.medicationName)
                    TextField("Dosage", text: $tempProfile.dosage)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                saveProfile()
            })
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
