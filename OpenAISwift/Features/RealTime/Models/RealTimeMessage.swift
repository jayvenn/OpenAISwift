import Foundation

/// A message in a real-time session
public struct RealTimeMessage: Codable {
    /// The role of who sent the message
    public let role: MessageRole
    
    /// The content of the message
    public let content: String
    
    /// Optional name of the assistant or tool
    public let name: String?
    
    public init(role: MessageRole, content: String, name: String? = nil) {
        self.role = role
        self.content = content
        self.name = name
    }
}

/// The role of the message sender
public enum MessageRole: String, Codable {
    case system
    case user
    case assistant
    case tool
}

/// A real-time message event from the server
public struct RealTimeEvent: Codable {
    /// The type of event
    public let type: EventType
    
    /// The message content if type is message
    public let message: RealTimeMessage?
    
    /// Error information if type is error
    public let error: ErrorInfo?
    
    private enum CodingKeys: String, CodingKey {
        case type, message, error
    }
}

/// The type of real-time event
public enum EventType: String, Codable {
    case message
    case error
    case ping
}

/// Error information in a real-time event
public struct ErrorInfo: Codable {
    /// The error code
    public let code: String
    
    /// A human-readable error message
    public let message: String
}
