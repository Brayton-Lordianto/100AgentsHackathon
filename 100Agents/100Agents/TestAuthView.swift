import SwiftUI

struct TestAuthView: View {
    @ObservedObject var viewModel = SimpleViewModel()
    let appwrite = SimpleAppwrite()
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoginSuccessful = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Test Authentication")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Register") {
                    Task {
                        if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            alertMessage = "Please enter both email and password"
                            showAlert = true
                        } else {
                            let success = await appwrite.onRegister(viewModel.email, viewModel.password)
                            if success {
                                alertMessage = "Registration successful! You can now login."
                                showAlert = true
                            } else {
                                alertMessage = "Registration failed"
                                showAlert = true
                            }
                        }
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Login") {
                    Task {
                        if viewModel.email.isEmpty || viewModel.password.isEmpty {
                            alertMessage = "Please enter both email and password"
                            showAlert = true
                        } else {
                            let success = await appwrite.onLogin(viewModel.email, viewModel.password)
                            if success {
                                isLoginSuccessful = true
                            } else {
                                alertMessage = "Login failed"
                                showAlert = true
                            }
                        }
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Check Session") {
                    Task {
                        let hasSession = await appwrite.checkSession()
                        alertMessage = hasSession ? "You are logged in!" : "No active session"
                        showAlert = true
                    }
                }
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(8)
                
                NavigationLink(
                    destination: LoggedInView(),
                    isActive: $isLoginSuccessful,
                    label: { EmptyView() }
                )
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Authentication"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct LoggedInView: View {
    let appwrite = SimpleAppwrite()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Login Successful!")
                .font(.largeTitle)
                .padding()
            
            Text("You are now authenticated")
                .padding()
            
            Button("Logout") {
                Task {
                    do {
                        try await appwrite.onLogout()
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        print("Failed to logout: \(error.localizedDescription)")
                    }
                }
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TestAuthView()
}