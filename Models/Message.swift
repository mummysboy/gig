import Foundation

struct Message: Identifiable, Codable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let suggestedProviders: [Provider]?
    
    init(id: String = UUID().uuidString,
         content: String,
         isFromUser: Bool,
         timestamp: Date = Date(),
         suggestedProviders: [Provider]? = nil) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.suggestedProviders = suggestedProviders
    }
} 