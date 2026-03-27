import SwiftUI
import SwiftData

struct MealView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allMeals: [MealEntry]
    @State private var showAddMeal = false

    private var todayMeals: [MealEntry] {
        allMeals.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }

    private var totalCalories: Int {
        todayMeals.reduce(0) { $0 + $1.calories }
    }

    private let categories = ["아침", "점심", "저녁", "간식"]

    var body: some View {
        NavigationStack {
            List {
                // 오늘 총 칼로리 헤더
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("오늘 총 칼로리")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("\(totalCalories) kcal")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                        Spacer()
                        Image(systemName: "flame.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.orange.opacity(0.3))
                    }
                    .padding(.vertical, 4)
                }

                // 카테고리별 식사 목록
                ForEach(categories, id: \.self) { category in
                    let meals = todayMeals.filter { $0.category == category }
                    if !meals.isEmpty {
                        Section(category) {
                            ForEach(meals) { meal in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(meal.name)
                                            .fontWeight(.medium)
                                        Text(meal.date, style: .time)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("\(meal.calories) kcal")
                                        .font(.subheadline)
                                        .foregroundStyle(.orange)
                                        .fontWeight(.semibold)
                                }
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        modelContext.delete(meal)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }

                if todayMeals.isEmpty {
                    ContentUnavailableView(
                        "오늘 식사 기록 없음",
                        systemImage: "fork.knife",
                        description: Text("+ 버튼으로 식사를 추가해보세요.")
                    )
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("식사 기록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddMeal = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddMeal) {
                AddMealView()
            }
        }
    }
}

struct AddMealView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "점심"
    @State private var caloriesText = ""

    private let categories = ["아침", "점심", "저녁", "간식"]

    var body: some View {
        NavigationStack {
            Form {
                Section("음식 이름") {
                    TextField("예: 비빔밥", text: $name)
                }
                Section("카테고리") {
                    Picker("카테고리", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)
                }
                Section("칼로리") {
                    TextField("예: 450", text: $caloriesText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("식사 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("추가") {
                        saveMeal()
                    }
                    .disabled(name.isEmpty || caloriesText.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func saveMeal() {
        guard !name.isEmpty, let calories = Int(caloriesText), calories >= 0 else { return }
        let meal = MealEntry(name: name, category: category, calories: calories)
        modelContext.insert(meal)
        dismiss()
    }
}
