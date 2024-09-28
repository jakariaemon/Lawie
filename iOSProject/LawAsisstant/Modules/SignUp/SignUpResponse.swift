//
//  SignUpResponse.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/02.
//

import Foundation

struct SignUpResponse: Codable {
    var id: Int?
    var email: String? = ""
    var isSubscribe: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email = "email"
        case isSubscribe = "is_subscribed"
    }
    
}
