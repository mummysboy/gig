import Foundation

struct Conversation: Identifiable, Codable {
    let id: String
    let participantId: String
    let participantName: String
    let participantImageURL: String?
    let lastMessage: String
    let lastMessageTime: Date
    let unreadCount: Int
    let isProvider: Bool
    
    init(id: String = UUID().uuidString,
         participantId: String,
         participantName: String,
         participantImageURL: String? = nil,
         lastMessage: String = "",
         lastMessageTime: Date = Date(),
         unreadCount: Int = 0,
         isProvider: Bool = false) {
        self.id = id
        self.participantId = participantId
        self.participantName = participantName
        self.participantImageURL = participantImageURL
        self.lastMessage = lastMessage
        self.lastMessageTime = lastMessageTime
        self.unreadCount = unreadCount
        self.isProvider = isProvider
    }
}

struct ConversationMessage: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let content: String
    let timestamp: Date
    let isFromCurrentUser: Bool
    let messageType: MessageType
    
    init(id: String = UUID().uuidString,
         conversationId: String,
         senderId: String,
         senderName: String,
         content: String,
         timestamp: Date = Date(),
         isFromCurrentUser: Bool = false,
         messageType: MessageType = .text) {
        self.id = id
        self.conversationId = conversationId
        self.senderId = senderId
        self.senderName = senderName
        self.content = content
        self.timestamp = timestamp
        self.isFromCurrentUser = isFromCurrentUser
        self.messageType = messageType
    }
}

enum MessageType: String, Codable, CaseIterable {
    case text = "text"
    case image = "image"
    case location = "location"
    case serviceRequest = "service_request"
    case payment = "payment"
    
    var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .image:
            return "Image"
        case .location:
            return "Location"
        case .serviceRequest:
            return "Service Request"
        case .payment:
            return "Payment"
        }
    }
}

// MARK: - Sample Data
extension Conversation {
    static let sampleData: [Conversation] = [
        Conversation(
            participantId: "provider1",
            participantName: "John Smith",
            participantImageURL: "https://example.com/john.jpg",
            lastMessage: "I can help you with that plumbing issue tomorrow at 2 PM.",
            lastMessageTime: Date().addingTimeInterval(-3600),
            unreadCount: 2,
            isProvider: true
        ),
        Conversation(
            participantId: "provider2",
            participantName: "Sarah Johnson",
            participantImageURL: "https://example.com/sarah.jpg",
            lastMessage: "Thank you for the great service!",
            lastMessageTime: Date().addingTimeInterval(-7200),
            unreadCount: 0,
            isProvider: true
        ),
        Conversation(
            participantId: "provider3",
            participantName: "Mike Wilson",
            participantImageURL: "https://example.com/mike.jpg",
            lastMessage: "What time works best for you?",
            lastMessageTime: Date().addingTimeInterval(-86400),
            unreadCount: 1,
            isProvider: true
        ),
        Conversation(
            participantId: "user1",
            participantName: "Emily Davis",
            participantImageURL: "https://example.com/emily.jpg",
            lastMessage: "I need help with my math homework.",
            lastMessageTime: Date().addingTimeInterval(-1800),
            unreadCount: 0,
            isProvider: false
        )
    ]
}

extension ConversationMessage {
    static func sampleMessages(for conversationId: String) -> [ConversationMessage] {
        [
            ConversationMessage(
                conversationId: conversationId,
                senderId: "currentUser",
                senderName: "You",
                content: "Hi! I need help with a plumbing issue in my kitchen.",
                timestamp: Date().addingTimeInterval(-7200),
                isFromCurrentUser: true
            ),
            ConversationMessage(
                conversationId: conversationId,
                senderId: "provider1",
                senderName: "John Smith",
                content: "Hello! I'd be happy to help. What exactly is the issue?",
                timestamp: Date().addingTimeInterval(-7000),
                isFromCurrentUser: false
            ),
            ConversationMessage(
                conversationId: conversationId,
                senderId: "currentUser",
                senderName: "You",
                content: "The sink is clogged and water is backing up.",
                timestamp: Date().addingTimeInterval(-6800),
                isFromCurrentUser: true
            ),
            ConversationMessage(
                conversationId: conversationId,
                senderId: "provider1",
                senderName: "John Smith",
                content: "I can help you with that plumbing issue tomorrow at 2 PM.",
                timestamp: Date().addingTimeInterval(-3600),
                isFromCurrentUser: false
            )
        ]
    }
} 