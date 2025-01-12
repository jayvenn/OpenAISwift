import Foundation

/// Chat API interface
public protocol ChatAPI {
    /// Send a message to the chat model
    /// - Parameters:
    ///   - message: The message to send
    ///   - model: The model to use
    ///   - temperature: What sampling temperature to use
    ///   - functions: The functions that can be called by the model
    ///   - functionCall: Controls how the model uses the available functions
    /// - Returns: The chat completion response
    func sendMessage(
        _ message: String,
        model: OpenAIModel,
        temperature: Double?,
        functions: [FunctionConfiguration]?,
        functionCall: ChatFunctionConfiguration.FunctionCallOption?
    ) async throws -> ChatCompletionResponse
    
    /// Send a message to the chat model with streaming
    /// - Parameters:
    ///   - message: The message to send
    ///   - model: The model to use
    ///   - temperature: What sampling temperature to use
    ///   - functions: The functions that can be called by the model
    ///   - functionCall: Controls how the model uses the available functions
    ///   - delegate: The delegate to receive streaming updates
    func sendMessageStreaming(
        _ message: String,
        model: OpenAIModel,
        temperature: Double?,
        functions: [FunctionConfiguration]?,
        functionCall: ChatFunctionConfiguration.FunctionCallOption?,
        delegate: ChatStreamingDelegate
    ) async throws
    
    /// Send a chat completion request
    /// - Parameter request: The chat completion request
    /// - Returns: The chat completion response
    func sendChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse
    
    /// Send a streaming chat completion request
    /// - Parameters:
    ///   - request: The chat completion request
    ///   - delegate: The delegate to receive streaming updates
    func sendChatCompletionStreaming(
        _ request: ChatCompletionRequest,
        delegate: ChatStreamingDelegate
    ) async throws
}

/// Implementation of the Chat API
public struct ChatEndpoint: OpenAIFeature, ChatAPI {
    public let client: OpenAIClient
    
    init(client: OpenAIClient) {
        self.client = client
    }
    
    public func sendMessage(
        _ message: String,
        model: OpenAIModel = .defaultModel(for: .chatCompletion),
        temperature: Double? = nil,
        functions: [FunctionConfiguration]? = nil,
        functionCall: ChatFunctionConfiguration.FunctionCallOption? = nil
    ) async throws -> ChatCompletionResponse {
        let request = ChatCompletionRequest(
            model: model,
            messages: [ChatMessage(role: .user, content: message)],
            temperature: temperature,
            functions: functions,
            functionCall: functionCall
        )
        return try await sendChatCompletion(request)
    }
    
    public func sendMessageStreaming(
        _ message: String,
        model: OpenAIModel = .defaultModel(for: .chatCompletion),
        temperature: Double? = nil,
        functions: [FunctionConfiguration]? = nil,
        functionCall: ChatFunctionConfiguration.FunctionCallOption? = nil,
        delegate: ChatStreamingDelegate
    ) async throws {
        let request = ChatCompletionRequest(
            model: model,
            messages: [ChatMessage(role: .user, content: message)],
            temperature: temperature,
            stream: true,
            functions: functions,
            functionCall: functionCall
        )
        try await sendChatCompletionStreaming(request, delegate: delegate)
    }
    
    public func sendChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse {
        return try await performRequest(endpoint: .chatCompletions, body: request)
    }
    
    public func sendChatCompletionStreaming(
        _ request: ChatCompletionRequest,
        delegate: ChatStreamingDelegate
    ) async throws {
        var streamingRequest = request
        streamingRequest.stream = true
        try await client.performStreamingRequest(
            endpoint: .chatCompletions,
            body: streamingRequest,
            delegate: delegate
        )
    }
}
