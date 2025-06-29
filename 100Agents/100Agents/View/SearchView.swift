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
            
            VStack(alignment: .leading, spacing: 16) {
                Text("Search")
                    .font(.largeTitle.bold())
                    .padding(.top, 30)
                    .padding(.horizontal)

                HStack {
                    TextField("Search topics...", text: $query, onCommit: performSearch)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)

                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .disabled(query.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView("Searching...")
                        .padding()
                } else if !searchResults.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(searchResults, id: \.url) { result in
                                Button(action: {
                                    selectedResult = result
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.title)
                                            .font(.headline)
                                            .foregroundColor(.white)

                                        Text(result.url)
                                            .font(.caption)
                                            .foregroundColor(.blue)

                                        if let content = result.content {
                                            Text(content.prefix(100) + "…")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(result.url == selectedResult?.url ? Color.blue.opacity(0.2) : Color(.systemGray5))
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                } else if !query.isEmpty {
                    Text("No results found.")
                        .padding()
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .frame(maxWidth: 400)
            .background(Color(.systemGray6))

            Divider()

            
            VStack(alignment: .leading) {
                if let result = selectedResult {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(result.title)
                                .font(.title.bold())
                            Text(result.url)
                                .font(.subheadline)
                                .foregroundColor(.blue)

                            Divider()

                            if let content = result.content {
                                Text(content)
                                    .font(.body)
                                    .lineSpacing(5)
                            }
                        }
                        .padding()
                    }
                } else {
                    Text("Select a result to see more.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
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
}
