import Foundation

struct TavilySearchResult: Codable {
    let title: String
    let url: String
    let content: String?
}

struct TavilyResponse: Codable {
    let results: [TavilySearchResult]
}

class TavilySearchService {
    static let shared = TavilySearchService()
    private init() {}

    private let endpoint = "https://api.tavily.com/search"
    private let apiKey = "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"

    func search(query: String, completion: @escaping ([TavilySearchResult]) -> Void) {
        guard let url = URL(string: endpoint) else {
            print("Invalid Tavily endpoint URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "api_key": apiKey,
            "query": query,
            "search_depth": "advanced",
            "include_answer": false,
            "include_raw_content": false
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print(" \(error)")
            completion([])
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                print(" Tavily request failed: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                print(" Tavily response:", String(data: data, encoding: .utf8) ?? "N/A")

                let response = try JSONDecoder().decode(TavilyResponse.self, from: data)
                completion(response.results)
            } catch {
                print(" \(error)")
                completion([])
            }
        }.resume()
    }
}
