import Foundation

/// Protocol defining the Real-Time API interface
public protocol RealTimeAPI {
    /// Create a new real-time session
    /// - Parameter request: The request containing the session configuration
    /// - Returns: The created session response with connection URL
    func create(_ request: CreateSessionRequest) async throws -> CreateSessionResponse
    
    /// Connect to a real-time session
    /// - Parameters:
    ///   - session: The session to connect to
    ///   - delegate: The delegate to receive session events
    func connect(to session: RealTimeSession, delegate: RealTimeSessionDelegate)
    
    /// Disconnect from the current session
    func disconnect()
    
    /// Send a message in the current session
    /// - Parameter message: The message to send
    func send(_ message: RealTimeMessage) async throws
}

/// Delegate protocol for receiving real-time session events
public protocol RealTimeSessionDelegate: AnyObject {
    /// Called when the session receives a message
    /// - Parameter message: The received message
    func session(_ session: RealTimeSession, didReceiveMessage message: RealTimeMessage)
    
    /// Called when the session encounters an error
    /// - Parameter error: The error that occurred
    func session(_ session: RealTimeSession, didEncounterError error: Error)
    
    /// Called when the session connection status changes
    /// - Parameter status: The new connection status
    func session(_ session: RealTimeSession, didChangeStatus status: SessionStatus)
}
