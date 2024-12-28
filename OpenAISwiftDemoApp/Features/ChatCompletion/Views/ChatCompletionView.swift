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
    
    private let openAI = DependencyContainer.shared.openAIClient
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(messages, id: \.content) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
            }
            
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
            .padding()
        }
        .navigationTitle("Chat")
    }
    
    private func sendMessage() {
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
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

#Preview {
    ChatCompletionView()
}
