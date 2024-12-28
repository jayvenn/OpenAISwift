import Foundation

/// Represents an OpenAI API endpoint
public enum OpenAIEndpoint {
    /// Chat completions endpoint
    case chatCompletions
    
    /// Embeddings endpoint
    case embeddings
    
    /// Image generations endpoint
    case imageGenerations
    
    /// Image edits endpoint
    case imageEdits
    
    /// Image variations endpoint
    case imageVariations
    
    /// Audio transcriptions endpoint
    case audioTranscriptions
    
    /// Audio translations endpoint
    case audioTranslations
    
    /// Files endpoint
    case files
    
    /// Fine-tunes endpoint
    case fineTunes
    
    /// Fine-tune events endpoint
    case fineTuneEvents(String)
    
    /// Completions endpoint
    case completions
    
    /// Models endpoint
    case models
    
    /// Model endpoint
    case model(String)
    
    /// Moderations endpoint
    case moderations
    
    /// Assistants endpoint
    case assistants
    
    /// Assistant endpoint
    case assistant(id: String)
    
    /// Real-time sessions endpoint
    case realTimeSessions
    
    /// The HTTP method to use for this endpoint
    public var method: HTTPMethod {
        switch self {
        case .chatCompletions, .embeddings, .imageGenerations,
             .imageEdits, .imageVariations, .audioTranscriptions,
             .audioTranslations, .moderations, .files, .fineTunes,
             .completions, .assistants, .realTimeSessions:
            return .post
        case .models, .model, .fineTuneEvents, .assistant:
            return .get
        }
    }
    
    /// The path component for this endpoint
    public var path: String {
        switch self {
        case .chatCompletions:
            return "chat/completions"
        case .embeddings:
            return "embeddings"
        case .imageGenerations:
            return "images/generations"
        case .imageEdits:
            return "images/edits"
        case .imageVariations:
            return "images/variations"
        case .audioTranscriptions:
            return "audio/transcriptions"
        case .audioTranslations:
            return "audio/translations"
        case .files:
            return "files"
        case .fineTunes:
            return "fine-tunes"
        case .fineTuneEvents(let id):
            return "fine-tunes/\(id)/events"
        case .completions:
            return "completions"
        case .models:
            return "models"
        case .model(let id):
            return "models/\(id)"
        case .moderations:
            return "moderations"
        case .assistants:
            return "assistants"
        case .assistant(let id):
            return "assistants/\(id)"
        case .realTimeSessions:
            return "sessions"
        }
    }
    
    /// The full URL for this endpoint
    public func url(baseURL: URL) -> URL {
        return baseURL.appendingPathComponent(path)
    }
}
