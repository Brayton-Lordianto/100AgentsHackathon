
import SwiftUI

struct BrowseView: View {
    @StateObject private var viewModel = BrowseViewModel()
    
    let allCategories = [
        ("Computer Science", "desktopcomputer"),
        ("Art", "paintpalette"),
        ("Physics", "atom"),
        ("History", "scroll"),
        ("Biology", "leaf"),
        ("Mathematics", "function"),
        ("Chemistry", "testtube.2"),
        ("Literature", "book"),
        ("Music", "guitars"),
        ("Geography", "map")
    ]
    
    let initialCategoryCount = 5
    @State private var showAllCategories = false

    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Choose a topic to learn")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .padding(.horizontal)

                        WrapLayout(verticalSpacing: 15) {
                            let categoriesToShow = showAllCategories ? allCategories : Array(allCategories.prefix(initialCategoryCount))
                            
                            ForEach(categoriesToShow, id: \.0) { category in
                                CategoryButton(
                                    title: category.0,
                                    icon: category.1,
                                    isSelected: viewModel.selectedCategories.contains(category.0)
                                ) {
                                    withAnimation {
                                        viewModel.toggleCategory(category.0)
                                    }
                                }
                                .padding(4)
                            }
                            
                            // "More" / "Less" Button
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
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 80) // Add padding to the bottom to avoid overlap with the button
                }

                if !viewModel.selectedCategories.isEmpty {
                    NavigationLink(destination: NarrowSelectionView(categories: Array(viewModel.selectedCategories))) {
                        Text("Narrow Selection (\(viewModel.selectedCategories.count))")
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
            }
            .navigationTitle("Browse")
        }
    }
}


struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var buttonView: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "checkmark.circle.fill" : icon)
                    .foregroundColor(.black)
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.white)
            .clipShape(Capsule())
            .overlay(
                Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: isSelected ? Color.green.opacity(0.7) : Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .animation(.spring(), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    let startDate = Date()


    var body: some View {
        TimelineView(.animation) { timeline in
            if isSelected {
                buttonView
                    .visualEffect { content, proxy in
                        content
                            .layerEffect(
                                ShaderLibrary.premium_shimmer(
                                    .float(startDate.timeIntervalSinceNow),
                                    .float2(proxy.size)
                                ),
                                maxSampleOffset: .zero
                            )
                    }
            } else {
                buttonView
            }
        }
    }
}


#Preview {
    BrowseView()
}
