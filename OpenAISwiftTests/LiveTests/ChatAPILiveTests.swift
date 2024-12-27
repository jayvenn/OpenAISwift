import XCTest
@testable import OpenAISwift

/// Live tests for the Chat API
/// These tests make actual API calls and require a valid API key in TestConfig
final class ChatAPILiveTests: XCTestCase {
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
    
    func testSimpleChat() async throws {
        // This test makes a real API call
        let message = "Say 'Hello, World!' in a friendly way"
        let response = try await client.chat.sendMessage(message)
        
        XCTAssertFalse(response.isEmpty)
        print("Chat Response: \(response)")
    }
    
    func testCustomModel() async throws {
        // This test makes a real API call with GPT-4
        let message = "What's 2+2? Answer with just the number."
        let response = try await client.chat.sendMessage(
            message,
            model: .gpt4
        )
        
        XCTAssertFalse(response.isEmpty)
        print("GPT-4 Response: \(response)")
    }
}
