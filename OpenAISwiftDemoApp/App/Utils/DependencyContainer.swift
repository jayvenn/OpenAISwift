 
//
//  DependencyContainer.swift
//  OpenAISwiftDemoApp
//
//  Created by Jayven on 28/12/24.
//

import Foundation
import OpenAISwift

/// A container that manages all dependencies in the app
final class DependencyContainer {
    /// Shared instance of the container
    static let shared = DependencyContainer()
    /// The OpenAI client instance
    let openAIClient: OpenAIClient = {
        let apiKey: String
        if let environmentAPIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            apiKey = environmentAPIKey
        } else {
            apiKey = "YOUR_API_KEY"
        }
        return OpenAIClient(apiKey: apiKey)
    }()
    
    private init() {}
}

