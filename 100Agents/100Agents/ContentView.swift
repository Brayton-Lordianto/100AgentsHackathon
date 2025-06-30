import SwiftUI

struct ContentView: View {
    @ObservedObject var authService: AuthService
    @State private var selectedTab = 0
    @State private var urlForBrowse = ""
    
    var body: some View {
        if authService.isAuthenticated {
            // User is logged in - show main app
            mainView
        } else {
            // User is not logged in - show auth screen
            AuthView(authService: authService)
        }

    }
    
    var mainView: some View {
        TabView(selection: $selectedTab) {
            BrowseView(authService: authService, urlFromSearch: $urlForBrowse)
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }
                .tag(0)
            
            SearchView(selectedTab: $selectedTab, urlForBrowse: $urlForBrowse)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView(authService: AuthService())
}
