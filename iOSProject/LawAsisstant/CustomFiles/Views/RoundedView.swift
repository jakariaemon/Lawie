//
//  RoundedView.swift
//  LawAsisstant
//  Created by MD SAZID HASAN DIP on 12/5/21.
//

import UIKit

@IBDesignable
class RoundedView: UIView {
    
    @IBInspectable var isCircle: Bool = false {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .darkGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowOffsetWidth: CGFloat = 0.0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowOffsetHeight: CGFloat = 0.8 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.30 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3.0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var viewOpacity: CGFloat = 1.0 {
        didSet {
            layer.opacity = Float(viewOpacity)
        }
    }
    
    @IBInspectable var maskClip: Bool = false {
        didSet {
            layer.masksToBounds = maskClip
        }
    }
    
    // Commented out for testing. Uncomment if you need gradient functionality.
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    @IBInspectable var makeGradient: Bool = false {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var startColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = .white {
        didSet {
            updateGradient()
        }
    }
    
    @IBInspectable var maskBounds: Bool = false {
        didSet {
            layer.masksToBounds = maskBounds
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    private func updateView() {
        layer.cornerRadius = isCircle ? frame.height / 2 : cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight)
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
        
        if makeGradient {
            updateGradient()
        }
    }
    
    private func updateGradient() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        updateView()
    }
}
