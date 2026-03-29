import Foundation
import SwiftData

@Model
final class TrackedItem {
    var name: String
    var category: String
    var expiryDate: Date
    var note: String
    var status: String // "active", "used", "discarded"
    var createdAt: Date

    init(name: String, category: String, expiryDate: Date,
         note: String = "", status: String = "active", createdAt: Date = .now) {
        self.name = name
        self.category = category
        self.expiryDate = expiryDate
        self.note = note
        self.status = status
        self.createdAt = createdAt
    }
}

@Model
final class CustomCategory {
    var name: String
    var iconName: String
    var colorHex: String

    init(name: String, iconName: String = "tag.fill", colorHex: String = "#888888") {
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
    }
}
