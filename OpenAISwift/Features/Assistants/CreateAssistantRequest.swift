//
//  CreateAssistantRequest.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Request to create a new assistant
public struct CreateAssistantRequest: Codable {
    /// ID of the model to use
    public let model: String
    
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
        model: String,
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
