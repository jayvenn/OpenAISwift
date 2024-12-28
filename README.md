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

- **Type-safe API**: Swift-native interfaces with strong typing
- **Modern Concurrency**: Built with async/await
- **Comprehensive**: Support for Chat, Embeddings, and Assistants APIs
- **Reliable**: Thoroughly tested with both unit and integration tests

## Documentation

For detailed usage examples and API documentation, visit our [documentation](https://github.com/jayvenn/OpenAISwift/wiki).

## Contributing

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for details.

## License

OpenAISwift is available under the MIT license. See the LICENSE file for more info.
