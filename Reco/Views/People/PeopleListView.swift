import SwiftUI
import SwiftData

struct PeopleListView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Person> { $0.archivedAt == nil }, sort: \Person.name)
    private var people: [Person]

    @State private var searchText = ""
    @State private var showingNew = false
    @State private var showingAlert = false
    @State private var alertMessage = ""

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
}
