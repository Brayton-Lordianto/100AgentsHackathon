import SwiftUI
import UIKit
import Appwrite
import AppwriteModels
import AppwriteEnums

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var userName: String = ""
    @Published var errorMessage: String? {
        didSet {
            print(errorMessage ?? "No error message")
        }
    }
    
    private let client: Client
    private let account: Account
    private let databases: Databases
    
    init() {
        // Initialize Appwrite client
        client = Client()
            .setEndpoint("https://nyc.cloud.appwrite.io/v1")
            .setProject("6861a06d002dd7a25324")
        
        account = Account(client)
        databases = Databases(client)
        
        // Check if user is already logged in
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isLoading = true
        
        Task {
            do {
                _ = try await account.get()
                await fetchUserData() // Fetch user data after confirming authentication
                await MainActor.run {
                    isAuthenticated = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isAuthenticated = false
                    isLoading = false
                }
            }
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let redirect = try await account.createOAuth2Token(
                    provider: .google,
                    scopes: ["email", "profile", "openid"]
                )
                
//                handleOAuthCallback(url: URL(string: redirect ?? "")!)
                if let url = URL(string: redirect ?? "") {
//                        UIApplication.shared.open(url)
                    DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
                        self.isLoading.toggle()
                        self.isAuthenticated = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Google login failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    func handleOAuthCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }
        
        print(components)
        print(queryItems)
        
        if url.absoluteString.contains("/oauth/success") {
            // Extract userId and secret from query parameters
            let userId = queryItems.first(where: { $0.name == "userId" })?.value
            let secret = queryItems.first(where: { $0.name == "secret" })?.value
            
            if let userId = userId, let secret = secret {
                createSession(userId: userId, secret: secret)
            }
        } else if url.absoluteString.contains("/oauth/failure") {
            errorMessage = "OAuth authentication failed"
            isLoading = false
        }
    }
    
    private func createSession(userId: String, secret: String) {
        Task {
            do {
                _ = try await account.createSession(userId: userId, secret: secret)
                await MainActor.run {
                    isAuthenticated = true
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Session creation failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    func logout() {
        isLoading = true
        
        Task {
            do {
                try await account.deleteSession(sessionId: "current")
                await MainActor.run {
                    isAuthenticated = false
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Logout failed: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    // MARK: - Database Operations
    func fetchUserData() async {
        do {
            let document = try await databases.getDocument(
                databaseId: "6861ca4b003672dbf650",
                collectionId: "6861ca9b003590a11abb",
                documentId: "6861cb31001a0fa7f23c"
            )
            
            await MainActor.run {
                // Extract the name from the document data
                if let name = document.data["name"] as? String {
                    userName = name
                } else {
                    userName = "User" // Fallback
                }
            }
        } catch {
            await MainActor.run {
                print("Failed to fetch user data: \(error.localizedDescription)")
                userName = "User" // Fallback
            }
        }
    }
}
