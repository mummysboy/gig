import Foundation
import Combine

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let maxTokens: Int
    let temperature: Double
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: OpenAIMessage
}

struct ServiceRecommendation: Codable {
    let service: String
    let description: String
    let reasoning: String
    let urgency: String // "low", "medium", "high"
}

struct AIAnalysisResult: Codable {
    let response: String
    let recommendations: [ServiceRecommendation]
    let intent: String
    let confidence: Double
}

class AIService: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    init() {
        // Use the secure configuration
        self.apiKey = Config.openAIKey
        
        // Validate the configuration
        if !Config.validateConfiguration() {
            print("⚠️ Warning: OpenAI API key configuration is invalid")
        }
    }
    
    func analyzeUserMessage(_ message: String) async throws -> AIAnalysisResult {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Get dynamic categories from the sample data
        let categoriesList = Provider.categoriesList
        
        let systemPrompt = """
        You are an AI assistant for a service marketplace app called "Gig". Your job is to:
        1. Analyze user messages to understand their needs
        2. Recommend relevant services from these EXACT categories (these are the only categories available in our system):
           \(Provider.categoriesForAIPrompt)
        
        3. Provide a helpful response and specific service recommendations
        
        IMPORTANT: Only recommend categories that exist in the list above. If a user asks for a service that doesn't match any of these categories, suggest the closest available category or ask for clarification.
        
        Available categories: \(categoriesList)
        
        Respond in JSON format:
        {
            "response": "Your helpful response to the user",
            "recommendations": [
                {
                    "service": "Exact category name from the list above",
                    "description": "Brief description of what this service can help with",
                    "reasoning": "Why you're recommending this service",
                    "urgency": "low/medium/high"
                }
            ],
            "intent": "Brief description of user's intent",
            "confidence": 0.95
        }
        """
        
        let request = OpenAIRequest(
            model: Config.openAIModel,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: message)
            ],
            maxTokens: Config.openAIMaxTokens,
            temperature: Config.openAITemperature
        )
        
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw AIError.encodingError
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = openAIResponse.choices.first?.message.content else {
                throw AIError.noContent
            }
            
            // Parse the JSON response from ChatGPT
            guard let jsonData = content.data(using: .utf8) else {
                throw AIError.parsingError
            }
            
            let analysisResult = try JSONDecoder().decode(AIAnalysisResult.self, from: jsonData)
            return analysisResult
            
        } catch {
            print("[AIService] OpenAI API error (parsing): \(error)")
            throw AIError.parsingError
        }
    }
    
    func getMockAnalysis(for message: String) -> AIAnalysisResult {
        // Fallback mock response when API is not available
        let lowercasedMessage = message.lowercased()
        
        // Get available categories for dynamic recommendations
        let availableCategories = Provider.availableCategories
        
        if lowercasedMessage.contains("plumbing") || lowercasedMessage.contains("leak") || lowercasedMessage.contains("pipe") {
            return AIAnalysisResult(
                response: "I can see you're having plumbing issues. Let me find you a qualified plumber who can help with that.",
                recommendations: [
                    ServiceRecommendation(
                        service: availableCategories.contains("Plumber") ? "Plumber" : "Handyman",
                        description: "Professional plumbing repair and maintenance",
                        reasoning: "Your message mentions plumbing issues which requires specialized skills",
                        urgency: "high"
                    ),
                    ServiceRecommendation(
                        service: "Handyman",
                        description: "General home repairs and maintenance",
                        reasoning: "Handyman can also help with basic plumbing and related repairs",
                        urgency: "medium"
                    )
                ],
                intent: "Plumbing repair needed",
                confidence: 0.9
            )
        } else if lowercasedMessage.contains("tutor") || lowercasedMessage.contains("math") || lowercasedMessage.contains("homework") || lowercasedMessage.contains("study") {
            return AIAnalysisResult(
                response: "I understand you need help with tutoring, particularly in math. I'll connect you with experienced tutors.",
                recommendations: [
                    ServiceRecommendation(
                        service: "Tutor",
                        description: "Expert math tutoring and academic support",
                        reasoning: "You mentioned needing tutoring help with math",
                        urgency: "medium"
                    )
                ],
                intent: "Academic tutoring needed",
                confidence: 0.85
            )
        } else if lowercasedMessage.contains("clean") || lowercasedMessage.contains("housekeeping") || lowercasedMessage.contains("organize") {
            return AIAnalysisResult(
                response: "I can help you find professional cleaning services for your home. Let me connect you with reliable cleaners.",
                recommendations: [
                    ServiceRecommendation(
                        service: "Cleaner",
                        description: "Professional house cleaning and organizing",
                        reasoning: "You mentioned needing cleaning services",
                        urgency: "medium"
                    )
                ],
                intent: "House cleaning needed",
                confidence: 0.8
            )
        } else if lowercasedMessage.contains("photo") || lowercasedMessage.contains("camera") || lowercasedMessage.contains("event") {
            return AIAnalysisResult(
                response: "I can help you find a professional photographer for your event. Let me connect you with talented photographers.",
                recommendations: [
                    ServiceRecommendation(
                        service: availableCategories.contains("Photographer") ? "Photographer" : "Creative",
                        description: "Professional photography for events and portraits",
                        reasoning: "You mentioned needing photography services",
                        urgency: "medium"
                    ),
                    ServiceRecommendation(
                        service: "Creative",
                        description: "Creative services including photography and videography",
                        reasoning: "Creative professionals can also help with photography needs",
                        urgency: "low"
                    )
                ],
                intent: "Photography services needed",
                confidence: 0.8
            )
        } else if lowercasedMessage.contains("trainer") || lowercasedMessage.contains("fitness") || lowercasedMessage.contains("workout") {
            return AIAnalysisResult(
                response: "I can help you find a personal trainer to achieve your fitness goals. Let me connect you with certified trainers.",
                recommendations: [
                    ServiceRecommendation(
                        service: availableCategories.contains("Personal Trainer") ? "Personal Trainer" : "Coach",
                        description: "Certified personal training and fitness coaching",
                        reasoning: "You mentioned needing fitness training",
                        urgency: "medium"
                    ),
                    ServiceRecommendation(
                        service: "Coach",
                        description: "Personal coaching including fitness and wellness",
                        reasoning: "Coaches can also help with fitness and wellness goals",
                        urgency: "low"
                    )
                ],
                intent: "Fitness training needed",
                confidence: 0.8
            )
        } else if lowercasedMessage.contains("electrical") || lowercasedMessage.contains("wiring") || lowercasedMessage.contains("outlet") {
            return AIAnalysisResult(
                response: "I can help you find a qualified electrician for your electrical work. Let me connect you with licensed professionals.",
                recommendations: [
                    ServiceRecommendation(
                        service: availableCategories.contains("Electrician") ? "Electrician" : "Handyman",
                        description: "Professional electrical work and installations",
                        reasoning: "You mentioned needing electrical services",
                        urgency: "high"
                    ),
                    ServiceRecommendation(
                        service: "Handyman",
                        description: "General home repairs including basic electrical work",
                        reasoning: "Handyman can help with basic electrical repairs",
                        urgency: "medium"
                    )
                ],
                intent: "Electrical work needed",
                confidence: 0.9
            )
        } else {
            // Default response with dynamic categories
            let defaultCategories = Array(availableCategories.prefix(3))
            let recommendations = defaultCategories.map { category in
                ServiceRecommendation(
                    service: category,
                    description: "Professional \(category.lowercased()) services",
                    reasoning: "General service category that covers a wide range of needs",
                    urgency: "low"
                )
            }
            
            return AIAnalysisResult(
                response: "I'd be happy to help you find the right service! I can help with \(Provider.categoriesList.lowercased()), and more. Could you tell me more about what you need?",
                recommendations: recommendations,
                intent: "General inquiry",
                confidence: 0.5
            )
        }
    }
    
    /// Enhances a service description using AI, given the service name and user description.
    func enhanceServiceDescription(name: String, description: String) async throws -> String {
        let prompt = """
        You are an expert copywriter for a service marketplace app. Improve the following service description to make it more compelling, clear, and professional. Use the service name for context. Do not change the meaning, just enhance the language. Return only the improved description, nothing else.
        
        Service Name: \(name)
        User Description: \(description)
        """
        let request = OpenAIRequest(
            model: Config.openAIModel,
            messages: [
                OpenAIMessage(role: "system", content: "You are a helpful assistant."),
                OpenAIMessage(role: "user", content: prompt)
            ],
            maxTokens: 200,
            temperature: 0.7
        )
        guard let url = URL(string: baseURL) else {
            throw AIError.invalidURL
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            urlRequest.httpBody = try JSONEncoder().encode(request)
        } catch {
            throw AIError.encodingError
        }
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        guard let content = openAIResponse.choices.first?.message.content else {
            throw AIError.noContent
        }
        // Return the improved description directly
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum AIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case invalidResponse
    case apiError(String)
    case noContent
    case parsingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let message):
            return "API Error: \(message)"
        case .noContent:
            return "No content received"
        case .parsingError:
            return "Failed to parse response"
        }
    }
} 
