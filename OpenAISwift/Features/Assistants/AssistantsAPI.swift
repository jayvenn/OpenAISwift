import Foundation

/// Protocol defining the Assistants API interface
public protocol AssistantsAPI {
    /// Create a new assistant
    /// - Parameter request: The request containing the assistant configuration
    /// - Returns: The created assistant
    func create(_ request: CreateAssistantRequest) async throws -> Assistant
    
    /// Retrieve an assistant by ID
    /// - Parameter id: The ID of the assistant to retrieve
    /// - Returns: The requested assistant
    func retrieve(id: String) async throws -> Assistant
    
    /// Modify an existing assistant
    /// - Parameters:
    ///   - id: The ID of the assistant to modify
    ///   - request: The request containing the modifications
    /// - Returns: The modified assistant
    func modify(id: String, _ request: ModifyAssistantRequest) async throws -> Assistant
    
    /// Delete an assistant
    /// - Parameter id: The ID of the assistant to delete
    /// - Returns: The deletion status
    func delete(id: String) async throws -> DeletionStatus
    
    /// List all assistants
    /// - Parameters:
    ///   - query: Optional query parameters for pagination
    /// - Returns: A paginated list of assistants
    func list(query: ListQuery?) async throws -> PaginatedResponse<Assistant>
}


/// Request to modify an existing assistant
public struct ModifyAssistantRequest: Codable {
    /// ID of the model to use
    public let model: String?
    
    /// The name of the assistant
    public let name: String?
    
    /// The description of the assistant
    public let description: String?
    
    /// The system instructions that the assistant uses
    public let instructions: String?
    
    /// A list of tools enabled on the assistant
    public let tools: [AssistantTool]?
    
    /// A list of file IDs attached to this assistant
    public let fileIds: [String]?
    
    /// Set of 16 key-value pairs that can be attached to the object
    public let metadata: [String: String]?
    
    public init(
        model: String? = nil,
        name: String? = nil,
        description: String? = nil,
        instructions: String? = nil,
        tools: [AssistantTool]? = nil,
        fileIds: [String]? = nil,
        metadata: [String: String]? = nil
    ) {
        self.model = model
        self.name = name
        self.description = description
        self.instructions = instructions
        self.tools = tools
        self.fileIds = fileIds
        self.metadata = metadata
    }
    
    private enum CodingKeys: String, CodingKey {
        case model, name, description, instructions, tools, metadata
        case fileIds = "file_ids"
    }
}
