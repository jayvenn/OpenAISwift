import XCTest
@testable import OpenAISwift

final class OpenAIClientTests: XCTestCase {
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
    
    func testClientInitialization() {
        XCTAssertNotNil(client)
        XCTAssertNotNil(client.chat)
        XCTAssertNotNil(client.embeddings)
    }
    
    func testDefaultHeaders() {
        let headers = client.defaultHeaders
        XCTAssertEqual(headers["Authorization"], "Bearer test-key")
        XCTAssertEqual(headers["Content-Type"], "application/json")
        XCTAssertNil(headers["OpenAI-Organization"])
        
        // Test with organization
        let configWithOrg = OpenAIConfiguration(apiKey: "test-key", organization: "test-org")
        let clientWithOrg = OpenAIClient(configuration: configWithOrg)
        let headersWithOrg = clientWithOrg.defaultHeaders
        
        XCTAssertEqual(headersWithOrg["OpenAI-Organization"], "test-org")
    }
    
    func testConfigureRequest() throws {
        let request = try client.configureRequest(for: .chatCompletions)
        
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertEqual(
            request.url?.absoluteString,
            "https://api.openai.com/v1/chat/completions"
        )
        XCTAssertEqual(
            request.allHTTPHeaderFields?["Authorization"],
            "Bearer test-key"
        )
    }
    
    func testPerformRequestSuccess() async throws {
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
        let response: ChatCompletionResponse = try await client.performRequest(
            endpoint: .chatCompletions,
            body: ChatCompletionRequest(
                model: .gpt3_5Turbo,
                messages: [ChatMessage(role: .user, content: "Hello")]
            )
        )
        
        XCTAssertEqual(response.choices.first?.message.content, "Hello! How can I help you today?")
    }
    
    func testPerformRequestFailure() async {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.error.data(using: .utf8)!)
        }
        
        // Test request
        do {
            let _: ChatCompletionResponse = try await client.performRequest(
                endpoint: .chatCompletions,
                body: ChatCompletionRequest(
                    model: .gpt3_5Turbo,
                    messages: [ChatMessage(role: .user, content: "Hello")]
                )
            )
            XCTFail("Expected error to be thrown")
        } catch let OpenAIError.httpError(statusCode, _) {
            XCTAssertEqual(statusCode, 401)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
