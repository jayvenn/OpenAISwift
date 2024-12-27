import Foundation
import Testing
@testable import OpenAISwift

@Suite("Embeddings API Tests")
struct EmbeddingsAPITests {
    var configuration: OpenAIConfiguration!
    var session: URLSession!
    var client: OpenAIClient!
    var embeddingsAPI: EmbeddingsAPI!
    
    mutating func setUp() {
        configuration = OpenAIConfiguration(apiKey: "test-key")
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        
        client = OpenAIClient(configuration: configuration, session: session)
        embeddingsAPI = client.embeddings
    }
    
    mutating func tearDown() {
        configuration = nil
        session = nil
        client = nil
        embeddingsAPI = nil
        MockURLProtocol.requestHandler = nil
    }
    
    @Test("Create embeddings with single input")
    func testCreateEmbeddings() async throws {
        // Given
        var test = EmbeddingsAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.embeddings.data(using: .utf8)!)
        }
        
        let request = EmbeddingRequest(
            model: .textEmbeddingAda002,
            input: "Hello world"
        )
        
        // When
        let response = try await test.embeddingsAPI.createEmbeddings(request)
        
        // Then
        #expect(!response.data.isEmpty, "Response data should not be empty")
        #expect(response.data.first?.embedding.count == 4, "Embedding should have correct dimension")
        #expect(response.model == "text-embedding-ada-002", "Response should use correct model")
    }
    
    @Test("Create embeddings with multiple inputs")
    func testCreateEmbeddingsWithMultipleInputs() async throws {
        // Given
        var test = EmbeddingsAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.embeddingsMultiple.data(using: .utf8)!)
        }
        
        let request = EmbeddingRequest(
            model: .textEmbeddingAda002,
            input: ["Hello world", "Another input"],
            user: "test-user"
        )
        
        // When
        let response = try await test.embeddingsAPI.createEmbeddings(request)
        
        // Then
        #expect(response.data.count == 2, "Should return embeddings for both inputs")
        #expect(response.data.first?.embedding.count == 4, "Embedding should have correct dimension")
        #expect(response.model == "text-embedding-ada-002", "Response should use correct model")
    }
    
    @Test("Handle invalid API response")
    func testCreateEmbeddingsFailure() async throws {
        // Given
        var test = EmbeddingsAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let errorResponse = """
            {
                "error": {
                    "message": "Invalid API key",
                    "type": "invalid_request_error",
                    "code": "invalid_api_key"
                }
            }
            """.data(using: .utf8)!
            
            return (response, errorResponse)
        }
        
        // Then
        await #expect(throws: OpenAIError.invalidResponse) {
            _ = try await test.embeddingsAPI.createEmbeddings(
                model: .textEmbeddingAda002,
                input: "Hello world"
            )
        }
    }
}
