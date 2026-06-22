import SwiftUI
import SwiftData

struct LogInteractionView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    let person: Person

    @State private var channel: Channel = .message
    @State private var summary = ""
    @State private var occurredAt = Date()
    @State private var followUpInDays: Int = 0

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.15))
                            Text(initials)
                                .font(.headline)
                                .foregroundStyle(Color.accentColor)
                        }
                        .frame(width: 48, height: 48)
                        VStack(alignment: .leading) {
                            Text(person.name).font(.headline)
                            Text(person.relationship.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Canal") {
                    Picker("Canal", selection: $channel) {
                        ForEach(Channel.allCases) { ch in
                            Label(ch.displayName, systemImage: ch.symbol).tag(ch)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Cuándo") {
                    DatePicker("Fecha", selection: $occurredAt, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Contexto (opcional)") {
                    TextField("¿De qué hablasteis?", text: $summary, axis: .vertical)
                        .lineLimit(3...8)
                }

                Section("Seguimiento (opcional)") {
                    Stepper(
                        followUpInDays == 0 ? "Sin seguimiento" : "Recordarme en \(followUpInDays) días",
                        value: $followUpInDays,
                        in: 0...180,
                        step: 7
                    )
                }
            }
            .navigationTitle("Marcar contacto")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                }
            }
        }
    }

    private var initials: String {
        let parts = person.name.split(separator: " ").prefix(2)
        return parts.map { String($0.first ?? "?") }.joined().uppercased()
    }

    private func save() {
        let interaction = Interaction(
            person: person,
            channel: channel,
            summary: summary.isEmpty ? nil : summary,
            occurredAt: occurredAt,
            followUpInDays: followUpInDays > 0 ? followUpInDays : nil
        )
        context.insert(interaction)
        person.updatedAt = .now
        dismiss()
    }
}
