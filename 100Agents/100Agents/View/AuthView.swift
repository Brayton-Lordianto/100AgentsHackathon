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
                
            }
            
            // Google Sign In Button
            Button(action: {
                authService.loginWithGoogle()
            }) {
                HStack {
                    Text("Sign in with Google")
                        .font(.headline)
                    Image("GoogleIcon")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .font(.title2)
                }
                .padding(40)
                .border(.blue, width: 5)
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
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
