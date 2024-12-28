//
//  OpenAIError.swift
//  OpenAISwift
//
//  Created by Jayven on 26/12/24.
//

import Foundation

/// Errors that can occur when using the OpenAI API
public enum OpenAIError: LocalizedError, Equatable {
    /// The URL was invalid
    case invalidURL
    
    /// The response was invalid
    case invalidResponse
    
    /// An HTTP error occurred
    case httpError(statusCode: Int, data: Data)
    
    /// A server error occurred
    case serverError(String)
    
    /// No active session
    case noActiveSession
    
    /// The API key is missing or invalid
    case invalidAPIKey
    
    /// The request exceeded the rate limit
    case rateLimitExceeded(resetTime: Date?)
    
    /// The model specified is not available
    case modelNotAvailable(model: String)
    
    /// Network connection error
    case networkError(Error)
    
    /// Request timeout
    case timeout
    
    /// Unknown error occurred
    case unknownError
    
    /// The response could not be decoded
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL was invalid"
        case .invalidResponse:
            return "The response was invalid"
        case .httpError(let statusCode, _):
            return "HTTP error \(statusCode)"
        case .serverError(let message):
            return message
        case .noActiveSession:
            return "No active session"
        case .invalidAPIKey:
            return "The API key is missing or invalid"
        case .rateLimitExceeded(let resetTime):
            if let time = resetTime {
                return "Rate limit exceeded. Try again after \(time)"
            }
            return "Rate limit exceeded"
        case .modelNotAvailable(let model):
            return "The model '\(model)' is not available"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .timeout:
            return "The request timed out"
        case .unknownError:
            return "An unknown error occurred"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL:
            return "Please check your request URL"
        case .invalidResponse:
            return "Please try again later"
        case .httpError:
            return "Please check your request parameters and try again"
        case .serverError:
            return "Please try again later"
        case .noActiveSession:
            return "Please establish a session before making a request"
        case .invalidAPIKey:
            return "Please check your API key configuration"
        case .rateLimitExceeded:
            return "Please wait before making another request"
        case .modelNotAvailable:
            return "Please use a different model or check model availability"
        case .networkError:
            return "Please check your internet connection"
        case .timeout:
            return "Please try again or increase the timeout interval"
        case .unknownError:
            return "Please try again or contact support if the issue persists"
        case .decodingError:
            return "Please ensure your request format is correct"
        }
    }
    
    public static func == (lhs: OpenAIError, rhs: OpenAIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.invalidAPIKey, .invalidAPIKey),
             (.timeout, .timeout),
             (.unknownError, .unknownError),
             (.noActiveSession, .noActiveSession):
            return true
        case let (.httpError(lhsCode, lhsData), .httpError(rhsCode, rhsData)):
            return lhsCode == rhsCode && lhsData == rhsData
        case let (.decodingError(lhsError), .decodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.rateLimitExceeded(lhsTime), .rateLimitExceeded(rhsTime)):
            return lhsTime == rhsTime
        case let (.modelNotAvailable(lhsModel), .modelNotAvailable(rhsModel)):
            return lhsModel == rhsModel
        case let (.networkError(lhsError), .networkError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.serverError(lhsMessage), .serverError(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
