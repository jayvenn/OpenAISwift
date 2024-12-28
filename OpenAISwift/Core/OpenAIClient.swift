import Foundation
/// Main client for interacting with OpenAI's API
public final class OpenAIClient {
    /// The client configuration
    private let configuration: OpenAIConfiguration
    
    /// Networking layer for API requests
    private let network: OpenAINetworking & OpenAIStreamingNetworking
    
    /// The API key used for authentication
    public var apiKey: String { configuration.apiKey }
    
    /// Optional organization ID
    public var organization: String? { configuration.organization }
    
    // MARK: - Features
    
    /// Chat completion API
    public lazy var chat: ChatAPI = ChatEndpoint(client: self)
    
    /// Embeddings API
    public lazy var embeddings: EmbeddingsAPI = EmbeddingsEndpoint(client: self)
    
    /// Creates a new OpenAI client with custom networking
    /// - Parameters:
    ///   - configuration: The configuration for the client
    ///   - network: Custom networking implementation
    public init(
        configuration: OpenAIConfiguration,
        network: OpenAINetworking & OpenAIStreamingNetworking
    ) {
        self.configuration = configuration
        self.network = network
    }
    
    /// Creates a new OpenAI client with default networking
    /// - Parameters:
    ///   - configuration: The configuration for the client
    ///   - session: Optional custom URLSession (useful for testing)
    public convenience init(
        configuration: OpenAIConfiguration,
        session: URLSession = .shared
    ) {
        let network = DefaultOpenAINetwork(
            configuration: configuration,
            session: session
        )
        self.init(configuration: configuration, network: network)
    }
    
    /// Creates a new OpenAI client with just an API key
    /// - Parameter apiKey: The OpenAI API key for authentication
    public convenience init(apiKey: String) {
        let configuration = OpenAIConfiguration(apiKey: apiKey)
        self.init(configuration: configuration)
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
        try await network.performRequest(endpoint: endpoint, body: body)
    }
    
    /// Performs a streaming API request
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - body: The request body to encode
    ///   - delegate: The delegate to receive streaming updates
    internal func performStreamingRequest<B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B,
        delegate: ChatStreamingDelegate
    ) async throws {
        try await network.performStreamingRequest(
            endpoint: endpoint,
            body: body,
            delegate: delegate
        )
    }
}
