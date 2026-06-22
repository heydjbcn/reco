import Foundation
import SwiftData

enum Relationship: String, Codable, CaseIterable, Identifiable {
    case family, friend, partner, work, mentor, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .family: return "Familia"
        case .friend: return "Amistad"
        case .partner: return "Pareja"
        case .work: return "Trabajo"
        case .mentor: return "Mentor"
        case .other: return "Otra"
        }
    }

    var symbol: String {
        switch self {
        case .family: return "house.fill"
        case .friend: return "person.2.fill"
        case .partner: return "heart.fill"
        case .work: return "briefcase.fill"
        case .mentor: return "graduationcap.fill"
        case .other: return "person.fill"
        }
    }
}

enum Channel: String, Codable, CaseIterable, Identifiable {
    case call, message, inPerson, email, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .call: return "Llamada"
        case .message: return "Mensaje"
        case .inPerson: return "En persona"
        case .email: return "Email"
        case .other: return "Otro"
        }
    }

    var symbol: String {
        switch self {
        case .call: return "phone.fill"
        case .message: return "message.fill"
        case .inPerson: return "person.wave.2.fill"
        case .email: return "envelope.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }
}

@Model
final class Person {
    var name: String
    var nickname: String?
    var relationshipRaw: String
    var birthday: Date?
    var email: String?
    var phone: String?
    var photoData: Data?

    /// 1-5, escala de importancia para el usuario
    var importance: Int

    /// Cada cuántos días debería contactar a esta persona
    var cadenceDays: Int

    /// Margen +/- en días antes de marcar como vencido
    var flexibilityDays: Int

    var notes: String?
    var tags: [String]

    var createdAt: Date
    var updatedAt: Date
    var archivedAt: Date?

    @Relationship(deleteRule: .cascade, inverse: \Interaction.person)
    var interactions: [Interaction] = []

    var relationship: Relationship {
        get { Relationship(rawValue: relationshipRaw) ?? .other }
        set { relationshipRaw = newValue.rawValue }
    }

    init(
        name: String,
        relationship: Relationship = .friend,
        importance: Int = 3,
        cadenceDays: Int = 30,
        flexibilityDays: Int = 7,
        nickname: String? = nil,
        birthday: Date? = nil,
        email: String? = nil,
        phone: String? = nil,
        photoData: Data? = nil,
        notes: String? = nil,
        tags: [String] = []
    ) {
        self.name = name
        self.relationshipRaw = relationship.rawValue
        self.importance = importance
        self.cadenceDays = cadenceDays
        self.flexibilityDays = flexibilityDays
        self.nickname = nickname
        self.birthday = birthday
        self.email = email
        self.phone = phone
        self.photoData = photoData
        self.notes = notes
        self.tags = tags
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }

    /// Init con argumentos en orden amigable para llamadas (nickname primero).
    convenience init(
        name: String,
        nickname: String?,
        relationship: Relationship,
        importance: Int,
        cadenceDays: Int,
        flexibilityDays: Int,
        notes: String? = nil,
        tags: [String] = [],
        email: String? = nil,
        phone: String? = nil
    ) {
        self.init(
            name: name,
            relationship: relationship,
            importance: importance,
            cadenceDays: cadenceDays,
            flexibilityDays: flexibilityDays,
            nickname: nickname,
            email: email,
            phone: phone,
            notes: notes,
            tags: tags
        )
    }

    var lastInteraction: Interaction? {
        interactions.sorted { $0.occurredAt > $1.occurredAt }.first
    }
}

@Model
final class Interaction {
    var person: Person?
    var channelRaw: String
    var summary: String?
    var occurredAt: Date
    var followUpInDays: Int?
    var createdAt: Date

    var channel: Channel {
        get { Channel(rawValue: channelRaw) ?? .other }
        set { channelRaw = newValue.rawValue }
    }

    init(
        person: Person,
        channel: Channel,
        summary: String? = nil,
        occurredAt: Date = .now,
        followUpInDays: Int? = nil
    ) {
        self.person = person
        self.channelRaw = channel.rawValue
        self.summary = summary
        self.occurredAt = occurredAt
        self.followUpInDays = followUpInDays
        self.createdAt = .now
    }
}

@Model
final class ReminderConfig {
    /// Hora del día para el resumen (0-23)
    var notifyHour: Int

    /// "local" o "none" en MVP
    var notifyChannel: String

    /// Días sin recordatorio
    var quietDays: [String]

    var notificationsAuthorized: Bool

    var updatedAt: Date

    init(notifyHour: Int = 9, notifyChannel: String = "local", quietDays: [String] = []) {
        self.notifyHour = notifyHour
        self.notifyChannel = notifyChannel
        self.quietDays = quietDays
        self.notificationsAuthorized = false
        self.updatedAt = .now
    }
}
