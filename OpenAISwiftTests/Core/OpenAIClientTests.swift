import Foundation
import Testing
@testable import OpenAISwift

@Suite("OpenAI Client Tests")
struct OpenAIClientTests {
    var configuration: OpenAIConfiguration!
    var session: URLSession!
    var client: OpenAIClient!
    
    mutating func setUp() {
        configuration = OpenAIConfiguration(apiKey: "test-key")
        
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        
        client = OpenAIClient(configuration: configuration, session: session)
    }
    
    mutating func tearDown() {
        configuration = nil
        session = nil
        client = nil
        MockURLProtocol.requestHandler = nil
    }
    
    @Test("Initialize client with API key")
    func testInitWithAPIKey() {
        let config = OpenAIConfiguration(apiKey: "test-key")
        let client = OpenAIClient(configuration: config)
        #expect(client.apiKey == "test-key", "API key should be set correctly")
    }
    
    @Test("Initialize client with configuration")
    func testInitWithConfiguration() {
        let config = OpenAIConfiguration(apiKey: "test-key", organization: "test-org")
        let client = OpenAIClient(configuration: config)
        #expect(client.apiKey == "test-key", "API key should be set correctly")
        #expect(client.organization == "test-org", "Organization should be set correctly")
    }
    
    @Test("Initialize client with custom session")
    func testInitWithSession() {
        let config = OpenAIConfiguration(apiKey: "test-key")
        let session = URLSession(configuration: .ephemeral)
        let client = OpenAIClient(configuration: config, session: session)
        #expect(client.session === session, "Session should be set correctly")
    }
    
    @Test("Make API request with valid response")
    func testMakeRequest() async throws {
        // Given
        var test = OpenAIClientTests()
        test.setUp()
        defer { test.tearDown() }
        
        let endpoint = OpenAIEndpoint.chat
        let expectedResponse = ChatResponse(
            id: "test-id",
            object: "chat.completion",
            created: 1234567890,
            model: "gpt-3.5-turbo",
            choices: [
                .init(
                    index: 0,
                    message: .init(role: .assistant, content: "Hello!"),
                    finishReason: "stop"
                )
            ],
            usage: .init(promptTokens: 10, completionTokens: 20, totalTokens: 30)
        )
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            
            let encoder = JSONEncoder()
            let data = try! encoder.encode(expectedResponse)
            return (response, data)
        }
        
        // When
        let response: ChatResponse = try await test.client.makeRequest(to: endpoint)
        
        // Then
        #expect(response.id == expectedResponse.id, "Response ID should match")
        #expect(response.model == expectedResponse.model, "Response model should match")
        #expect(response.choices.count == expectedResponse.choices.count, "Response should have correct number of choices")
    }
    
    @Test("Handle API request error")
    func testMakeRequestError() async throws {
        // Given
        var test = OpenAIClientTests()
        test.setUp()
        defer { test.tearDown() }
        
        let endpoint = OpenAIEndpoint.chat
        
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
            let _: ChatResponse = try await test.client.makeRequest(to: endpoint)
        }
    }
    
    @Test("Handle network error")
    func testMakeRequestNetworkError() async throws {
        // Given
        var test = OpenAIClientTests()
        test.setUp()
        defer { test.tearDown() }
        
        let endpoint = OpenAIEndpoint.chat
        let networkError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)
        
        MockURLProtocol.requestHandler = { _ in
            throw networkError
        }
        
        // Then
        await #expect(throws: OpenAIError.networkError) {
            let _: ChatResponse = try await test.client.makeRequest(to: endpoint)
        }
    }
}
