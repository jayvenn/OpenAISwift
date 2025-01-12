//
//  FunctionConfiguration.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Configuration for a function tool
public struct FunctionConfiguration: Codable, Sendable {
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
@dynamicMemberLookup
public final class JSONSchema: Codable, @unchecked Sendable {
    /// The type of the schema value
    public let type: SchemaType
    
    /// Description of the schema
    public let description: String?
    
    /// Whether the property is required
    public let required: [String]?
    
    /// Properties for object types
    public let properties: [String: JSONSchema]?
    
    /// Items schema for array types
    public let items: JSONSchema?
    
    /// Whether additional properties are allowed for object types
    public let additionalProperties: Bool?
    
    /// Whether the schema is strict
    public let strict: Bool?
    
    public init(
        type: SchemaType,
        description: String? = nil,
        required: [String]? = nil,
        properties: [String: JSONSchema]? = nil,
        items: JSONSchema? = nil,
        additionalProperties: Bool? = nil,
        strict: Bool? = nil
    ) {
        self.type = type
        self.description = description
        self.required = required
        self.properties = properties
        self.items = items
        self.additionalProperties = additionalProperties
        self.strict = strict
    }
    
    public enum SchemaType: String, Codable, Sendable {
        case object
        case array
        case string
        case number
        case integer
        case boolean
        case null
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case description
        case required
        case properties
        case items
        case additionalProperties
        case strict
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<JSONSchema, T>) -> T {
        self[keyPath: keyPath]
    }
}

// Helper function to create a schema for your example
public extension JSONSchema {
    static func generateBabyPredictionsSchema() -> JSONSchema {
        return JSONSchema(
            type: .object,
            required: [
                "parent_photos",
                "sweet_details",
                "delightful_surprises",
                "viral_moments",
                "day_in_life"
            ],
            properties: [
                "day_in_life": JSONSchema(
                    type: .string,
                    description: "A touching 'Day in the Life' story of the child at age 3."
                ),
                "parent_photos": JSONSchema(
                    type: .array,
                    description: "Array of two parent photos to generate predictions from.",
                    items: JSONSchema(
                        type: .string,
                        description: "Base64 encoded string of the parent photo."
                    )
                ),
                "sweet_details": JSONSchema(
                    type: .object,
                    required: [
                        "first_smile",
                        "comfort_food",
                        "special_talent",
                        "inherited_habits",
                        "expressions"
                    ],
                    properties: [
                        "expressions": JSONSchema(
                            type: .string,
                            description: "Which parent's expressions the baby will mirror most."
                        ),
                        "first_smile": JSONSchema(
                            type: .string,
                            description: "Prediction of who will make the baby smile first."
                        ),
                        "comfort_food": JSONSchema(
                            type: .string,
                            description: "Future comfort food cravings based on parents' favorites."
                        ),
                        "special_talent": JSONSchema(
                            type: .string,
                            description: "Special talent or passion that the baby might inherit."
                        ),
                        "inherited_habits": JSONSchema(
                            type: .string,
                            description: "Heartwarming habits the baby will learn from each parent."
                        )
                    ],
                    additionalProperties: false
                ),
                "viral_moments": JSONSchema(
                    type: .object,
                    required: [
                        "celebrity_twin",
                        "future_career",
                        "signature_move"
                    ],
                    properties: [
                        "future_career": JSONSchema(
                            type: .string,
                            description: "Unexpected career aspiration based on combined parent traits."
                        ),
                        "celebrity_twin": JSONSchema(
                            type: .string,
                            description: "Which famous person's baby photos the child will resemble."
                        ),
                        "signature_move": JSONSchema(
                            type: .string,
                            description: "Unique, cute habit or gesture known for combining both parents."
                        )
                    ],
                    additionalProperties: false
                ),
                "delightful_surprises": JSONSchema(
                    type: .object,
                    required: [
                        "early_years",
                        "childhood",
                        "teen_years"
                    ],
                    properties: [
                        "childhood": JSONSchema(
                            type: .array,
                            description: "Predictions for early childhood stage (6-10 years).",
                            items: JSONSchema(
                                type: .string,
                                description: "Creative tendencies, special interests, friend dynamics."
                            )
                        ),
                        "teen_years": JSONSchema(
                            type: .array,
                            description: "Predictions for the teen years (11-18 years).",
                            items: JSONSchema(
                                type: .string,
                                description: "Future dreams, unique talents, family bonds."
                            )
                        ),
                        "early_years": JSONSchema(
                            type: .array,
                            description: "Predictions for the baby and toddler stage (1-5 years).",
                            items: JSONSchema(
                                type: .string,
                                description: "Personality quirks, first words, unique preferences."
                            )
                        )
                    ],
                    additionalProperties: false
                )
            ],
            additionalProperties: false,
            strict: true
        )
    }
}
