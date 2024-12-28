//
//  EnvironmentLoader.swift
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
    lazy var openAIClient: OpenAIClient = {
        do {
            let apiKey = try EnvironmentLoader.loadAPIKey()
            let configuration = OpenAIConfiguration(apiKey: apiKey)
            return OpenAIClient(configuration: configuration)
        } catch {
            fatalError("OpenAI API key not found. Please add OPENAI_API_KEY to your environment or .env file")
        }
    }()
    
    private init() {}
}
