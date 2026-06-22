import SwiftUI
import SwiftData
import Contacts

struct PeopleListView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Person> { $0.archivedAt == nil }, sort: \Person.name)
    private var people: [Person]

    @State private var searchText = ""
    @State private var showingNew = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isImporting = false

    private var filtered: [Person] {
        guard !searchText.isEmpty else { return people }
        let q = searchText.lowercased()
        return people.filter {
            $0.name.lowercased().contains(q)
            || ($0.nickname?.lowercased().contains(q) ?? false)
            || $0.tags.contains(where: { $0.lowercased().contains(q) })
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { person in
                    NavigationLink(value: person) {
                        PersonRow(person: person)
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Personas")
            .searchable(text: $searchText, prompt: "Buscar")
            .navigationDestination(for: Person.self) { person in
                PersonDetailView(person: person)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button {
                            seedDemo()
                        } label: {
                            Label("Datos demo", systemImage: "sparkles")
                        }
                        Button {
                            Task { await importContacts() }
                        } label: {
                            Label("Importar contactos", systemImage: "square.and.arrow.down")
                        }
                        .disabled(isImporting)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNew = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNew) {
                NewPersonView()
            }
            .alert("Info", isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isImporting {
                    ProgressView("Importando contactos…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for idx in offsets {
            context.delete(filtered[idx])
        }
    }

    private func seedDemo() {
        let demo = DatabaseSeeder.makeDemoPeople()
        for p in demo { context.insert(p) }
        alertMessage = "Añadidas \(demo.count) personas demo"
        showingAlert = true
    }

    private func importContacts() async {
        isImporting = true
        defer { isImporting = false }

        let result = await ContactsImporter.shared.importContacts()

        if let error = result.error {
            alertMessage = "Error: \(error)"
            showingAlert = true
            return
        }

        // Deduplicar por nombre (case-insensitive)
        let existingNames = Set(people.map { $0.name.lowercased() })
        let toAdd = result.imported.filter { !existingNames.contains($0.name.lowercased()) }
        let skippedDuplicates = result.imported.count - toAdd.count

        for p in toAdd { context.insert(p) }

        alertMessage = "Importadas \(toAdd.count) personas. Omitidas \(skippedDuplicates) duplicadas, \(result.skipped) sin nombre."
        showingAlert = true
    }
}
