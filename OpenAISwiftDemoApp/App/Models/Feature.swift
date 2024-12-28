import SwiftUI

struct Feature: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let destination: AnyView
    let description: String
    
    static func == (lhs: Feature, rhs: Feature) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
