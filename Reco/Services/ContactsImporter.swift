import Foundation
import Contacts

/// Importador de contactos del dispositivo.
@MainActor
final class ContactsImporter {
    static let shared = ContactsImporter()

    private init() {}

    struct ImportResult {
        var imported: [Person]
        var skipped: Int
        var error: String?
    }

    func importContacts() async -> ImportResult {
        let store = CNContactStore()

        do {
            let granted = try await store.requestAccess(for: .contacts)
            guard granted else {
                return ImportResult(imported: [], skipped: 0, error: "Permiso denegado")
            }

            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey,
                CNContactEmailAddressesKey,
            ] as [CNKeyDescriptor]

            let request = CNContactFetchRequest(keysToFetch: keys)
            var candidates: [Person] = []
            var skipped = 0

            try store.enumerateContacts(with: request) { contact, _ in
                let name = [contact.givenName, contact.familyName]
                    .filter { !$0.isEmpty }
                    .joined(separator: " ")

                guard !name.isEmpty else {
                    skipped += 1
                    return
                }

                let phone = contact.phoneNumbers.first?.value.stringValue
                let email = contact.emailAddresses.first?.value as String?

                let person = Person(
                    name: name,
                    relationship: .other,
                    importance: 3,
                    cadenceDays: 60,
                    flexibilityDays: 14,
                    email: email,
                    phone: phone
                )
                candidates.append(person)
            }

            return ImportResult(imported: candidates, skipped: skipped)
        } catch {
            return ImportResult(imported: [], skipped: 0, error: error.localizedDescription)
        }
    }
}
