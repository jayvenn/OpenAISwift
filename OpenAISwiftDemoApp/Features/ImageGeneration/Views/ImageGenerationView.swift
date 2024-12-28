import SwiftUI
import OpenAISwift

struct ImageGenerationView: View {
    @State private var prompt = ""
    @State private var generatedImage: Image?
    @State private var isLoading = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let image = generatedImage {
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .padding()
                }
                
                VStack(spacing: 8) {
                    TextField("Enter image prompt", text: $prompt)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3)
                    
                    Button(action: {
                        // TODO: Implement image generation
                        isLoading = true
                    }) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Generate")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
                .padding()
            }
        }
        .navigationTitle("Image Generation")
        .navigationBarTitleDisplayMode(.inline)
    }
}
