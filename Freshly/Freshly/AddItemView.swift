import SwiftUI
import SwiftData

struct AddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var category = "fridge"
    @State private var expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now
    @State private var note = ""

    @Query private var customCategories: [CustomCategory]
    @AppStorage("isPro") private var isPro = false

    var body: some View {
        NavigationStack {
            Form {
                Section(L("Name")) {
                    TextField(L("e.g. Milk"), text: $name)
                }

                Section(L("Category")) {
                    Picker(L("Category"), selection: $category) {
                        ForEach(PresetCategory.all) { preset in
                            Label(preset.label, systemImage: preset.icon)
                                .tag(preset.id)
                        }
                        if isPro {
                            ForEach(customCategories) { custom in
                                Label(custom.name, systemImage: custom.iconName)
                                    .tag(custom.name)
                            }
                        }
                    }
                }

                Section(L("Expiry Date")) {
                    DatePicker(
                        L("Expiry Date"),
                        selection: $expiryDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                }

                Section(L("Note")) {
                    TextField(L("Optional"), text: $note)
                }
            }
            .navigationTitle(L("Add Item"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Save")) {
                        saveItem()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("Cancel")) { dismiss() }
                }
            }
        }
    }

    private func saveItem() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        let normalizedDate = Calendar.current.startOfDay(for: expiryDate)
        let item = TrackedItem(
            name: trimmedName,
            category: category,
            expiryDate: normalizedDate,
            note: note.trimmingCharacters(in: .whitespaces)
        )
        modelContext.insert(item)

        // Schedule notifications and request permission on first add
        Task {
            let granted = await NotificationManager.shared.requestPermission()
            if granted {
                NotificationManager.shared.scheduleNotifications(for: item)
            }
        }

        dismiss()
    }
}
