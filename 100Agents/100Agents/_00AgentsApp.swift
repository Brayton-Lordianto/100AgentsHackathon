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
            ContentView(authService: authService)
        }
    }
}
