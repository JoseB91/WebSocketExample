//
//  Models.swift
//  WebSocketExample
//
//  Created by José Briones on 16/5/25.
//

struct CoinCapResponse: Codable {
    let data: CoinData
}

struct CoinData: Codable {
    let priceUsd: String
    let id: String
    let symbol: String
}
