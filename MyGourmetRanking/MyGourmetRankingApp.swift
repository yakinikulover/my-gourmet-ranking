import SwiftUI

@main
struct MyGourmetRankingApp: App {
    @StateObject private var dataStore = GourmetDataStore()
    @StateObject private var proState = ProState()

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
