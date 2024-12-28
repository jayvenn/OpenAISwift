import Foundation

/// Chat completion API interface
public protocol ChatAPI {
    /// Send a chat completion request to generate responses
    /// - Parameter request: The chat completion request parameters
    /// - Returns: The chat completion response
    func createChatCompletion(_ request: ChatCompletionRequest) async throws -> ChatCompletionResponse
    
    /// Convenience method to send chat messages
    /// - Parameters:
    ///   - messages: Array of chat messages
    ///   - model: The model to use
    /// - Returns: The assistant's response message
    func sendMessage(
        _ messages: [ChatMessage],
        model: OpenAIModel
    ) async throws -> ChatMessage
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
        _ messages: [ChatMessage],
        model: OpenAIModel = .defaultModel(for: .chatCompletion)
    ) async throws -> ChatMessage {
        let request = ChatCompletionRequest(model: model, messages: messages)
        
        do {
            let response = try await createChatCompletion(request)
            guard let choice = response.choices.first else {
                let error = OpenAIError.invalidResponse
                print("Error in sendMessage: \(error.localizedDescription)")
                throw error
            }
            return choice.message
        } catch let error as OpenAIError {
            switch error {
            case .httpError(let statusCode, let data):
                if let errorResponse = try? JSONDecoder().decode(OpenAIErrorResponse.self, from: data) {
                    print("OpenAI API Error (\(statusCode)): \(errorResponse.error.message)")
                } else {
                    print("HTTP Error \(statusCode): \(error.localizedDescription)")
                }
            default:
                print("Error in sendMessage: \(error.localizedDescription)")
            }
            throw error
        } catch {
            print("Unexpected error in sendMessage: \(error.localizedDescription)")
            throw error
        }
    }
}
