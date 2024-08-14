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
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 20) {
                            weightSection
                            sideEffectSection
                            foodNoiseSection
                            emotionSection
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    saveButton
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle("New Log Entry")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(AppColors.accentColor))
        }
        .accentColor(AppColors.accentColor)
    }
    
    private var weightSection: some View {
        VStack(alignment: .leading) {
            Text("Weight")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            TextField("Weight (kg)", text: $weight)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(AppColors.textColor)
        }
    }
    
    private var sideEffectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Side Effect")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            FlexibleView(data: ["None"] + viewModel.sideEffects, spacing: 10, alignment: .leading) { effect in
                Button(action: {
                    selectedSideEffect = effect
                }) {
                    Text(effect)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedSideEffect == effect ? AppColors.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(selectedSideEffect == effect ? .white : AppColors.textColor)
                        .cornerRadius(20)
                }
            }
        }
    }
    
    private var foodNoiseSection: some View {
        VStack(alignment: .leading) {
            Text("Food Noise")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            Stepper(value: $foodNoise, in: 1...5) {
                Text("Food Noise: \(foodNoise)")
                    .foregroundColor(AppColors.textColor)
            }
        }
    }
    
    private var emotionSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Emotion")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            FlexibleView(data: ["None"] + viewModel.emotions, spacing: 10, alignment: .leading) { emotion in
                Button(action: {
                    selectedEmotion = emotion
                }) {
                    Text(emotion)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEmotion == emotion ? AppColors.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(selectedEmotion == emotion ? .white : AppColors.textColor)
                        .cornerRadius(20)
                }
            }
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            saveLog()
            presentationMode.wrappedValue.dismiss()
        }) {
            Text("Save")
                .frame(maxWidth: .infinity)
                .padding()
                .background(weight.isEmpty ? Color.gray.opacity(0.2) : AppColors.accentColor  )
                .foregroundColor(weight.isEmpty ? AppColors.textColor.opacity(0.2) : AppColors.textColor)
                .cornerRadius(25)
        }
        .disabled(weight.isEmpty)
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

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State private var availableWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: alignment, vertical: .center)) {
            Color.clear
                .frame(height: 1)
                .readSize { size in
                    availableWidth = size.width
                }
            
            _FlexibleView(
                availableWidth: availableWidth,
                data: data,
                spacing: spacing,
                alignment: alignment,
                content: content
            )
        }
    }
}

struct _FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let availableWidth: CGFloat
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    @State var elementsSize: [Data.Element: CGSize] = [:]
    
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { rowElements in
                HStack(spacing: spacing) {
                    ForEach(rowElements, id: \.self) { element in
                        content(element)
                            .fixedSize()
                            .readSize { size in
                                elementsSize[element] = size
                            }
                    }
                }
            }
        }
    }
    
    func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRow = 0
        var remainingWidth = availableWidth

        for element in data {
            let elementSize = elementsSize[element, default: CGSize(width: availableWidth, height: 1)]
            
            if remainingWidth - (elementSize.width + spacing) >= 0 {
                rows[currentRow].append(element)
            } else {
                currentRow = currentRow + 1
                rows.append([element])
                remainingWidth = availableWidth
            }
            
            remainingWidth = remainingWidth - (elementSize.width + spacing)
        }
        
        return rows
    }
}

extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
