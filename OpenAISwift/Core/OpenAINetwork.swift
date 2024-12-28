import Foundation

/// Protocol defining the networking interface for OpenAI API requests
public protocol OpenAINetworking {
    /// Performs an API request and decodes the response
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - body: The request body to encode (optional)
    /// - Returns: Decoded response of type T
    func performRequest<T: Decodable, B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B?
    ) async throws -> T
}

/// Default implementation of OpenAINetworking using URLSession
public final class DefaultOpenAINetwork: OpenAINetworking {
    private let configuration: OpenAIConfiguration
    private let session: URLSession
    
    public init(
        configuration: OpenAIConfiguration,
        session: URLSession = .shared
    ) {
        self.configuration = configuration
        self.session = session
    }
    
    private var defaultHeaders: [String: String] {
        var headers = [
            "Authorization": "Bearer \(configuration.apiKey)",
            "Content-Type": "application/json"
        ]
        
        if let organization = configuration.organization {
            headers["OpenAI-Organization"] = organization
        }
        
        return headers
    }
    
    private func configureRequest(
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
