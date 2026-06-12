import SwiftUI
import CoreText

@main
struct MyGourmetRankingApp: App {
    @StateObject private var dataStore = GourmetDataStore()
    @StateObject private var proState = ProState()

    init() {
        BrushFont.registerIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
                .environmentObject(proState)
                .task {
                    proState.configure()
                }
        }
    }
}

/// Registers the bundled brush calligraphy font (Yuji Syuku, OFL) used for the
/// onboarding hero title. The font ships as a Data Set in the asset catalog and
/// is registered at runtime so no Info.plist entry is required.
enum BrushFont {
    /// PostScript name of the bundled brush font.
    static let postScriptName = "YujiSyuku-Regular"

    private static var didRegister = false

    static func registerIfNeeded() {
        guard !didRegister else { return }
        didRegister = true

        guard let asset = NSDataAsset(name: "YujiSyukuBrush"),
              let provider = CGDataProvider(data: asset.data as CFData),
              let font = CGFont(provider) else {
            return
        }
        CTFontManagerRegisterGraphicsFont(font, nil)
    }
}

extension Font {
    /// Brush calligraphy title font, matching the onboarding artwork.
    static func brush(_ size: CGFloat) -> Font {
        .custom(BrushFont.postScriptName, size: size)
    }
}
