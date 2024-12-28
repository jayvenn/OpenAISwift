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
    let openAIClient: OpenAIClient = OpenAIClient(apiKey: "")
    
    private init() {}
}
