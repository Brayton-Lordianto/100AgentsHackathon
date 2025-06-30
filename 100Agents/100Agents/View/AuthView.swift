import SwiftUI

struct AuthView: View {
    @ObservedObject var authService: AuthService
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Clean background
//                Color(.systemGroupedBackground)
//                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
//                    Spacer()
                    
                    // App Logo/Title Section
                    VStack(spacing: 24) {
                        Image("logo")
                            .resizable()
                            .frame(width: 650 * 0.8, height: 450 * 0.8)
                    }
                    
                    Spacer()
                    
                    // Sign In Section
                    VStack(spacing: 20) {
                        // Google Sign In Button with Notion-style design
                        Button(action: {
                            authService.loginWithGoogle()
                        }) {
                            HStack(spacing: 12) {
                                Image("GoogleIcon")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                                Text("Continue with Google")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                            )
                            // 3D embossed effect matching PDF button
                            .shadow(color: Color.white.opacity(0.8), radius: 1, x: 0, y: -1)
                            .shadow(color: Color.black.opacity(0.8), radius: 2, x: 0, y: 2)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                        }
                        .disabled(authService.isLoading)
                        .scaleEffect(authService.isLoading ? 0.98 : 1.0)
                        .animation(.easeInOut(duration: 0.1), value: authService.isLoading)
                        
                        // Loading indicator
                        if authService.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Signing in...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 60)
                    
                    // Error message
                    if let errorMessage = authService.errorMessage {
                        VStack(spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 14))
                                
                                Text(errorMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.orange.opacity(0.08))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                            )
                            
//                            Spacer()
                            
//                            Spacer()
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 32)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .offset(x: -70)
            }
        }
    }
}


#Preview {
    AuthView(authService: .init())
}
