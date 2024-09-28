//
//  AdapterResponse.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 15/9/24.
//

import Foundation

// Data model for Adapter
struct Adapter: Codable {
    let name: String
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case name, id
    }
}

// Data model for the entire response
struct AdapterResponse: Codable {
    let adapters: [Adapter]
    
    enum CodingKeys: String, CodingKey {
        case adapters
    }
}
