//
//  CommonBackgroundView.swift
//  LawAsisstant
//
//  Created by Outcast Traveler on 6/9/24.
//

import UIKit

class CommonBackgroundView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(named: "ColorSecondary")
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor(named: "ColorBorder")?.cgColor
    }
    
}
