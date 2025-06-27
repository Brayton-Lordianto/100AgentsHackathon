
import Foundation

// MARK: - Data Models for Curated Content

struct ContentItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    // Could add more properties like description, image name, etc.
}

struct TopicSection: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let items: [ContentItem]
}

// MARK: - Curated Content Data

struct ContentData {
    static let physicsContent: [TopicSection] = [
        TopicSection(title: "🔥 Trending Now", items: [
            ContentItem(title: "Why is the James Webb telescope revolutionary?"),
            ContentItem(title: "Quantum computing breakthroughs 2025"),
            ContentItem(title: "SpaceX's new propulsion tech")
        ]),
        TopicSection(title: "📚 Fundamentals", items: [
            ContentItem(title: "Newton's Laws Explained"),
            ContentItem(title: "Understanding Relativity"),
            ContentItem(title: "Quantum Mechanics Basics")
        ]),
        TopicSection(title: "🎯 Popular This Week", items: [
            ContentItem(title: "Physics behind viral TikTok experiments"),
            ContentItem(title: "How do black holes actually work?"),
            ContentItem(title: "The physics of climate change")
        ]),
        TopicSection(title: "⚡ Quick Concepts (5-min reels)", items: [
            ContentItem(title: "Momentum in 60 seconds"),
            ContentItem(title: "Energy conservation explained")
        ])
    ]
    
    // We can add more curated content for other topics here
    static let data: [MainCategory: [TopicSection]] = [
        .physics: physicsContent
        // .computerScience: computerScienceContent,
        // .art: artContent,
    ]
}
