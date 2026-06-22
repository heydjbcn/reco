import Foundation

/// Calcula la urgencia de contactar a una persona.
///
/// Fórmula:
///   daysSince = (now - lastInteraction.occurredAt) en días
///   raw = daysSince / cadenceDays
///   urgency = min(raw * importance, 3)
struct UrgencyCalculator {
    static let secondsPerDay: TimeInterval = 86_400

    static func urgency(for person: Person, now: Date = .now) -> Double {
        guard let last = person.lastInteraction else {
            return Double(person.importance) * 2
        }
        let daysSince = now.timeIntervalSince(last.occurredAt) / secondsPerDay
        let raw = daysSince / Double(person.cadenceDays)
        let scaled = raw * Double(person.importance)
        return min(scaled, 3.0)
    }

    static func isOverdue(for person: Person, now: Date = .now) -> Bool {
        guard let last = person.lastInteraction else {
            return true
        }
        let daysSince = now.timeIntervalSince(last.occurredAt) / secondsPerDay
        let limit = Double(person.cadenceDays + person.flexibilityDays)
        return daysSince > limit
    }

    static func daysSinceLastContact(for person: Person, now: Date = .now) -> Int? {
        guard let last = person.lastInteraction else { return nil }
        let secs = now.timeIntervalSince(last.occurredAt)
        return max(0, Int(secs / secondsPerDay))
    }

    static func todaysList(from people: [Person], now: Date = .now) -> [Person] {
        let active = people.filter { $0.archivedAt == nil }
        let scored = active.map { p -> (Person, Double, Bool) in
            let u = urgency(for: p, now: now)
            let od = isOverdue(for: p, now: now)
            return (p, u, od)
        }
        let filtered = scored.filter { _, u, od in od || u >= 0.8 }
        return filtered
            .sorted { lhs, rhs in
                if lhs.2 != rhs.2 { return lhs.2 }
                return lhs.1 > rhs.1
            }
            .map { $0.0 }
    }

    static func label(for person: Person, now: Date = .now) -> String {
        if let days = daysSinceLastContact(for: person, now: now) {
            if days == 0 { return "Hoy" }
            if days == 1 { return "Hace 1 día" }
            return "Hace \(days) días"
        }
        return "Nunca contactado"
    }
}
