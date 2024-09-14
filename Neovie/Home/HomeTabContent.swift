import SwiftUI
import Firebase

struct HomeTabContent: View {
    @ObservedObject var viewModel: HomePageViewModel
    @Binding var showingSettingsHome: Bool
    @Binding var showingNewLog: Bool
    @Binding var showingWeightLossAdvice: Bool
    @Binding var showingSideEffects: Bool
    
    // Add this new state variable
    @State private var currentAffirmation: String = ""
    
    var body: some View {
        ScrollView {
            RefreshControl(
                coordinateSpace: .named("RefreshControl"),
                isRefreshing: $viewModel.isRefreshing,
                onRefresh: {
                    viewModel.refreshData()
                }
            )
            VStack(spacing: 20) {
                
                if let userProfile = viewModel.userProfile {
                    if viewModel.showMedicationReminder {
                        MedicationReminderWidget(
                            medicationName: userProfile.medicationInfo?.name ?? "Your medication",
                            dosage: userProfile.dosage,
                            onSkip: {
                                viewModel.updateShowMedicationReminder(false)
                            },
                            onTaken: {
                                viewModel.updateShowMedicationReminder(false)
                            }
                        )
                    }
                }       
                if viewModel.isBannersLoaded {
                    BannerView(bannerContents: viewModel.bannerContents, actionHandler: handleBannerAction, viewModel: viewModel)
                }
                PositiveAffirmationWidget(affirmation: currentAffirmation)
                WeightLossPlannerWidget(onKnowMoreTapped: {
                    showingWeightLossAdvice = true
                })
                
                WaterView()
                ProteinView(proteinManager: viewModel.proteinManager)
                BMIView(viewModel: viewModel)
//                quickActionsSection
//                weightLossAdviceButton
//                sideEffectsButton
            }
            .padding()
        }
        .coordinateSpace(name: "RefreshControl")
        .background(AppColors.backgroundColor)
        .onAppear {
            viewModel.fetchUserData()
            viewModel.fetchBannerContents()
            viewModel.setupMedicationReminderListener()
            currentAffirmation = getRandomAffirmation() // Add this line
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
    
    // Add this new function to get a random affirmation
    private func getRandomAffirmation() -> String {
        let affirmations = [
            "You are capable of amazing things.",
            "Every day, you're getting stronger and healthier.",
            "Your journey is inspiring and unique.",
            "You have the power to create positive change.",
            "Your efforts are paying off - keep going!",
            "You're making progress, even when you can't see it.",
            "Your health journey matters, and so do you.",
            "Small steps lead to big changes - you've got this!",
            "You're resilient and can overcome any challenge.",
            "Your body is strong, and your mind is stronger."
        ]
        return affirmations.randomElement() ?? "You are doing great!"
    }
}

struct RefreshControl: View {
    var coordinateSpace: CoordinateSpace
    @Binding var isRefreshing: Bool
    var onRefresh: () -> Void

    @State private var refresh: Bool = false

    var body: some View {
        GeometryReader { geo in
            if (geo.frame(in: coordinateSpace).midY > 50) {
                Spacer()
                    .onAppear {
                        if !refresh {
                            onRefresh()
                        }
                        refresh = true
                    }
            } else if (geo.frame(in: coordinateSpace).maxY < 1) {
                Spacer()
                    .onAppear {
                        refresh = false
                    }
            }
            ZStack(alignment: .center) {
                if isRefreshing {
                    ProgressView()
                }
            }.frame(width: geo.size.width)
        }.padding(.top, -50)
    }
}

extension Notification.Name {
    static let medicationReminderReceived = Notification.Name("medicationReminderReceived")
}

// Add this new widget struct
struct PositiveAffirmationWidget: View {
    let affirmation: String
    
    var body: some View {
        VStack(spacing:20) {
            Spacer()
            Text("Today's Affirmation")
                .font(.headline)
                .fontWeight(.heavy)
            Text(affirmation)
                .font(.body)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.accentColor)
        .foregroundColor(AppColors.textColor)
        .cornerRadius(10)
    }
}
