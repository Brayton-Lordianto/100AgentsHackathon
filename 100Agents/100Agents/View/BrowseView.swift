
import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    
    let allCategories = MainCategory.allCases
    
    let initialCategoryCount = 5
    @State private var showAllCategories = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Group {
                            if !viewModel.recentCategories.isEmpty {
                                RecentlySelectedView(viewModel: viewModel, recentCategories: viewModel.recentCategories) { category in
                                    viewModel.toggleCategory(category)
                                }
                            } else {
                                Color.clear
                            }
                        }
                        
                        Text("Trending Topics")
                        //                            .font(.system(size: 20, weight: .semibold, design: .default))
                            .font(.headline)
                            .padding(.horizontal)
                        WrapLayout(verticalSpacing: 15) {
                            let categoriesToShow = showAllCategories ? allCategories : Array(allCategories.prefix(initialCategoryCount))
                            
                            ForEach(categoriesToShow, id: \.self) { category in
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
                            
                            moreLessButton
                        }
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 80) // Add padding to the bottom to avoid overlap with the button
                    .padding(.horizontal, 5)
                }

                if viewModel.selectedCategories.count > 0 {
                    submitButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    VStack(alignment: .leading) {
                        Text("Browse")
                            .font(.system(size: 35, weight: .semibold, design: .default))
                        Text("Choose a topic to learn -- or multiple!")
                    }
                }
            }
        }
    }
    
    var submitButton: some View {
        NavigationLink(destination: NarrowSelectionView(category: viewModel.selectedCategories)) {
            Text("Continue (\(viewModel.selectedCategories.count))")
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(15)
                .shadow(radius: 10)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(), value: viewModel.selectedCategories.isEmpty)
    }
    
    var moreLessButton: some View {
        Button(action: {
            withAnimation(.spring()) {
                showAllCategories.toggle()
            }
        }) {
            HStack {
                Image(systemName: showAllCategories ? "arrow.up.right.and.arrow.down.left" : "ellipsis")
                Text(showAllCategories ? "Less" : "More")
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(4)
    }
}

#Preview {
    BrowseView()
}
