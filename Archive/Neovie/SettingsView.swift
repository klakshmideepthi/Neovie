import SwiftUI
import Firebase

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var signInManager = GoogleSignInManager.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Account")) {
                    NavigationLink(destination: ProfileView()) {
                        Label("Profile", systemImage: "person.circle")
                    }
                    
                    Button(action: signOut) {
                        Label("Sign Out", systemImage: "arrow.right.square")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func signOut() {
        signInManager.signOut()
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProfileView: View {
    @ObservedObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        List {
            Section(header: Text("Personal Information")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(viewModel.userProfile.name)
                }
                HStack {
                    Text("Gender")
                    Spacer()
                    Text(viewModel.userProfile.gender)
                }
                HStack {
                    Text("Date of Birth")
                    Spacer()
                    Text(viewModel.formattedDateOfBirth)
                }
            }
            
            Section(header: Text("Medication")) {
                HStack {
                    Text("Medication Name")
                    Spacer()
                    Text(viewModel.userProfile.medicationName)
                }
                HStack {
                    Text("Dosage")
                    Spacer()
                    Text(viewModel.userProfile.dosage)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Profile")
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }
}

class ProfileViewModel: ObservableObject {
    @Published var userProfile = UserProfile()
    
    var formattedDateOfBirth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: userProfile.dateOfBirth)
    }
    
    func fetchUserProfile() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let profile):
                DispatchQueue.main.async {
                    self.userProfile = profile
                }
            case .failure(let error):
                print("Error fetching user profile: \(error.localizedDescription)")
            }
        }
    }
}
