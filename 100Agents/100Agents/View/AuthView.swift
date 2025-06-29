import SwiftUI

struct AuthView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        VStack(spacing: 40) {
            // App Logo/Title
            VStack(spacing: 20) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("100 Agents")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Sign in to continue")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Google Sign In Button
            Button(action: {
                authService.loginWithGoogle()
            }) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                    
                    Text("Continue with Google")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(authService.isLoading)
            
            // Loading indicator
            if authService.isLoading {
                ProgressView("Signing in...")
                    .padding()
            }
            
            // Error message
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}


#Preview {
    AuthView(authService: .init())
}
