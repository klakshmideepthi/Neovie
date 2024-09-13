import Foundation

class WaterReminderManager: ObservableObject {
    @Published var shouldShowWaterReminder: Bool = false
    
    init() {
        setupNotificationObserver()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .waterReminderReceived,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.shouldShowWaterReminder = true
        }
    }
}

extension Notification.Name {
    static let waterReminderReceived = Notification.Name("waterReminderReceived")
}
