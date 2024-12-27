import Foundation

/// Request parameters for creating embeddings
public struct EmbeddingRequest: Codable, Sendable {
    /// The model to use for embeddings
    public let model: OpenAIModel
    
    /// Input text to get embeddings for
    public let input: [String]
    
    /// A unique identifier representing your end-user
    public let user: String?
    
    public init(model: OpenAIModel = .textEmbeddingAda002, input: String, user: String? = nil) {
        self.model = model
        self.input = [input]
        self.user = user
    }
    
    public init(model: OpenAIModel = .textEmbeddingAda002, input: [String], user: String? = nil) {
        self.model = model
        self.input = input
        self.user = user
    }
}
