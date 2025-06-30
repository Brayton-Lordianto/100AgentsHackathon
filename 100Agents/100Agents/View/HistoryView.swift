
import SwiftUI

struct HistoryView: View {
    // Selected demo videos for history
    @State private var historyItems: [DemoVideo] = [
        .pythagoreanTheorem,
        .derivatives,
        .matrixOperations
    ]
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header section
                    headerSection
                    
                    if historyItems.isEmpty {
                        emptyHistoryView
                    } else {
                        // History items
                        LazyVStack(spacing: 16) {
                            ForEach(historyItems, id: \.id) { demoVideo in
                                HistoryItemCard(demoVideo: demoVideo)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !historyItems.isEmpty {
                        Button("Clear") {
                            showingClearAlert = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .alert("Clear History", isPresented: $showingClearAlert) {
                Button("Clear All", role: .destructive) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        historyItems.removeAll()
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to clear all learning history? This action cannot be undone.")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recent Learning")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Continue where you left off")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            Divider()
                .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No Learning History")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Start learning to see your progress here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

struct HistoryItemCard: View {
    let demoVideo: DemoVideo
    
    var body: some View {
        NavigationLink(destination: reelDestination) {
            VStack(alignment: .leading, spacing: 16) {
                // Header with icon and time
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text("Completed • 2 days ago")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                        
                        Text("3:42")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Prompt description
                Text(demoVideo.prompt)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Progress and action section
                VStack(spacing: 12) {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 6) {
//                        HStack {
//                            Text("Progress")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                            
//                            Spacer()
//                            
//                            Text("100%")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.blue)
//                        }
                        
//                        GeometryReader { geometry in
//                            ZStack(alignment: .leading) {
//                                Rectangle()
//                                    .fill(Color.gray.opacity(0.2))
//                                    .frame(height: 4)
//                                    .cornerRadius(2)
//                                
//                                Rectangle()
//                                    .fill(Color.blue)
//                                    .frame(width: geometry.size.width, height: 4)
//                                    .cornerRadius(2)
//                            }
//                        }
//                        .frame(height: 4)
                    }
                    
                    // Action button
                    HStack {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                            Text("Watch Again")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
            .padding(20)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    var formattedTitle: String {
        switch demoVideo {
        case .pythagoreanTheorem:
            return "Pythagorean Theorem"
        case .derivatives:
            return "Understanding Derivatives"
        case .matrixOperations:
            return "Matrix Operations"
        default:
            return demoVideo.rawValue.capitalized
        }
    }
    
    var reelDestination: some View {
        ReelView(
            title: formattedTitle,
            videoURL: videoURL,
            isActive: true
        )
    }
    
    var videoURL: URL? {
        guard let path = Bundle.main.path(forResource: demoVideo.rawValue, ofType: "mp4") else {
            print("Could not find video file: \(demoVideo.rawValue).mp4")
            return nil
        }
        return URL(fileURLWithPath: path)
    }
}

#Preview {
    HistoryView()
}
