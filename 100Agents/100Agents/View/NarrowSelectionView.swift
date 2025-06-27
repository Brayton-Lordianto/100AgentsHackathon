
import SwiftUI

struct NarrowSelectionView: View {
    @StateObject private var viewModel = NarrowSelectionViewModel()
    let categories: [MainCategory]

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(categories, id: \.self) { category in
                    Section(header: Text(category.rawValue).font(.headline).padding(.leading, -10)) {
                        if let subTopics = TopicData.subTopics[category.subTopicKey] {
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
                TimelineView(.animation) { timeline in
                    NavigationLink(destination: ReelView(subTopics: Array(viewModel.selectedSubTopics))) {
                        Text("Refine")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black.opacity(0.8))
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .layerEffect(Shader(function: .init(library: .default, name: "premium_shimmer"), arguments: [.float(timeline.date.timeIntervalSinceReferenceDate)]), maxSampleOffset: .zero)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(), value: viewModel.selectedSubTopics.isEmpty)
                }
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
        NarrowSelectionView(categories: [.computerScience, .art])
    }
}
