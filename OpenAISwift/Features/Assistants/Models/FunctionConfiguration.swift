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
    public let parameters: JSONSchema
    
    public init(
        name: String,
        description: String? = nil,
        parameters: JSONSchema
    ) {
        self.name = name
        self.description = description
        self.parameters = parameters
    }
}

/// Represents a JSON Schema structure
public struct JSONSchema: Codable {
    /// The underlying storage for schema properties
    private var storage: [String: Any]
    
    public init(_ dictionary: [String: Any]) {
        self.storage = dictionary
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StringCodingKey.self)
        var dictionary: [String: Any] = [:]
        
        for key in container.allKeys {
            if let value = try? container.decode(String.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Int.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Double.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(Bool.self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode([String].self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode([String: JSONSchema].self, forKey: key) {
                dictionary[key.stringValue] = value
            } else if let value = try? container.decode(JSONSchema.self, forKey: key) {
                dictionary[key.stringValue] = value
            }
        }
        
        self.storage = dictionary
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringCodingKey.self)
        
        for (key, value) in storage {
            let codingKey = StringCodingKey(stringValue: key)
            switch value {
            case let value as String:
                try container.encode(value, forKey: codingKey)
            case let value as Int:
                try container.encode(value, forKey: codingKey)
            case let value as Double:
                try container.encode(value, forKey: codingKey)
            case let value as Bool:
                try container.encode(value, forKey: codingKey)
            case let value as [String]:
                try container.encode(value, forKey: codingKey)
            case let value as [String: JSONSchema]:
                try container.encode(value, forKey: codingKey)
            case let value as JSONSchema:
                try container.encode(value, forKey: codingKey)
            default:
                break
            }
        }
    }
}

private struct StringCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}
