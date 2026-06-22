import Foundation
import SwiftData

enum DatabaseSeeder {
    static func makeDemoPeople() -> [Person] {
        let calendar = Calendar.current
        let now = Date()

        func daysAgo(_ d: Int) -> Date {
            calendar.date(byAdding: .day, value: -d, to: now) ?? now
        }

        var result: [Person] = []

        let mom = Person(
            name: "María",
            nickname: "Mamá",
            relationship: .family,
            importance: 5,
            cadenceDays: 7,
            flexibilityDays: 2,
            notes: "Le gusta que le llame los domingos.",
            tags: ["familia", "valencia"]
        )
        mom.interactions = [
            Interaction(person: mom, channel: .call, summary: "Cómo va el trabajo, le conté lo de IMFALU", occurredAt: daysAgo(14)),
            Interaction(person: mom, channel: .message, summary: "Felicitaciones día madre", occurredAt: daysAgo(45)),
        ]
        result.append(mom)

        let bestFriend = Person(
            name: "Javi Ruiz",
            nickname: nil,
            relationship: .friend,
            importance: 5,
            cadenceDays: 14,
            flexibilityDays: 3,
            tags: ["barcelona", "tech"]
        )
        bestFriend.interactions = [
            Interaction(person: bestFriend, channel: .inPerson, summary: "Cena en Gresca", occurredAt: daysAgo(10)),
        ]
        result.append(bestFriend)

        let brother = Person(
            name: "Carlos",
            nickname: nil,
            relationship: .family,
            importance: 4,
            cadenceDays: 21,
            flexibilityDays: 5,
            tags: ["familia"]
        )
        brother.interactions = [
            Interaction(person: brother, channel: .message, summary: "Birthday wishes", occurredAt: daysAgo(18)),
        ]
        result.append(brother)

        let exCoworker = Person(
            name: "Ana López",
            nickname: "Anita",
            relationship: .work,
            importance: 2,
            cadenceDays: 90,
            flexibilityDays: 30,
            tags: ["tech", "ex-globant"]
        )
        exCoworker.interactions = [
            Interaction(person: exCoworker, channel: .message, summary: "Networking", occurredAt: daysAgo(100)),
        ]
        result.append(exCoworker)

        let partner = Person(
            name: "Cata",
            nickname: "Polola",
            relationship: .partner,
            importance: 5,
            cadenceDays: 1,
            flexibilityDays: 1,
            tags: ["santiago"]
        )
        partner.interactions = [
            Interaction(person: partner, channel: .inPerson, summary: "Cena en casa", occurredAt: daysAgo(1)),
        ]
        result.append(partner)

        let mentor = Person(
            name: "Pedro M.",
            nickname: nil,
            relationship: .mentor,
            importance: 4,
            cadenceDays: 30,
            flexibilityDays: 7,
            notes: "Le debo un café desde hace meses.",
            tags: ["startup"]
        )
        mentor.interactions = [
            Interaction(person: mentor, channel: .email, summary: "Pregunta sobre fundraising", occurredAt: daysAgo(75)),
        ]
        result.append(mentor)

        let friend = Person(
            name: "Lucía",
            nickname: nil,
            relationship: .friend,
            importance: 3,
            cadenceDays: 30,
            flexibilityDays: 7,
            tags: ["universidad"]
        )
        result.append(friend)

        let client = Person(
            name: "Roberto (IMFALU)",
            nickname: nil,
            relationship: .work,
            importance: 4,
            cadenceDays: 14,
            flexibilityDays: 3,
            tags: ["cliente", "construccion"]
        )
        client.interactions = [
            Interaction(person: client, channel: .call, summary: "Status obras", occurredAt: daysAgo(12)),
        ]
        result.append(client)

        return result
    }
}
