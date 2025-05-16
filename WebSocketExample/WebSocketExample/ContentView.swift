//
//  ContentView.swift
//  WebSocketExample
//
//  Created by José Briones on 16/5/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var webSocketManager = WebSocketManager()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Status and controls
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
                
                // Current Bitcoin price
                VStack {
                    Text("\(webSocketManager.symbol)/USD")
                        .font(.headline)
                    
                    Text(webSocketManager.currentPrice)
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.green)
                    
                    if webSocketManager.percentChange != 0 {
                        Text("\(webSocketManager.percentChange >= 0 ? "+" : "-")\(String(format: "%.2f", webSocketManager.percentChange))%")
                            .foregroundColor(webSocketManager.percentChange >= 0 ? .green : .red)
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Recent messages
                VStack(alignment: .leading) {
                    Text("Recent Updates")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(webSocketManager.messages, id: \.self) { message in
                            Text(message)
                                .font(.system(.body, design: .monospaced))
                                .lineLimit(3)
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
