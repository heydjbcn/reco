import WidgetKit
import SwiftUI

struct TodayEntry: TimelineEntry {
    let date: Date
    let topPeople: [PersonSnapshot]
}

struct PersonSnapshot: Identifiable, Hashable {
    let id: String
    let name: String
    let relationshipSymbol: String
    let isOverdue: Bool
    let daysSince: Int?
}

struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, topPeople: [
            PersonSnapshot(id: "1", name: "María", relationshipSymbol: "house.fill", isOverdue: true, daysSince: 14),
            PersonSnapshot(id: "2", name: "Javi", relationshipSymbol: "person.2.fill", isOverdue: false, daysSince: 3),
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        // Recargar al inicio de cada hora
        let now = Date()
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: now) ?? now
        let entry = TodayEntry(date: now, topPeople: placeholder(in: context).topPeople)
        let timeline = Timeline(entries: [entry], policy: .after(nextHour))
        completion(timeline)
    }
}

struct TodayWidgetView: View {
    let entry: TodayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
                Text("Hoy en Reco")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
            }

            if entry.topPeople.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                    Text("Al día")
                        .font(.headline)
                    Text("Sin contactos pendientes")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(entry.topPeople.prefix(3)) { p in
                    HStack(spacing: 8) {
                        Image(systemName: p.relationshipSymbol)
                            .font(.caption)
                            .foregroundStyle(p.isOverdue ? .red : .accentColor)
                            .frame(width: 16)
                        Text(p.name)
                            .font(.subheadline)
                            .lineLimit(1)
                        Spacer()
                        if let d = p.daysSince {
                            Text(d == 0 ? "hoy" : "\(d)d")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("nunca")
                                .font(.caption2)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(.background, for: .widget)
    }
}

struct TodayWidget: Widget {
    let kind: String = "TodayWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
        }
        .configurationDisplayName("Hoy en Reco")
        .description("Las personas con las que deberías contactar hoy.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct RecoWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
    }
}
