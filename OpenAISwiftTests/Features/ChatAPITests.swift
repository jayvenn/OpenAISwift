import XCTest
@testable import OpenAISwift

final class ChatAPITests: XCTestCase {
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
    
    func testCreateChatCompletion() async throws {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.chatCompletion.data(using: .utf8)!)
        }
        
        // Test request
        let request = ChatCompletionRequest(
            model: .gpt3_5Turbo,
            messages: [ChatMessage(role: .user, content: "Hello")]
        )
        
        let response = try await client.chat.createChatCompletion(request)
        
        XCTAssertEqual(response.choices.count, 1)
        XCTAssertEqual(response.choices.first?.message.content, "Hello! How can I help you today?")
        XCTAssertEqual(response.choices.first?.message.role, .assistant)
    }
    
    func testSendMessage() async throws {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            // Verify request body
            let data = try! JSONDecoder().decode(
                ChatCompletionRequest.self,
                from: request.httpBody!
            )
            XCTAssertEqual(data.messages.first?.content, "Test message")
            XCTAssertEqual(data.messages.first?.role, .user)
            
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.chatCompletion.data(using: .utf8)!)
        }
        
        // Test simple message
        let reply = try await client.chat.sendMessage("Test message")
        XCTAssertEqual(reply, "Hello! How can I help you today?")
        
        // Test with specific model
        let replyWithModel = try await client.chat.sendMessage(
            "Test message",
            model: .gpt4
        )
        XCTAssertEqual(replyWithModel, "Hello! How can I help you today?")
    }
    
    func testInvalidResponse() async {
        // Setup mock response with missing choice
        MockURLProtocol.requestHandler = { request in
            let invalidResponse = """
            {
                "id": "chatcmpl-123",
                "object": "chat.completion",
                "created": 1677652288,
                "model": "gpt-3.5-turbo",
                "choices": [],
                "usage": {
                    "prompt_tokens": 9,
                    "completion_tokens": 12,
                    "total_tokens": 21
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
            _ = try await client.chat.sendMessage("Test message")
            XCTFail("Expected error to be thrown")
        } catch OpenAIError.invalidResponse {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
