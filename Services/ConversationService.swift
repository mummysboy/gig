import Foundation
import Combine

class ConversationService: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversation: Conversation?
    @Published var messages: [ConversationMessage] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadConversations()
    }
    
    func loadConversations() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.conversations = Conversation.sampleData
            self?.isLoading = false
        }
    }
    
    func loadMessages(for conversationId: String) {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.messages = ConversationMessage.sampleMessages(for: conversationId)
            self?.isLoading = false
        }
    }
    
    func sendMessage(_ content: String, to conversationId: String) {
        let message = ConversationMessage(
            conversationId: conversationId,
            senderId: "currentUser",
            senderName: "You",
            content: content,
            isFromCurrentUser: true
        )
        
        messages.append(message)
        
        // Update conversation's last message
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index] = Conversation(
                id: conversations[index].id,
                participantId: conversations[index].participantId,
                participantName: conversations[index].participantName,
                participantImageURL: conversations[index].participantImageURL,
                lastMessage: content,
                lastMessageTime: Date(),
                unreadCount: conversations[index].unreadCount,
                isProvider: conversations[index].isProvider
            )
        }
        
        // Simulate response from provider
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            let response = self?.generateProviderResponse(to: content) ?? "Thanks for your message. I'll get back to you soon."
            
            let providerMessage = ConversationMessage(
                conversationId: conversationId,
                senderId: "provider",
                senderName: "Provider",
                content: response,
                isFromCurrentUser: false
            )
            
            self?.messages.append(providerMessage)
            
            // Update conversation's last message
            if let index = self?.conversations.firstIndex(where: { $0.id == conversationId }) {
                self?.conversations[index] = Conversation(
                    id: self?.conversations[index].id ?? "",
                    participantId: self?.conversations[index].participantId ?? "",
                    participantName: self?.conversations[index].participantName ?? "",
                    participantImageURL: self?.conversations[index].participantImageURL,
                    lastMessage: response,
                    lastMessageTime: Date(),
                    unreadCount: 0,
                    isProvider: self?.conversations[index].isProvider ?? false
                )
            }
        }
    }
    
    private func generateProviderResponse(to message: String) -> String {
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("plumbing") || lowercasedMessage.contains("sink") || lowercasedMessage.contains("water") {
            return "I can definitely help with that plumbing issue. What time works best for you tomorrow?"
        } else if lowercasedMessage.contains("tutor") || lowercasedMessage.contains("math") || lowercasedMessage.contains("homework") {
            return "I'd be happy to help with tutoring. What subject and grade level are we working with?"
        } else if lowercasedMessage.contains("cleaning") || lowercasedMessage.contains("house") {
            return "I can help with house cleaning. How many rooms and what's your preferred schedule?"
        } else if lowercasedMessage.contains("price") || lowercasedMessage.contains("cost") || lowercasedMessage.contains("rate") {
            return "My rates start at $50/hour. I can provide a detailed quote once I understand your specific needs."
        } else if lowercasedMessage.contains("available") || lowercasedMessage.contains("when") || lowercasedMessage.contains("time") {
            return "I'm available weekdays 9 AM - 6 PM and weekends 10 AM - 4 PM. What works for you?"
        } else {
            return "Thanks for your message! I'll get back to you with more details soon."
        }
    }
    
    func markConversationAsRead(_ conversationId: String) {
        if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
            conversations[index] = Conversation(
                id: conversations[index].id,
                participantId: conversations[index].participantId,
                participantName: conversations[index].participantName,
                participantImageURL: conversations[index].participantImageURL,
                lastMessage: conversations[index].lastMessage,
                lastMessageTime: conversations[index].lastMessageTime,
                unreadCount: 0,
                isProvider: conversations[index].isProvider
            )
        }
    }
    
    func createNewConversation(with provider: Provider) -> String {
        let conversationId = UUID().uuidString
        let conversation = Conversation(
            id: conversationId,
            participantId: provider.id,
            participantName: provider.name,
            participantImageURL: provider.profileImageURL,
            lastMessage: "",
            lastMessageTime: Date(),
            unreadCount: 0,
            isProvider: true
        )
        
        conversations.insert(conversation, at: 0)
        return conversationId
    }
    
    func deleteConversation(_ conversationId: String) {
        conversations.removeAll { $0.id == conversationId }
        if currentConversation?.id == conversationId {
            currentConversation = nil
            messages.removeAll()
        }
    }
    
    func searchConversations(query: String) -> [Conversation] {
        guard !query.isEmpty else { return conversations }
        
        return conversations.filter { conversation in
            conversation.participantName.localizedCaseInsensitiveContains(query) ||
            conversation.lastMessage.localizedCaseInsensitiveContains(query)
        }
    }
} 