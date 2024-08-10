import SwiftUI

struct WeightLossAdviceView: View {
    @StateObject private var viewModel = WeightLossAdviceViewModel()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if viewModel.isLoading {
                        ProgressView("Generating your personalized weight loss plan...")
                    } else if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                    } else if !viewModel.weightLossAdvice.isEmpty {
                        Text("Your Personalized Weight Loss Plan")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(viewModel.weightLossAdvice)
                            .font(.body)
                    } else {
                        Text("We're preparing your personalized weight loss plan. Please wait...")
                            .font(.body)
                    }
                }
                .padding()
            }
            .navigationTitle("Weight Loss Advice")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }.foregroundColor(Color(hex: 0xC67C4E)))
        }
        .onAppear {
            viewModel.fetchWeightLossAdvice()
        }
    }
}
