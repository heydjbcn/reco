import SwiftUI
import SwiftData

@main
struct RecoApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: Person.self, Interaction.self, ReminderConfig.self
            )
        } catch {
            fatalError("[Reco] No se pudo inicializar SwiftData: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
