import Foundation
import SwiftData

@Model
final class WaterEntry {
    var amount: Int  // ml 단위
    var date: Date

    init(amount: Int, date: Date = .now) {
        self.amount = amount
        self.date = date
    }
}

@Model
final class MealEntry {
    var name: String
    var category: String  // "아침", "점심", "저녁", "간식"
    var calories: Int
    var date: Date

    init(name: String, category: String, calories: Int, date: Date = .now) {
        self.name = name
        self.category = category
        self.calories = calories
        self.date = date
    }
}
