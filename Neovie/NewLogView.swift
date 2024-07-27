import SwiftUI

struct NewLogView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var weight = ""
    @State private var selectedSideEffect = ""
    @State private var selectedEmotion = ""
    @State private var foodNoise = 3
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Weight")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Side Effect")) {
                    Picker("Side Effect", selection: $selectedSideEffect) {
                        Text("None").tag("")
                        ForEach(viewModel.sideEffects, id: \.self) { effect in
                            Text(effect)
                        }
                    }
                }
                
                Section(header: Text("Food Noise")) {
                    Stepper(value: $foodNoise, in: 1...5) {
                        Text("Food Noise: \(foodNoise)")
                    }
                }
                
                Section(header: Text("Emotion")) {
                    Picker("Emotion", selection: $selectedEmotion) {
                        Text("None").tag("")
                        ForEach(viewModel.emotions, id: \.self) { emotion in
                            Text(emotion)
                        }
                    }
                }
                
                Button("Save") {
                    saveLog()
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(weight.isEmpty)
            }
            .navigationTitle("New Log Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveLog() {
        guard let weightValue = Double(weight) else { return }
        viewModel.logEntry(
            weight: weightValue,
            sideEffect: selectedSideEffect.isEmpty ? "None" : selectedSideEffect,
            emotion: selectedEmotion.isEmpty ? "None" : selectedEmotion,
            foodNoise: foodNoise
        )
    }
}

