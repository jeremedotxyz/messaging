import SwiftUI

@main
struct MessagingApp: App {
    @StateObject private var store = ChatStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
