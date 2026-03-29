import SwiftUI

struct SettingsView: View {
    @AppStorage("notify3Days") private var notify3Days = true
    @AppStorage("notify1Day") private var notify1Day = true
    @AppStorage("notifySameDay") private var notifySameDay = true
    @AppStorage("isPro") private var isPro = false
    private var localeManager = LocaleManager.shared

    var body: some View {
        NavigationStack {
            List {
                // Language
                Section(L("Language")) {
                    ForEach(AppLanguage.allCases) { lang in
                        Button {
                            localeManager.setLanguage(lang.code)
                        } label: {
                            HStack {
                                Text(lang.displayName)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if localeManager.currentCode == lang.code {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }

                // Pro Section
                if !isPro {
                    Section {
                        ProBannerRow()
                    }
                } else {
                    Section {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(.yellow)
                            Text(L("Pro Unlocked"))
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }

                // Custom Categories (Pro)
                if isPro {
                    Section(L("Categories")) {
                        NavigationLink {
                            CustomCategoryListView()
                        } label: {
                            Label(L("Custom Categories"), systemImage: "folder.badge.plus")
                        }
                    }
                }

                // Notifications
                Section(L("Notifications")) {
                    Toggle(L("3 days before"), isOn: $notify3Days)
                    Toggle(L("1 day before"), isOn: $notify1Day)
                    Toggle(L("On expiry day"), isOn: $notifySameDay)
                }

                // Data
                Section(L("Data")) {
                    Button(L("Restore Purchases")) {
                        Task {
                            await StoreManager.shared.restorePurchases()
                        }
                    }
                }

                #if DEBUG
                Section("Debug") {
                    Button("Test Notifications (3s / 6s / 9s)") {
                        NotificationManager.shared.sendTestNotifications()
                    }
                }
                #endif

                // About
                Section(L("About")) {
                    HStack {
                        Text(L("Version"))
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(L("Privacy Policy"),
                         destination: URL(string: "https://vac2git.github.io/claude_0328/freshly-privacy.html")!)

                    Link(L("Contact"),
                         destination: URL(string: "mailto:neologoff@gmail.com")!)
                }
            }
            .navigationTitle(L("Settings"))
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case korean = "ko"
    case chinese = "zh-Hans"

    var id: String { rawValue }

    var code: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        case .chinese: return "中文(简体)"
        }
    }
}

struct ProBannerRow: View {
    @State private var showPaywall = false

    var body: some View {
        Button {
            showPaywall = true
        } label: {
            HStack {
                Image(systemName: "crown.fill")
                    .foregroundStyle(.yellow)
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text(L("Upgrade to Pro"))
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(L("Unlimited items, custom categories & more"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}
