import Foundation
import Combine

class ChatService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    
    private var cancellables = Set<AnyCancellable>()
    
    func sendMessage(_ content: String) {
        let userMessage = Message(content: content, isFromUser: true)
        messages.append(userMessage)
        
        // Simulate AI processing
        isLoading = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
            self?.generateAIResponse(to: content)
        }
    }
    
    private func generateAIResponse(to userMessage: String) {
        let lowercasedMessage = userMessage.lowercased()
        var response = ""
        var suggestedProviders: [Provider] = []
        
        // Simple keyword-based response system
        if lowercasedMessage.contains("handyman") || lowercasedMessage.contains("plumbing") || lowercasedMessage.contains("electrical") || lowercasedMessage.contains("repair") {
            response = "I found some great handymen in your area who can help with that! Here are a few options:"
            suggestedProviders = Provider.sampleData.filter { $0.category == "Handyman" }
        } else if lowercasedMessage.contains("tutor") || lowercasedMessage.contains("math") || lowercasedMessage.contains("science") || lowercasedMessage.contains("english") || lowercasedMessage.contains("study") {
            response = "I have excellent tutors available who can help with your studies. Here are some recommendations:"
            suggestedProviders = Provider.sampleData.filter { $0.category == "Tutor" }
        } else if lowercasedMessage.contains("clean") || lowercasedMessage.contains("cleaning") || lowercasedMessage.contains("house") {
            response = "I found professional cleaners who can help keep your home spotless. Here are some options:"
            suggestedProviders = Provider.sampleData.filter { $0.category == "Cleaner" }
        } else if lowercasedMessage.contains("photo") || lowercasedMessage.contains("photographer") || lowercasedMessage.contains("video") || lowercasedMessage.contains("creative") {
            response = "I have talented photographers and videographers available for your creative needs. Here are some options:"
            suggestedProviders = Provider.sampleData.filter { $0.category == "Creative" }
        } else if lowercasedMessage.contains("trainer") || lowercasedMessage.contains("fitness") || lowercasedMessage.contains("coach") || lowercasedMessage.contains("workout") {
            response = "I found certified personal trainers and coaches who can help you reach your fitness goals. Here are some options:"
            suggestedProviders = Provider.sampleData.filter { $0.category == "Coach" }
        } else {
            response = "I understand you're looking for services. Let me find some great providers in your area. What specific type of service do you need? I can help with handyman work, tutoring, cleaning, photography, personal training, and more."
            suggestedProviders = Array(Provider.sampleData.prefix(3))
        }
        
        let aiMessage = Message(
            content: response,
            isFromUser: false,
            suggestedProviders: suggestedProviders.isEmpty ? nil : suggestedProviders
        )
        
        messages.append(aiMessage)
    }
    
    func clearChat() {
        messages.removeAll()
    }
} 