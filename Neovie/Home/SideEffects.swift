import SwiftUI
import Firebase

struct MedicationSideEffects {
    let common: String
    let serious: String
    let warning: String
    let usage: String
    let note: String
}

struct SideEffectsView: View {
    @Binding var userProfile: UserProfile
    @State private var sideEffects: MedicationSideEffects?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var currentMedicationName: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 20) {
                                if isLoading {
                                    ProgressView()
                                } else if let error = errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                } else if let sideEffects = sideEffects {
                                    sideEffectSection(title: "Common Side Effects", content: sideEffects.common, geometry: geometry)
                                    sideEffectSection(title: "Serious Side Effects", content: sideEffects.serious, geometry: geometry)
                                    sideEffectSection(title: "Warning", content: sideEffects.warning, geometry: geometry)
                                    sideEffectSection(title: "Usage", content: sideEffects.usage, geometry: geometry)
                                    sideEffectSection(title: "Note", content: sideEffects.note, geometry: geometry)
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Side Effects: \(currentMedicationName)", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(AppColors.accentColor)
            })
        }
        .onAppear {
            updateCurrentMedicationName()
            loadSideEffects()
        }
    }

    private func sideEffectSection(title: String, content: String, geometry: GeometryProxy) -> some View {
        let boxWidth = geometry.size.width * 0.9 // 90% of screen width

        return VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.accentColor)
            Text(content)
                .font(.body)
                .foregroundColor(AppColors.textColor)
        }
        .padding()
        .frame(width: boxWidth)
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(10)
    }

    private func updateCurrentMedicationName() {
        currentMedicationName = userProfile.medicationName
    }

    private func loadSideEffects() {
        let medicationName = userProfile.medicationName
        
        isLoading = true
        errorMessage = nil
        sideEffects = nil

        FirestoreManager.shared.getMedicationSideEffects(medicationName: medicationName) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let effects):
                    self.sideEffects = effects
                case .failure(let error):
                    self.errorMessage = "Failed to load side effects: \(error.localizedDescription)"
                    print("Detailed error: \(error)")
                }
            }
        }
    }
}
