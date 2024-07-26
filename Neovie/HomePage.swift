import SwiftUI
import Firebase

struct HomePage: View {
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Today's Overview")) {
                    HStack {
                        Text("Current Weight:")
                        Spacer()
                    }
                    HStack {
                        Text("Medication:")
                        Spacer()

                    }
                    HStack {
                        Text("Next Dose:")
                        Spacer()

                    }
                }
                
                Section(header: Text("Quick Actions")) {
                    Button(action: {
                        // TODO: Implement log weight action
                    }) {
                        Label("Log Weight", systemImage: "scale.3d")
                    }
                    
                    Button(action: {
                        // TODO: Implement log side effect action
                    }) {
                        Label("Log Side Effect", systemImage: "bandage")
                    }
                    
                    Button(action: {
                        // TODO: Implement log emotion action
                    }) {
                        Label("Log Emotion", systemImage: "heart")
                    }
                }
                
                Section(header: Text("Progress")) {
                    // TODO: Implement progress chart
                    Text("Progress chart coming soon")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: Implement settings action
                    }) {
                        Image(systemName: "gear")
                    }
                }
            }
        }
        .onAppear {
            
        }
    }
}

class HomePageViewModel: ObservableObject {
    @Published var currentWeight: Double = 0.0
    @Published var medicationName: String = ""
    @Published var nextDose: String = ""
    
    func fetchUserData() {
        FirestoreManager.shared.getUserProfile { result in
            switch result {
            case .success(let userProfile):
                DispatchQueue.main.async {
                    self.currentWeight = userProfile.weight
                    self.medicationName = userProfile.medicationName
                    // TODO: Calculate next dose based on medication schedule
                    self.nextDose = "Calculate based on schedule"
                }
            case .failure(let error):
                print("Error fetching user data: \(error.localizedDescription)")
            }
        }
    }
}
