//
//  DefaultChatStreamingDelegate.swift
//  OpenAISwift
//
//  Created by Jayven on 28/12/24.
//

import Foundation

/// Default implementation of streaming delegate
public class DefaultChatStreamingDelegate {
    /// The accumulated content of the message
    private var content: String = ""
    
    /// The accumulated function call arguments
    private var functionCallArguments: String = ""
    
    /// The name of the function being called
    private var functionCallName: String?
    
    /// Completion handler for the final message
    private let completion: (Result<ChatMessage, Error>) -> Void
    
    public init(completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        self.completion = completion
    }
}

extension DefaultChatStreamingDelegate: ChatStreamingDelegate {
    public func didReceive(chunk: ChatStreamingResponse) {
        guard let choice = chunk.choices.first else { return }
        
        if let content = choice.delta.content {
            self.content += content
        }
        
        if let functionCall = choice.delta.functionCall {
            self.functionCallName = functionCall.name
            self.functionCallArguments += functionCall.arguments
        }
    }
    
    public func didComplete() {
        let message: ChatMessage
        if let name = functionCallName {
            message = ChatMessage(
                role: .assistant,
                content: content.isEmpty ? nil : content,
                functionCall: ChatFunctionCall(
                    name: name,
                    arguments: functionCallArguments
                )
            )
        } else {
            message = ChatMessage(role: .assistant, content: content)
        }
        completion(.success(message))
    }
    
    public func didError(_ error: Error) {
        completion(.failure(error))
    }
} 
