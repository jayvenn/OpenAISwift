import Foundation
import WebKit

/// Implementation of the Real-Time API
final class RealTimeEndpoint: NSObject, RealTimeAPI {
    private let client: OpenAIClient
    private var webSocket: URLSessionWebSocketTask?
    private var currentSession: RealTimeSession?
    private weak var delegate: RealTimeSessionDelegate?
    private let session: URLSession
    
    init(client: OpenAIClient) {
        self.client = client
        self.session = URLSession(configuration: .default)
        super.init()
    }
    
    func create(_ request: CreateSessionRequest) async throws -> CreateSessionResponse {
        try await client.performRequest(
            endpoint: .realTimeSessions,
            body: request
        )
    }
    
    func connect(to session: RealTimeSession, url: String, delegate: RealTimeSessionDelegate) {
        guard let url = URL(string: url) else {
            delegate.session(session, didEncounterError: OpenAIError.invalidURL)
            return
        }
        
        self.currentSession = session
        self.delegate = delegate
        
        let webSocket = self.session.webSocketTask(with: url)
        webSocket.resume()
        
        self.webSocket = webSocket
        self.receiveMessage()
        
        delegate.session(session, didChangeStatus: .active)
    }
    
    func disconnect() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        
        if let session = currentSession {
            delegate?.session(session, didChangeStatus: .expired)
        }
        
        currentSession = nil
        delegate = nil
    }
    
    func send(_ message: RealTimeMessage) async throws {
        guard let webSocket = webSocket else {
            throw OpenAIError.noActiveSession
        }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        let string = String(data: data, encoding: .utf8)!
        
        let message = URLSessionWebSocketTask.Message.string(string)
        try await webSocket.send(message)
    }
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handle(message)
                self.receiveMessage() // Continue receiving messages
                
            case .failure(let error):
                if let session = self.currentSession {
                    self.delegate?.session(session, didEncounterError: error)
                }
                self.disconnect()
            }
        }
    }
    
    private func handle(_ message: URLSessionWebSocketTask.Message) {
        guard let session = currentSession else { return }
        
        switch message {
        case .string(let text):
            do {
                let decoder = JSONDecoder()
                let data = text.data(using: .utf8)!
                let event = try decoder.decode(RealTimeEvent.self, from: data)
                
                switch event.type {
                case .message:
                    if let message = event.message {
                        delegate?.session(session, didReceiveMessage: message)
                    }
                case .error:
                    if let error = event.error {
                        let openAIError = OpenAIError.serverError(error.message)
                        delegate?.session(session, didEncounterError: openAIError)
                    }
                case .ping:
                    break // Handle ping event if needed
                }
            } catch {
                delegate?.session(session, didEncounterError: error)
            }
            
        case .data:
            break // Handle binary data if needed
            
        @unknown default:
            break
        }
    }
}
