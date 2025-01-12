import Foundation

/// Response structure for streaming chat completions
public struct ChatStreamingResponse: Codable, Sendable {
    /// The unique identifier for this completion
    public let id: String
    
    /// The object type (always "chat.completion.chunk")
    public let object: String
    
    /// The timestamp of when the chunk was created
    public let created: Int
    
    /// The model used for completion
    public let model: String
    
    /// The list of completion choices
    public let choices: [Choice]
}

// MARK: - Nested Types
public extension ChatStreamingResponse {
    /// A single completion choice in a streaming response
    struct Choice: Codable, Sendable {
        /// The index of this choice in the list
        public let index: Int
        
        /// The delta of content to append
        public let delta: Delta
        
        /// Why the completion stopped (if applicable)
        public let finishReason: FinishReason?
        
        enum CodingKeys: String, CodingKey {
            case index
            case delta
            case finishReason = "finish_reason"
        }
    }
    
    /// The delta content to append
    struct Delta: Codable, Sendable {
        /// The role of the message author (only in first chunk)
        public let role: ChatRole?
        
        /// The content to append
        public let content: String?
        
        /// The function call to append
        public let functionCall: ChatFunctionCall?
        
        enum CodingKeys: String, CodingKey {
            case role
            case content
            case functionCall = "function_call"
        }
    }
    
    /// Reasons why a streaming completion finished
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

/// Protocol for handling streaming chat completions
public protocol ChatStreamingDelegate: AnyObject {
    /// Called when a new chunk of the response is received
    /// - Parameter chunk: The streaming response chunk
    func didReceive(chunk: ChatStreamingResponse)
    
    /// Called when the streaming is completed
    func didComplete()
    
    /// Called when an error occurs during streaming
    /// - Parameter error: The error that occurred
    func didError(_ error: Error)
}
