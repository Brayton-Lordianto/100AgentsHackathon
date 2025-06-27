
import SwiftUI

struct ReelView: View {
    let subTopics: [String]
    @State private var isLoading = true

    var body: some View {
        ZStack {
            if isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .green))
                        .scaleEffect(2)
                    Text("Generating your reel...")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            } else {
                // This will be the reel player UI
                VStack {
                    Text("Reel Content")
                        .font(.largeTitle)
                    Text("Based on: \(subTopics.joined(separator: ", "))")
                        .padding()
                        .multilineTextAlignment(.center)
                    Spacer()
                    // Placeholder for reel controls
                    HStack(spacing: 40) {
                        Image(systemName: "backward.fill")
                        Image(systemName: "play.fill")
                        Image(systemName: "forward.fill")
                    }
                    .font(.largeTitle)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Your Reel")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Simulate network request and AI generation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ReelView(subTopics: ["Artificial Intelligence", "Machine Learning"])
    }
}
