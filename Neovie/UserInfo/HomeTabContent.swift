import SwiftUI

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    @Binding var showingNewLog: Bool
    @Binding var showingWeightLossAdvice: Bool
    @Binding var showingSideEffects: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                todaysOverviewSection
                quickActionsSection
                weightLossAdviceButton
                sideEffectsButton
                progressSection
            }
            .padding()
        }
        .background(AppColors.backgroundColor)
        .overlay(newLogButton, alignment: .bottomTrailing)
    }
    
    private var todaysOverviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Today's Overview")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            HStack {
                Text("Current Weight:").foregroundColor(AppColors.textColor)
                Spacer()
                Text("\(viewModel.currentWeight, specifier: "%.1f") kg").foregroundColor(AppColors.textColor)
            }
            HStack {
                Text("Medication:").foregroundColor(.customTextColor)
                Spacer()
                Text(viewModel.medicationName).foregroundColor(.customTextColor)
            }
            HStack {
                Text("Next Dose:").foregroundColor(.customTextColor)
                Spacer()
                Text(viewModel.nextDose).foregroundColor(.customTextColor)
            }
        }
        .padding()
        .background(AppColors.secondaryBackgroundColor)
        .cornerRadius(10)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick Actions")
                .font(.headline)
                .foregroundColor(.customTextColor)
            
            Button(action: {
                showingNewLog = true
            }) {
                Label("New Log Entry", systemImage: "plus.circle")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(10)
            .foregroundColor(Color(hex: 0xC67C4E))
        }
    }
    
    private var sideEffectsButton: some View {
        Button(action: {
            if viewModel.userProfile != nil {
                showingSideEffects = true
            }
        }) {
            Text("View Side Effects")
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.userProfile != nil ? Color(hex: 0xC67C4E) : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.userProfile == nil)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Progress")
                .font(.headline)
                .foregroundColor(.customTextColor)
            
            WeightProgressChart(data: viewModel.logs)
                .frame(height: 200)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .foregroundColor(AppColors.accentColor)
        }
    }
    
    private var weightLossAdviceButton: some View {
            Button(action: {
                showingWeightLossAdvice = true
            }) {
                Text("View Weight Management Advice")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: 0xC67C4E))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    
    private var newLogButton: some View {
        Button(action: {
            showingNewLog = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(Color(hex: 0xC67C4E))
                .cornerRadius(15)
                .shadow(radius: 3)
        }
        .padding()
    }
}
