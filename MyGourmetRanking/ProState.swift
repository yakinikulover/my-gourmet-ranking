import Foundation
import StoreKit

/// Owns the Pro-unlock entitlement using StoreKit 2 directly (no third-party SDK).
/// The public surface (`isPro`, `displayPrice`, `purchasePro`, `restorePurchases`)
/// is intentionally unchanged so the paywall and feature gates keep working.
@MainActor
final class ProState: ObservableObject {
    @Published private(set) var isPro = false
    @Published private(set) var isLoading = false
    @Published private(set) var displayPrice = "¥500"
    @Published var message: String?

    private var product: Product?
    private var updatesTask: Task<Void, Never>?
    private var hasConfigured = false
    private var realEntitled = false
    private var sampleUnlock = false

    func configure() {
        guard !hasConfigured else { return }
        hasConfigured = true

        if StoreConfig.forceProForUAT {
            isPro = true
        }

        // Observe transactions that arrive outside an explicit purchase call:
        // Ask-to-Buy approvals, purchases made on another device, and refunds.
        updatesTask = Task { [weak self] in
            for await update in Transaction.updates {
                await self?.handle(update)
            }
        }

        Task {
            await loadProduct()
            await refreshEntitlements()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [StoreConfig.proProductID])
            product = products.first
            if let price = product?.displayPrice {
                displayPrice = price
            }
        } catch {
            message = "Pro商品の情報を取得できませんでした。しばらくしてから再度お試しください。"
        }
    }

    /// Re-derives `isPro` from the current StoreKit entitlements.
    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            if transaction.productID == StoreConfig.proProductID,
               transaction.revocationDate == nil {
                entitled = true
            }
        }
        applyEntitled(entitled)
    }

    func purchasePro() async {
        if product == nil {
            await loadProduct()
        }
        guard let product else {
            message = "Pro商品が見つかりませんでした。時間をおいて再度お試しください。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                await handle(verification)
                if isPro {
                    message = "Proが有効になりました。"
                }
            case .userCancelled:
                break
            case .pending:
                message = "購入は承認待ちです。完了するとProが有効になります。"
            @unknown default:
                break
            }
        } catch {
            message = "購入を完了できませんでした。もう一度お試しください。"
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        // AppStore.sync() re-syncs the receipt; it throws if the user cancels the
        // App Store sign-in sheet, in which case we still re-check entitlements.
        try? await AppStore.sync()
        await refreshEntitlements()
        message = isPro ? "購入を復元しました。" : "復元できるPro購入が見つかりませんでした。"
    }

    private func handle(_ verification: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = verification else { return }
        if transaction.productID == StoreConfig.proProductID {
            applyEntitled(transaction.revocationDate == nil)
        }
        await transaction.finish()
    }

    private func applyEntitled(_ entitled: Bool) {
        realEntitled = entitled
        recomputePro()
    }

    /// Temporarily grants Pro access for the sample-experience mode (no purchase,
    /// no persistence). Cleared when the user leaves the sample.
    func setSampleUnlock(_ on: Bool) {
        sampleUnlock = on
        recomputePro()
    }

    private func recomputePro() {
        isPro = StoreConfig.forceProForUAT || realEntitled || sampleUnlock
    }
}
