import Foundation
import OpenAISwift
import Observation

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var currentMessage: String = ""
    var isLoading = false
    var isStreaming = false
    var streamingResponse = ""
    
    private let openAI: OpenAIClient
    private var streamingHandler: StreamingHandler?
    
    init(openAI: OpenAIClient = DependencyContainer.shared.openAIClient) {
        self.openAI = openAI
    }
    
    @MainActor
    func sendMessage() async {
        let userMessage = ChatMessage(role: .user, content: currentMessage)
        messages.append(userMessage)
        currentMessage = ""
        isLoading = true
        
        do {
            if isStreaming {
                try await sendStreamingMessage(userMessage)
            } else {
                let response = try await openAI.chat.sendMessage(messages, model: .gpt4)
                messages.append(response)
            }
        } catch {
            print("Error: \(error)")
        }
        
        isLoading = false
    }
    
    private func sendStreamingMessage(_ message: ChatMessage) async throws {
        streamingResponse = ""
        
        let handler = StreamingHandler(
            content: { [weak self] in self?.streamingResponse += $0 },
            completion: { [weak self] in
                guard let self else { return }
                self.messages.append(.init(role: .assistant, content: self.streamingResponse))
                self.streamingResponse = ""
            }
        )
        
        self.streamingHandler = handler
        
        try await openAI.sendStreamingMessage(
            message.content,
            model: .gpt4,
            delegate: handler
        )
    }
}

private final class StreamingHandler: ChatStreamingDelegate {
    private let onContent: (String) -> Void
    private let onCompletion: () -> Void
    
    init(
        content: @escaping (String) -> Void,
        completion: @escaping () -> Void
    ) {
        self.onContent = content
        self.onCompletion = completion
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
        print("Streaming error: \(error)")
    }
}
