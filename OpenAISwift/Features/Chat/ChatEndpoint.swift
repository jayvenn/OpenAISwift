import Foundation

extension OpenAIClient {
    /// Send a chat completion request to generate responses
    /// - Parameter request: The chat completion request parameters
    /// - Returns: The chat completion response
    public func createChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        return try await performRequest(
            endpoint: .chatCompletions,
            body: request
        )
    }
    
    /// Convenience method to send a simple chat message
    /// - Parameters:
    ///   - message: The message content
    ///   - model: The model to use (defaults to gpt-3.5-turbo)
    /// - Returns: The assistant's response message
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
