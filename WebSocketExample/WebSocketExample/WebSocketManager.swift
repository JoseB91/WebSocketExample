//
//  WebSocketManager.swift
//  WebSocketExample
//
//  Created by José Briones on 16/5/25.
//

import SwiftUI

class WebSocketManager: ObservableObject {
    private var webSocketTask: URLSessionWebSocketTask?
    private var pingTimer: Timer?
    private var reconnectTimer: Timer?
    @Published var connectionStatus: String = "Disconnected"
    @Published var messages: [String] = []
    @Published var currentPrice: String = "Loading..."
    @Published var symbol: String = "BTC"
    @Published var percentChange: Double = 0.0
    let apiKey = ""
    
    func connect() {
        guard webSocketTask == nil else { return }
        
        let url = URL(string: "wss://streamer.cryptocompare.com/v2?api_key=\(apiKey)")!
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        
        connectionStatus = "Connecting..."
        webSocketTask?.resume()
        
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.ping()
        }
        
        sendSubscription()
        
        receiveMessage()
        connectionStatus = "Connected"
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        pingTimer?.invalidate()
        reconnectTimer?.invalidate()
        connectionStatus = "Disconnected"
    }
    
    private func ping() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
    
    private func sendSubscription() {
        // Subscription message for BTC/USD price updates
        let subscriptionMessage = """
        {
            "action": "SubAdd",
            "subs": ["5~CCCAGG~BTC~USD"]
        }
        """
        
        let message = URLSessionWebSocketTask.Message.string(subscriptionMessage)
        webSocketTask?.send(message) { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    DispatchQueue.main.async {
                        self?.processMessage(text)
                        
                        self?.receiveMessage()
                    }
                case .data(let data):
                    if let string = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.processMessage(string)
                            self?.receiveMessage()
                        }
                    }
                @unknown default:
                    break
                }
            case .failure(let error):
                self?.handleError(error)
            }
        }
    }
    
    private func processMessage(_ text: String) {
        if let data = text.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            
            if let messageType = json["TYPE"] as? String, messageType == "5",
               let fromSymbol = json["FROMSYMBOL"] as? String,
               let price = json["PRICE"] as? Double {
                
                self.symbol = fromSymbol
                self.currentPrice = String(format: "$%.2f", price)
                
                if let open24Hour = json["OPEN24HOUR"] as? Double, open24Hour > 0 {
                    self.percentChange = ((price - open24Hour) / open24Hour) * 100
                }
                messages.append("\(symbol)/USD \(currentPrice) \(percentChange)")
            }
        }
        
        if messages.count > 10 {
            messages.removeFirst(messages.count - 10)
        }
    }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.connectionStatus = "Error: \(error.localizedDescription)"
            self.disconnect()
            
            self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
                self?.connect()
            }
        }
    }
}
