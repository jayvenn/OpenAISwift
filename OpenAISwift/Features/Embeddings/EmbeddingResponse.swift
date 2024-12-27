import Foundation

/// Response structure for embeddings
public struct EmbeddingResponse: Codable, Sendable {
    /// The object type (always "list")
    public let object: String
    
    /// The model used for embedding
    public let model: String
    
    /// The list of embeddings
    public let data: [Embedding]
    
    /// Usage statistics for the request
    public let usage: Usage
}

// MARK: - Nested Types
public extension EmbeddingResponse {
    struct Embedding: Codable, Sendable {
        /// The object type (always "embedding")
        public let object: String
        
        /// The embedding vector
        public let embedding: [Double]
        
        /// The index of this embedding in the list
        public let index: Int
    }
    
    struct Usage: Codable, Sendable {
        /// Number of tokens in the prompt
        public let promptTokens: Int
        
        /// Total number of tokens used
        public let totalTokens: Int
        
        enum CodingKeys: String, CodingKey {
            case promptTokens = "prompt_tokens"
            case totalTokens = "total_tokens"
        }
    }
}
