import Foundation

/// Request parameters for chat completion
public struct ChatCompletionRequest: Codable, Sendable {
    /// The model to use for completion
    public let model: OpenAIModel
    
    /// The messages to generate chat completions for
    public let messages: [ChatMessage]
    
    /// What sampling temperature to use, between 0 and 2
    public let temperature: Double?
    
    /// An alternative to sampling with temperature
    public let topP: Double?
    
    /// How many chat completion choices to generate for each input message
    public let n: Int?
    
    /// Whether to stream back partial progress
    public var stream: Bool?
    
    /// Up to 4 sequences where the API will stop generating further tokens
    public let stop: [String]?
    
    /// The maximum number of tokens to generate in the chat completion
    public let maxTokens: Int?
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on whether they appear in the text so far
    public let presencePenalty: Double?
    
    /// Number between -2.0 and 2.0. Positive values penalize new tokens based on their existing frequency in the text so far
    public let frequencyPenalty: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case topP = "top_p"
        case n, stream, stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
    }
    
    public init(
        model: OpenAIModel = .defaultModel(for: .chatCompletion),
        messages: [ChatMessage],
        temperature: Double? = nil,
        topP: Double? = nil,
        n: Int? = nil,
        stream: Bool? = nil,
        stop: [String]? = nil,
        maxTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil
    ) {
        self.model = model
        self.messages = messages
        self.temperature = temperature
        self.topP = topP
        self.n = n
        self.stream = stream
        self.stop = stop
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
    }
}
