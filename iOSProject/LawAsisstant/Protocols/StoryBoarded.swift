//
//  StoryBoarded.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/08/26.
//
import UIKit

// MARK: - Storyboard Initiate Protocol

protocol Storyboarded {
    static var storyboardIdentifier: String { get }
    static func instantiate<T>() -> T where T: Storyboarded
}

extension UIViewController: Storyboarded {}
