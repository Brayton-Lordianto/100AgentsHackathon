import Foundation

// MARK: - Content Models
struct ContentItem: Identifiable {
    let id = UUID()
    let title: String
}

struct TopicSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [ContentItem]
}

// MARK: - Content Data
struct ContentData {
    static let data: [MainCategory: [TopicSection]] = [
        .physics: [
            TopicSection(title: "🔥 Trending Now", items: [
                ContentItem(title: "Complex Numbers Visualization"),
                ContentItem(title: "Quantum Mechanics Basics"),
                ContentItem(title: "Wave-Particle Duality")
            ]),
            TopicSection(title: "📚 Fundamentals", items: [
                ContentItem(title: "Pythagorean Theorem"),
                ContentItem(title: "Unit Circle"),
                ContentItem(title: "Derivatives"),
                ContentItem(title: "Matrix Operations")
            ]),
            TopicSection(title: "⚡ Quick Concepts (5-min reels)", items: [
                ContentItem(title: "3D Surface Plots"),
                ContentItem(title: "Sphere Volume"),
                ContentItem(title: "Cube Surface Area"),
                ContentItem(title: "Eigenvalues")
            ])
        ],
        .mathematics: [
            TopicSection(title: "🔥 Trending Now", items: [
                ContentItem(title: "Calculus Fundamentals"),
                ContentItem(title: "Linear Algebra"),
                ContentItem(title: "Number Theory")
            ]),
            TopicSection(title: "📚 Fundamentals", items: [
                ContentItem(title: "Quadratic Functions"),
                ContentItem(title: "Trigonometry"),
                ContentItem(title: "Statistics Basics")
            ]),
            TopicSection(title: "⚡ Quick Concepts (5-min reels)", items: [
                ContentItem(title: "Probability"),
                ContentItem(title: "Geometry"),
                ContentItem(title: "Algebra")
            ])
        ]
    ]
}