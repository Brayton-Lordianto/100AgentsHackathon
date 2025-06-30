import Foundation

class SimpleViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
}