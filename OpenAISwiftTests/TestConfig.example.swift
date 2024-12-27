import Foundation

/// Test configuration
enum TestConfig {
    /// Your OpenAI API key for testing
    static let apiKey = "your-api-key-here"
    
    /// Optional organization ID
    static let organization: String? = nil
    
    /// Base URL for the API (defaults to OpenAI production)
    static let baseURL = URL(string: "https://api.openai.com/v1")!
    
    /// Timeout interval for requests (in seconds)
    static let timeoutInterval: TimeInterval = 30
}
