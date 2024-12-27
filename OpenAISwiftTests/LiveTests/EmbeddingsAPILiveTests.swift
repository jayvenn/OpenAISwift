import Foundation
import Testing
@testable import OpenAISwift

@Suite("Embeddings API Live Tests")
struct EmbeddingsAPILiveTests {
    var client: OpenAIClient!
    var embeddingsAPI: EmbeddingsAPI!
    
    mutating func setUp() throws {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw TestError("OPENAI_API_KEY environment variable not set")
        }
        
        let config = OpenAIConfiguration(apiKey: apiKey)
        client = OpenAIClient(configuration: config)
        embeddingsAPI = client.embeddings
    }
    
    @Test("Create embeddings with single input")
    func testCreateEmbeddings() async throws {
        let request = EmbeddingRequest(
            model: .textEmbeddingAda002,
            input: "Hello world"
        )
        
        let response = try await embeddingsAPI.createEmbeddings(request)
        #expect(!response.data.isEmpty)
    }
    
    @Test("Create embeddings with multiple inputs")
    func testCreateEmbeddingsWithMultipleInputs() async throws {
        let request = EmbeddingRequest(
            model: .textEmbeddingAda002,
            input: ["Hello world", "Another test input"]
        )
        
        let response = try await embeddingsAPI.createEmbeddings(request)
        #expect(response.data.count == 2)
    }
    
    @Test("Create embeddings with user identifier")
    func testCreateEmbeddingsWithUser() async throws {
        let request = EmbeddingRequest(
            model: .textEmbeddingAda002,
            input: "Hello world",
            user: "test-user"
        )
        
        let response = try await embeddingsAPI.createEmbeddings(request)
        #expect(!response.data.isEmpty)
    }
}
