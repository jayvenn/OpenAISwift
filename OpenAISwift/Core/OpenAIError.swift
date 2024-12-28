//
//  OpenAIError.swift
//  OpenAISwift
//
//  Created by Jayven on 26/12/24.
//

import Foundation

/// Represents errors that can occur when interacting with the OpenAI API
public enum OpenAIError: LocalizedError, Equatable {
    /// The API request failed with an HTTP error
    case httpError(statusCode: Int, data: Data)
    
    /// The response could not be decoded
    case decodingError(Error)
    
    /// The response was invalid or malformed
    case invalidResponse
    
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
    
    public var errorDescription: String? {
        switch self {
        case .httpError(let statusCode, _):
            return "Request failed with status code: \(statusCode)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidResponse:
            return "The server returned an invalid response"
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
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .httpError:
            return "Please check your request parameters and try again"
        case .decodingError:
            return "Please ensure your request format is correct"
        case .invalidResponse:
            return "Please try again later"
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
        }
    }
    
    public static func == (lhs: OpenAIError, rhs: OpenAIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.invalidAPIKey, .invalidAPIKey),
             (.timeout, .timeout),
             (.unknownError, .unknownError):
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
        default:
            return false
        }
    }
}
