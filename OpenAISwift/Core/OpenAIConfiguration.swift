//
//  OpenAIConfiguration.swift
//  OpenAISwift
//
//  Created by Jayven on 26/12/24.
//

import Foundation

/// Configuration for the OpenAI client
public struct OpenAIConfiguration {
    /// The API key used for authentication with OpenAI services
    public let apiKey: String
    
    /// The base URL for the OpenAI API
    public let baseURL: URL
    
    /// The organization ID (optional)
    public let organization: String?
    
    /// Default timeout interval for requests in seconds
    public let timeoutInterval: TimeInterval
    
    /// Creates a new OpenAI configuration
    /// - Parameters:
    ///   - apiKey: Your OpenAI API key
    ///   - organization: Optional organization ID
    ///   - baseURL: The base URL for API requests (defaults to OpenAI's API)
    ///   - timeoutInterval: Request timeout in seconds (defaults to 60)
    public init(
        apiKey: String,
        organization: String? = nil,
        baseURL: URL = URL(string: "https://api.openai.com/v1")!,
        timeoutInterval: TimeInterval = 60
    ) {
        self.apiKey = apiKey
        self.organization = organization
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
    }
}
