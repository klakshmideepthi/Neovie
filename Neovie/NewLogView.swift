import SwiftUI

struct NewLogView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var weight = ""
    @State private var selectedSideEffect = ""
    @State private var selectedEmotion = ""
    @State private var intensity = 3
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Log Weight")) {
                    TextField("Weight (kg)", text: $weight)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Log Side Effect")) {
                    Picker("Side Effect", selection: $selectedSideEffect) {
                        ForEach(viewModel.sideEffects, id: \.self) { effect in
                            Text(effect)
                        }
                    }
                }
                
                Section(header: Text("Log Emotion")) {
                    Picker("Emotion", selection: $selectedEmotion) {
                        ForEach(viewModel.emotions, id: \.self) { emotion in
                            Text(emotion)
                        }
                    }
                    
                    Stepper(value: $intensity, in: 1...5) {
                        Text("Intensity: \(intensity)")
                    }
                }
                
                Button("Save") {
                    if let weightValue = Double(weight) {
                        viewModel.logWeight(weightValue)
                    }
                    if !selectedSideEffect.isEmpty {
                        let sideEffect = SideEffect(type: selectedSideEffect, severity: intensity, date: Date())
                        viewModel.logSideEffect(sideEffect)
                    }
                    if !selectedEmotion.isEmpty {
                        let emotion = Emotion(type: selectedEmotion, intensity: intensity, date: Date())
                        viewModel.logEmotion(emotion)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("New Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
