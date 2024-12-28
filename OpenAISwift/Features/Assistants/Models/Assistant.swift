import Foundation

/// Represents an OpenAI Assistant
public struct Assistant: Codable, Identifiable {
    /// The identifier of the assistant
    public let id: String
    
    /// The object type (always "assistant")
    public let object: String
    
    /// The Unix timestamp (in seconds) for when the assistant was created
    public let createdAt: Int
    
    /// Name of the assistant
    public let name: String?
    
    /// Description of the assistant
    public let description: String?
    
    /// The model that the assistant uses
    public let model: String
    
    /// The system instructions that the assistant uses
    public let instructions: String?
    
    /// A list of tool configurations for the assistant
    public let tools: [AssistantTool]
    
    /// A list of file IDs attached to this assistant
    public let fileIds: [String]
    
    /// Set of 16 key-value pairs that can be attached to the object
    public let metadata: [String: String]?
    
    private enum CodingKeys: String, CodingKey {
        case id, object, name, description, model, instructions, tools, metadata
        case createdAt = "created_at"
        case fileIds = "file_ids"
    }
}

/// Represents a tool that can be used by an assistant
public struct AssistantTool: Codable {
    /// The type of tool
    public let type: AssistantToolType
    
    /// Function configuration for the tool if type is "function"
    public let function: FunctionConfiguration?
}

/// The type of tool available to an assistant
public enum AssistantToolType: String, Codable {
    case code = "code_interpreter"
    case retrieval = "retrieval"
    case function = "function"
}

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
