import SwiftUI
import SwiftData

struct NewPersonView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var nickname = ""
    @State private var relationship: Relationship = .friend
    @State private var importance = 3
    @State private var cadenceDays = 30
    @State private var flexibilityDays = 7
    @State private var email = ""
    @State private var phone = ""
    @State private var notes = ""
    @State private var tagsText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Identidad") {
                    TextField("Nombre", text: $name)
                    TextField("Apodo (opcional)", text: $nickname)
                    Picker("Relación", selection: $relationship) {
                        ForEach(Relationship.allCases) { rel in
                            Label(rel.displayName, systemImage: rel.symbol)
                                .tag(rel)
                        }
                    }
                }

                Section("Recordatorio") {
                    Stepper("Importancia: \(importance)/5", value: $importance, in: 1...5)
                    Stepper("Cada \(cadenceDays) días", value: $cadenceDays, in: 1...365, step: 5)
                    Stepper("Margen ±\(flexibilityDays) días", value: $flexibilityDays, in: 0...60, step: 1)
                }

                Section("Contacto") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Teléfono", text: $phone)
                        .keyboardType(.phonePad)
                }

                Section("Extras") {
                    TextField("Notas", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Tags (separados por coma)", text: $tagsText)
                        .textInputAutocapitalization(.never)
                }
            }
            .navigationTitle("Nueva persona")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let tags = tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let person = Person(
            name: name.trimmingCharacters(in: .whitespaces),
            relationship: relationship,
            importance: importance,
            cadenceDays: cadenceDays,
            flexibilityDays: flexibilityDays,
            nickname: nickname.isEmpty ? nil : nickname,
            email: email.isEmpty ? nil : email,
            phone: phone.isEmpty ? nil : phone,
            notes: notes.isEmpty ? nil : notes,
            tags: tags
        )
        context.insert(person)
        dismiss()
    }
}
