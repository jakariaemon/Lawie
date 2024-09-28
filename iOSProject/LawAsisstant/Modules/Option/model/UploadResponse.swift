//
//  UploadResponse.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 15/9/24.
//

import Foundation

struct UploadResponse: Codable {
    var message: String?
    var task_id: Int?
    
    enum CodingKeys: String, CodingKey {
        case message, task_id
    }
}

struct ProgressResponse: Codable {
    var status: String?
    var updated_at: String?
    
    enum CodingKeys: String, CodingKey {
        case status, updated_at
    }
}
