import SwiftUI

// MARK: - Main View

struct NarrowSelectionView: View {
    let category: Set<MainCategory>
    var title: String {
        category.map(\.rawValue).joined(separator: ", ")
    }
    
    // Use the new ContentData model
    private var contentSections: [TopicSection] {
        ///for now
        ContentData.data[.physics] ?? []
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text(title)
                    .fontWeight(.semibold)
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)  // Add this line to allow unlimited lines
                    .padding(.horizontal)
                
                ForEach(contentSections) { section in
                    // Use a switch to apply different layouts for each section
                    switch section.title {
                    case "🔥 Trending Now", "🎯 Popular This Week":
                        HorizontalCarouselSection(section: section)
                    case "📚 Fundamentals":
                        FundamentalsSection(section: section)
                    case "⚡ Quick Concepts (5-min reels)":
                        QuickConceptsSection(section: section)
                    default:
                        // Fallback for any other sections
                        Text(section.title).font(.title).padding(.horizontal)
                        ForEach(section.items) { item in
                            Text(item.title).padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - Reusable Component Views

struct HorizontalCarouselSection: View {
    let section: TopicSection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(section.title)
                .font(.title2).bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(section.items) { item in
                        TrendingCard(item: item)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

struct FundamentalsSection: View {
    let section: TopicSection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(section.title)
                .font(.title2).bold()
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                ForEach(section.items) { item in
                    FundamentalsRow(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct QuickConceptsSection: View {
    let section: TopicSection
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(section.title)
                .font(.title2).bold()
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(section.items) { item in
                        QuickConceptCard(item: item)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Individual Item Views

struct TrendingCard: View {
    let item: ContentItem
    
    var body: some View {
        NavigationLink(destination: ReelView(subTopics: [item.title])) {
            VStack(alignment: .leading) {
                Spacer()
                Text(item.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
            }
            .frame(width: 250, height: 150)
            .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .cornerRadius(20)
            .shadow(radius: 5)
        }
    }
}

struct FundamentalsRow: View {
    let item: ContentItem
    
    var body: some View {
        NavigationLink(destination: ReelView(subTopics: [item.title])) {
            HStack {
                Image(systemName: "book.closed.fill")
                    .font(.title)
                    .foregroundColor(.accentColor)
                Text(item.title)
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct QuickConceptCard: View {
    let item: ContentItem
    
    var body: some View {
        NavigationLink(destination: ReelView(subTopics: [item.title])) {
            Text(item.title)
                .font(.subheadline).bold()
                .padding()
                .frame(width: 180, height: 100)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .shadow(radius: 3)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        NarrowSelectionView(category: Set<MainCategory>(arrayLiteral: .physics))
    }
}
