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

    var body: some View {
        HStack(spacing: 0) {
            // LEFT PANE
            VStack(alignment: .leading, spacing: 16) {
                Text("Search")
                    .font(.largeTitle.bold())
                    .padding(.top, 32)
                    .padding(.horizontal)

                HStack(spacing: 8) {
                    TextField("Search topics...", text: $query, onCommit: performSearch)
                        .textFieldStyle(.roundedBorder)
                        .padding(.leading)
                        .frame(height: 36)

                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.trailing)
                }

                if isLoading {
                    ProgressView("Searching...")
                        .padding(.leading)
                } else if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(searchResults, id: \.url) { result in
                                Button(action: {
                                    selectedResult = result
                                }) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(result.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)

                                        Text(result.url)
                                            .font(.caption)
                                            .foregroundColor(.blue)

                                        if let content = result.content {
                                            Text(String(content.prefix(100)) + "…")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(12)
                                    .hoverEffect(.highlight)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if !query.isEmpty {
                    Text("No results found.")
                        .foregroundColor(.gray)
                        .padding(.leading)
                }

                Spacer()
            }
            .frame(maxWidth: 400)
            .background(Color(.systemGroupedBackground))

            Divider()

        
            VStack(alignment: .leading, spacing: 12) {
                if let result = selectedResult {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(result.title)
                                .font(.title.bold())
                                .foregroundColor(.primary)

                            Text(result.url)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .contextMenu {
                                    Button("Copy URL") {
                                        UIPasteboard.general.string = result.url
                                    }
                                }

                            if let content = result.content {
                                Text(content)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Select a result to see more.")
                        .italic()
                        .foregroundColor(.gray)
                        .padding()
                }
                Spacer()
            }
            .padding(.top, 32)
            .frame(maxWidth: .infinity)
        }
    }

    func performSearch() {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLoading = true
        searchResults = []
        selectedResult = nil

        TavilySearchService.shared.search(query: trimmed) { results in
            DispatchQueue.main.async {
                self.searchResults = results
                self.isLoading = false
            }
        }
    }
}
