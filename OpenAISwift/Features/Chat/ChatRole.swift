import Foundation

/// Available roles for chat messages
public enum ChatRole: String, Codable, Sendable {
    case system
    case user
    case assistant
    case function
    case tool
}
