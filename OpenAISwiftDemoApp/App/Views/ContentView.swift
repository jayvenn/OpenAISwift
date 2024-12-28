//
//  ContentView.swift
//  OpenAISwiftDemoApp
//
//  Created by Jayven on 26/12/24.
//

import SwiftUI
import OpenAISwift

struct ContentView: View {
    private var features: [Feature] {
        [
            Feature(
                name: "Chat Completion",
                icon: "bubble.left.and.bubble.right.fill",
                destination: AnyView(ChatCompletionView()),
                description: "Have interactive conversations using GPT models"
            ),
            Feature(
                name: "Image Generation",
                icon: "photo.artframe",
                destination: AnyView(ImageGenerationView()),
                description: "Generate images from text descriptions using DALL-E"
            ),
            Feature(
                name: "Text Completion",
                icon: "text.bubble.fill",
                destination: AnyView(TextCompletionView()),
                description: "Generate and complete text using GPT models"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            List(features) { feature in
                NavigationLink(value: feature) {
                    FeatureCard(feature: feature)
                }
            }
            .navigationDestination(for: Feature.self) { feature in
                feature.destination
            }
            .navigationTitle("OpenAI Features")
            .listStyle(.insetGrouped)
        }
    }
}

#Preview {
    ContentView()
}

