import Foundation

struct Config {
    // MARK: - API Keys
    static let openAIKey: String = {
        print("🔍 [Config] Checking for OpenAI API key...")
        print("🔍 [Config] All environment variables: \(ProcessInfo.processInfo.environment)")
        // First try to get from environment variable
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            print("✅ [Config] Found API key in environment variable: \(envKey.prefix(10))... (source: ENV)")
            return envKey
        } else {
            print("❌ [Config] No API key found in environment variable")
        }
        // Fallback to Info.plist for development
        if let plistKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !plistKey.isEmpty {
            print("✅ [Config] Found API key in Info.plist: \(plistKey.prefix(10))... (source: Info.plist)")
            return plistKey
        } else {
            print("❌ [Config] No API key found in Info.plist")
        }
        print("⚠️ [Config] No valid OpenAI API key found. Fallback/mock mode will be used.")
        return ""
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
        let valid = !openAIKey.isEmpty && openAIKey.starts(with: "sk-")
        print("[Config] API key validation: \(valid ? "✅ valid" : "❌ invalid")")
        return valid
    }
} 