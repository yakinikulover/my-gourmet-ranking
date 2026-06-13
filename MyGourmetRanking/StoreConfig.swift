import Foundation

/// Central configuration for the in-app purchase (StoreKit 2).
///
/// The app ships a single non-consumable "Pro" unlock. Keeping the identifier
/// and the legal links here avoids scattering environment values across the app.
enum StoreConfig {
    /// App Store Connect non-consumable product identifier for the Pro unlock.
    /// This MUST match the product configured in App Store Connect exactly.
    /// (Mismatch here makes Product.products(for:) return empty → purchase errors,
    ///  which caused the Guideline 2.1(b) review rejection.)
    static let proProductID = "com.mysmallgoodapps.gourmetrank2"

    static let termsURL = URL(string: "https://yakinikulover.github.io/my-gourmet-ranking/terms.html")!
    static let privacyURL = URL(string: "https://yakinikulover.github.io/my-gourmet-ranking/privacy.html")!

    /// Debug-only switch that unlocks Pro for internal UAT without purchasing.
    /// Always false in Release builds, so production users never get a free unlock.
    #if DEBUG
    static let forceProForUAT = false
    #else
    static let forceProForUAT = false
    #endif
}
