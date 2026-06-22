import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var context

    @Query private var configs: [ReminderConfig]
    @State private var notifyHour = 9
    @State private var notificationsOn = false

    private var config: ReminderConfig {
        if let existing = configs.first { return existing }
        let new = ReminderConfig()
        context.insert(new)
        return new
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Notificaciones") {
                    Toggle("Recordatorio diario", isOn: $notificationsOn)
                        .onChange(of: notificationsOn) { _, newValue in
                            Task { await toggleNotifications(enabled: newValue) }
                        }
                    if notificationsOn {
                        Stepper("A las \(notifyHour):00", value: $notifyHour, in: 0...23)
                            .onChange(of: notifyHour) { _, newValue in
                                Task { await reschedule(hour: newValue) }
                            }
                    }
                }

                Section("Acerca de") {
                    LabeledContent("Versión", value: "0.1.0")
                    LabeledContent("Stack", value: "SwiftUI + SwiftData")
                }
            }
            .navigationTitle("Ajustes")
            .task {
                await loadInitial()
            }
        }
    }

    private func loadInitial() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        let granted = settings.authorizationStatus == .authorized
            || settings.authorizationStatus == .provisional

        notificationsOn = granted
        notifyHour = config.notifyHour
        _ = config
    }

    private func toggleNotifications(enabled: Bool) async {
        if enabled {
            let granted = await NotificationService.shared.requestAuthorization()
            if granted {
                await NotificationService.shared.scheduleDailyReminder(
                    hour: notifyHour,
                    body: "Revisa quién necesita tu atención hoy."
                )
            } else {
                notificationsOn = false
            }
        } else {
            NotificationService.shared.cancelDailyReminder()
        }
        config.notificationsAuthorized = enabled
        config.updatedAt = .now
    }

    private func reschedule(hour: Int) async {
        config.notifyHour = hour
        config.updatedAt = .now
        if notificationsOn {
            await NotificationService.shared.scheduleDailyReminder(
                hour: hour,
                body: "Revisa quién necesita tu atención hoy."
            )
        }
    }
}
