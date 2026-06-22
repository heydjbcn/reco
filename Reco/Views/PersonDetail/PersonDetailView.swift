import SwiftUI
import SwiftData

struct PersonDetailView: View {
    @Environment(\.modelContext) private var context
    @Bindable var person: Person

    @State private var showingEdit = false
    @State private var showingLog = false

    var body: some View {
        List {
            Section {
                LabeledContent("Relación", value: person.relationship.displayName)
                LabeledContent("Importancia", value: "\(person.importance)/5")
                LabeledContent("Cadencia", value: "Cada \(person.cadenceDays) días")
                LabeledContent("Margen", value: "±\(person.flexibilityDays) días")
                LabeledContent("Urgencia", value: String(format: "%.2f", UrgencyCalculator.urgency(for: person)))
                if UrgencyCalculator.isOverdue(for: person) {
                    Label("Vencida", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Recordatorio")
            }

            if let email = person.email {
                Section("Contacto") {
                    LabeledContent("Email", value: email)
                }
            }
            if let phone = person.phone {
                Section("Contacto") {
                    LabeledContent("Teléfono", value: phone)
                }
            }
            if let notes = person.notes, !notes.isEmpty {
                Section("Notas") {
                    Text(notes)
                }
            }
            if !person.tags.isEmpty {
                Section("Tags") {
                    Text(person.tags.joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
            }

            Section("Historial") {
                if person.interactions.isEmpty {
                    Text("Sin interacciones registradas.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(person.interactions.sorted(by: { $0.occurredAt > $1.occurredAt })) { inter in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: inter.channel.symbol)
                                    .foregroundStyle(Color.accentColor)
                                Text(inter.channel.displayName)
                                    .fontWeight(.medium)
                                Spacer()
                                Text(inter.occurredAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let summary = inter.summary, !summary.isEmpty {
                                Text(summary)
                                    .font(.callout)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { offsets in
                        let sorted = person.interactions.sorted(by: { $0.occurredAt > $1.occurredAt })
                        for idx in offsets {
                            context.delete(sorted[idx])
                        }
                    }
                }
            }
        }
        .navigationTitle(person.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingLog = true
                    } label: {
                        Label("Marcar contacto", systemImage: "checkmark.circle")
                    }
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        person.archivedAt = .now
                    } label: {
                        Label("Archivar", systemImage: "archivebox")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingLog) {
            LogInteractionView(person: person)
        }
        .sheet(isPresented: $showingEdit) {
            EditPersonView(person: person)
        }
    }
}

struct EditPersonView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var person: Person

    var body: some View {
        NavigationStack {
            Form {
                Section("Identidad") {
                    TextField("Nombre", text: $person.name)
                    TextField("Apodo", text: Binding(
                        get: { person.nickname ?? "" },
                        set: { person.nickname = $0.isEmpty ? nil : $0 }
                    ))
                    Picker("Relación", selection: $person.relationship) {
                        ForEach(Relationship.allCases) { rel in
                            Text(rel.displayName).tag(rel)
                        }
                    }
                }
                Section("Recordatorio") {
                    Stepper("Importancia: \(person.importance)/5", value: $person.importance, in: 1...5)
                    Stepper("Cada \(person.cadenceDays) días", value: $person.cadenceDays, in: 1...365, step: 5)
                    Stepper("Margen ±\(person.flexibilityDays) días", value: $person.flexibilityDays, in: 0...60)
                }
            }
            .navigationTitle("Editar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Listo") {
                        person.updatedAt = .now
                        dismiss()
                    }
                }
            }
        }
    }
}
