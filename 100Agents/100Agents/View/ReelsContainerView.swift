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
    let startingVideo: DemoVideo?
    
    @State private var currentIndex: Int
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var videoFlow: [DemoVideo] = []
    
    init(reels: [ReelData], startingIndex: Int = 0, startingVideo: DemoVideo? = nil) {
        self.reels = reels
        self.startingIndex = startingIndex
        self.startingVideo = startingVideo
        self._currentIndex = State(initialValue: startingIndex)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.ignoresSafeArea()
                
                if !videoFlow.isEmpty {
                    // Video flow stack
                    ForEach(Array(videoFlow.enumerated()), id: \.element.id) { index, video in
                        ReelView(
                            title: video.displayTitle,
                            videoURL: videoURL(for: video),
                            isActive: index == currentIndex
                        )
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .offset(y: CGFloat(index - currentIndex) * geometry.size.height + dragOffset)
                        .opacity(abs(index - currentIndex) <= 1 ? 1 : 0)
                    }
                } else {
                    // Fallback to original reels
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
                        let maxIndex = videoFlow.isEmpty ? reels.count - 1 : videoFlow.count - 1
                        
                        withAnimation(.easeOut(duration: 0.3)) {
                            if value.translation.height > threshold && currentIndex > 0 {
                                // Swipe down - go to previous reel
                                currentIndex -= 1
                            } else if value.translation.height < -threshold && currentIndex < maxIndex {
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
        .onAppear {
            setupVideoFlow()
        }
    }
    
    private func setupVideoFlow() {
        // Create a learning flow based on starting video or content
        var flow: [DemoVideo] = []
        
        if let startingVideo = startingVideo {
            // Start with the provided video and build flow from there
            flow.append(startingVideo)
            var current = startingVideo
            
            // Add next videos in the flow
            while let next = current.next {
                flow.append(next)
                current = next
            }
            
            // Add previous videos at the beginning (reverse order)
            current = startingVideo
            var previousVideos: [DemoVideo] = []
            while let previous = current.previous {
                previousVideos.insert(previous, at: 0)
                current = previous
            }
            flow = previousVideos + flow
            
            // Set current index to the starting video position
            currentIndex = previousVideos.count
        } else if !reels.isEmpty {
            // Map from existing reels to demo videos based on title matching
            flow = reels.compactMap { reel in
                mapTitleToDemoVideo(reel.title)
            }
            
            // If we found matches, create a proper flow
            if !flow.isEmpty {
                let startVideo = flow[min(startingIndex, flow.count - 1)]
                setupFlowFromVideo(startVideo)
                return
            }
        }
        
        // Default flow if nothing else works
        if flow.isEmpty {
            flow = [
                .pythagoreanTheorem,
                .derivatives,
                .quadraticFunction,
                .unitCircle,
                .surfacePlot,
                .sphereVolume,
                .cubeSurfaceArea,
                .matrixOperations,
                .eigenvalues,
                .complexNumbers
            ]
        }
        
        videoFlow = flow
    }
    
    private func setupFlowFromVideo(_ startVideo: DemoVideo) {
        var flow: [DemoVideo] = [startVideo]
        var current = startVideo
        
        // Add next videos
        while let next = current.next {
            flow.append(next)
            current = next
        }
        
        // Add previous videos at the beginning
        current = startVideo
        var previousVideos: [DemoVideo] = []
        while let previous = current.previous {
            previousVideos.insert(previous, at: 0)
            current = previous
        }
        flow = previousVideos + flow
        currentIndex = previousVideos.count
        videoFlow = flow
    }
    
    private func mapTitleToDemoVideo(_ title: String) -> DemoVideo? {
        let titleMapping: [String: DemoVideo] = [
            "Complex Numbers": .complexNumbers,
            "Pythagorean Theorem": .pythagoreanTheorem,
            "Quadratic Functions": .quadraticFunction,
            "Unit Circle": .unitCircle,
            "3D Surface Plots": .surfacePlot,
            "Sphere Volume": .sphereVolume,
            "Cube Surface Area": .cubeSurfaceArea,
            "Derivatives": .derivatives,
            "Understanding Derivatives": .derivatives,
            "Matrix Operations": .matrixOperations,
            "Eigenvalues": .eigenvalues,
            "Eigenvalues & Eigenvectors": .eigenvalues
        ]
        
        // Find exact match first
        if let exactMatch = titleMapping[title] {
            return exactMatch
        }
        
        // Find partial match
        return titleMapping.keys.first { key in
            title.lowercased().contains(key.lowercased()) || key.lowercased().contains(title.lowercased())
        }.flatMap { titleMapping[$0] }
    }
    
    private func videoURL(for video: DemoVideo) -> URL? {
        // Try old_100_agents_videos directory first
        if let url = Bundle.main.url(forResource: video.rawValue, withExtension: "mp4", subdirectory: "media/old_100_agents_videos") {
            return url
        }
        
        // Fallback to root directory
        return Bundle.main.url(forResource: video.rawValue, withExtension: "mp4")
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
