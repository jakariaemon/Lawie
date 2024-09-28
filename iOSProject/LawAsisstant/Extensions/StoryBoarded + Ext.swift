//
//  StoryBoarded + Ext.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/08/26.
//

import UIKit

// MARK: - StoryBoard Extension
extension Storyboarded where Self: UIViewController {
    
    static var storyboardIdentifier: String {
        "\(Self.self)"
    }
    
    static var storyboard: UIStoryboard {
        UIStoryboard(name: storyboardIdentifier, bundle: nil)
    }
    
    static func instantiate<T>() -> T where T: Storyboarded {
        storyboard.instantiateViewController(withIdentifier: T.storyboardIdentifier) as! T
    }
}
