import Foundation

/// Chat completion API interface
public protocol ChatAPI {
    /// Send a chat completion request to generate responses
    /// - Parameter request: The chat completion request parameters
    /// - Returns: The chat completion response
    func createChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse
    
    /// Convenience method to send a simple chat message
    /// - Parameters:
    ///   - message: The message content
    ///   - model: The model to use
    /// - Returns: The assistant's response message
    func sendMessage(
        _ message: String,
        model: OpenAIModel
    ) async throws -> String
}

/// Implementation of the Chat API
public struct ChatEndpoint: OpenAIFeature, ChatAPI {
    public let client: OpenAIClient
    
    init(client: OpenAIClient) {
        self.client = client
    }
    
    public func createChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        return try await performRequest(
            endpoint: .chatCompletions,
            body: request
        )
    }
    
    public func sendMessage(
        _ message: String,
        model: OpenAIModel = .defaultModel(for: .chatCompletion)
    ) async throws -> String {
        let messages = [ChatMessage(role: .user, content: message)]
        let request = ChatCompletionRequest(model: model, messages: messages)
        
        let response = try await createChatCompletion(request)
        guard let choice = response.choices.first else {
            throw OpenAIError.invalidResponse
        }
        
        return choice.message.content
    }
}
