import Foundation

extension OpenAIClient {
    /// Create embeddings for the provided input text
    /// - Parameter request: The embedding request parameters
    /// - Returns: The embedding response containing vector representations
    public func createEmbeddings(_ request: EmbeddingRequest) async throws -> EmbeddingResponse {
        return try await performRequest(
            endpoint: .embeddings,
            body: request
        )
    }
    
    /// Convenience method to get embeddings for a single text input
    /// - Parameters:
    ///   - text: The input text to embed
    ///   - model: The model to use (defaults to text-embedding-ada-002)
    /// - Returns: The embedding vector for the input text
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
