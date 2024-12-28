import Foundation
import OpenAISwift
import Observation

final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentMessage: String = ""
    @Published var isLoading = false
    @Published var isStreaming = false
    @Published var streamingResponse = ""
    @Published var error: Error?
    
    private let openAI: OpenAIClient
    private var streamingHandler: StreamingHandler?
    
    init(openAI: OpenAIClient = DependencyContainer.shared.openAIClient) {
        self.openAI = openAI
    }
    
    @MainActor
    func sendMessage() async {
        guard !currentMessage.isEmpty else { return }
        
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
        error = nil
        
        do {
            if isStreaming {
                try await sendStreamingMessage(userMessage)
            } else {
                let responseContent = try await openAI.sendMessage(userMessage.content, model: .gpt4)
                await MainActor.run {
                    messages.append(.init(role: .assistant, content: responseContent))
                }
            }
        } catch {
            await MainActor.run {
                self.error = error
                print("Error in sendMessage: \(error.localizedDescription)")
            }
        }
        
        await MainActor.run {
            isLoading = false
        }
    }
    
    @MainActor
    private func sendStreamingMessage(_ message: ChatMessage) async throws {
        streamingResponse = ""
        
        let handler = StreamingHandler(
            content: { [weak self] content in
                Task { @MainActor [weak self] in
                    self?.streamingResponse += content
                }
            },
            completion: { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.messages.append(.init(role: .assistant, content: self.streamingResponse))
                    self.streamingResponse = ""
                    self.isLoading = false
                }
            },
            error: { [weak self] error in
                Task { @MainActor [weak self] in
                    self?.error = error
                    self?.isLoading = false
                }
            }
        )
        
        self.streamingHandler = handler
        
        let request = ChatCompletionRequest(
            model: .gpt4,
            messages: [message]
        )
        
        try await openAI.createStreamingChatCompletion(
            request,
            delegate: handler
        )
    }
}

private final class StreamingHandler: ChatStreamingDelegate {
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
