//
//  FontHelper.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import Foundation
import FontBlaster

struct AppFontName {
    static let regular = "Lexend Regular"
    static let bold = "Lexend Bold"
    static let light = "Lexend Light"
    static let medium = "Lexend Medium"
    static let semiBold = "Lexend SemiBold"
}

extension UIFontDescriptor.AttributeName {
    static let nsctFontUIUsage = UIFontDescriptor.AttributeName(rawValue: "NSCTFontUIUsageAttribute")
}

extension UIFont {

 @objc class func mySystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: AppFontName.regular, size: size)!
 }

 @objc class func myBoldSystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: AppFontName.bold, size: size)!
 }

 @objc class func myItalicSystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: AppFontName.light, size: size)!
 }

 @objc class func myMediumSystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: AppFontName.medium, size: size)!
 }

 @objc class func mySemiBoldSystemFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: AppFontName.semiBold, size: size)!
 }

 @objc convenience init(myCoder aDecoder: NSCoder) {
  guard
    let fontDescriptor = aDecoder.decodeObject(forKey: "UIFontDescriptor") as? UIFontDescriptor,
    let fontAttribute = fontDescriptor.fontAttributes[.nsctFontUIUsage] as? String else {
    self.init(myCoder: aDecoder)
    return
  }
  var fontName = ""
  switch fontAttribute {
  case "CTFontRegularUsage":
    fontName = AppFontName.regular
  case "CTFontEmphasizedUsage", "CTFontBoldUsage", "CTFontDemiUsage":
    fontName = AppFontName.bold
  case "CTFontObliqueUsage", "CTFontLightUsage":
    fontName = AppFontName.light
  case "CTFontMediumUsage":
    fontName = AppFontName.medium
  default:
    fontName = AppFontName.regular
  }
  self.init(name: fontName, size: fontDescriptor.pointSize)!
 }

 class func overrideInitialize() {
  guard self == UIFont.self else { return }

  if let systemFontMethod = class_getClassMethod(self, #selector(systemFont(ofSize:))),
    let mySystemFontMethod = class_getClassMethod(self, #selector(mySystemFont(ofSize:))) {
    method_exchangeImplementations(systemFontMethod, mySystemFontMethod)
  }

  if let boldSystemFontMethod = class_getClassMethod(self, #selector(boldSystemFont(ofSize:))),
    let myBoldSystemFontMethod = class_getClassMethod(self, #selector(myBoldSystemFont(ofSize:))) {
    method_exchangeImplementations(boldSystemFontMethod, myBoldSystemFontMethod)
  }

  if let italicSystemFontMethod = class_getClassMethod(self, #selector(italicSystemFont(ofSize:))),
    let myItalicSystemFontMethod = class_getClassMethod(self, #selector(myItalicSystemFont(ofSize:))) {
    method_exchangeImplementations(italicSystemFontMethod, myItalicSystemFontMethod)
  }

  if let initCoderMethod = class_getInstanceMethod(self, #selector(UIFontDescriptor.init(coder:))), // Trick to get over the lack of UIFont.init(coder:))
    let myInitCoderMethod = class_getInstanceMethod(self, #selector(UIFont.init(myCoder:))) {
    method_exchangeImplementations(initCoderMethod, myInitCoderMethod)
  }
 }
}
