import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Person> { $0.archivedAt == nil })
    private var people: [Person]

    @State private var showingNewPerson = false
    @State private var logPerson: Person?

    private var todaysList: [Person] {
        UrgencyCalculator.todaysList(from: people)
    }

    var body: some View {
        NavigationStack {
            Group {
                if people.isEmpty {
                    EmptyStateView(action: { showingNewPerson = true })
                } else if todaysList.isEmpty {
                    AllCaughtUpView()
                } else {
                    List {
                        Section {
                            ForEach(todaysList) { person in
                                Button {
                                    logPerson = person
                                } label: {
                                    PersonRow(person: person)
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Text("Hoy toca \(todaysList.count) \(todaysList.count == 1 ? "persona" : "personas")")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Hoy")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingNewPerson = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showingNewPerson) {
                NewPersonView()
            }
            .sheet(item: $logPerson) { person in
                LogInteractionView(person: person)
            }
        }
    }
}

struct PersonRow: View {
    let person: Person

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                Text(initials)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text(person.name)
                    .font(.body)
                    .fontWeight(.semibold)
                HStack(spacing: 6) {
                    Image(systemName: person.relationship.symbol)
                        .font(.caption2)
                    Text(person.relationship.displayName)
                        .font(.caption)
                    Text("·")
                    Text(UrgencyCalculator.label(for: person))
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            if UrgencyCalculator.isOverdue(for: person) {
                Image(systemName: "exclamationmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 4)
    }

    private var initials: String {
        let parts = person.name.split(separator: " ").prefix(2)
        return parts.map { String($0.first ?? "?") }.joined().uppercased()
    }
}

struct EmptyStateView: View {
    let action: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 72))
                .foregroundStyle(.tertiary)
            Text("Añade tu primera persona")
                .font(.title2.bold())
            Text("Reco te ayuda a no perder el contacto con quien te importa.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button {
                action()
            } label: {
                Label("Nueva persona", systemImage: "plus")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct AllCaughtUpView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.green)
            Text("Al día")
                .font(.title2.bold())
            Text("No tienes que contactar a nadie ahora mismo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
