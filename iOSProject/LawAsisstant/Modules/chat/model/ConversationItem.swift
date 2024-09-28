//
//  ConversationItem.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 25/10/23.
//

import UIKit

struct ConversationItem: Codable {
    var userId: String? = ""
    var conversationId: String? = ""
    var requestId: String? = ""
    var deviceId: String? = ""
    var subscription: Bool? = false
    var message: String? = ""
    var adapterId: String? = ""
    var response: String? = ""
    var timestamp: String? = ""
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case conversationId = "conversation_id"
        case requestId = "request_id"
        case deviceId = "device_id"
        case adapterId = "adapter_id"
        case subscription, message, response, timestamp
    }
    
    func customUpdatedDate() -> String {
        if let dateTime = timestamp {
            return dateTime
        }
        return ""
    }
    
}
