import SwiftUI

struct FeatureCard: View {
    let feature: Feature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(feature.name)
                    .font(.headline)
            } icon: {
                Image(systemName: feature.icon)
                    .foregroundStyle(.blue)
            }
            
            Text(feature.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}
