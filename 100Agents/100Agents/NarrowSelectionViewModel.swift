
import SwiftUI

class NarrowSelectionViewModel: ObservableObject {
    @Published var selectedSubTopics: Set<String> = []

    func toggleSubTopic(_ subTopic: String) {
        if selectedSubTopics.contains(subTopic) {
            selectedSubTopics.remove(subTopic)
        } else {
            selectedSubTopics.insert(subTopic)
        }
    }
}
