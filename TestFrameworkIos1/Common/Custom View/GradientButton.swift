//
//  GradientButton.swift
//  Yippi
//
//  Created by Jerry Ng on 26/12/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

public class GradientButton: UIButton {
    let gradientLayer = CAGradientLayer()
    
    var leftGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: leftGradientColor, bottomGradientColor: rightGradientColor, cornerRadius:cornerRadius)
        }
    }
    
    var rightGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: leftGradientColor, bottomGradientColor: rightGradientColor, cornerRadius:cornerRadius)
        }
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            setGradient(topGradientColor: leftGradientColor, bottomGradientColor: rightGradientColor, cornerRadius:cornerRadius)
        }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0.0, y: 0.5) {
        didSet {
            setGradient(topGradientColor: leftGradientColor, bottomGradientColor: rightGradientColor, cornerRadius:cornerRadius)
        }
    }
    var endPoint: CGPoint = CGPoint(x: 1.0, y: 0.5) {
        didSet {
            setGradient(topGradientColor: leftGradientColor, bottomGradientColor: rightGradientColor, cornerRadius:cornerRadius)
        }
    }
    
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?, cornerRadius: CGFloat) {
        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
            gradientLayer.frame = bounds
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = cornerRadius
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.gradientLayer.frame = self.bounds
    }
}
