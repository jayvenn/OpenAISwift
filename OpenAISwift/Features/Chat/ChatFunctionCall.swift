//
//  ChatFunctionCall.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Represents a function call in chat completions
public struct ChatFunctionCall: Codable, Sendable {
    /// The name of the function to call
    public let name: String
    
    /// The arguments to pass to the function
    public let arguments: String
    
    public init(name: String, arguments: String) {
        self.name = name
        self.arguments = arguments
    }
}

/// Configuration for available functions in chat completions
public struct ChatFunctionConfiguration: Codable, Sendable {
    /// The list of available functions
    public let functions: [FunctionConfiguration]
    
    /// Whether function calling is required
    public let functionCall: FunctionCallOption?
    
    public init(functions: [FunctionConfiguration], functionCall: FunctionCallOption? = nil) {
        self.functions = functions
        self.functionCall = functionCall
    }
    
    /// Options for function calling behavior
    public enum FunctionCallOption: Codable, Sendable {
        /// Allow the model to choose which function to call, if any
        case auto
        
        /// Force the model to call a specific function
        case forceName(String)
        
        /// Don't call any function
        case none
        
        private enum CodingKeys: String, CodingKey {
            case name
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let name = try? container.decode(String.self, forKey: .name) {
                if name == "auto" {
                    self = .auto
                } else if name == "none" {
                    self = .none
                } else {
                    self = .forceName(name)
                }
            } else {
                self = .auto
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            switch self {
            case .auto:
                try container.encode("auto", forKey: .name)
            case .none:
                try container.encode("none", forKey: .name)
            case .forceName(let name):
                try container.encode(name, forKey: .name)
            }
        }
    }
}

// Example usage extension
public extension ChatFunctionConfiguration {
    /// Creates a configuration for the baby predictions function
    static func babyPredictions() -> ChatFunctionConfiguration {
        let function = FunctionConfiguration(
            name: "generate_baby_predictions",
            description: "Generates enchanting, personalized baby predictions based on parent photos.",
            parameters: JSONSchema.generateBabyPredictionsSchema()
        )
        
        return ChatFunctionConfiguration(functions: [function])
    }
} 
