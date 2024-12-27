import Foundation

/// Response structure for chat completion
public struct ChatCompletionResponse: Codable, Sendable {
    /// The ID of the chat completion
    public let id: String
    
    /// The object type (always "chat.completion")
    public let object: String
    
    /// The Unix timestamp of when the chat completion was created
    public let created: Int
    
    /// The model used for completion
    public let model: String
    
    /// The list of completion choices
    public let choices: [Choice]
    
    /// Usage statistics for the completion
    public let usage: Usage
}

// MARK: - Nested Types
public extension ChatCompletionResponse {
    struct Choice: Codable, Sendable {
        /// The index of this choice
        public let index: Int
        
        /// The chat message generated
        public let message: ChatMessage
        
        /// Why the completion stopped
        public let finishReason: String?
        
        enum CodingKeys: String, CodingKey {
            case index, message
            case finishReason = "finish_reason"
        }
    }
    
    struct Usage: Codable, Sendable {
        /// Number of tokens in the prompt
        public let promptTokens: Int
        
        /// Number of tokens in the completion
        public let completionTokens: Int
        
        /// Total number of tokens used
        public let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case completionTokens = "completion_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
