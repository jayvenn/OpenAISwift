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
