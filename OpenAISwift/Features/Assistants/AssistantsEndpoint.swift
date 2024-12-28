import Foundation

/// Implementation of the Assistants API
final class AssistantsEndpoint: AssistantsAPI {
    private let client: OpenAIClient
    
    init(client: OpenAIClient) {
        self.client = client
    }
    
    func create(_ request: CreateAssistantRequest) async throws -> Assistant {
        try await client.performRequest(
            endpoint: .assistants,
            body: request
        )
    }
    
    func retrieve(id: String) async throws -> Assistant {
        try await client.performRequest(
            endpoint: .assistant(id: id),
            body: EmptyBody()
        )
    }
    
    func modify(id: String, _ request: ModifyAssistantRequest) async throws -> Assistant {
        try await client.performRequest(
            endpoint: .assistant(id: id),
            body: request
        )
    }
    
    func delete(id: String) async throws -> DeletionStatus {
        try await client.performRequest(
            endpoint: .assistant(id: id),
            body: EmptyBody()
        )
    }
    
    func list(query: ListQuery?) async throws -> PaginatedResponse<Assistant> {
        try await client.performRequest(
            endpoint: .assistants,
            body: query
        )
    }
}

/// Empty body for requests that don't need a body
private struct EmptyBody: Codable {}
