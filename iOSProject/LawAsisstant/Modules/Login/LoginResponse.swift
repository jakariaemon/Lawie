//
//  LoginResponse.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/02.
//

import Foundation

struct LoginResponse: Codable {
    var token: String? = ""
    var tokenType: String? = ""
    var user:User? = nil
    
    enum CodingKeys: String, CodingKey {
        case token = "access_token"
        case tokenType = "token_type"
        case user = "user"
        
    }
}

struct User: Codable {
    var id: Int?
    var name: String?
    var email: String?
    var subscriptionType: String?
    var isSubscribed:Bool?
    var deviceId:String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case isSubscribed = "is_subscribed"
        case subscriptionType = "subscription_type"
        case email = "email"
        case deviceId = "device_id"
        
    }
    
}

struct ForgotPassword: Codable {
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
