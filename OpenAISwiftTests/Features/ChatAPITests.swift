import Foundation
import Testing
@testable import OpenAISwift

@Suite("Chat API Tests")
struct ChatAPITests {
    var configuration: OpenAIConfiguration!
    var session: URLSession!
    var client: OpenAIClient!
    var chatAPI: ChatAPI!
    
    mutating func setUp() {
        configuration = OpenAIConfiguration(apiKey: "test-key")
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        
        client = OpenAIClient(configuration: configuration, session: session)
        chatAPI = client.chat
    }
    
    mutating func tearDown() {
        configuration = nil
        session = nil
        client = nil
        chatAPI = nil
        MockURLProtocol.requestHandler = nil
    }
    
    @Test("Create chat completion with basic message")
    func testCreateChatCompletion() async throws {
        // Given
        var test = ChatAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.chatCompletion.data(using: .utf8)!)
        }
        
        let messages = [
            ChatMessage(role: .user, content: "Hello!")
        ]
        
        // When
        let response = try await test.chatAPI.createChatCompletion(
            model: .gpt3_5Turbo,
            messages: messages
        )
        
        // Then
        #expect(response.choices.count == 1, "Should return one choice")
        #expect(response.choices.first?.message.role == .assistant, "Response should be from assistant")
        #expect(response.choices.first?.message.content == "Hello! How can I help you today?", "Response content should match")
    }
    
    @Test("Create chat completion with conversation history")
    func testCreateChatCompletionWithHistory() async throws {
        // Given
        var test = ChatAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.chatCompletion.data(using: .utf8)!)
        }
        
        let messages = [
            ChatMessage(role: .system, content: "You are a helpful assistant."),
            ChatMessage(role: .user, content: "What's your purpose?"),
            ChatMessage(role: .assistant, content: "I'm here to help!"),
            ChatMessage(role: .user, content: "Tell me more.")
        ]
        
        // When
        let response = try await test.chatAPI.createChatCompletion(
            model: .gpt3_5Turbo,
            messages: messages
        )
        
        // Then
        #expect(response.choices.count == 1, "Should return one choice")
        #expect(response.model == "gpt-3.5-turbo", "Should use correct model")
        #expect(response.usage.totalTokens == 21, "Should report token usage")
    }
    
    @Test("Create chat completion with options")
    func testCreateChatCompletionWithOptions() async throws {
        // Given
        var test = ChatAPITests()
        test.setUp()
        defer { test.tearDown() }
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.chatCompletion.data(using: .utf8)!)
        }
        
        let messages = [ChatMessage(role: .user, content: "Generate a creative story.")]
        
        // When
        let response = try await test.chatAPI.createChatCompletion(
            model: .gpt3_5Turbo,
            messages: messages,
            temperature: 0.8,
            topP: 1,
            n: 1,
            stream: false,
            stop: ["THE END"],
            maxTokens: 100,
            presencePenalty: 0.5,
            frequencyPenalty: 0.5,
            user: "test-user"
        )
        
        // Then
        #expect(response.choices.count == 1, "Should return one choice")
        #expect(response.choices.first?.finishReason == "stop", "Should have correct finish reason")
    }
    
    @Test("Handle chat completion error")
    func testCreateChatCompletionError() async throws {
        // Given
        var test = ChatAPITests()
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
        
        let messages = [ChatMessage(role: .user, content: "Hello!")]
        
        // Then
        await #expect(throws: OpenAIError.invalidResponse) {
            _ = try await test.chatAPI.createChatCompletion(
                model: .gpt3_5Turbo,
                messages: messages
            )
        }
    }
}
