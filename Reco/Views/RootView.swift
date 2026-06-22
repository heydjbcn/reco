import SwiftUI
import SwiftData

struct RootView: View {
    var body: some View {
        TabView {
            Tab("Hoy", systemImage: "sun.max.fill") {
                TodayView()
            }
            Tab("Personas", systemImage: "person.2.fill") {
                PeopleListView()
            }
            Tab("Ajustes", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(.accentColor)
    }
}
