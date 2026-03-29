import SwiftUI
import SwiftData

struct WasteStatsCard: View {
    @Query(filter: #Predicate<TrackedItem> { $0.status == "used" })
    private var usedItems: [TrackedItem]

    @Query(filter: #Predicate<TrackedItem> { $0.status == "discarded" })
    private var discardedItems: [TrackedItem]

    @AppStorage("isPro") private var isPro = false

    private var totalResolved: Int {
        usedItems.count + discardedItems.count
    }

    private var usageRate: Double {
        guard totalResolved > 0 else { return 0 }
        return Double(usedItems.count) / Double(totalResolved)
    }

    var body: some View {
        if isPro {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                    Text(L("Waste Score"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                }

                if totalResolved > 0 {
                    Text("\(Int(usageRate * 100))%")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)

                    ProgressView(value: usageRate)
                        .tint(.green)

                    Text(L("of items used before expiry"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 16) {
                        Label(L("\(usedItems.count) used"), systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Label(L("\(discardedItems.count) discarded"), systemImage: "trash.circle")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } else {
                    Text(L("No usage data yet"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}
