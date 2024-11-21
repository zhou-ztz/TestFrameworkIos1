//
//  HorizontalPageControlView.swift
//  Yippi
//
//  Created by Wong Jin Lun on 09/11/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

open class HorizontalPageControlView: UIView {
    @IBInspectable open var selectedColor: UIColor? {
        didSet {
            self.setNeedsDisplay()
        }
    }

    public enum HorizontalPageControlType {
        case totalPageCount
        case indicatorFactor
    }
    
    open var horizontalPageControlType: HorizontalPageControlType = .totalPageCount
    
    open var totalPageCount  : Int = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    open var indicatorFactor  : CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }

    open var indicatorOffset : CGFloat = 0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
    }
    
    open var selectedPosition: Int {
        get { return Int(round(self.indicatorOffset)) }
        set { self.indicatorOffset = CGFloat(newValue) }
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        switch horizontalPageControlType {
        case .indicatorFactor:
            guard self.indicatorFactor > 0 else { return }
            break
        default:
            guard self.totalPageCount > 0  else { return }
            break
        }
        
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let width = self.bounds.width / (horizontalPageControlType == .indicatorFactor ? CGFloat(self.indicatorFactor ):CGFloat(self.totalPageCount))
        let xPosition = self.indicatorOffset * width
        let drawRect = CGRect(x: xPosition, y: 0, width: width, height: self.bounds.height)
        let clipPath = UIBezierPath(roundedRect: drawRect, cornerRadius: self.layer.cornerRadius).cgPath
        
        context?.addPath(clipPath)
        context?.setFillColor(self.selectedColor?.cgColor ?? UIColor.black.cgColor)
        context?.closePath()
        context?.fillPath()
    }
}
