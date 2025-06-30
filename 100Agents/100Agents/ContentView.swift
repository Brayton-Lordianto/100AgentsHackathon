import SwiftUI

struct ContentView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        BrowseView(authService: authService)
    }
}

#Preview {
    ContentView(authService: AuthService())
}