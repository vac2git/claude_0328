import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(filter: #Predicate<TrackedItem> { $0.status == "active" })
    private var activeItems: [TrackedItem]
    @AppStorage("isPro") private var isPro = false
    @State private var showAddItem = false
    @State private var showPaywall = false

    private let freeItemLimit = 15

    private var expiringSoonCount: Int {
        activeItems.filter {
            let days = $0.expiryDate.daysUntilExpiry
            return days >= 0 && days <= 7
        }.count
    }

    private var expiredCount: Int {
        activeItems.filter { $0.expiryDate.daysUntilExpiry < 0 }.count
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return L("Good Morning")
        case 12..<18: return L("Good Afternoon")
        default: return L("Good Evening")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Greeting
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

                    // Expiring Soon Card
                    SummaryCard(
                        title: L("Expiring Soon"),
                        icon: "exclamationmark.triangle.fill",
                        iconColor: .orange,
                        value: "\(expiringSoonCount)",
                        subtitle: L("items within 7 days"),
                        progress: nil
                    )

                    // Expired Card
                    SummaryCard(
                        title: L("Expired"),
                        icon: "xmark.circle.fill",
                        iconColor: .red,
                        value: "\(expiredCount)",
                        subtitle: L("items past expiry date"),
                        progress: nil
                    )

                    // Active Items Card
                    SummaryCard(
                        title: L("Active Items"),
                        icon: "tray.full.fill",
                        iconColor: .blue,
                        value: "\(activeItems.count)",
                        subtitle: isPro
                            ? L("Pro — Unlimited")
                            : L("\(activeItems.count) / \(freeItemLimit) items"),
                        progress: isPro ? nil : Double(activeItems.count) / Double(freeItemLimit)
                    )

                    // Quick Add Button
                    Button {
                        if !isPro && activeItems.count >= freeItemLimit {
                            showPaywall = true
                        } else {
                            showAddItem = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text(L("Add Item"))
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal)

                    // Waste Stats (Pro only)
                    WasteStatsCard()

                    // Tip Card
                    TipCard()
                }
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L("Today"))
            .sheet(isPresented: $showAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
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
                ProgressView(value: min(progress, 1.0))
                    .tint(progress >= 1.0 ? .red : iconColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }
}

struct TipCard: View {
    private let tips: [String] = [
        L("Check your fridge weekly to avoid waste."),
        L("Items in the freezer last longer, but don't forget them!"),
        L("Cosmetics expire too — check your skincare products."),
        L("Medicine past its expiry date can be less effective."),
        L("First in, first out — use older items first."),
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
                Text(L("Tip of the Day"))
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
