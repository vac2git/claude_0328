import SwiftUI
import SwiftData

enum ItemFilter: String, CaseIterable {
    case all
    case expiringSoon
    case expired

    var label: String {
        switch self {
        case .all: return L("All")
        case .expiringSoon: return L("Expiring Soon")
        case .expired: return L("Expired")
        }
    }
}

struct ItemListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TrackedItem> { $0.status == "active" },
           sort: \TrackedItem.expiryDate)
    private var activeItems: [TrackedItem]

    @State private var showAddItem = false
    @State private var showPaywall = false
    @State private var filter: ItemFilter = .all
    @AppStorage("isPro") private var isPro = false

    private var filteredItems: [TrackedItem] {
        switch filter {
        case .all:
            return activeItems
        case .expiringSoon:
            return activeItems.filter {
                let days = $0.expiryDate.daysUntilExpiry
                return days >= 0 && days <= 7
            }
        case .expired:
            return activeItems.filter { $0.expiryDate.daysUntilExpiry < 0 }
        }
    }

    private let freeItemLimit = 15

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(ItemFilter.allCases, id: \.self) { f in
                        Text(f.label).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding()

                if filteredItems.isEmpty {
                    ContentUnavailableView(
                        filter == .all
                            ? L("No Items Yet")
                            : L("No Items"),
                        systemImage: filter == .all ? "tray" : "checkmark.circle",
                        description: Text(filter == .all
                            ? L("Tap + to add your first item.")
                            : L("No items match this filter."))
                    )
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ItemRow(item: item)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        NotificationManager.shared.cancelNotifications(for: item)
                                        modelContext.delete(item)
                                    } label: {
                                        Label(L("Delete"), systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                    Button {
                                        NotificationManager.shared.cancelNotifications(for: item)
                                        item.status = "used"
                                    } label: {
                                        Label(L("Used"), systemImage: "checkmark.circle")
                                    }
                                    .tint(.green)

                                    Button {
                                        NotificationManager.shared.cancelNotifications(for: item)
                                        item.status = "discarded"
                                    } label: {
                                        Label(L("Discarded"), systemImage: "trash.circle")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L("Items"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !isPro && activeItems.count >= freeItemLimit {
                            showPaywall = true
                        } else {
                            showAddItem = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddItem) {
                AddItemView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

struct ItemRow: View {
    let item: TrackedItem
    private var urgency: UrgencyLevel {
        UrgencyLevel.from(expiryDate: item.expiryDate)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: PresetCategory.icon(for: item.category))
                .foregroundStyle(PresetCategory.color(for: item.category))
                .font(.title3)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .fontWeight(.medium)
                Text(PresetCategory.label(for: item.category))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(item.expiryDate.expiryDisplayText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(urgency.color)
                Text(item.expiryDate, format: .dateTime.month().day())
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}
