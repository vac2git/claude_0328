import SwiftUI
import SwiftData

struct CustomCategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var customCategories: [CustomCategory]
    @State private var showAddCategory = false

    var body: some View {
        List {
            Section(L("Custom Categories")) {
                ForEach(customCategories) { category in
                    HStack {
                        Image(systemName: category.iconName)
                            .foregroundStyle(Color(hex: category.colorHex) ?? .gray)
                            .frame(width: 24)
                        Text(category.name)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(customCategories[index])
                    }
                }

                Button {
                    showAddCategory = true
                } label: {
                    Label(L("Add Category"), systemImage: "plus")
                }
            }
        }
        .navigationTitle(L("Categories"))
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView()
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var selectedIcon = "tag.fill"

    private let iconOptions = [
        "tag.fill", "leaf.fill", "cup.and.saucer.fill", "birthday.cake.fill",
        "pawprint.fill", "fish.fill", "carrot.fill", "takeoutbag.and.cup.and.straw.fill",
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section(L("Category Name")) {
                    TextField(L("e.g. Baby Food"), text: $name)
                }
                Section(L("Icon")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                selectedIcon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.title2)
                                    .frame(width: 44, height: 44)
                                    .background(selectedIcon == icon ? Color.blue.opacity(0.2) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(L("Add Category"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("Add")) {
                        let category = CustomCategory(name: name.trimmingCharacters(in: .whitespaces), iconName: selectedIcon)
                        modelContext.insert(category)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(L("Cancel")) { dismiss() }
                }
            }
        }
    }
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        guard hexSanitized.count == 6,
              let hexNumber = UInt64(hexSanitized, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((hexNumber & 0xFF0000) >> 16) / 255,
            green: Double((hexNumber & 0x00FF00) >> 8) / 255,
            blue: Double(hexNumber & 0x0000FF) / 255
        )
    }
}
