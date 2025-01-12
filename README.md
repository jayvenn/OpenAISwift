# OpenAISwift

A modern, elegant Swift interface to OpenAI's APIs.

## Overview

OpenAISwift provides a type-safe, async/await-based interface to OpenAI's powerful AI models. Built for simplicity and reliability, it supports chat completions, embeddings, and assistants.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/jayvenn/OpenAISwift.git", from: "0.1.0-beta.1")
]
```

## Quick Start

```swift
import OpenAISwift

// Initialize the client
let client = OpenAIClient(configuration: .init(apiKey: "your-api-key"))

// Chat completions
let chatResponse = try await client.chat.sendMessage("Explain quantum computing in simple terms.")

// Generate embeddings
let embedding = try await client.embeddings.embed("Convert this text to a vector representation.")

// Use the Assistants API
let assistant = try await client.assistants.create(
    name: "Math Tutor",
    instructions: "You are a helpful math tutor",
    model: .gpt4
)
```

## Features

### Function Calling

You can define custom functions that the model can call:

```swift
// Define a function schema
let babyPredictions = ChatFunctionConfiguration.babyPredictions()

// Use it in a chat completion
let response = try await client.chat.sendMessage(
    "Generate predictions for these parents",
    functions: babyPredictions.functions
)

// Handle the function call
if let functionCall = response.choices.first?.message.functionCall {
    print("Function called: \(functionCall.name)")
    print("Arguments: \(functionCall.arguments)")
}

// Stream function calls
let delegate = DefaultChatStreamingDelegate { result in
    switch result {
    case .success(let message):
        if let functionCall = message.functionCall {
            print("Function called: \(functionCall.name)")
            print("Arguments: \(functionCall.arguments)")
        } else {
            print("Message: \(message.content ?? "")")
        }
    case .failure(let error):
        print("Error: \(error)")
    }
}

try await client.chat.sendMessageStreaming(
    "Generate predictions for these parents",
    functions: babyPredictions.functions,
    delegate: delegate
)
```

### Chat Completions

Send messages and receive AI-generated responses:

```swift
// Simple message
let response = try await client.chat.sendMessage("Hello!")

// With custom parameters
let customResponse = try await client.chat.sendMessage(
    "Write a story",
    model: .gpt4,
    temperature: 0.8
)

// Stream responses
let delegate = DefaultChatStreamingDelegate { result in
    switch result {
    case .success(let message):
        print("Received: \(message.content ?? "")")
    case .failure(let error):
        print("Error: \(error)")
    }
}

try await client.chat.sendMessageStreaming(
    "Tell me a long story",
    delegate: delegate
)
```

### Embeddings

Generate vector representations of text:

```swift
// Single text
let vector = try await client.embeddings.embed("Hello, world!")

// Multiple texts
let vectors = try await client.embeddings.createEmbeddings(
    .init(input: ["Hello", "World"])
)
```

## Error Handling

The SDK provides detailed error information:

```swift
do {
    let response = try await client.chat.sendMessage("Hello!")
} catch let error as OpenAIError {
    switch error {
    case .invalidAPIKey:
        print("Invalid API key")
    case .rateLimitExceeded(let resetTime):
        print("Rate limit exceeded. Try again after: \(resetTime ?? Date())")
    case .modelNotAvailable(let model):
        print("Model not available: \(model)")
    default:
        print("Error: \(error.localizedDescription)")
    }
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

OpenAISwift is available under the MIT license. See the LICENSE file for more info.
