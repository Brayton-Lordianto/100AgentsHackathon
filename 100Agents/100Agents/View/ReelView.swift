
import SwiftUI
import AVKit

struct ReelView: View {
    let title: String
    let videoURL: URL?
    let isActive: Bool
    
    @State private var player: AVPlayer?
    @State private var isPlaying = true
    @State private var currentTime: Double = 0
    @State private var duration: Double = 0
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    @State private var showShareSheet = false
    @State private var showManimModal = false
    
    init(title: String, videoURL: URL?, isActive: Bool = true) {
        self.title = title
        self.videoURL = videoURL
        self.isActive = isActive
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .ignoresSafeArea(.all)
                        .allowsHitTesting(false)
                } else {
                    Color.black
                        .ignoresSafeArea(.all)
                }
                
                videoOverlay(geometry)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                togglePlayPause()
                print("hi")
            }
        }
        .navigationBarHidden(true)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            setupPlayer()
        }
        .onDisappear {
            player?.pause()
        }
        .onChange(of: isActive) { active in
            if active && player != nil {
                player?.play()
                isPlaying = true
            } else {
                player?.pause()
                isPlaying = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { _ in
            player?.seek(to: .zero)
            if isPlaying {
                player?.play()
            }
        }
    }
    
    private var progressValue: Double {
        isDragging ? dragValue : (duration > 0 ? currentTime / duration : 0)
    }
    
    @Environment(\.presentationMode) var presentationMode

    func videoOverlay(_ geometry: GeometryProxy) -> some View {
        ZStack {
            // Back button
            VStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }

            VStack {
                
                Spacer()
                
                // Custom progress bar at bottom
                VStack(spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.5), radius: 2)
                        Spacer()
                    }
                    .padding(.top, 60)
                    
                    progressBar(geometry)
                        .highPriorityGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    isDragging = true
                                    let newValue = Double(value.location.x / geometry.size.width)
                                    dragValue = max(0, min(1, newValue))
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    seekToTime(dragValue * duration)
                                }
                        )
                    
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            
            // Action buttons on the right side
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    // Share button
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                    }
                    
                    // Manim version button (twinkle stars)
                    Button(action: {
                        showManimModal = true
                    }) {
                        Image(systemName: "sparkles")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .shadow(color: .black.opacity(0.3), radius: 3)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 120) // Above progress bar
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .sheet(isPresented: $showShareSheet) {
            if let videoURL = videoURL {
                ShareSheet(activityItems: [videoURL])
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(isPresented: $showManimModal) {
            ManimModalView(title: title, onDismiss: {
                showManimModal = false
            })
            .presentationDetents([.medium, .large])
        }
    }
    
    func progressBar(_ geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            // Background track
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 3)
            
            // Progress fill
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.cyan, .blue, .purple]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: CGFloat(progressValue) * geometry.size.width, height: 3)
                .glow(radius: 0.5)
            
            // Draggable circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.white, .cyan]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 3
                    )
                )
                .frame(width: 8, height: 8)
                .scaleEffect(isDragging ? 1.5 : 1.0)
                .glow()
                .offset(x: CGFloat(progressValue) * geometry.size.width)
            
            Text(formatTime(dragValue * duration))
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.7))
                .cornerRadius(4)
                .offset(x: CGFloat(progressValue) * geometry.size.width)
                .offset(y: -35)
                .opacity(isDragging ? 1 : 0)
        }
    }

    
    private func setupPlayer() {
        guard let url = videoURL else { return }
        
        player = AVPlayer(url: url)
        
        // Only auto-play if this reel is active
        if isActive {
            player?.play()
            isPlaying = true
        } else {
            isPlaying = false
        }
        
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            currentTime = time.seconds
            if let duration = player?.currentItem?.duration.seconds, !duration.isNaN {
                self.duration = duration
            }
        }
    }
    
    private func togglePlayPause() {
        guard let player = player else { return }
        
        if player.timeControlStatus == .playing {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    private func seekToTime(_ time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: cmTime)
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Manim Modal View
struct ManimModalView: View {
    let title: String
    let onDismiss: () -> Void
    @State private var manimPlayer: AVPlayer?
    @State private var isLoading = true
    
    private var manimVideoURL: URL? {
        // Map title to corresponding Manim video
        let mapping: [String: String] = [
            "Complex Numbers": "complexNumbersManim",
            "Pythagorean Theorem": "pythagoreanTheoremManim",
            "Quadratic Functions": "quadraticFunctionManim",
            "Unit Circle": "unitCircleManim",
            "3D Surface Plots": "surfacePlotManim",
            "Sphere Volume": "sphereVolumeManim",
            "Cube Surface Area": "cubeSurfaceAreaManim",
            "Derivatives": "derivativesManim",
            "Matrix Operations": "matrixOperationsManim",
            "Eigenvalues": "eigenvaluesManim"
        ]
        
        // Find best match
        let bestMatch = mapping.keys.first { key in
            title.lowercased().contains(key.lowercased()) || key.lowercased().contains(title.lowercased())
        }
        
        if let match = bestMatch, let videoName = mapping[match] {
            return Bundle.main.url(forResource: videoName, withExtension: "mp4")
        }
        
        return nil
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                            .scaleEffect(1.5)
                        
                        Text("Loading Visualization...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                } else if let player = manimPlayer {
                    VStack {
                        Text(title + " Visualization")
                            .foregroundStyle(.white)
                        VideoPlayer(player: player)
                            .ignoresSafeArea()
                    }
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 60))
                            .foregroundColor(.cyan)
                            .glow()
                        
                        Text("Visualization Not Available")
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("The mathematical visualization for this video is not yet available.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Visualization")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        manimPlayer?.pause()
                        onDismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
        .onAppear {
            setupManimPlayer()
        }
        .onDisappear {
            manimPlayer?.pause()
        }
    }
    
    private func setupManimPlayer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if let url = manimVideoURL {
                manimPlayer = AVPlayer(url: url)
                manimPlayer?.play()
            }
            isLoading = false
        }
    }
}

extension View {
    func glow(color: Color = .cyan, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
    
    func neonGlow(color: Color = .cyan, radius: CGFloat = 20) -> some View {
        self
            .overlay(self.blur(radius: radius / 6))
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
    
    func rainbowGlow(radius: CGFloat = 20) -> some View {
        ZStack {
            ForEach(0..<3) { i in
                Rectangle()
                    .fill(
                        AngularGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red]),
                            center: .center
                        )
                    )
//                    .frame(width: 200, height: 200)
                    .mask(self.blur(radius: radius / 2))
                    .overlay(self.blur(radius: CGFloat(5 - i * 2)))
            }
        }
    }
}

#Preview {
    ReelView(
        title: "Complex Numbers",
        videoURL: Bundle.main.url(forResource: "complexNumbers", withExtension: "mp4"),
        isActive: true
    )
}
