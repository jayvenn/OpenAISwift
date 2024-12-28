import Foundation

/// A utility for loading environment variables from a .env file
public enum EnvironmentLoader {
    /// Possible errors when loading environment variables
    public enum Error: Swift.Error {
        case apiKeyNotFound
    }
    
    /// Retrieves the OpenAI API key from either .env file or environment variables
    /// - Returns: The OpenAI API key
    /// - Throws: Error if API key is not found
    public static func loadAPIKey() throws -> String {
        // Try loading from .env file first
        if let key = try? loadFromEnvFile() {
            return key
        }
        
        // Fall back to environment variables
        guard let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] else {
            throw Error.apiKeyNotFound
        }
        
        return key
    }
    
    /// Attempts to load API key from .env file
    private static func loadFromEnvFile() throws -> String? {
        let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            .appendingPathComponent(".env")
        
        guard let contents = try? String(contentsOf: fileURL, encoding: .utf8) else {
            return nil
        }
        
        return contents
            .split(separator: "\n")
            .filter { !$0.hasPrefix("#") }
            .compactMap { line -> String? in
                let parts = line.split(separator: "=", maxSplits: 1)
                guard parts.count == 2,
                      parts[0].trimmingCharacters(in: .whitespaces) == "OPENAI_API_KEY"
                else { return nil }
                
                return parts[1]
                    .trimmingCharacters(in: .whitespaces)
                    .trimmingCharacters(in: .init(charactersIn: "\"'"))
            }
            .first
    }
}
