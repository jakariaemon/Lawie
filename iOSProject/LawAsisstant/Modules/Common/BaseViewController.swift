//
//  BaseViewController.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import UIKit

class BaseViewController: UIViewController {
    
    let router = Router()
    let sharedUtility = Utility.shared
    let sharedUserDefaults = UserDefaultsUtility.shared

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension BaseViewController {
    func showCustomAlert(title: String, message: String, action: (() -> Void)? = nil ) {
           // Create an alert controller
           let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

           // Create attributed strings for the title and message
           let titleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
           let messageAttributes = [NSAttributedString.Key.foregroundColor: UIColor.lightGray]

           let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
           let attributedMessage = NSAttributedString(string: message, attributes: messageAttributes)

           // Set the attributed strings to the alert controller
           alertController.setValue(attributedTitle, forKey: "attributedTitle")
           alertController.setValue(attributedMessage, forKey: "attributedMessage")

           // Customize the background color of the alert controller
        let backgroundColor = UIColor.primaryBackground
           let backView = alertController.view.subviews.first?.subviews.first?.subviews.first
           backView?.backgroundColor = backgroundColor

           // Add actions to the alert controller
        let okAction = UIAlertAction(title: "OK", style: .default ) {_ in
            action?()
        }
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

           // Add actions to the alert
           alertController.addAction(okAction)
           alertController.addAction(cancelAction)

           // Present the alert controller
           self.present(alertController, animated: true, completion: nil)
       }
}
