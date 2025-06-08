import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    /// Request notification permission and return result via completion
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ Notification permission granted.")
            } else {
                print("⚠️ Notification permission denied.")
            }
            completion(granted)
        }
    }

    /// Schedule a daily reminder at the specified hour and minute
    func scheduleDailyReminder(hour: Int = 8, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Check-In"
        content.body = "How are you feeling today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyCheckIn", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to schedule notification: \(error)")
            } else {
                print("📆 Daily check-in reminder scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }

    /// Cancel any scheduled daily check-in reminders
    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyCheckIn"])
        print("🗑️ Daily check-in reminder canceled.")
    }

    /// One-time push when user has missed 5 check-ins
    func sendPushAbsenceNotification() {
        let content = UNMutableNotificationContent()
        content.title = "You've Missed 5 Check-Ins"
        content.body = "Please check in or reach out for support. We're here for you."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "absenceAlert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("⚠️ Failed to schedule absence notification: \(error)")
            } else {
                print("🚨 Absence notification sent.")
            }
        }
    }
}
