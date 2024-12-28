//
//  ChatCompletionView.swift
//  OpenAISwiftDemoApp
//
//  Created by Jayven on 28/12/24.
//

import SwiftUI
import OpenAISwift

struct ChatCompletionView: View {
    @State private var messages: [ChatMessage] = []
    @State private var currentMessage: String = ""
    @State private var isLoading = false
    @State private var isStreaming = false
    @State private var streamingResponse = ""
    
    private let openAI = DependencyContainer.shared.openAIClient
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.content) { message in
                        MessageBubble(message: message)
                    }
                    
                    // Show streaming response if active
                    if !streamingResponse.isEmpty {
                        MessageBubble(
                            message: ChatMessage(
                                role: .assistant,
                                content: streamingResponse
                            )
                        )
                    }
                }
                .padding()
            }
            
            VStack {
                Toggle("Streaming Mode", isOn: $isStreaming)
                    .padding(.horizontal)
                
                HStack {
                    TextField("Type a message...", text: $currentMessage)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .disabled(isLoading)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(currentMessage.isEmpty ? .gray : .blue)
                    }
                    .disabled(currentMessage.isEmpty || isLoading)
                }
            }
            .padding()
        }
        .navigationTitle("Chat")
    }
    
    private func sendMessage() {
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
        
        if isStreaming {
            sendStreamingMessage(userMessage)
        } else {
            sendNormalMessage(userMessage)
        }
    }
    
    private func sendNormalMessage(_ message: ChatMessage) {
        Task {
            do {
                let response = try await openAI.chat.sendMessage(messages, model: .gpt4)
                await MainActor.run {
                    messages.append(response)
                    isLoading = false
                }
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
    
    private func sendStreamingMessage(_ message: ChatMessage) {
        streamingResponse = ""
        
        Task {
            do {
                try await openAI.sendStreamingMessage(
                    message.content,
                    model: .gpt4,
                    delegate: StreamingHandler { content in
                        Task { @MainActor in
                            streamingResponse += content
                        }
                    } completion: {
                        Task { @MainActor in
                            messages.append(
                                ChatMessage(
                                    role: .assistant,
                                    content: streamingResponse
                                )
                            )
                            streamingResponse = ""
                            isLoading = false
                        }
                    } error: { error in
                        print("Streaming error: \(error)")
                        Task { @MainActor in
                            isLoading = false
                        }
                    }
                )
            } catch {
                print("Error: \(error)")
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.role == .user {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .background(message.role == .user ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(message.role == .user ? .white : .primary)
                .cornerRadius(16)
            
            if message.role == .assistant {
                Spacer()
            }
        }
    }
}

private class StreamingHandler: ChatStreamingDelegate {
    private let onContent: (String) -> Void
    private let onCompletion: () -> Void
    private let onError: (Error) -> Void
    
    init(
        content: @escaping (String) -> Void,
        completion: @escaping () -> Void,
        error: @escaping (Error) -> Void
    ) {
        self.onContent = content
        self.onCompletion = completion
        self.onError = error
    }
    
    func didReceive(chunk: ChatStreamingResponse) {
        if let content = chunk.choices.first?.delta.content {
            onContent(content)
        }
    }
    
    func didComplete() {
        onCompletion()
    }
    
    func didError(_ error: Error) {
        onError(error)
    }
}

#Preview {
    ChatCompletionView()
}
