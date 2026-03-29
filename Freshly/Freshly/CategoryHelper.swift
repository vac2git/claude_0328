import SwiftUI

struct PresetCategory: Identifiable {
    let id: String
    let label: String
    let icon: String
    let color: Color

    static let all: [PresetCategory] = [
        PresetCategory(id: "fridge", label: L("Fridge"), icon: "refrigerator.fill", color: .blue),
        PresetCategory(id: "freezer", label: L("Freezer"), icon: "snowflake", color: .cyan),
        PresetCategory(id: "pantry", label: L("Pantry"), icon: "cabinet.fill", color: .brown),
        PresetCategory(id: "medicine", label: L("Medicine Cabinet"), icon: "cross.case.fill", color: .red),
        PresetCategory(id: "cosmetics", label: L("Cosmetics"), icon: "sparkles", color: .pink),
        PresetCategory(id: "household", label: L("Household"), icon: "house.fill", color: .green),
        PresetCategory(id: "other", label: L("Other"), icon: "tray.fill", color: .gray),
    ]

    static func find(_ id: String) -> PresetCategory? {
        all.first { $0.id == id }
    }

    static func icon(for categoryId: String) -> String {
        find(categoryId)?.icon ?? "tag.fill"
    }

    static func color(for categoryId: String) -> Color {
        find(categoryId)?.color ?? .gray
    }

    static func label(for categoryId: String) -> String {
        find(categoryId)?.label ?? categoryId
    }
}

enum UrgencyLevel {
    case expired
    case urgent   // 3일 이내
    case warning  // 7일 이내
    case safe

    var color: Color {
        switch self {
        case .expired: return .red
        case .urgent: return .orange
        case .warning: return .yellow
        case .safe: return .green
        }
    }

    var label: String {
        switch self {
        case .expired: return L("Expired")
        case .urgent: return L("Expiring Soon")
        case .warning: return L("This Week")
        case .safe: return L("Fresh")
        }
    }

    static func from(expiryDate: Date) -> UrgencyLevel {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        let expiry = calendar.startOfDay(for: expiryDate)
        let days = calendar.dateComponents([.day], from: now, to: expiry).day ?? 0

        if days < 0 { return .expired }
        if days <= 3 { return .urgent }
        if days <= 7 { return .warning }
        return .safe
    }
}

extension Date {
    var daysUntilExpiry: Int {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: .now)
        let expiry = calendar.startOfDay(for: self)
        return calendar.dateComponents([.day], from: now, to: expiry).day ?? 0
    }

    var expiryDisplayText: String {
        let days = daysUntilExpiry
        if days < 0 {
            return L("\(abs(days))d overdue")
        } else if days == 0 {
            return L("Today")
        } else if days == 1 {
            return L("Tomorrow")
        } else {
            return L("\(days)d left")
        }
    }
}
