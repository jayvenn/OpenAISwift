import SwiftUI
import OpenAISwift

struct ChatCompletionView: View {
    @State private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            messageList
            inputArea
        }
        .navigationTitle("Chat")
    }
    
    private var messageList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.messages, id: \.content) { message in
                    MessageBubble(message: message)
                }
                
                if !viewModel.streamingResponse.isEmpty {
                    MessageBubble(
                        message: .init(
                            role: .assistant,
                            content: viewModel.streamingResponse
                        )
                    )
                }
            }
            .padding()
        }
    }
    
    private var inputArea: some View {
        VStack(spacing: 12) {
            Toggle("Streaming Mode", isOn: $viewModel.isStreaming)
                .padding(.horizontal)
            
            HStack {
                TextField("Type a message...", text: $viewModel.currentMessage)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isLoading)
                
                Button {
                    Task { await viewModel.sendMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundStyle(
                            viewModel.currentMessage.isEmpty || viewModel.isLoading
                            ? .gray
                            : .blue
                        )
                }
                .disabled(viewModel.currentMessage.isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background {
            Color(.systemBackground)
                .shadow(radius: 8, y: -4)
                .ignoresSafeArea()
        }
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            Text(message.content)
                .padding()
                .foregroundStyle(isUser ? .white : .primary)
                .background(isUser ? .blue : .gray.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            if !isUser { Spacer() }
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
