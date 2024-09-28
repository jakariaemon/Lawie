//
//  ChatResponse.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 5/10/23.
//

import Foundation

struct ChatResponse: Codable {
    var response: String? = ""
}

struct ConversationPart: Codable {
    var type: String? = ""
    var totalCount: Int? = 0
    var conversation: [ConversationItem] = []
    
    enum CodingKeys: String, CodingKey {
        case type
        case totalCount = "total_count"
        case conversation = "conversation_parts"
    }
    
}
