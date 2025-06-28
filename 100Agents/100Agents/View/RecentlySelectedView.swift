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
    
    var clearButton: some View {
        Button(action: {
            withAnimation(.bouncy) {
                viewModel.clearRecentCategories()
            }
        }) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray)
                .font(.title3)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Recently Viewed")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                clearButton
            }
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
