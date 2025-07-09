// AIService.swift — Enhanced with Similarity Logic

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
    let urgency: String
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
        self.apiKey = Config.openAIKey
        if !Config.validateConfiguration() {
            print("⚠️ Warning: OpenAI API key configuration is invalid")
        }
    }

    func analyzeUserMessage(_ message: String) async throws -> AIAnalysisResult {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let categoriesList = Provider.categoriesList
        let systemPrompt = """
        You are an AI assistant for a service marketplace app called \"Gig\". Your responsibilities:

        1. Understand the user's message and identify their intent.
        2. Match their request to services from the following categories:
           \(Provider.categoriesForAIPrompt)

        3. If there’s no exact match, suggest the closest matching services based on semantic similarity or shared functionality.

        4. Always use categories that exist in the list above. If a service doesn't exist, recommend the most relevant alternative based on the service description.

        5. Output only valid JSON, in this format:

        {
          "response": "Concise and actionable response to the user",
          "recommendations": [
            {
              "service": "Exact match or most relevant category name from the list",
              "description": "Short explanation of what this service covers",
              "reasoning": "Why this service was recommended (match, similarity, or substitution)",
              "urgency": "low/medium/high"
            }
          ],
          "intent": "Short phrase explaining user’s intent",
          "confidence": 0.0 to 1.0
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError("HTTP \(statusCode): \(errorMessage)")
        }

        guard let content = try JSONDecoder().decode(OpenAIResponse.self, from: data).choices.first?.message.content else {
            throw AIError.noContent
        }

        guard let jsonData = content.data(using: .utf8) else {
            throw AIError.parsingError
        }

        return try JSONDecoder().decode(AIAnalysisResult.self, from: jsonData)
    }

    func getMockAnalysis(for message: String) -> AIAnalysisResult {
        let lowercased = message.lowercased()
        let categories = Provider.availableCategories

        let match = categories.max(by: { fuzzySimilarity($0, lowercased) < fuzzySimilarity($1, lowercased) })

        if let best = match, fuzzySimilarity(best, lowercased) > 0.4 {
            return AIAnalysisResult(
                response: "We couldn’t find an exact match, but here’s something close:",
                recommendations: [
                    ServiceRecommendation(
                        service: best,
                        description: "Professional \(best.lowercased()) services",
                        reasoning: "This category closely matches your request",
                        urgency: "medium"
                    )
                ],
                intent: "Similar service",
                confidence: 0.6
            )
        }

        return AIAnalysisResult(
            response: "Here are a few general services we offer:",
            recommendations: categories.prefix(3).map {
                ServiceRecommendation(
                    service: $0,
                    description: "Professional \($0.lowercased()) services",
                    reasoning: "Popular default recommendation",
                    urgency: "low"
                )
            },
            intent: "General inquiry",
            confidence: 0.5
        )
    }

    func enhanceServiceDescription(name: String, description: String) async throws -> String {
        let prompt = """
        You are an expert copywriter for a service marketplace app. Improve the following service description to make it more compelling, clear, and professional. Do not change the meaning.
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

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw AIError.apiError("HTTP \(statusCode): \(errorMessage)")
        }

        guard let content = try JSONDecoder().decode(OpenAIResponse.self, from: data).choices.first?.message.content else {
            throw AIError.noContent
        }

        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Basic fuzzy similarity using token overlap (replace with embeddings for production)
    private func fuzzySimilarity(_ a: String, _ b: String) -> Double {
        let aWords = Set(a.lowercased().split(separator: " "))
        let bWords = Set(b.lowercased().split(separator: " "))
        let overlap = aWords.intersection(bWords)
        return Double(overlap.count) / Double(aWords.union(bWords).count)
    }
}

enum AIError: Error, LocalizedError {
    case invalidURL, encodingError, invalidResponse, apiError(String), noContent, parsingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .encodingError: return "Failed to encode request"
        case .invalidResponse: return "Invalid server response"
        case .apiError(let msg): return "API Error: \(msg)"
        case .noContent: return "No content received"
        case .parsingError: return "Failed to parse response"
        }
    }
}
