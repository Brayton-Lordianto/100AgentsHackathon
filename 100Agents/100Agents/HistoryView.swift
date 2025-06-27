
import SwiftUI

struct HistoryView: View {
    var body: some View {
        VStack {
            Image(systemName: "books.vertical")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            Text("Browse to get started")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    HistoryView()
}
