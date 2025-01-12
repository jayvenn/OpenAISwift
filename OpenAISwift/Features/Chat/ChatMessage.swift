import Foundation

/// Represents a message in a chat conversation
public struct ChatMessage: Codable, Sendable {
    /// The role of the message author
    public let role: ChatRole
    
    /// The content of the message
    public let content: String?
    
    /// Name of the author of this message
    public let name: String?
    
    /// The function call made by the assistant
    public let functionCall: ChatFunctionCall?
    
    public init(
        role: ChatRole,
        content: String? = nil,
        name: String? = nil,
        functionCall: ChatFunctionCall? = nil
    ) {
        self.role = role
        self.content = content
        self.name = name
        self.functionCall = functionCall
    }
    
    enum CodingKeys: String, CodingKey {
        case role
        case content
        case name
        case functionCall = "function_call"
    }
}
