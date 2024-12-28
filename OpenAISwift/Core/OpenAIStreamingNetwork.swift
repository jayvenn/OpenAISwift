import Foundation

/// Protocol for handling streaming API requests
public protocol OpenAIStreamingNetworking {
    /// Performs a streaming API request
    /// - Parameters:
    ///   - endpoint: The API endpoint
    ///   - body: The request body to encode
    ///   - delegate: The delegate to receive streaming updates
    func performStreamingRequest<B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B,
        delegate: ChatStreamingDelegate
    ) async throws
}

extension DefaultOpenAINetwork: OpenAIStreamingNetworking {
    public func performStreamingRequest<B: Encodable>(
        endpoint: OpenAIEndpoint,
        body: B,
        delegate: ChatStreamingDelegate
    ) async throws {
        var request = try configureRequest(for: endpoint)
        request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
        
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)
        
        let (bytes, response) = try await session.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw OpenAIError.httpError(statusCode: httpResponse.statusCode, data: Data())
        }
        
        let decoder = JSONDecoder()
        
        for try await line in bytes.lines {
            guard line.hasPrefix("data: ") else { continue }
            let data = line.dropFirst(6)
            
            if data == "[DONE]" {
                delegate.didComplete()
                break
            }
            
            do {
                guard let jsonData = data.data(using: .utf8) else {
                    throw OpenAIError.invalidResponse
                }
                
                let chunk = try decoder.decode(ChatStreamingResponse.self, from: jsonData)
                delegate.didReceive(chunk: chunk)
            } catch {
                delegate.didError(OpenAIError.decodingError(error))
                break
            }
        }
    }
}
