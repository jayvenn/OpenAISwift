import Foundation

/// Represents available OpenAI models
public enum OpenAIModel: String, Codable, Sendable {
    // MARK: - GPT-4 Models
    case gpt4 = "gpt-4"
    case gpt4Turbo = "gpt-4-1106-preview"
    case gpt4Vision = "gpt-4-vision-preview"
    case gpt4_32k = "gpt-4-32k"
    
    // MARK: - GPT-3.5 Models
    case gpt3_5Turbo = "gpt-3.5-turbo"
    case gpt3_5Turbo_16k = "gpt-3.5-turbo-16k"
    
    // MARK: - Embedding Models
    case embeddings = "text-embedding-ada-002"
    case embeddingsV3 = "text-embedding-3-small"
    case embeddingsV3Large = "text-embedding-3-large"
    
    // MARK: - Image Models
    case dalle2 = "dall-e-2"
    case dalle3 = "dall-e-3"
    
    // MARK: - Audio Models
    case whisper = "whisper-1"
    case tts = "tts-1"
    case ttsHD = "tts-1-hd"
    
    // MARK: - Moderation Models
    case moderationLatest = "text-moderation-latest"
    case moderationStable = "text-moderation-stable"
}

// MARK: - Model Capabilities
public extension OpenAIModel {
    /// Maximum number of tokens the model can process in a single request
    var maxTokens: Int {
        switch self {
        case .gpt4:
            return 8192
        case .gpt4Turbo:
            return 128000
        case .gpt4Vision:
            return 128000
        case .gpt4_32k:
            return 32768
        case .gpt3_5Turbo:
            return 4096
        case .gpt3_5Turbo_16k:
            return 16384
        case .embeddings, .embeddingsV3, .embeddingsV3Large:
            return 8191
        default:
            return 4096
        }
    }
    
    /// Whether the model supports vision/image input
    var supportsVision: Bool {
        switch self {
        case .gpt4Vision, .dalle2, .dalle3:
            return true
        default:
            return false
        }
    }
    
    /// Whether the model supports audio input/output
    var supportsAudio: Bool {
        switch self {
        case .whisper, .tts, .ttsHD:
            return true
        default:
            return false
        }
    }
    
    /// The default purpose/capability of the model
    var purpose: ModelPurpose {
        switch self {
        case .gpt4, .gpt4Turbo, .gpt4Vision, .gpt4_32k,
             .gpt3_5Turbo, .gpt3_5Turbo_16k:
            return .chatCompletion
        case .embeddings, .embeddingsV3, .embeddingsV3Large:
            return .embedding
        case .dalle2, .dalle3:
            return .imageGeneration
        case .whisper:
            return .audioTranscription
        case .tts, .ttsHD:
            return .textToSpeech
        case .moderationLatest, .moderationStable:
            return .moderation
        }
    }
}

/// Represents the primary purpose/capability of a model
public enum ModelPurpose {
    case chatCompletion
    case embedding
    case imageGeneration
    case audioTranscription
    case textToSpeech
    case moderation
}

// MARK: - Default Models
public extension OpenAIModel {
    /// Returns the recommended default model for a given purpose
    static func defaultModel(for purpose: ModelPurpose) -> OpenAIModel {
        switch purpose {
        case .chatCompletion:
            return .gpt3_5Turbo
        case .embedding:
            return .embeddings
        case .imageGeneration:
            return .dalle3
        case .audioTranscription:
            return .whisper
        case .textToSpeech:
            return .tts
        case .moderation:
            return .moderationLatest
        }
    }
}
