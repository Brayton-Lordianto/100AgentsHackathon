import SwiftUI

struct RecentlySelectedView: View {
    let recentCategories: [MainCategory]
    let onSelectCategory: (MainCategory) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text("Recently Selected")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recentCategories) { category in
                        Button(action: { onSelectCategory(category) }) {
                            VStack {
                                Image(systemName: category.icon)
                                    .font(.largeTitle)
                                Text(category.rawValue)
                                    .fontWeight(.semibold)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
