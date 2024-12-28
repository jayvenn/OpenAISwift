//
//  ChatCompletionView.swift
//  OpenAISwiftDemoApp
//
//  Created by Jayven on 28/12/24.
//

import SwiftUI
import OpenAISwift

struct ChatCompletionView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        ChatContentView(viewModel: viewModel)
            .navigationTitle("Chat")
    }
}

// MARK: - Chat Content View

private struct ChatContentView: View {
    let viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ChatMessagesView(
                messages: viewModel.messages,
                streamingResponse: viewModel.streamingResponse
            )
            
            ChatInputView(viewModel: viewModel)
        }
    }
}

// MARK: - Chat Messages View

private struct ChatMessagesView: View {
    let messages: [ChatMessage]
    let streamingResponse: String
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(messages, id: \.content) { message in
                    MessageBubble(message: message)
                }
                
                if !streamingResponse.isEmpty {
                    MessageBubble(
                        message: .init(
                            role: .assistant,
                            content: streamingResponse
                        )
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Chat Input View

private struct ChatInputView: View {
    let viewModel: ChatViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Toggle("Streaming Mode", isOn: $viewModel.isStreaming)
                .padding(.horizontal)
            
            HStack {
                TextField("Type a message...", text: $viewModel.currentMessage)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                
                SendButton(
                    isEnabled: !viewModel.currentMessage.isEmpty && !viewModel.isLoading,
                    action: {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                )
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background {
            Rectangle()
                .fill(.background)
                .shadow(radius: 8, y: -4)
                .ignoresSafeArea()
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage
    
    private var isUser: Bool {
        message.role == .user
    }
    
    var body: some View {
        HStack {
            if isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding()
                .foregroundStyle(isUser ? .white : .primary)
                .background(isUser ? .blue : .gray.opacity(0.2))
                .clipShape(BubbleShape(isUser: isUser))
            
            if !isUser {
                Spacer()
            }
        }
    }
}

// MARK: - Send Button

private struct SendButton: View {
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "paperplane.fill")
                .foregroundStyle(isEnabled ? .blue : .gray)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Bubble Shape

private struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let radius: CGFloat = 16
        let cornerRadius: CGFloat = 4
        
        path.move(to: CGPoint(x: rect.minX + radius, y: rect.minY))
        
        // Top edge
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        
        // Top right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.minY + radius),
            radius: radius,
            startAngle: Angle(degrees: -90),
            endAngle: Angle(degrees: 0),
            clockwise: false
        )
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        
        // Bottom right corner
        path.addArc(
            center: CGPoint(x: rect.maxX - radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        
        // Bottom left corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.maxY - radius),
            radius: radius,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )
        
        // Left edge
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        
        // Top left corner
        path.addArc(
            center: CGPoint(x: rect.minX + radius, y: rect.minY + radius),
            radius: radius,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )
        
        return path
    }
}

// MARK: - Chat View Model

class ChatViewModel {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading = false
    @Published var isStreaming = false
    @Published var streamingResponse = ""
    
    private let openAI = DependencyContainer.shared.openAIClient
    
    func sendMessage() async {
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
        
        if isStreaming {
            await sendStreamingMessage(userMessage)
        } else {
            await sendNormalMessage(userMessage)
        }
    }
    
    private func sendNormalMessage(_ message: ChatMessage) async {
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
    
    private func sendStreamingMessage(_ message: ChatMessage) async {
        streamingResponse = ""
        
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

// MARK: - Streaming Handler

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
    NavigationStack {
        ChatCompletionView()
    }
}
