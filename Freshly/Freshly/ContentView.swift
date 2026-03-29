import SwiftUI

struct ContentView: View {
    private var localeManager = LocaleManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tag(0)
                .tabItem {
                    Label(L("Home"), systemImage: "house.fill")
                }
            ItemListView()
                .tag(1)
                .tabItem {
                    Label(L("Items"), systemImage: "tray.full.fill")
                }
            SettingsView()
                .tag(2)
                .tabItem {
                    Label(L("Settings"), systemImage: "gearshape")
                }
        }
        .environment(\.locale, localeManager.locale)
    }
}
