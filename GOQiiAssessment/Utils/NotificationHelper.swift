import UserNotifications

class NotificationManager {

    static let shared = NotificationManager()

    private init() {}

    func scheduleDailyHydrationReminder(hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Hydration Reminder"
        content.body = "It's time to drink water and stay hydrated!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "hydrationReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error adding notification request: \(error.localizedDescription)")
            }
        }
    }

    func removeScheduledNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
