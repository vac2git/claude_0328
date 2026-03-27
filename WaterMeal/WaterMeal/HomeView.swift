import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var allWater: [WaterEntry]
    @Query private var allMeals: [MealEntry]
    @AppStorage("waterGoal") private var dailyGoal: Int = 2000

    private var todayWater: Int {
        allWater
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amount }
    }

    private var todayCalories: Int {
        allMeals
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.calories }
    }

    private var waterProgress: Double {
        min(Double(todayWater) / Double(dailyGoal), 1.0)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "좋은 아침이에요"
        case 12..<18: return "좋은 오후예요"
        default: return "좋은 저녁이에요"
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 인사말
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(greeting)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(Date.now, format: Date.FormatStyle().month().day().weekday())
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    // 물 카드
                    SummaryCard(
                        title: "물",
                        icon: "drop.fill",
                        iconColor: .blue,
                        value: "\(todayWater) ml",
                        subtitle: "목표 \(dailyGoal) ml",
                        progress: waterProgress
                    )

                    // 칼로리 카드
                    SummaryCard(
                        title: "칼로리",
                        icon: "flame.fill",
                        iconColor: .orange,
                        value: "\(todayCalories) kcal",
                        subtitle: "오늘 섭취량",
                        progress: nil
                    )

                    // 팁 섹션
                    TipCard()
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("오늘")
        }
    }
}

struct SummaryCard: View {
    let title: String
    let icon: String
    let iconColor: Color
    let value: String
    let subtitle: String
    let progress: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(iconColor)
                    .font(.title3)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(iconColor)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            if let progress {
                ProgressView(value: progress)
                    .tint(iconColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct TipCard: View {
    private let tips = [
        "식사 30분 전에 물 한 잔 마시면 소화에 도움이 돼요.",
        "하루 8잔의 물 마시기를 목표로 해보세요.",
        "규칙적인 식사 시간이 신체 리듬을 만들어줍니다.",
        "채소와 과일도 수분 섭취에 도움이 됩니다.",
        "아침 공복에 물 한 잔은 하루를 활기차게 시작하는 방법이에요.",
    ]

    private var todayTip: String {
        let index = Calendar.current.component(.day, from: .now) % tips.count
        return tips[index]
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.title3)
            VStack(alignment: .leading, spacing: 4) {
                Text("오늘의 팁")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(todayTip)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}
