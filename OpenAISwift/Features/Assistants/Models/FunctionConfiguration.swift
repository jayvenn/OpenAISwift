//
//  FunctionConfiguration.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Configuration for a function tool
public struct FunctionConfiguration: Codable {
    /// The name of the function
    public let name: String
    
    /// A description of what the function does
    public let description: String?
    
    /// The parameters the function accepts, described as a JSON Schema object
    public let parameters: [String: Any]
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        parameters = try container.decode([String: Any].self, forKey: .parameters)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(parameters, forKey: .parameters)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name, description, parameters
    }
}
