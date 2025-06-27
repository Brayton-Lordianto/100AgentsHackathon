
import SwiftUI

struct NarrowSelectionView: View {
    @StateObject private var viewModel = NarrowSelectionViewModel()
    let categories: [String]

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(categories, id: \.self) { category in
                    Section(header: Text(category).font(.headline).padding(.leading, -10)) {
                        if let subTopics = TopicData.subTopics[category] {
                            ForEach(subTopics, id: \.self) { subTopic in
                                SubTopicRow(
                                    title: subTopic,
                                    isSelected: viewModel.selectedSubTopics.contains(subTopic)
                                ) {
                                    viewModel.toggleSubTopic(subTopic)
                                }
                            }
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20))
            }
            .listStyle(InsetGroupedListStyle())

            if !viewModel.selectedSubTopics.isEmpty {
                NavigationLink(destination: ReelView(subTopics: Array(viewModel.selectedSubTopics))) {
                    Text("Generate Reel (\(viewModel.selectedSubTopics.count))")
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
                .animation(.spring(), value: viewModel.selectedSubTopics.isEmpty)
            }
        }
        .navigationTitle("Refine Topics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SubTopicRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationView {
        NarrowSelectionView(categories: ["Computer Science", "Art"])
    }
}
