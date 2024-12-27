import Foundation

/// Loads environment variables from .env file
enum EnvironmentLoader {
    /// Load environment variables from .env file
    static func load() {
        let envFile = ".env"
        let currentDirectoryURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let envFileURL = currentDirectoryURL.appendingPathComponent(envFile)
        
        guard let envContents = try? String(contentsOf: envFileURL, encoding: .utf8) else {
            print("⚠️ No .env file found at \(envFileURL.path)")
            return
        }
        
        let envVars = envContents
            .split(separator: "\n")
            .filter { !$0.hasPrefix("#") }
            .map(String.init)
        
        for line in envVars {
            let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                setenv(key, value, 1)
            }
        }
    }
}
