import Foundation

/// Response structure for chat completions
public struct ChatCompletionResponse: Codable, Sendable {
    /// The unique identifier for this completion
    public let id: String
    
    /// The object type (always "chat.completion")
    public let object: String
    
    /// The timestamp of when the completion was created
    public let created: Int
    
    /// The model used for completion
    public let model: String
    
    /// The list of completion choices
    public let choices: [Choice]
    
    /// Usage statistics for the request
    public let usage: Usage
}

// MARK: - Nested Types
public extension ChatCompletionResponse {
    /// A single completion choice
    struct Choice: Codable, Sendable {
        /// The index of this choice in the list
        public let index: Int
        
        /// The generated message
        public let message: ChatMessage
        
        /// Why the completion stopped
        public let finishReason: FinishReason
        
        enum CodingKeys: String, CodingKey {
            case index
            case message
            case finishReason = "finish_reason"
        }
    }
    
    /// Usage statistics for tokens
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
    
    /// Reasons why a completion finished
    enum FinishReason: String, Codable, Sendable {
        /// API returned complete message
        case stop
        
        /// Incomplete model output due to max_tokens parameter or token limit
        case length
        
        /// Omitted content due to content filter
        case contentFilter = "content_filter"
        
        /// The model called a function
        case functionCall = "function_call"
        
        /// The model decided to call a function
        case tool = "tool_calls"
    }
}
