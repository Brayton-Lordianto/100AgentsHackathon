//
//  MCPUtility.swift
//  100Agents
//
//  Created by Brayton Lordianto on 6/27/25.
//

import Foundation
import MCP

class MCPService: ObservableObject {
    private let client: Client
    @Published var isConnected = false
    
    init() {
        client = Client(name: "LearningApp", version: "1.0.0")
    }
    
    func connectToAppWrite() async {
        do {
            let transport = HTTPClientTransport(
                endpoint: URL(string: "https://your-appwrite-mcp.com")!,
                streaming: true
            )
            
            let result = try await client.connect(transport: transport)
            
            Task {
                self.isConnected = true
            }
            
            // Check capabilities
            if result.capabilities.tools != nil {
                // Can use tools
            }
            
        } catch {
            print("Failed to connect: \(error)")
        }
    }
    
//    func generateContent(topic: String) async -> String? {
//        do {
//            let (content, isError) = try await client.callTool(
//                name: "content-generator",
//                arguments: ["topic": topic]
//            )
//            
//            return content.first?.textValue
//        } catch {
//            print("Tool call failed: \(error)")
//            return nil
//        }
//    }
}
