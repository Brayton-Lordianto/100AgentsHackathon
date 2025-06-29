import SwiftUI
import Appwrite
import AppwriteModels
import AppwriteEnums

@MainActor
class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: Client
    private let account: Account
    
    init() {
        // Initialize Appwrite client
        client = Client()
            .setEndpoint("https://nyc.cloud.appwrite.io/v1")
            .setProject("6861a06d002dd7a25324")
            .setKey("standard_e879f6398519886bc16dbe1464d2801209843cdb51051be2dc2fd04dcaca6edaa48c79a7827a603d7a3ed93c241b6febe97b1ab2ebb187fb712c168338940d4bf5f90be3942f7c2b90185b5ec28dc99748f66754480d41a414cf34665b976c637ebc7761ec4ed2b7e56e3280b195e979f13f447db7eefaf36f6820a4be0ca19e")
        
        account = Account(client)
        
        // Check if user is already logged in
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isLoading = true
        
        Task {
            do {
                _ = try await account.get()
                isAuthenticated = true
            } catch {
                isAuthenticated = false
            }
            isLoading = false
        }
    }
    
    func loginWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await account.createOAuth2Token(provider: .google)
                isAuthenticated = true
            } catch {
                errorMessage = "Google login failed: \(error.localizedDescription)"
                isAuthenticated = false
            }
            isLoading = false
        }
    }
    
    func logout() {
        isLoading = true
        
        Task {
            do {
                try await account.deleteSession(sessionId: "current")
                isAuthenticated = false
            } catch {
                errorMessage = "Logout failed: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
