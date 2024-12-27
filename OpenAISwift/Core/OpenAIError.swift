//
//  OpenAIError.swift
//  OpenAISwift
//
//  Created by Jayven on 26/12/24.
//

import Foundation

public enum OpenAIError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case invalidData
    case httpError(statusCode: Int, data: Data?)
    case decodingError(Error)
    case encodingError(Error)
    case unknownError(Error)
    case networkError(String)
    case apiError(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Invalid data"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .apiError(let message):
            return "API error: \(message)"
        }
    }
    
    public static func == (lhs: OpenAIError, rhs: OpenAIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse),
             (.invalidURL, .invalidURL),
             (.invalidData, .invalidData):
            return true
        case let (.httpError(lhsStatusCode, _), .httpError(rhsStatusCode, _)):
            return lhsStatusCode == rhsStatusCode
        case let (.decodingError(lhsError), .decodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.encodingError(lhsError), .encodingError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.unknownError(lhsError), .unknownError(rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case let (.networkError(lhsMessage), .networkError(rhsMessage)):
            return lhsMessage == rhsMessage
        case let (.apiError(lhsMessage), .apiError(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
