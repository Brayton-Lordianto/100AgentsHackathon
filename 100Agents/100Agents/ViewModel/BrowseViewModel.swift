
import SwiftUI

class BrowseViewModel: ObservableObject {
    @Published var selectedCategories: Set<String> = []

    func toggleCategory(_ category: String) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}
