import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BrowseView()
                .tabItem {
                    Image(systemName: "square.grid.2x2")
                    Text("Browse")
                }
                .background(Color.gray.opacity(0.2))

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
