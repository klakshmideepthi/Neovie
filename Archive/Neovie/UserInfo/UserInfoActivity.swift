import SwiftUI

struct UserInfoActivity: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedActivity: ActivityLevel?
    @State private var navigateToNextView = false
    
    enum ActivityLevel: String, CaseIterable {
        case sedentary = "Sedentary"
        case lightActivity = "Light Activity"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        
        var description: String {
                switch self {
                case .sedentary:
                    return "Minimal physical activity, mostly sitting or lying down throughout the day"
                case .lightActivity:
                    return "Regular daily activities with occasional light exercise, like a short walk"
                case .moderatelyActive:
                    return "Daily exercise routine equivalent to a brisk walk for about 2 hours"
                case .veryActive:
                    return "Intense daily workouts or physically demanding job, active most of the day"
                }
        }
        
        var icon: String {
            switch self {
            case .sedentary: return "person.fill"
            case .lightActivity: return "figure.walk"
            case .moderatelyActive: return "figure.walk.motion"
            case .veryActive: return "figure.run"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Activity Level")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        activityGrid
                    }
                }
                .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: UserInfoMedication(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
            HStack {
                backButton
                Spacer()
                progressView
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.accentColor.opacity(0.1))
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(AppColors.accentColor)
        }
        .padding(.leading)
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 7 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var activityGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(ActivityLevel.allCases, id: \.self) { activity in
                ActivityButton(activity: activity, isSelected: selectedActivity == activity) {
                    selectedActivity = activity
                }
                .padding(5)  // Add padding around each button
            }
        }
// Add horizontal padding to the grid
    }
    
    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Continue")
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedActivity != nil ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(selectedActivity != nil ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedActivity == nil)
        .simultaneousGesture(TapGesture().onEnded {
            if selectedActivity != nil {
                saveUserProfile()
            }
        })
        .padding(.bottom, UIScreen.main.bounds.height * 0.05) // 5% of screen height for bottom padding
    }
    
    private func saveUserProfile() {
        if let activity = selectedActivity {
            userProfile.activityLevel = activity.rawValue
            
            FirestoreManager.shared.saveUserProfile(userProfile) { result in
                switch result {
                case .success:
                    print("User profile saved successfully")
                    self.navigateToNextView = true
                case .failure(let error):
                    print("Failed to save user profile: \(error.localizedDescription)")
                }
            }
        }
    }
}

struct ActivityButton: View {
    let activity: UserInfoActivity.ActivityLevel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: action) {
                VStack(spacing: 0) {  // Increased spacing between elements
                    Image(systemName: activity.icon)
                        .font(.system(size: 32))
                        .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.6))
                        .frame(height: geometry.size.height * 0.4)  // Adjusted height
                    
                    Text(activity.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.6))
                        .frame(height: geometry.size.height * 0.1)  // Adjusted height
                    
                    Text(activity.description)
                        .font(.caption)
                        .foregroundColor(AppColors.textColor)
                        .multilineTextAlignment(.center)
                        .frame(height: geometry.size.height * 0.5)  // Adjusted height
                }
                .padding(12)  // Increased padding inside the button
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? AppColors.accentColor.opacity(0.1) : AppColors.buttonBackground)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? AppColors.accentColor : Color.gray.opacity(0.3), lineWidth: 4)
                )
                .cornerRadius(12) 
            }
        }
        .aspectRatio(0.9, contentMode: .fit)
    }
}
