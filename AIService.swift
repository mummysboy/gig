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
        
        let systemPrompt = """
        You are an AI assistant for a service marketplace app called "Gig". Your job is to:
        1. Analyze user messages to understand their needs
        2. Recommend relevant services from these EXACT categories:
           - Handyman (plumbing, electrical, repairs, home maintenance, carpentry)
           - Tutor (academic subjects, test prep, skills training, homework help)
           - Cleaner (house cleaning, deep cleaning, organizing, laundry)
           - Creative (photography, videography, graphic design, content creation)
           - Coach (personal training, life coaching, career coaching, fitness)
           - Photographer (portraits, events, commercial photography)
           - Personal Trainer (fitness training, nutrition, weight loss)
           - Plumber (plumbing repairs, installations, maintenance)
           - Electrician (electrical work, installations, repairs)
           - Carpenter (woodworking, furniture, construction)
           - Painter (interior/exterior painting, refinishing)
           - Landscaper (gardening, lawn care, outdoor design)
        
        3. Provide a helpful response and specific service recommendations
        
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
            throw AIError.parsingError
        }
    }
    
    func getMockAnalysis(for message: String) -> AIAnalysisResult {
        // Fallback mock response when API is not available
        let lowercasedMessage = message.lowercased()
        
        if lowercasedMessage.contains("plumbing") || lowercasedMessage.contains("leak") || lowercasedMessage.contains("pipe") {
            return AIAnalysisResult(
                response: "I can see you're having plumbing issues. Let me find you a qualified plumber who can help with that.",
                recommendations: [
                    ServiceRecommendation(
                        service: "Plumber",
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
                        service: "Photographer",
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
                        service: "Personal Trainer",
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
                        service: "Electrician",
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
            return AIAnalysisResult(
                response: "I'd be happy to help you find the right service! I can help with handyman work, tutoring, cleaning, photography, personal training, electrical work, and more. Could you tell me more about what you need?",
                recommendations: [
                    ServiceRecommendation(
                        service: "Handyman",
                        description: "General home repairs and maintenance",
                        reasoning: "Handyman services cover a wide range of home needs",
                        urgency: "low"
                    ),
                    ServiceRecommendation(
                        service: "Tutor",
                        description: "Academic tutoring and educational support",
                        reasoning: "Tutoring is a common service need",
                        urgency: "low"
                    ),
                    ServiceRecommendation(
                        service: "Cleaner",
                        description: "Professional house cleaning services",
                        reasoning: "Cleaning is a frequently requested service",
                        urgency: "low"
                    )
                ],
                intent: "General inquiry",
                confidence: 0.5
            )
        }
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
