
import SwiftUI

class BrowseViewModel: ObservableObject {
    @Published var selectedCategories: Set<MainCategory> = []
    @Published var recentCategories: [MainCategory] = []

    func toggleCategory(_ category: MainCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
            addRecentCategory(category)
        }
    }

    private func addRecentCategory(_ category: MainCategory) {
        recentCategories.removeAll { $0 == category }
        recentCategories.insert(category, at: 0)
        if recentCategories.count > 5 {
            recentCategories.removeLast()
        }
    }

    func clearRecentCategories() {
        recentCategories.removeAll()
    }
}
