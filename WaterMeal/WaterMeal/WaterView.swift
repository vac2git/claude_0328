import SwiftUI
import SwiftData

struct WaterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allEntries: [WaterEntry]
    @AppStorage("waterGoal") private var dailyGoal: Int = 2000
    @State private var showGoalEditor = false

    private var todayEntries: [WaterEntry] {
        allEntries.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date > $1.date }
    }

    private var totalToday: Int {
        todayEntries.reduce(0) { $0 + $1.amount }
    }

    private var progress: Double {
        min(Double(totalToday) / Double(dailyGoal), 1.0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // 원형 프로그레스 링
                    ZStack {
                        Circle()
                            .stroke(Color.blue.opacity(0.15), lineWidth: 22)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(lineWidth: 22, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5), value: progress)
                        VStack(spacing: 4) {
                            Text("\(totalToday)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(.blue)
                            Text("/ \(dailyGoal) ml")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            if progress >= 1.0 {
                                Text("목표 달성!")
                                    .font(.caption)
                                    .foregroundStyle(.green)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .frame(width: 210, height: 210)
                    .padding(.top, 8)

                    // 빠른 추가 버튼
                    HStack(spacing: 12) {
                        ForEach([150, 250, 500], id: \.self) { amount in
                            Button {
                                addWater(amount)
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: "drop.fill")
                                        .font(.title3)
                                    Text("+\(amount)ml")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                    }
                    .padding(.horizontal)

                    // 오늘 기록 목록
                    if !todayEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("오늘 기록")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.bottom, 8)

                            ForEach(todayEntries) { entry in
                                HStack {
                                    Image(systemName: "drop.fill")
                                        .foregroundStyle(.blue)
                                        .frame(width: 20)
                                    Text("\(entry.amount) ml")
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text(entry.date, style: .time)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                .background(Color(.systemBackground))
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        modelContext.delete(entry)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }

                                if entry.persistentModelID != todayEntries.last?.persistentModelID {
                                    Divider().padding(.leading)
                                }
                            }
                        }
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("물 트래커")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showGoalEditor = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }
            }
            .sheet(isPresented: $showGoalEditor) {
                GoalEditorView(dailyGoal: $dailyGoal)
            }
        }
    }

    private func addWater(_ amount: Int) {
        let entry = WaterEntry(amount: amount)
        modelContext.insert(entry)
    }
}

struct GoalEditorView: View {
    @Binding var dailyGoal: Int
    @Environment(\.dismiss) private var dismiss
    @State private var goalText = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("예: 2000", text: $goalText)
                        .keyboardType(.numberPad)
                } header: {
                    Text("일일 목표 (ml)")
                } footer: {
                    Text("하루에 마실 물의 양을 밀리리터(ml) 단위로 입력하세요.")
                }
            }
            .navigationTitle("목표 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        if let value = Int(goalText), value > 0 {
                            dailyGoal = value
                        }
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
            .onAppear {
                goalText = "\(dailyGoal)"
            }
        }
    }
}
