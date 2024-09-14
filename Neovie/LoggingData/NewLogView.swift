import SwiftUI
import FirebaseAnalytics

struct NewLogView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var weight = ""
    @State private var selectedSideEffect = ""
    @State private var selectedEmotion = ""
    @State private var foodNoise = 3
    @State private var proteinIntake: String = ""
    @State private var showSideEffectTooltip = false
    @State private var showFoodNoiseTooltip = false
    init(viewModel: HomePageViewModel) {
        self.viewModel = viewModel
        _weight = State(initialValue: String(format: "%.1f", viewModel.currentWeight))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    ScrollView {
                        VStack(spacing: 20) {
                            proteinSection
                            sideEffectSection
                            foodNoiseSection
                            emotionSection
                            weightSection
                        }
                        .padding()
                    }
                    
                    Spacer()
                    
                    saveButton
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
            .navigationTitle(getGreeting())
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .foregroundColor(AppColors.accentColor)
                    .font(.system(size: 16, weight: .medium))
            })
            .onTapGesture {
                hideAllTooltips()
            }
        }
        .accentColor(AppColors.accentColor)
    }  
    private func createWeightFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
    
    private var weightSection: some View {
        HStack {
                Text("Current Weight : ")
                    .font(.headline)
                    .foregroundColor(AppColors.accentColor)
                Spacer()
                TextField("Current Weight", text: $weight)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(AppColors.textColor)
                Text("kg")
            }
    }
        
        private var proteinSection: some View {
            HStack {
                Text("Protein Intake : ")
                    .font(.headline)
                    .foregroundColor(AppColors.accentColor)
                Spacer()
                TextField("Protein", text: $proteinIntake)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .foregroundColor(AppColors.textColor)
                Text("g")
            }
        }
    
    private var sideEffectSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing:4) {
                Text("Side Effect")
                    .font(.headline)
                    .foregroundColor(AppColors.accentColor)
                InfoButton(text: "Physical reactions to your medication", showTooltip: $showSideEffectTooltip)
            }
            
            FlexibleView(data: ["None"] + viewModel.sideEffects, spacing: 10, alignment: .leading) { effect in
                Button(action: {
                    selectedSideEffect = effect
                }) {
                    Text(effect)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedSideEffect == effect ? AppColors.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(selectedSideEffect == effect ? .white : AppColors.textColor)
                        .cornerRadius(10)
                }
            }
        }
    }
    
    private var foodNoiseSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing:4) {
                Text("Food Noise")
                    .font(.headline)
                    .foregroundColor(AppColors.accentColor)
                InfoButton(text: "Intensity of food-related thoughts (1-5)", showTooltip: $showFoodNoiseTooltip)
            }
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
                .foregroundColor(AppColors.accentColor)
            
            FlexibleView(data: ["None"] + viewModel.emotions, spacing: 10, alignment: .leading) { emotion in
                Button(action: {
                    selectedEmotion = emotion
                }) {
                    Text(emotion)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedEmotion == emotion ? AppColors.accentColor : Color.gray.opacity(0.2))
                        .foregroundColor(selectedEmotion == emotion ? .white : AppColors.textColor)
                        .cornerRadius(10)
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
        let proteinValue = Double(proteinIntake) ?? 0
        viewModel.logEntry(
            weight: weightValue,
            sideEffect: selectedSideEffect.isEmpty ? "None" : selectedSideEffect,
            emotion: selectedEmotion.isEmpty ? "None" : selectedEmotion,
            foodNoise: foodNoise,
            proteinIntake: proteinValue
        )
        viewModel.proteinManager.addProtein(proteinValue)
        
        Analytics.logEvent("new_log_entry", parameters: [
                    "weight": weightValue,
                    "side_effect": selectedSideEffect.isEmpty ? "None" : selectedSideEffect,
                    "emotion": selectedEmotion.isEmpty ? "None" : selectedEmotion,
                    "food_noise": foodNoise,
                    "protein_intake": proteinValue
                ])
    }
    private func getGreeting() -> String {
            let hour = Calendar.current.component(.hour, from: Date())
            switch hour {
            case 0..<12:
                return "Good Morning"
            case 12..<17:
                return "Good Afternoon"
            default:
                return "Good Evening"
            }
        }
    
    private func hideAllTooltips() {
        showSideEffectTooltip = false
        showFoodNoiseTooltip = false
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

struct InfoButton: View {
    let text: String
    @Binding var showTooltip: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(systemName: "info.circle")
                .foregroundColor(AppColors.accentColor)
                .font(.system(size: 12))
                .onTapGesture {
                    showTooltip.toggle()
                }
            
            if showTooltip {
                Text(text)
                    .font(.caption2)
                    .padding(5)
                    .background(AppColors.secondaryBackgroundColor)
                    .foregroundColor(AppColors.textColor)
                    .cornerRadius(8)
                    .offset(x: 25)
                    .transition(.opacity)
            }
        }
    }
}
