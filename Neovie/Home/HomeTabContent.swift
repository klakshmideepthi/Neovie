import SwiftUI

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    @Binding var showingNewLog: Bool
    @Binding var showingWeightLossAdvice: Bool
    @Binding var showingSideEffects: Bool
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Overview").tag(0)
                Text("Water").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                ScrollView {
                    VStack(spacing: 20) {
                        BannerView(bannerContents: viewModel.bannerContents, actionHandler: handleBannerAction)
                        quickActionsSection
                        weightLossAdviceButton
                        sideEffectsButton
                        progressSection
                    }
                    .padding()
                }
            } else {
                WaterView()
            }
        }
        .background(AppColors.backgroundColor)
        .overlay(newLogButton, alignment: .bottomTrailing)
        .onAppear {
            viewModel.fetchUserData()
            viewModel.fetchBannerContents()
        }
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
    
    private func handleBannerAction(_ identifier: String) {
        switch identifier {
        case "show_side_effects":
            showingSideEffects = true
        case "show_weight_loss_advice":
            showingWeightLossAdvice = true
        case "show_new_log":
            showingNewLog = true
        default:
            print("Unknown action: \(identifier)")
        }
    }
}
