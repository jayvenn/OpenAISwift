import SwiftUI
import OpenAISwift

struct TextCompletionView: View {
    @State private var prompt = ""
    @State private var response = ""
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if !response.isEmpty {
                        Text(response)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
            
            VStack(spacing: 8) {
                TextField("Enter prompt", text: $prompt)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3)
                
                Button(action: {
                    // TODO: Implement text completion
                    isLoading = true
                }) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Complete")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("Text Completion")
        .navigationBarTitleDisplayMode(.inline)
    }
}
