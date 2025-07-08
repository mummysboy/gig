import Foundation

struct Config {
    // MARK: - API Keys
    static let openAIKey: String = {
        // First try to get from environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return envKey
        }
        
        // Fallback to Info.plist for development
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String {
            return plistKey
        }
        
        // No API key found - this should be set via environment variable or Info.plist
        #if DEBUG
        print("⚠️ Warning: OPENAI_API_KEY not found. Please set it in your environment variables or Info.plist")
        return ""
        #else
        fatalError("OPENAI_API_KEY not found in environment or Info.plist")
        #endif
    }()
    
    // MARK: - API Configuration
    static let openAIModel = "gpt-3.5-turbo"
    static let openAIMaxTokens = 500
    static let openAITemperature = 0.7
    
    // MARK: - App Configuration
    static let appName = "Gig"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // MARK: - Validation
    static func validateConfiguration() -> Bool {
        let key = openAIKey
        return !key.isEmpty && key.hasPrefix("sk-")
    }
} 