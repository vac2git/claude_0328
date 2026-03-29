import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isPro") private var isPro = false
    @State private var isPurchasing = false

    private var store: StoreManager { .shared }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.yellow)

                // Title
                Text(L("Upgrade to Pro"))
                    .font(.title)
                    .fontWeight(.bold)

                // Features
                VStack(alignment: .leading, spacing: 12) {
                    FeatureRow(icon: "infinity", text: L("Unlimited items"))
                    FeatureRow(icon: "folder.badge.plus", text: L("Custom categories"))
                    FeatureRow(icon: "chart.bar.fill", text: L("Waste statistics"))
                }
                .padding(.horizontal, 32)

                Spacer()

                // Purchase Button
                Button {
                    Task {
                        isPurchasing = true
                        let success = await store.purchase()
                        isPurchasing = false
                        if success {
                            isPro = true
                            dismiss()
                        }
                    }
                } label: {
                    if isPurchasing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    } else {
                        Text(store.product?.displayPrice ?? "$2.99")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 32)
                .disabled(isPurchasing)

                // One-time purchase note
                Text(L("One-time purchase. No subscription."))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Restore
                Button(L("Restore Purchases")) {
                    Task {
                        await store.restorePurchases()
                        if store.isPurchased {
                            isPro = true
                            dismiss()
                        }
                    }
                }
                .font(.caption)
                .padding(.bottom, 8)

                // Dismiss
                Button(L("Maybe Later")) {
                    dismiss()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
            Text(text)
                .font(.body)
        }
    }
}
