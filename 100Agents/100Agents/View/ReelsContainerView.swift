import SwiftUI
import AVKit

// MARK: - Reel Data Model
struct ReelData: Identifiable {
    let id = UUID()
    let title: String
    let videoURL: URL?
    
    init(title: String, videoFileName: String) {
        self.title = title
        self.videoURL = Bundle.main.url(forResource: videoFileName, withExtension: "mp4")
    }
}

// MARK: - Reels Container View
struct ReelsContainerView: View {
    let reels: [ReelData]
    let startingIndex: Int
    
    @State private var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    
    init(reels: [ReelData], startingIndex: Int = 0) {
        self.reels = reels
        self.startingIndex = startingIndex
        self._currentIndex = State(initialValue: startingIndex)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                // Reels stack
                ForEach(Array(reels.enumerated()), id: \.element.id) { index, reel in
                    ReelView(
                        title: reel.title,
                        videoURL: reel.videoURL,
                        isActive: index == currentIndex
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(y: CGFloat(index - currentIndex) * geometry.size.height + dragOffset)
                    .opacity(abs(index - currentIndex) <= 1 ? 1 : 0)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        isDragging = false
                        let threshold: CGFloat = geometry.size.height * 0.25
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            if value.translation.height > threshold && currentIndex > 0 {
                                // Swipe down - go to previous reel
                                currentIndex -= 1
                            } else if value.translation.height < -threshold && currentIndex < reels.count - 1 {
                                // Swipe up - go to next reel
                                currentIndex += 1
                            }
                            dragOffset = 0
                        }
                    }
            )
        }
        .navigationBarHidden(true)
        .statusBarHidden()
    }
}

// MARK: - Helper Functions
extension ReelsContainerView {
    static func createReelsFromContentItems(_ items: [ContentItem]) -> [ReelData] {
        return items.map { item in
            let videoMapping: [String: String] = [
                "Complex Numbers": "complexNumbers",
                "Pythagorean Theorem": "pythagoreanTheorem",
                "Quadratic Functions": "quadraticFunction",
                "Unit Circle": "unitCircle",
                "3D Surface Plots": "surfacePlot",
                "Sphere Volume": "sphereVolume",
                "Cube Surface Area": "cubeSurfaceArea",
                "Derivatives": "derivatives",
                "Matrix Operations": "matrixOperations",
                "Eigenvalues": "eigenvalues"
            ]
            
            // Find best match
            let bestMatch = videoMapping.keys.first { key in
                item.title.lowercased().contains(key.lowercased()) || key.lowercased().contains(item.title.lowercased())
            }
            
            let videoFileName = bestMatch.flatMap { videoMapping[$0] } ?? "complexNumbers"
            return ReelData(title: item.title, videoFileName: videoFileName)
        }
    }
}

// MARK: - Preview
#Preview {
    let sampleReels = [
        ReelData(title: "Complex Numbers", videoFileName: "complexNumbers"),
        ReelData(title: "Pythagorean Theorem", videoFileName: "pythagoreanTheorem"),
        ReelData(title: "Unit Circle", videoFileName: "unitCircle"),
        ReelData(title: "Derivatives", videoFileName: "derivatives"),
        ReelData(title: "Matrix Operations", videoFileName: "matrixOperations")
    ]
    
    return ReelsContainerView(reels: sampleReels, startingIndex: 0)
}
