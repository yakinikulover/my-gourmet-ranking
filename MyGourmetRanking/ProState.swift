import Foundation
import RevenueCat

@MainActor
final class ProState: ObservableObject {
    @Published private(set) var isPro = false
    @Published private(set) var isLoading = false
    @Published private(set) var displayPrice = "¥500"
    @Published var message: String?

    private var proPackage: Package?
    private var hasConfiguredRevenueCat = false

    func configure() {
        guard !hasConfiguredRevenueCat else { return }
        hasConfiguredRevenueCat = true

        guard RevenueCatConfig.isConfigured else {
            message = "RevenueCatのSDK Keyが未設定です。公開前に設定してください。"
            return
        }

        Purchases.logLevel = .warn
        Purchases.configure(withAPIKey: RevenueCatConfig.publicSDKKey)

        Task {
            await refreshCustomerInfo()
            await loadOffering()
        }
    }

    func refreshCustomerInfo() async {
        guard RevenueCatConfig.isConfigured else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            apply(customerInfo)
        } catch {
            message = "購入状態を確認できませんでした。通信状態を確認してもう一度お試しください。"
        }
    }

    func loadOffering() async {
        guard RevenueCatConfig.isConfigured else { return }

        do {
            let offerings = try await Purchases.shared.offerings()
            proPackage = offerings.current?.availablePackages.first
            if let price = proPackage?.storeProduct.localizedPriceString {
                displayPrice = price
            }
        } catch {
            message = "Pro商品の情報を取得できませんでした。しばらくしてから再度お試しください。"
        }
    }

    func purchasePro() async {
        guard RevenueCatConfig.isConfigured else {
            message = "RevenueCatのSDK Keyが未設定です。公開前に設定してください。"
            return
        }

        if proPackage == nil {
            await loadOffering()
        }

        guard let proPackage else {
            message = "Pro商品が見つかりませんでした。RevenueCatのOffering設定を確認してください。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await Purchases.shared.purchase(package: proPackage)
            apply(result.customerInfo)
            if !result.userCancelled, isPro {
                message = "Proが有効になりました。"
            }
        } catch {
            message = "購入を完了できませんでした。もう一度お試しください。"
        }
    }

    func restorePurchases() async {
        guard RevenueCatConfig.isConfigured else {
            message = "RevenueCatのSDK Keyが未設定です。公開前に設定してください。"
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            apply(customerInfo)
            message = isPro ? "購入を復元しました。" : "復元できるPro購入が見つかりませんでした。"
        } catch {
            message = "購入を復元できませんでした。もう一度お試しください。"
        }
    }

    private func apply(_ customerInfo: CustomerInfo) {
        isPro = customerInfo.entitlements[RevenueCatConfig.entitlementIdentifier]?.isActive == true
    }
}
