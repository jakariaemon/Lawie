//
//  ChatViewModel.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2/10/23.
//

import Foundation

class ChatViewModel {
    var messages = [ConversationItem]()
    var messageListResponse: ChatResponse? {
        didSet {
            self.messages[0].response = messageListResponse?.response ?? "-"
            self.bindResponseToController()
        }
    }
    
    var bindMessagesToController: (() -> ()) = {}
    var bindResponseToController: (() -> ()) = {}
    
    func sendMessage(message: ConversationItem) {
        ApiManager.shared.sendChatMessage(message: message) { response in
            self.messageListResponse = response
        }
    }
}
