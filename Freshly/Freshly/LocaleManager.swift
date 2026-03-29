import SwiftUI

@Observable
final class LocaleManager {
    static let shared = LocaleManager()

    var locale: Locale
    var refreshId = UUID()

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        self.locale = Locale(identifier: saved)
    }

    func setLanguage(_ code: String) {
        UserDefaults.standard.set(code, forKey: "appLanguage")
        UserDefaults.standard.set([code], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        locale = Locale(identifier: code)
        refreshId = UUID()
    }

    var currentCode: String {
        UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }

    /// Get the bundle for the currently selected language
    var bundle: Bundle {
        let code = currentCode
        // Try exact code first, then base language identifier
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        // For English (source language), use Base or main bundle
        if let path = Bundle.main.path(forResource: "Base", ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .main
    }
}

/// Localize a string using the user-selected language bundle
func L(_ key: String) -> String {
    // Access refreshId to create an observable dependency
    _ = LocaleManager.shared.refreshId
    let bundle = LocaleManager.shared.bundle
    let result = bundle.localizedString(forKey: key, value: nil, table: nil)
    // If the bundle returns the key itself (no translation found), try main bundle
    if result == key {
        return Bundle.main.localizedString(forKey: key, value: key, table: nil)
    }
    return result
}
