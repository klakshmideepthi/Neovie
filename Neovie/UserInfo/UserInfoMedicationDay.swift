import SwiftUI

struct UserInfoMedicationDay: View {
    @Binding var userProfile: UserProfile
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDay: String = ""
    @State private var selectedTime = Date()
    @State private var navigateToNextView = false
    
    let daysOfWeek = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    
    var body: some View {
        NavigationView {
            VStack(alignment:.leading,spacing: 0) {
                progressBar
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("When do you take your medication?")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        daySelectionView
                        
                        timeSelectionView
                    }
                }
                .padding()
                
                Spacer()
                
                continueButton
                
                NavigationLink(destination: BMIAndProteinCalculationView(userProfile: $userProfile), isActive: $navigateToNextView) {
                    EmptyView()
                }
            }
            .background(AppColors.backgroundColor)
            .foregroundColor(AppColors.textColor)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
    }
    
    private var progressView: some View {
        HStack {
            ForEach(0..<10) { index in
                Rectangle()
                    .fill(index < 10 ? AppColors.accentColor : Color.gray.opacity(0.3))
                    .frame(height: 4)
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.6, height: 10)
    }
    
    private var progressBar: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: UIScreen.main.bounds.height * 0.07)
            HStack {
                Spacer()
                progressView
                Spacer()
                skipButton
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(AppColors.accentColor.opacity(0.1))
    }
    
    private var daySelectionView: some View {
        HStack(spacing: 10) {
            ForEach(daysOfWeek, id: \.self) { day in
                DayCircle(day: day, isSelected: selectedDay == day) {
                    selectedDay = day
                }
            }
        }
        .padding()
    }
    
    private var timeSelectionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time")
                .font(.headline)
            
            DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
        }
    }
    
    private var continueButton: some View {
        Button(action: {
            saveUserProfile()
        }) {
            Text("Done!")
                .frame(maxWidth: .infinity)
                .padding()
                .background(!selectedDay.isEmpty ? AppColors.accentColor : AppColors.accentColor.opacity(0.3))
                .foregroundColor(!selectedDay.isEmpty ? .white : .white.opacity(0.5))
                .cornerRadius(10)
        }
        .padding(.horizontal)
        .disabled(selectedDay.isEmpty)
        .padding(.bottom, UIScreen.main.bounds.height * 0.05)
    }
    
    private var skipButton: some View {
        Button(action: {
            navigateToNextView = true
        }) {
            Text("Skip")
                .foregroundColor(AppColors.accentColor)
        }
    }
    
    private func saveUserProfile() {
        userProfile.dosageDay = selectedDay
        userProfile.dosageTime = selectedTime
        
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

struct DayCircle: View {
    let day: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? AppColors.accentColor : Color.clear)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? AppColors.accentColor : AppColors.textColor.opacity(0.3), lineWidth: 2)
                    )
                
                Text(day)
                    .foregroundColor(isSelected ? .white : AppColors.textColor)
                    .font(.system(size: 14, weight: .medium))
            }
            .frame(width: 40, height: 40)
        }
    }
}
