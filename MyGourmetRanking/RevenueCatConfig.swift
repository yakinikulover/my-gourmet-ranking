import Foundation

enum RevenueCatConfig {
    static let entitlementIdentifier = "pro"

    // Replace before App Store submission with the RevenueCat public SDK key
    // for this app. Keeping it centralized avoids scattering environment values.
    static let publicSDKKey = "REVENUECAT_PUBLIC_SDK_KEY"

    static let termsURL = URL(string: "https://example.com/terms")!
    static let privacyURL = URL(string: "https://example.com/privacy")!

    static var isConfigured: Bool {
        !publicSDKKey.isEmpty && publicSDKKey != "REVENUECAT_PUBLIC_SDK_KEY"
    }
}
