import Foundation

/// Embeddings API interface
public protocol EmbeddingsAPI {
    /// Create embeddings for the provided input text
    /// - Parameter request: The embedding request parameters
    /// - Returns: The embedding response containing vector representations
    func createEmbeddings(_ request: EmbeddingRequest) async throws -> EmbeddingResponse
    
    /// Convenience method to get embeddings for a single text input
    /// - Parameters:
    ///   - text: The input text to embed
    ///   - model: The model to use
    /// - Returns: The embedding vector for the input text
    func embed(
        _ text: String,
        model: OpenAIModel
    ) async throws -> [Double]
}

/// Implementation of the Embeddings API
public struct EmbeddingsEndpoint: OpenAIFeature, EmbeddingsAPI {
    public let client: OpenAIClient
    
    init(client: OpenAIClient) {
        self.client = client
    }
    
    public func createEmbeddings(_ request: EmbeddingRequest) async throws -> EmbeddingResponse {
        return try await performRequest(
            endpoint: .embeddings,
            body: request
        )
    }
    
    public func embed(
        _ text: String,
        model: OpenAIModel = .defaultModel(for: .embedding)
    ) async throws -> [Double] {
        let request = EmbeddingRequest(model: model, input: [text])
        let response = try await createEmbeddings(request)
        
        guard let embedding = response.data.first else {
            throw OpenAIError.invalidResponse
        }
        
        return embedding.embedding
    }
}
