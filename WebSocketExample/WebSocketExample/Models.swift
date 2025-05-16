//
//  Models.swift
//  WebSocketExample
//
//  Created by José Briones on 16/5/25.
//

struct CryptoUpdate: Codable {
    let type: String
    let fromSymbol: String
    let price: Double?
    let open24Hour: Double?
    let volume24Hour: Double?
    let volume24HourTo: Double?
    
    enum CodingKeys: String, CodingKey {
        case type = "TYPE"
        case fromSymbol = "FROMSYMBOL"
        case price = "PRICE"
        case open24Hour = "OPEN24HOUR"
        case volume24Hour = "VOLUME24HOUR"
        case volume24HourTo = "VOLUME24HOURTO"
    }
}
