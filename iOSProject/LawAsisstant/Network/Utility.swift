//
//  Utility.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 2024/09/09.
//

import SystemConfiguration
import PKHUD
import UIKit

final class Utility {
    static let shared = Utility()
    private init(){ }
    
    private var labelTextFieldPairs: [UILabel: UITextField] = [:]
    private var dateFormatter = DateFormatter()
    
    func getDeviceId() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func startLoadingActivity() {
        HUD.show(.progress)
    }
    
    func hideLoadingActivity() {
        HUD.hide()
    }
    
    func alert(message: String, isLong: Bool = false) {
        HUD.flash(.label(message), delay: isLong ? 4.0 : 2.0)
    }
    
    func alert(message: String, isLong: Bool, completion: @escaping () -> Void) {
        HUD.flash(.label(message), delay: isLong ? 4.0 : 2.0) { _ in
            completion()
        }
    }
    
    func alert(view: UILabel){
        HUD.flash(.customView(view: view))
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func textWithColor(noneColoredText:String , coloredText: String , color:UIColor, isUnderlined: Bool, linkURL: String = "") -> NSMutableAttributedString {
        let fullString = NSMutableAttributedString(string: noneColoredText)
        
        // Define attributes for the colored text
        let coloredAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .underlineStyle: {isUnderlined ?  NSUnderlineStyle.single.rawValue : NSUnderlineStyle().rawValue}(),
            //.link: URL(string: linkURL)!// Add underline
        ]
        
        
        let coloredText = NSAttributedString(string: coloredText, attributes: coloredAttributes)
        
        // Append the colored text to the full string
        fullString.append(coloredText)
        return fullString
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        let uppercaseLetterRegex = ".*[A-Z]+.*"
        let lowercaseLetterRegex = ".*[a-z]+.*"
        let digitRegex = ".*\\d+.*"
        let specialCharacterRegex = ".*[^A-Za-z0-9]+.*"
        let newLineOrDotRegex = ".*[.\n]+.*"
        
        let hasUppercase = NSPredicate(format: "SELF MATCHES %@", uppercaseLetterRegex)
        let hasLowercase = NSPredicate(format: "SELF MATCHES %@", lowercaseLetterRegex)
        let hasDigit = NSPredicate(format: "SELF MATCHES %@", digitRegex)
        let hasSpecialCharacter = NSPredicate(format: "SELF MATCHES %@", specialCharacterRegex)
        let hasNewLineOrDot = NSPredicate(format: "SELF MATCHES %@", newLineOrDotRegex)
        
        let containsUppercase = hasUppercase.evaluate(with: password)
        let containsLowercase = hasLowercase.evaluate(with: password)
        let containsDigit = hasDigit.evaluate(with: password)
        let containsSpecialCharacter = hasSpecialCharacter.evaluate(with: password)
        let containsNewLineOrDot = hasNewLineOrDot.evaluate(with: password)
        
        return containsUppercase && containsLowercase && containsDigit && containsSpecialCharacter && !containsNewLineOrDot
    }
    
    func getTapGesture(for action: Selector ) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: self, action: action)
    }
    
    func setupLabelTapGestureToOpenLink(for label: UILabel) {
        let tapGesture = getTapGesture(for: #selector(labelTappedForOpenLink(sender:)) )
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGesture)
    }
    
    
    
    @objc private func labelTappedForOpenLink(sender: UITapGestureRecognizer) {
        // Handle the tap gesture here
        guard let label = sender.view as? UILabel else {
            return
        }
        
        let layoutManager = NSLayoutManager()
        
        // Create a text container with the label's bounds
        let textContainer = NSTextContainer(size: CGSize.zero)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        textContainer.lineBreakMode = label.lineBreakMode
        
        // Add the text container to the layout manager
        layoutManager.addTextContainer(textContainer)
        
        // Create a text storage with the attributed text
        let textStorage = NSTextStorage(attributedString: label.attributedText ?? NSAttributedString())
        
        // Set the text storage to the layout manager
        textStorage.addLayoutManager(layoutManager)
        
        // Convert the tap location to the text container's coordinates
        let locationOfTouchInLabel = sender.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let alignmentOffset = CGPoint(x: (label.bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                      y: (label.bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - alignmentOffset.x,
                                                     y: locationOfTouchInLabel.y - alignmentOffset.y)
        
        // Determine which glyph is tapped
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // Check if the tapped character has a link attribute
        if let url = label.attributedText?.attribute(.link, at: indexOfCharacter, effectiveRange: nil) as? URL {
            print("Tapped link: \(url.absoluteString)")
            
            // You can open the link in Safari or perform any other action
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func setupTapGesturesToLabelSpecificTextField(labelTextFieldPairs: [UILabel: UITextField]){
        self.labelTextFieldPairs = labelTextFieldPairs
        
        for (label, _) in labelTextFieldPairs {
            let tapGesture = getTapGesture(for: #selector(pairedlabelTapped(sender: )))
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(tapGesture)
        }
        
    }
    
    @objc private func pairedlabelTapped(sender: UITapGestureRecognizer ) {
        if let tappedLabel = sender.view as? UILabel {
            // Find the corresponding text field for the tapped label
            if let textField = self.labelTextFieldPairs[tappedLabel]{
                textField.isEnabled = true
                textField.becomeFirstResponder()
            }
        }
    }
    
    func dateFormatter(_ date: Date, format: String) -> String {
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    func getDateFrom(dateString: String) -> String {
        // Create a DateFormatter instance with the desired output format
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"

        // Parse the input time string into a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Convert Date object to string with the desired format
            let formattedTime = dateFormatter.string(from: date)
            
            // Print the formatted time
            print("Formatted Time:", formattedTime)
            return formattedTime
        } else {
            print("Failed to convert the time string into a Date object")
        }
        return "Date Failed"
    }
    

    private func gradientColor(from startColor: UIColor, to endColor: UIColor, withFrame frame: CGRect, horizontal: Bool = false) -> UIColor {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return UIColor(patternImage: image!)
    }
    
}


extension UIViewController {
    
    func hideKeyboardIfVisible() {
        if let keyWindow = UIApplication.shared.keyWindow {
            keyWindow.endEditing(true)
        }
    }
    
}
