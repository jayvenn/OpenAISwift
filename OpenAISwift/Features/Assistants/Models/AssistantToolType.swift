//
//  AssistantToolType.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// The type of tool available to an assistant
public enum AssistantToolType: String, Codable {
    case code = "code_interpreter"
    case retrieval = "retrieval"
    case function = "function"
}
