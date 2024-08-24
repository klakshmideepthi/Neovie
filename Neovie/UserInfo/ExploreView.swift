import SwiftUI

struct ExploreView: View {
    @StateObject private var healthKitManager = HealthKitManager.shared
    
    var body: some View {
        VStack(spacing: 0) {
            
            ScrollView {
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
            
        }
        .background(AppColors.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            healthKitManager.requestAuthorization { success, error in
                if success {
                    healthKitManager.fetchTodaySteps()
                } else if let error = error {
                    print("HealthKit authorization failed: \(error.localizedDescription)")
                }
            }
        }
    }
}
