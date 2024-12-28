import Foundation
import OpenAISwift
import Observation

@Observable
final class ChatViewModel {
    // MARK: - Properties
    
    private let openAI: OpenAIClient
    private var streamingHandler: StreamingHandler?
    
    var messages: [ChatMessage] = []
    var currentMessage: String = ""
    var isLoading = false
    var isStreaming = false
    var streamingResponse = ""
    
    // MARK: - Initialization
    
    init(openAI: OpenAIClient = DependencyContainer.shared.openAIClient) {
        self.openAI = openAI
    }
    
    // MARK: - Public Methods
    
    func sendMessage() async {
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
        
        do {
            if isStreaming {
                try await sendStreamingMessage(userMessage)
            } else {
                try await sendNormalMessage(userMessage)
            }
        } catch {
            print("Error: \(error)")
            isLoading = false
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func sendNormalMessage(_ message: ChatMessage) async throws {
        let response = try await openAI.chat.sendMessage(messages, model: .gpt4)
        messages.append(response)
        isLoading = false
    }
    
    @MainActor
    private func sendStreamingMessage(_ message: ChatMessage) async throws {
        streamingResponse = ""
        
        let handler = StreamingHandler(
            content: { [weak self] content in
                self?.streamingResponse += content
            },
            completion: { [weak self] in
                guard let self else { return }
                self.messages.append(
                    ChatMessage(
                        role: .assistant,
                        content: self.streamingResponse
                    )
                )
                self.streamingResponse = ""
                self.isLoading = false
            },
            error: { [weak self] error in
                print("Streaming error: \(error)")
                self?.isLoading = false
            }
        )
        
        // Keep strong reference to handler while streaming
        self.streamingHandler = handler
        
        try await openAI.sendStreamingMessage(
            message.content,
            model: .gpt4,
            delegate: handler
        )
    }
}

// MARK: - StreamingHandler

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
