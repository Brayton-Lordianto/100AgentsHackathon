//
//  SearchView.swift
//  100Agents
//
//  Created by Sho Tsunoda on 28/6/25.
//
import SwiftUI

struct SearchView: View {
    @State private var query: String = ""
    @State private var searchResults: [TavilySearchResult] = []
    @State private var isLoading = false
    @State private var selectedResult: TavilySearchResult?
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var selectedTab: Int
    @Binding var urlForBrowse: String

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Header
                VStack(alignment: .leading, spacing: 16) {
                    // Search input section
                    VStack(spacing: 12) {
                        searchBar
                        
                        if isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Searching...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemGroupedBackground))
                
                // Results section
                if !searchResults.isEmpty {
                    searchResultsList
                } else if !query.isEmpty && !isLoading {
                    emptyStateView
                } else {
                    initialStateView
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style on iPhone
    }
    
    var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Search topics...", text: $query)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .onSubmit {
                        performSearch()
                    }
                
                if !query.isEmpty {
                    Button(action: {
                        query = ""
                        searchResults = []
                        selectedResult = nil
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            Button(action: performSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .medium))
                    .padding(12)
                    .background(
                        Circle()
                            .fill(query.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                    )
            }
            .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
            .animation(.easeInOut(duration: 0.2), value: query.isEmpty)
        }
    }
    
    var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults, id: \.url) { result in
                    SearchResultCard(
                        result: result,
                        isSelected: result.url == selectedResult?.url,
                        onTap: {
                            selectedResult = result
                        },
                        onProceedToBrowse: {
                            proceedToBrowse(with: result.url)
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "magnifyingglass.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    var initialStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Search for anything")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Find articles, papers, and resources\nto create educational content")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    func performSearch() {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        searchResults = []
        selectedResult = nil

        TavilySearchService.shared.search(query: query) { results in
            DispatchQueue.main.async {
                self.searchResults = results
                self.isLoading = false
            }
        }
    }
    
    func proceedToBrowse(with url: String) {
        urlForBrowse = url
        selectedTab = 0 // Switch to Browse tab (index 0)
    }
}

struct SearchResultCard: View {
    let result: TavilySearchResult
    let isSelected: Bool
    let onTap: () -> Void
    let onProceedToBrowse: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Main content - tappable to select
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title and URL
                    VStack(alignment: .leading, spacing: 6) {
                        Text(result.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        Text(result.url)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                    
                    // Content preview
                    if let content = result.content {
                        Text(content.prefix(150) + (content.count > 150 ? "…" : ""))
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Action buttons
            HStack(spacing: 12) {
                Spacer()
                
                Button(action: onProceedToBrowse) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 12, weight: .medium))
                        Text("Use in Browse")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.primary.opacity(0.1), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .scaleEffect(isSelected ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isSelected)
    }
}

#Preview {
    SearchView(selectedTab: .constant(1), urlForBrowse: .constant(""))
}
