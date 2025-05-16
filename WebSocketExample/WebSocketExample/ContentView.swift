//
//  ContentView.swift
//  WebSocketExample
//
//  Created by José Briones on 16/5/25.
//

import SwiftUI

// MARK: - ContentView
struct ContentView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // HStack for Status
                HStack {
                    Text("Status: \(webSocketManager.connectionStatus)")
                        .foregroundColor(statusColor)
                    
                    Spacer()
                    
                    if webSocketManager.connectionStatus == "Connected" {
                        Button("Disconnect") {
                            webSocketManager.disconnect()
                        }
                        .foregroundColor(.red)
                    } else {
                        Button("Connect") {
                            webSocketManager.connect()
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // VStack for Bitcoin price
                VStack {
                    Text("Bitcoin")
                        .font(.headline)
                    
                    Text(webSocketManager.currentPrice)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.green)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // VStack for Recent messages
                VStack(alignment: .leading) {
                    Text("Recent Updates")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(webSocketManager.messages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("CryptoTracker")
            .onAppear {
                webSocketManager.connect()
            }
            .onDisappear {
                webSocketManager.disconnect()
            }
        }
    }
    
    private var statusColor: Color {
        switch webSocketManager.connectionStatus {
        case "Connected":
            return .green
        case "Connecting...":
            return .orange
        default:
            return .red
        }
    }
}
