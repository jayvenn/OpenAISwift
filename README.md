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

### Setting Up API Keys for Testing

1. Copy the environment template:
```bash
cp .env.example .env
```

2. Edit `.env` with your API keys:
```bash
# OpenAI API Configuration
OPENAI_API_KEY=your-actual-api-key-here
OPENAI_ORGANIZATION=optional-org-id
OPENAI_BASE_URL=https://api.openai.com/v1
OPENAI_TIMEOUT=30
```

3. Create `OpenAISwiftTests/Config/TestConfig.swift`:
```swift
import Foundation

enum TestConfig {
    private static let _: Void = {
        EnvironmentLoader.load()
    }()
    
    static var apiKey: String {
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            fatalError("⚠️ Please set OPENAI_API_KEY in .env file")
        }
        return key
    }
    
    static var organization: String? {
        ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]
    }
    
    static var baseURL: URL {
        if let urlString = ProcessInfo.processInfo.environment["OPENAI_BASE_URL"],
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "https://api.openai.com/v1")!
    }
    
    static var timeoutInterval: TimeInterval {
        if let timeoutString = ProcessInfo.processInfo.environment["OPENAI_TIMEOUT"],
           let timeout = TimeInterval(timeoutString) {
            return timeout
        }
        return 30
    }
}
```

The environment variables will be automatically loaded when running tests. Both the `.env` file and `TestConfig.swift` are git-ignored for security.

### Unit Tests

Unit tests use mock responses and don't make actual API calls:

```bash
# Run all unit tests
swift test --filter "OpenAIClientTests"
swift test --filter "ChatAPITests"
swift test --filter "EmbeddingsAPITests"
```

### Live API Tests

Live tests make actual API calls using your API key from the `.env` file:

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
│   ├── TestConfig.swift (git-ignored)
│   └── EnvironmentLoader.swift
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
