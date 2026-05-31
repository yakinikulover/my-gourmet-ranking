import SwiftUI

@main
struct MyGourmetRankingApp: App {
    @StateObject private var dataStore = GourmetDataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
    }
}
