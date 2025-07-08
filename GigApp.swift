import SwiftUI

@main
struct GigApp: App {
    init() {
        print("OpenAI API Key: \(Config.openAIKey.prefix(10)))")
        print("Config valid: \(Config.validateConfiguration())")
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}