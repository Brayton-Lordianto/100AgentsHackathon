import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }

            HistoryView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("History")
                }
        }
    }
}

#Preview {
    ContentView()
}