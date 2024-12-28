import Foundation

/// Response structure for OpenAI API errors
public struct OpenAIErrorResponse: Codable {
    /// The error details
    public let error: ErrorDetail
    
    /// Structure containing error details
    public struct ErrorDetail: Codable {
        /// The error message
        public let message: String
        /// The error type
        public let type: String?
        /// The parameter that caused the error, if any
        public let param: String?
        /// The error code, if any
        public let code: String?
    }
}
