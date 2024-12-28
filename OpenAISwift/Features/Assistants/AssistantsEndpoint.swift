import Foundation

/// Implementation of the Assistants API
final class AssistantsEndpoint: AssistantsAPI {
    private let client: OpenAIClient
    
    init(client: OpenAIClient) {
        self.client = client
    }
    
    func create(_ request: CreateAssistantRequest) async throws -> Assistant {
        let endpoint = OpenAIEndpoint.assistants
        return try await client.post(to: endpoint, body: request)
    }
    
    func retrieve(id: String) async throws -> Assistant {
        let endpoint = OpenAIEndpoint.assistant(id: id)
        return try await client.get(from: endpoint)
    }
    
    func modify(id: String, _ request: ModifyAssistantRequest) async throws -> Assistant {
        let endpoint = OpenAIEndpoint.assistant(id: id)
        return try await client.post(to: endpoint, body: request)
    }
    
    func delete(id: String) async throws -> DeletionStatus {
        let endpoint = OpenAIEndpoint.assistant(id: id)
        return try await client.delete(at: endpoint)
    }
    
    func list(query: ListQuery?) async throws -> PaginatedResponse<Assistant> {
        let endpoint = OpenAIEndpoint.assistants
        return try await client.get(from: endpoint, query: query)
    }
}
