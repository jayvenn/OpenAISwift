import XCTest
@testable import OpenAISwift

final class EmbeddingsAPITests: XCTestCase {
    var configuration: OpenAIConfiguration!
    var session: URLSession!
    var client: OpenAIClient!
    
    override func setUp() {
        super.setUp()
        configuration = OpenAIConfiguration(apiKey: "test-key")
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        
        client = OpenAIClient(configuration: configuration, session: session)
    }
    
    override func tearDown() {
        configuration = nil
        session = nil
        client = nil
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }
    
    func testCreateEmbeddings() async throws {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.embedding.data(using: .utf8)!)
        }
        
        // Test request
        let request = EmbeddingRequest(
            model: .ada,
            input: ["Test text"]
        )
        
        let response = try await client.embeddings.createEmbeddings(request)
        
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.data.first?.embedding.count, 3)
        XCTAssertEqual(response.model, "text-embedding-ada-002")
    }
    
    func testEmbed() async throws {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            // Verify request body
            let data = try! JSONDecoder().decode(
                EmbeddingRequest.self,
                from: request.httpBody!
            )
            XCTAssertEqual(data.input.first, "Test text")
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.embedding.data(using: .utf8)!)
        }
        
        // Test simple embedding
        let embedding = try await client.embeddings.embed("Test text")
        XCTAssertEqual(embedding.count, 3)
        XCTAssertEqual(embedding[0], 0.0023064255)
        
        // Test with specific model
        let embeddingWithModel = try await client.embeddings.embed(
            "Test text",
            model: .embeddingsV3
        )
        XCTAssertEqual(embeddingWithModel.count, 3)
    }
    
    func testInvalidResponse() async {
        // Setup mock response with missing data
        MockURLProtocol.requestHandler = { request in
            let invalidResponse = """
            {
                "object": "list",
                "data": [],
                "model": "text-embedding-ada-002",
                "usage": {
                    "prompt_tokens": 8,
                    "total_tokens": 8
                }
            }
            """
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidResponse.data(using: .utf8)!)
        }
        
        do {
            _ = try await client.embeddings.embed("Test text")
            XCTFail("Expected error to be thrown")
        } catch OpenAIError.invalidResponse {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
