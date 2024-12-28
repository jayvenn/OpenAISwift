import Foundation

/// Response when deleting a resource
public struct DeletionStatus: Codable {
    /// The ID of the deleted resource
    public let id: String
    
    /// The object type that was deleted
    public let object: String
    
    /// Whether the deletion was successful
    public let deleted: Bool
}

/// Query parameters for listing resources
public struct ListQuery: Codable {
    /// Maximum number of results to return
    public let limit: Int?
    
    /// Identifier for the next page of results
    public let after: String?
    
    /// Identifier for the previous page of results
    public let before: String?
    
    /// Order of the results
    public let order: String?
    
    public init(
        limit: Int? = nil,
        after: String? = nil,
        before: String? = nil,
        order: String? = nil
    ) {
        self.limit = limit
        self.after = after
        self.before = before
        self.order = order
    }
    
    /// Convert to URL query items
    public var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        if let limit = limit {
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        if let after = after {
            items.append(URLQueryItem(name: "after", value: after))
        }
        if let before = before {
            items.append(URLQueryItem(name: "before", value: before))
        }
        if let order = order {
            items.append(URLQueryItem(name: "order", value: order))
        }
        
        return items
    }
}

/// A paginated response containing a list of items
public struct PaginatedResponse<T: Codable>: Codable {
    /// The list of items
    public let data: [T]
    
    /// Whether there are more results available
    public let hasMore: Bool
    
    /// Token for the next page of results
    public let nextToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case data
        case hasMore = "has_more"
        case nextToken = "next_token"
    }
}
