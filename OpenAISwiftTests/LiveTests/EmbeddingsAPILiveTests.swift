import XCTest
@testable import OpenAISwift

/// Live tests for the Embeddings API
/// These tests make actual API calls and require a valid API key in TestConfig
final class EmbeddingsAPILiveTests: XCTestCase {
    var client: OpenAIClient!
    
    override func setUp() {
        super.setUp()
        let config = OpenAIConfiguration(
            apiKey: TestConfig.apiKey,
            organization: TestConfig.organization,
            baseURL: TestConfig.baseURL,
            timeoutInterval: TestConfig.timeoutInterval
        )
        client = OpenAIClient(configuration: config)
    }
    
    override func tearDown() {
        client = nil
        super.tearDown()
    }
    
    func testSimpleEmbedding() async throws {
        // This test makes a real API call
        let text = "Hello, World!"
        let embedding = try await client.embeddings.embed(text)
        
        XCTAssertFalse(embedding.isEmpty)
        print("Embedding dimension: \(embedding.count)")
        print("First few values: \(embedding.prefix(5))")
    }
    
    func testCustomModel() async throws {
        // This test makes a real API call with a specific model
        let text = "Testing embeddings"
        let embedding = try await client.embeddings.embed(
            text,
            model: .ada
        )
        
        XCTAssertFalse(embedding.isEmpty)
        print("Ada Embedding dimension: \(embedding.count)")
    }
}
