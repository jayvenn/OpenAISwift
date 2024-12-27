import Foundation

/// Represents all available OpenAI API endpoints
public enum OpenAIEndpoint {
    // MARK: - Chat Endpoints
    case chatCompletions
    
    // MARK: - Embedding Endpoints
    case embeddings
    
    // MARK: - Image Endpoints
    case imageGenerations
    case imageEdits
    case imageVariations
    
    // MARK: - Audio Endpoints
    case audioTranscriptions
    case audioTranslations
    case audioSpeech
    
    // MARK: - File Endpoints
    case files
    case fileContent(String)
    case fileDelete(String)
    
    // MARK: - Fine-tuning Endpoints
    case fineTuningJobs
    case fineTuningJobCancel(String)
    case fineTuningJobEvents(String)
    
    // MARK: - Moderation Endpoints
    case moderations
    
    // MARK: - Assistants API Endpoints
    case assistants
    case assistant(String)
    case assistantFiles(String)
    case threads
    case thread(String)
    case threadMessages(String)
    case threadRuns(String)
    case threadRunSteps(String, String)
    
    /// The HTTP method to use for this endpoint
    public var method: HTTPMethod {
        switch self {
        case .chatCompletions, .embeddings, .imageGenerations,
             .imageEdits, .imageVariations, .audioTranscriptions,
             .audioTranslations, .audioSpeech, .files,
             .fineTuningJobs, .moderations, .assistants,
             .assistantFiles, .threads, .threadMessages,
             .threadRuns:
            return .post
            
        case .fileContent, .fineTuningJobEvents:
            return .get
            
        case .fileDelete, .assistant, .thread:
            return .delete
            
        case .fineTuningJobCancel:
            return .post
            
        case .threadRunSteps:
            return .get
        }
    }
    
    /// The path component for this endpoint
    public var path: String {
        switch self {
        case .chatCompletions:
            return "/chat/completions"
        case .embeddings:
            return "/embeddings"
        case .imageGenerations:
            return "/images/generations"
        case .imageEdits:
            return "/images/edits"
        case .imageVariations:
            return "/images/variations"
        case .audioTranscriptions:
            return "/audio/transcriptions"
        case .audioTranslations:
            return "/audio/translations"
        case .audioSpeech:
            return "/audio/speech"
        case .files:
            return "/files"
        case .fileContent(let fileId):
            return "/files/\(fileId)/content"
        case .fileDelete(let fileId):
            return "/files/\(fileId)"
        case .fineTuningJobs:
            return "/fine_tuning/jobs"
        case .fineTuningJobCancel(let jobId):
            return "/fine_tuning/jobs/\(jobId)/cancel"
        case .fineTuningJobEvents(let jobId):
            return "/fine_tuning/jobs/\(jobId)/events"
        case .moderations:
            return "/moderations"
        case .assistants:
            return "/assistants"
        case .assistant(let assistantId):
            return "/assistants/\(assistantId)"
        case .assistantFiles(let assistantId):
            return "/assistants/\(assistantId)/files"
        case .threads:
            return "/threads"
        case .thread(let threadId):
            return "/threads/\(threadId)"
        case .threadMessages(let threadId):
            return "/threads/\(threadId)/messages"
        case .threadRuns(let threadId):
            return "/threads/\(threadId)/runs"
        case .threadRunSteps(let threadId, let runId):
            return "/threads/\(threadId)/runs/\(runId)/steps"
        }
    }
}

/// HTTP methods supported by the OpenAI API
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}
