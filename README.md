# OpenAISwift

A powerful and elegant Swift library for the OpenAI API.

## Features

- 🤖 Chat Completions API
- 🧮 Embeddings API
- 🔒 Type-safe API with enums for models and endpoints
- ✨ Modern Swift async/await API
- 🧪 Comprehensive test suite

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/jayvenn/OpenAISwift.git", from: "1.0.0")
]
```

## Usage

### Initialize the client

```swift
import OpenAISwift

let config = OpenAIConfiguration(apiKey: "your-api-key")
let client = OpenAIClient(configuration: config)
```

### Chat Completions

```swift
// Simple chat
let response = try await client.chat.sendMessage("Hello!")

// Custom model
let response = try await client.chat.sendMessage(
    "What's 2+2?",
    model: .gpt4
)

// Advanced usage
let messages = [
    ChatMessage(role: .system, content: "You are a helpful assistant"),
    ChatMessage(role: .user, content: "Hello!")
]
let request = ChatCompletionRequest(
    model: .gpt3_5Turbo,
    messages: messages
)
let response = try await client.chat.createChatCompletion(request)
```

### Embeddings

```swift
// Simple embedding
let embedding = try await client.embeddings.embed("Hello, World!")

// Custom model
let embedding = try await client.embeddings.embed(
    "Hello, World!",
    model: .ada
)

// Advanced usage
let request = EmbeddingRequest(
    model: .ada,
    input: ["Hello", "World"]
)
let response = try await client.embeddings.createEmbeddings(request)
```

## Testing

The library includes both unit tests and live API tests.

### Unit Tests

Unit tests use mock responses and don't make actual API calls:

```bash
# Run all unit tests
swift test --filter "OpenAIClientTests"
swift test --filter "ChatAPITests"
swift test --filter "EmbeddingsAPITests"
```

### Live API Tests

Live tests make actual API calls to test the integration:

1. Configure your API key in `OpenAISwiftTests/Config/TestConfig.swift`:
```swift
enum TestConfig {
    static let apiKey = "your-api-key-here"
    static let organization: String? = nil
    static let baseURL = URL(string: "https://api.openai.com/v1")!
    static let timeoutInterval: TimeInterval = 30
}
```

2. Run the live tests:
```bash
# Test Chat API
swift test --filter "ChatAPILiveTests"

# Test Embeddings API
swift test --filter "EmbeddingsAPILiveTests"
```

### Test Structure

```
OpenAISwiftTests/
├── Config/             # Test configuration
│   └── TestConfig.swift
│
├── Core/              # Core component tests
│   └── OpenAIClientTests.swift
│
├── Features/         # Feature-specific tests
│   ├── ChatAPITests.swift
│   └── EmbeddingsAPITests.swift
│
├── LiveTests/       # Real API integration tests
│   ├── ChatAPILiveTests.swift
│   └── EmbeddingsAPILiveTests.swift
│
└── Mocks/          # Test utilities
    ├── MockURLProtocol.swift
    └── MockResponses.swift
```

### Writing Tests

1. Unit Tests
```swift
final class YourTests: XCTestCase {
    func testFeature() async throws {
        // Setup mock response
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, MockResponses.yourResponse.data(using: .utf8)!)
        }
        
        // Test your feature
        let result = try await client.yourFeature.doSomething()
        XCTAssertEqual(result, expectedResult)
    }
}
```

2. Live Tests
```swift
final class YourLiveTests: XCTestCase {
    func testFeature() async throws {
        let result = try await client.yourFeature.doSomething()
        XCTAssertNotNil(result)
        print("Result: \(result)")
    }
}
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
