//
//  Url+Ext.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/27.
//

import Foundation

extension URL {
    func toData() -> Data? {
        do {
            let fileData = try Data(contentsOf: self)
            return fileData
            
        } catch {
            return nil
        }
    }
}
