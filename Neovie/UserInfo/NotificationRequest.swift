import SwiftUI
import UserNotifications

struct NotificationRequest: View {
    @State private var isNotificationsEnabled = false
    @State private var navigateToHomePage = false
    @Environment(\.presentationMode) var presentationMode
    @State private var isActive = false // New state for navigation

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer()
                
                if let uiImage = UIImage(named: "Icon4") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                } else {
                    Text("Image not found")
                        .foregroundColor(.red)
                }

                Text("Help us keep you updated")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(AppColors.textColor)

                Text("Enable notifications to receive reminders for logging your progress and taking your medication.")
                    .multilineTextAlignment(.center)
                    .padding()
                    .foregroundColor(AppColors.textColor)

                VStack(spacing: 20) {
                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        Text("Allow")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        navigateToHomePage = true
                    }) {
                        Text("Skip")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(AppColors.secondaryBackgroundColor)
                            .foregroundColor(AppColors.textColor)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()

                NavigationLink(destination: HomePage().navigationBarBackButtonHidden(true), isActive: $navigateToHomePage) {
                    EmptyView()
                }
            }
            .padding()
            .background(AppColors.backgroundColor)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .onAppear(perform: checkNotificationStatus)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                    isNotificationsEnabled = true
                    navigateToHomePage = true
                } else {
                    print("Notification permission denied")
                    // The user denied permission, but we'll still navigate to the home page
                    navigateToHomePage = true
                }
            }
        }
    }

    private func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    isNotificationsEnabled = true
                    navigateToHomePage = true
                }
            }
        }
    }
}
