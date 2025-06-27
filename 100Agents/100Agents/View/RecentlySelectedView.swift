import SwiftUI

struct RecentlySelectedView: View {
    @StateObject var viewModel: BrowseViewModel
    let recentCategories: [MainCategory]
    let onSelectCategory: (MainCategory) -> Void

    func buttonView(_ category: MainCategory) -> some View {
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
    
    func categoryButton(_ category: MainCategory) -> some View {
        CategoryButton(
            title: category.rawValue,
            icon: category.icon,
            isSelected: viewModel.selectedCategories.contains(category)
        ) {
            withAnimation {
                viewModel.toggleCategory(category)
            }
        }
        .padding(4)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Recently Selected")
                .font(.headline)
                .padding(.horizontal)

            ScrollView(.horizontal,showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(recentCategories) { category in
                        categoryButton(category)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}
