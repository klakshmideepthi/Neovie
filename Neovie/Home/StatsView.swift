import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: HomePageViewModel
    @StateObject private var healthKitManager = HealthKitManager.shared
    @State private var showingLogsView = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button(action: {
                    showingLogsView = true
                }) {
                    Text("View Logs")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.accentColor)
                        .cornerRadius(15)
                }
                .padding(.horizontal)
                
                if healthKitManager.isStepsAuthorized {
                    stepsSection
                }
                
                waterIntakeSection
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            fetchData()
        }
        .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showingLogsView) {
            LogsView(viewModel: viewModel)
        }
    }
    
    private func fetchData() {
        healthKitManager.requestAuthorization { success, error in
            if success {
                healthKitManager.fetchTodaySteps()
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
        viewModel.fetchWeeklyWaterIntake()
    }
    
    private var stepsSection: some View {
        VStack(alignment: .center) {
            Text("Today's Steps")
                .font(.title)
                .padding()
            
            Text("\(healthKitManager.steps)")
                .font(.system(size: 48, weight: .bold))
                .padding()
            
            Button("Refresh Steps") {
                healthKitManager.fetchTodaySteps()
            }
            .padding()
        }
    }
    
    private var waterIntakeSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Water Intake")
                .font(.title2)
                .fontWeight(.bold)
            
            WaterIntakeGraphView(waterIntakes: viewModel.weeklyWaterIntake)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(AppColors.secondaryBackgroundColor)
                .padding()
                .cornerRadius(15)
            
        }
        .padding()
        .frame(maxWidth: .infinity)
        
    }
}
