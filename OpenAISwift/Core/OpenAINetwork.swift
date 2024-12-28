import Foundation

/// Protocol defining the networking interface for OpenAI API requests
public protocol OpenAINetworking {
    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint to call
    ///   - body: The request body to encode (optional)
    /// - Returns: Decoded response of type T
    /// - Throws: OpenAIError if the request fails or response cannot be decoded
    func performRequest<T: Decodable, B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B?
    ) async throws -> T
}

/// Protocol for logging network requests and responses
public protocol NetworkLogger {
    /// Log a request before it is sent
    /// - Parameter request: The URLRequest to be sent
    func logRequest(_ request: URLRequest)
    
    /// Log a response after it is received
    /// - Parameters:
    ///   - response: The URLResponse received
    ///   - data: The data received
    func logResponse(_ response: URLResponse, data: Data)
    
    /// Log an error that occurred during the request
    /// - Parameter error: The error that occurred
    func logError(_ error: Error)
}

/// Default implementation of OpenAINetworking using URLSession
public final class DefaultOpenAINetwork: OpenAINetworking {
    internal let configuration: OpenAIConfiguration
    internal let session: URLSession
    private let logger: NetworkLogger?
    private let retryCount: Int
    
    /// Initialize a new DefaultOpenAINetwork instance
    /// - Parameters:
    ///   - configuration: The OpenAI configuration
    ///   - session: URLSession to use (defaults to .shared)
    ///   - logger: Optional logger for network requests
    ///   - retryCount: Number of times to retry failed requests (defaults to 2)
    public init(
        configuration: OpenAIConfiguration,
        session: URLSession = .shared,
        logger: NetworkLogger? = nil,
        retryCount: Int = 2
    ) {
        self.configuration = configuration
        self.session = session
        self.logger = logger
        self.retryCount = retryCount
    }
    
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
    
    public func performRequest<T: Decodable, B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B? = nil
    ) async throws -> T {
        var attempt = 0
        var lastError: Error?
        
        repeat {
            do {
                var request = try configureRequest(for: endpoint)
                
                if let body = body {
                    let encoder = JSONEncoder()
                    request.httpBody = try encoder.encode(body)
                }
                
                logger?.logRequest(request)
                
                let (data, response) = try await session.data(for: request)
                logger?.logResponse(response, data: data)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw OpenAIError.invalidResponse
                }
                
                // Check for rate limiting
                if httpResponse.statusCode == 429 {
                    let resetTime = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Reset")
                        .flatMap { Double($0) }
                        .map { Date(timeIntervalSince1970: $0) }
                    throw OpenAIError.rateLimitExceeded(resetTime: resetTime)
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    throw OpenAIError.httpError(statusCode: httpResponse.statusCode, data: data)
                }
                
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    logger?.logError(error)
                    throw OpenAIError.decodingError(error)
                }
            } catch {
                lastError = error
                attempt += 1
                
                // Don't retry on certain errors
                if case .invalidAPIKey = error as? OpenAIError {
                    throw error
                }
                
                if attempt <= retryCount {
                    // Add exponential backoff
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt)) * 1_000_000_000))
                    continue
                }
                throw error
            }
        } while attempt <= retryCount
        
        throw lastError ?? OpenAIError.unknownError
    }
}
