import UserNotifications
import SwiftData

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotifications(for item: TrackedItem) {
        let notify3Days = UserDefaults.standard.object(forKey: "notify3Days") as? Bool ?? true
        let notify1Day = UserDefaults.standard.object(forKey: "notify1Day") as? Bool ?? true
        let notifySameDay = UserDefaults.standard.object(forKey: "notifySameDay") as? Bool ?? true

        let itemId = item.name.hashValue

        if notify3Days {
            scheduleNotification(
                itemName: item.name,
                expiryDate: item.expiryDate,
                daysBefore: 3,
                identifier: "freshly-\(itemId)-3d"
            )
        }
        if notify1Day {
            scheduleNotification(
                itemName: item.name,
                expiryDate: item.expiryDate,
                daysBefore: 1,
                identifier: "freshly-\(itemId)-1d"
            )
        }
        if notifySameDay {
            scheduleNotification(
                itemName: item.name,
                expiryDate: item.expiryDate,
                daysBefore: 0,
                identifier: "freshly-\(itemId)-0d"
            )
        }
    }

    func cancelNotifications(for item: TrackedItem) {
        let itemId = item.name.hashValue
        let identifiers = [
            "freshly-\(itemId)-3d",
            "freshly-\(itemId)-1d",
            "freshly-\(itemId)-0d",
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleNotification(itemName: String, expiryDate: Date, daysBefore: Int, identifier: String) {
        guard let triggerDate = Calendar.current.date(byAdding: .day, value: -daysBefore, to: expiryDate) else { return }

        let now = Date.now
        if triggerDate <= now { return }

        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        dateComponents.hour = 9
        dateComponents.minute = 0

        let content = UNMutableNotificationContent()
        content.sound = .default

        if daysBefore == 0 {
            content.title = L("Expires Today")
            content.body = L("\(itemName) expires today. Use it before it's too late!")
        } else {
            content.title = L("Expiring Soon")
            content.body = L("\(itemName) expires in \(daysBefore) day(s).")
        }

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    #if DEBUG
    func sendTestNotifications() {
        Task {
            let granted = await requestPermission()
            guard granted else { return }

            let tests: [(String, String, TimeInterval)] = [
                (L("Expiring Soon"), "Milk " + L("expires in 3 day(s)."), 3),
                (L("Expiring Soon"), "Eggs " + L("expires in 1 day(s)."), 6),
                (L("Expires Today"), "Yogurt " + L("expires today. Use it before it's too late!"), 9),
            ]

            for (title, body, delay) in tests {
                let content = UNMutableNotificationContent()
                content.title = title
                content.body = body
                content.sound = .default

                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
                let request = UNNotificationRequest(
                    identifier: "freshly-test-\(delay)",
                    content: content,
                    trigger: trigger
                )
                try? await UNUserNotificationCenter.current().add(request)
            }
        }
    }
    #endif
}
