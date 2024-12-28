import Foundation

/// Represents a real-time session with OpenAI
public struct RealTimeSession: Codable, Identifiable {
    /// The unique identifier for the session
    public let id: String
    
    /// The status of the session
    public let status: SessionStatus
    
    /// The Unix timestamp (in seconds) for when the session was created
    public let createdAt: Int
    
    /// The Unix timestamp (in seconds) for when the session expires
    public let expiresAt: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, status
        case createdAt = "created_at"
        case expiresAt = "expires_at"
    }
}

/// The status of a real-time session
public enum SessionStatus: String, Codable {
    case active = "active"
    case expired = "expired"
    case failed = "failed"
}

/// Request to create a new real-time session
public struct CreateSessionRequest: Codable {
    /// The model to use for the session
    public let model: String
    
    public init(model: String) {
        self.model = model
    }
}

/// Response when creating a real-time session
public struct CreateSessionResponse: Codable {
    /// The session information
    public let session: RealTimeSession
    
    /// The URL to connect to for real-time communication
    public let url: String
}
