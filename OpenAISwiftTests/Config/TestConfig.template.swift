import Foundation

/// Test configuration for OpenAI API
enum TestConfig {
    /// Get API key from environment variable
    static var apiKey: String {
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] {
            return key
        }
        fatalError("⚠️ Please set OPENAI_API_KEY environment variable")
    }
    
    /// Get optional organization ID from environment variable
    static var organization: String? {
        ProcessInfo.processInfo.environment["OPENAI_ORGANIZATION"]
    }
    
    /// Base URL for the API (can be overridden for testing)
    static var baseURL: URL {
        if let urlString = ProcessInfo.processInfo.environment["OPENAI_BASE_URL"],
           let url = URL(string: urlString) {
            return url
        }
        return URL(string: "https://api.openai.com/v1")!
    }
    
    /// Timeout interval for requests (in seconds)
    static var timeoutInterval: TimeInterval {
        if let timeoutString = ProcessInfo.processInfo.environment["OPENAI_TIMEOUT"],
           let timeout = TimeInterval(timeoutString) {
            return timeout
        }
        return 30
    }
}
