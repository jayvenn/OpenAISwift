import Foundation

/// Represents available chat endpoints
public enum ChatEndpoint: OpenAIEndpoint {
    /// Chat completions endpoint
    case chatCompletions
    
    public var path: String {
        switch self {
        case .chatCompletions:
            return "v1/chat/completions"
        }
    }
    
    public var method: HTTPMethod {
        switch self {
        case .chatCompletions:
            return .post
        }
    }
}
