import Foundation
import Combine

class ChatService: ObservableObject {
    @Published var messages: [Message] = []
    @Published var isLoading = false
    @Published var error: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let aiService = AIService()
    
    func sendMessage(_ content: String) {
        let userMessage = Message(content: content, isFromUser: true)
        messages.append(userMessage)
        
        // Start AI analysis
        isLoading = true
        error = nil
        
        Task {
            await analyzeMessageWithAI(content)
        }
    }
    
    @MainActor
    private func analyzeMessageWithAI(_ userMessage: String) async {
        do {
            // Try to get AI analysis (will use mock if API key is not set)
            let analysis = try await aiService.analyzeUserMessage(userMessage)
            
            // Map AI recommendations to actual providers
            let suggestedProviders = mapRecommendationsToProviders(analysis.recommendations)
            
            let aiMessage = Message(
                content: analysis.response,
                isFromUser: false,
                suggestedProviders: suggestedProviders.isEmpty ? nil : suggestedProviders
            )
            
            messages.append(aiMessage)
            
        } catch {
            // Fallback to mock analysis if AI fails
            let mockAnalysis = aiService.getMockAnalysis(for: userMessage)
            let suggestedProviders = mapRecommendationsToProviders(mockAnalysis.recommendations)
            
            let aiMessage = Message(
                content: mockAnalysis.response,
                isFromUser: false,
                suggestedProviders: suggestedProviders.isEmpty ? nil : suggestedProviders
            )
            
            messages.append(aiMessage)
            self.error = "Using fallback analysis. Set up your OpenAI API key for full AI capabilities."
        }
        
        isLoading = false
    }
    
    private func mapRecommendationsToProviders(_ recommendations: [ServiceRecommendation]) -> [Provider] {
        var providers: [Provider] = []
        
        print("[ChatService] Mapping \(recommendations.count) recommendations to providers")
        
        for recommendation in recommendations {
            let category = recommendation.service
            print("[ChatService] Looking for providers in category: '\(category)'")
            
            let matchingProviders = Provider.sampleData.filter { $0.category == category }
            print("[ChatService] Found \(matchingProviders.count) providers for category '\(category)'")
            
            if !matchingProviders.isEmpty {
                // Add up to 3 providers per category
                let selectedProviders = Array(matchingProviders.prefix(3))
                providers.append(contentsOf: selectedProviders)
                print("[ChatService] Added \(selectedProviders.count) providers for '\(category)': \(selectedProviders.map { $0.name })")
            } else {
                // If no exact match, add some general providers
                let generalProviders = Array(Provider.sampleData.prefix(2))
                providers.append(contentsOf: generalProviders)
                print("[ChatService] No exact match for '\(category)', added general providers: \(generalProviders.map { $0.name })")
            }
        }
        
        // Remove duplicates and limit to 6 total
        let uniqueProviders = Array(Set(providers)).prefix(6).map { $0 }
        print("[ChatService] Final provider list (\(uniqueProviders.count) providers): \(uniqueProviders.map { "\($0.name) (\($0.category))" })")
        
        return uniqueProviders
    }
    
    // Fallback method for backward compatibility
    private func generateAIResponse(to userMessage: String) {
        let mockAnalysis = aiService.getMockAnalysis(for: userMessage)
        let suggestedProviders = mapRecommendationsToProviders(mockAnalysis.recommendations)
        
        let aiMessage = Message(
            content: mockAnalysis.response,
            isFromUser: false,
            suggestedProviders: suggestedProviders.isEmpty ? nil : suggestedProviders
        )
        
        messages.append(aiMessage)
    }
    
    func clearChat() {
        messages.removeAll()
    }
} 