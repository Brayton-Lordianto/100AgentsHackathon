import Foundation
import Appwrite

class SimpleAppwrite {
    var client: Client
    var account: Account
    
    public init() {
        self.client = Client()
            .setEndpoint("https://nyc.cloud.appwrite.io/v1")
            .setProject("6861a06d002dd7a25324")
        
        self.account = Account(client)
    }
    
    public func onRegister(
        _ email: String,
        _ password: String
    ) async -> Bool {
        do {
            let _ = try await account.create(
                userId: ID.unique(), 
                email: email, 
                password: password
            )
            return true
        } catch {
            print("Register Error: \(error)")
            return false
        }
    }
    
    public func onLogin(
        _ email: String,
        _ password: String
    ) async -> Bool {
        do {
            let _ = try await account.createEmailPasswordSession(
                email: email, 
                password: password
            )
            return true
        } catch {
            print("Login Error: \(error)")
            return false
        }
    }
    
    public func onLogout() async throws {
        _ = try await account.deleteSession(sessionId: "current")
    }
    
    public func checkSession() async -> Bool {
        do {
            let _ = try await account.get()
            return true
        } catch {
            print("Session check failed: \(error)")
            return false
        }
    }
}