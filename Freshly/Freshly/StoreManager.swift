import StoreKit
import SwiftUI

@Observable
final class StoreManager {
    static let shared = StoreManager()

    private let productId = "com.vac2mac.freshly.pro"

    var product: Product?
    var isPurchased = false

    private init() {
        Task { await loadProduct() }
        Task { await listenForTransactions() }
        Task { await checkEntitlements() }
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productId])
            product = products.first
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase() async -> Bool {
        guard let product else { return false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await MainActor.run {
                    isPurchased = true
                    UserDefaults.standard.set(true, forKey: "isPro")
                }
                return true
            case .pending, .userCancelled:
                return false
            @unknown default:
                return false
            }
        } catch {
            print("Purchase failed: \(error)")
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productId {
                await MainActor.run {
                    isPurchased = true
                    UserDefaults.standard.set(true, forKey: "isPro")
                }
                return
            }
        }
        await MainActor.run {
            isPurchased = false
            UserDefaults.standard.set(false, forKey: "isPro")
        }
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await checkEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverifiedTransaction
        case .verified(let value):
            return value
        }
    }

    enum StoreError: Error {
        case unverifiedTransaction
    }
}
