import Foundation
import Testing
@testable import OpenAISwift

@Suite("Chat API Live Tests")
struct ChatAPILiveTests {
    var client: OpenAIClient!
    var chatAPI: ChatAPI!
    
    mutating func setUp() throws {
        guard let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw TestError("OPENAI_API_KEY environment variable not set")
        }
        
        let config = OpenAIConfiguration(apiKey: apiKey)
        client = OpenAIClient(configuration: config)
        chatAPI = client.chat
    }
    
    mutating func tearDown() {
        client = nil
        chatAPI = nil
    }
    
    @Test("Create chat completion with basic message")
    func testCreateChatCompletion() async throws {
        // Given
        var test = ChatAPILiveTests()
        try test.setUp()
        defer { test.tearDown() }
        
        let messages = [
            ChatMessage(role: .user, content: "Say hello!")
        ]
        
        // When
    
        let response = try await test.chatAPI.createChatCompletion(
            model: .gpt3_5Turbo,
            messages: messages
        )
        
        // Then
        #expect(response.choices.count == 1, "Should return one choice")
        #expect(response.choices.first?.message.role == .assistant, "Response should be from assistant")
        #expect(!response.choices.first?.message.content.isEmpty, "Response should not be empty")
        #expect(response.model.contains("gpt-3.5-turbo"), "Should use correct model")
        #expect(response.usage.totalTokens > 0, "Should report token usage")
    }
    
    @Test("Create chat completion with conversation history")
    func testCreateChatCompletionWithHistory() async throws {
        // Given
        var test = ChatAPILiveTests()
        try test.setUp()
        defer { test.tearDown() }
        
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
        #expect(response.choices.first?.message.role == .assistant, "Response should be from assistant")
        #expect(!response.choices.first?.message.content.isEmpty, "Response should not be empty")
        #expect(response.usage.totalTokens > 0, "Should report token usage")
    }
    
    @Test("Create chat completion with options")
    func testCreateChatCompletionWithOptions() async throws {
        // Given
        var test = ChatAPILiveTests()
        try test.setUp()
        defer { test.tearDown() }
        
        let messages = [
            ChatMessage(role: .user, content: "Generate a creative story.")
        ]
        
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
        #expect(!response.choices.first?.message.content.isEmpty, "Response should not be empty")
        #expect(response.usage.totalTokens <= 100, "Should respect max tokens")
    }
}
