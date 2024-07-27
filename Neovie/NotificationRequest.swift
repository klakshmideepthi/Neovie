import SwiftUI
import UserNotifications

struct NotificationRequest: View {
    @State private var isNotificationsEnabled = false
    @State private var navigateToHomePage = false
    @State private var showAlert = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.scenePhase) var scenePhase

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

                Text("Enable notifications to receive reminders for logging your progress and taking your medication.")
                    .multilineTextAlignment(.center)
                    .padding()

                VStack(spacing: 20) {
                    Button(action: {
                        requestNotificationPermission()
                    }) {
                        Text("Allow")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        navigateToHomePage = true
                    }) {
                        Text("Skip")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .background(Color.white)
            .edgesIgnoringSafeArea(.all)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Notifications Disabled"),
                    message: Text("To enable notifications, go to Settings > Notifications > Neovie and turn on Allow Notifications."),
                    primaryButton: .default(Text("Open Settings")) {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsUrl)
                        }
                    },
                    secondaryButton: .cancel(Text("Skip")) {
                        navigateToHomePage = true
                    }
                )
            }
            .navigationDestination(isPresented: $navigateToHomePage) {
                HomePage().navigationBarBackButtonHidden(true)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                checkNotificationStatus()
            }
        }
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
                    showAlert = true
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
