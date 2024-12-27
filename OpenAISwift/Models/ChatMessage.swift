import Foundation

/// Represents a message in a chat conversation
public struct ChatMessage: Codable, Sendable {
    /// The role of the message author
    public let role: ChatRole
    
    /// The content of the message
    public let content: String
    
    /// Name of the author of this message
    public let name: String?
    
    public init(role: ChatRole, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }
}
