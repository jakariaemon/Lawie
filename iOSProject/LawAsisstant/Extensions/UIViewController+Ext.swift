//
//  UIViewController+Ext.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/01.
//

import UIKit

extension UIViewController {
    
    @objc func hideKeyboardWhenTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

//MARK: - Animated TextField
extension UIViewController {
    
    fileprivate func animationFormatForTextFields() -> AnimatedFieldFormat {
        var format = AnimatedFieldFormat()
        format.titleFont = UIFont(name: "AvenirNext-Bold", size: 14)!
        format.textFont = UIFont(name: "AvenirNext-Regular", size: 16)!
        format.lineColor = UIColor.white
        format.textColor = .white
        format.titleColor = .white
        format.highlightColor = .white
        format.alertColor = .red
        format.alertFieldActive = false
        format.titleAlwaysVisible = true
        
        format.alertFont = UIFont(name: "AvenirNext-Regular", size: 14)!
        
        return format
    }
    
    func setupAnimateTexField(textField: AnimatedField, placeHolder: String, textFieldType: AnimatedFieldType, dataSource: AnimatedFieldDataSource, delegate: AnimatedFieldDelegate, textFieldTag: Int ) {
        textField.format = animationFormatForTextFields()
        textField.placeholder = placeHolder
        textField.isPlaceholderVisible = true
        
        textField.dataSource = dataSource
        textField.delegate = delegate
        textField.type = textFieldType
        textField.tag = textFieldTag
        switch textFieldType {
        case .email:
            textField.lowercased = true
        case .password(_, _):
            textField.isSecure = true
            textField.showVisibleButton = true
        default:
            break
       
        }
    }
}

