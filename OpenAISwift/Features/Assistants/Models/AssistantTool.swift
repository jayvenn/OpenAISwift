//
//  AssistantTool.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Represents a tool that can be used by an assistant
public struct AssistantTool: Codable {
    /// The type of tool
    public let type: AssistantToolType
    
    /// Function configuration for the tool if type is "function"
    public let function: FunctionConfiguration?
}
