import Foundation

/// Protocol that all OpenAI API features must conform to
public protocol OpenAIFeature {
    /// The client that this feature belongs to
    var client: OpenAIClient { get }
}

/// Base implementation for OpenAI features
public extension OpenAIFeature {
    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - body: The request body to encode (optional)
    /// - Returns: Decoded response of type T
    func performRequest<T: Decodable, B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B? = nil
    ) async throws -> T {
        try await client.performRequest(endpoint: endpoint, body: body)
    }
}
