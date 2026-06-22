import Foundation
import UserNotifications

/// Wrapper sobre UNUserNotificationCenter para notificaciones locales.
@MainActor
final class NotificationService {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            return false
        }
    }

    func scheduleDailyReminder(hour: Int, body: String) async {
        center.removePendingNotificationRequests(withIdentifiers: ["reco.daily.summary"])

        let content = UNMutableNotificationContent()
        content.title = "Reco"
        content.body = body
        content.sound = .default

        var components = DateComponents()
        components.hour = hour
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: "reco.daily.summary",
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("[NotificationService] error scheduling daily: \(error)")
        }
    }

    func cancelDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["reco.daily.summary"])
    }

    func sendImmediate(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "reco.immediate.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        try? await center.add(request)
    }
}
