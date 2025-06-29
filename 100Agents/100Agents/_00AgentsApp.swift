//
//  _00AgentsApp.swift
//  100Agents
//
//  Created by Brayton Lordianto on 6/26/25.
//

import SwiftUI
import Appwrite
import AppwriteModels

@main
struct _00AgentsApp: App {
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            if authService.isLoading {
                // Loading screen
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .padding()
                }
            } else if authService.isAuthenticated {
                // User is logged in - show main app
                ContentView()
            } else {
                // User is not logged in - show auth screen
                AuthView(authService: authService)
            }
        }
    }
}
