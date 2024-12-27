import Foundation

/// Main client for interacting with OpenAI's API
public final class OpenAIClient {
    /// The client configuration
    private let configuration: OpenAIConfiguration
    
    /// URLSession for making network requests
    private let session: URLSession
    
    /// The API key used for authentication
    public var apiKey: String { configuration.apiKey }
    
    /// Optional organization ID
    public var organization: String? { configuration.organization }
    
    // MARK: - Features
    
    /// Chat completion API
    public lazy var chat: ChatAPI = ChatEndpoint(client: self)
    
    /// Embeddings API
    public lazy var embeddings: EmbeddingsAPI = EmbeddingsEndpoint(client: self)
    
    /// Creates a new OpenAI client
    /// - Parameter configuration: The configuration for the client
    /// - Parameter session: Optional custom URLSession (useful for testing)
    public init(
        configuration: OpenAIConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    /// Creates default headers for API requests
    internal var defaultHeaders: [String: String] {
        var headers = [
            "Authorization": "Bearer \(configuration.apiKey)",
            "Content-Type": "application/json"
        ]
        
        if let organization = configuration.organization {
            headers["OpenAI-Organization"] = organization
        }
        
        return headers
    }
    
    /// Creates and configures a URLRequest for an API endpoint
    /// - Parameter endpoint: The API endpoint
    /// - Returns: Configured URLRequest
    internal func configureRequest(
        for endpoint: OpenAIEndpoint
    ) throws -> URLRequest {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        
        var request = URLRequest(
            url: url,
            timeoutInterval: configuration.timeoutInterval
        )
        
        request.httpMethod = endpoint.method.rawValue
        request.allHTTPHeaderFields = defaultHeaders
        
        return request
    }
    
    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - body: The request body to encode (optional)
    /// - Returns: Decoded response of type T
    internal func performRequest<T: Decodable, B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B? = nil
    ) async throws -> T {
        var request = try configureRequest(for: endpoint)
        
        if let body = body {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(body)
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
        
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw OpenAIError.decodingError(error)
        }
    }
}
