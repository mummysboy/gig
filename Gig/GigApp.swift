import SwiftUI

@main
struct GigApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // Optional: force light mode
        }
    }
}