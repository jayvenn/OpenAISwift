import Foundation

/// Represents a streaming chat completion response chunk
public struct ChatStreamingResponse: Codable {
    /// The ID of the chat completion
    public let id: String
    
    /// The object type (always "chat.completion.chunk")
    public let object: String
    
    /// The timestamp of when the completion was created
    public let created: Int
    
    /// The model used for completion
    public let model: String
    
    /// The streaming choices containing delta messages
    public let choices: [ChatStreamingChoice]
}

/// Represents a streaming choice in the chat completion response
public struct ChatStreamingChoice: Codable {
    /// The index of this choice
    public let index: Int
    
    /// The delta containing the message content
    public let delta: ChatStreamingDelta
    
    /// The reason why the streaming stopped, if applicable
    public let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case index
        case delta
        case finishReason = "finish_reason"
    }
}

/// Represents the delta content in a streaming response
public struct ChatStreamingDelta: Codable {
    /// The role of the message, if present in the delta
    public let role: ChatRole?
    
    /// The content of the message, if present in the delta
    public let content: String?
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
