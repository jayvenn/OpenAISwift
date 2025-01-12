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
    
    /// Send a streaming chat completion request
    /// - Parameters:
    ///   - request: The chat completion request parameters
    ///   - delegate: The delegate to receive streaming updates
    public func createStreamingChatCompletion(
        _ request: ChatCompletionRequest,
        delegate: ChatStreamingDelegate
    ) async throws {
        var streamingRequest = request
        streamingRequest.stream = true
        
        try await performStreamingRequest(
            endpoint: .chatCompletions,
            body: streamingRequest,
            delegate: delegate
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
        
        return choice.message.content ?? ""
    }
    
    /// Convenience method to send a simple streaming chat message
    /// - Parameters:
    ///   - message: The message content
    ///   - model: The model to use (defaults to gpt-3.5-turbo)
    ///   - delegate: The delegate to receive streaming updates
    public func sendStreamingMessage(
        _ message: String,
        model: OpenAIModel = .defaultModel(for: .chatCompletion),
        delegate: ChatStreamingDelegate
    ) async throws {
        let messages = [ChatMessage(role: .user, content: message)]
        let request = ChatCompletionRequest(model: model, messages: messages)
        try await createStreamingChatCompletion(request, delegate: delegate)
    }
}
