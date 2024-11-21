//
//  CameraOverlayView.swift
//  Yippi
//
//  Created by francis on 26/07/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

class CameraOverlayView: UIView {
    
    let transparentHoleView: UIView = UIView()
    let label: UILabel = UILabel()
    let focusBounds: CGRect
    
    init(focusBounds: CGRect, text: String = "") {
        self.focusBounds = focusBounds
        
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor.clear
        
        self.isUserInteractionEnabled = false
        
        addSubview(transparentHoleView)
        addSubview(label)
        
        backgroundColor = .clear
        
        transparentHoleView.frame = focusBounds
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = .white
        label.numberOfLines = 36
        
        label.snp.makeConstraints {
            $0.bottom.equalTo(transparentHoleView.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview().inset(16)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let strokeWidth: CGFloat = 5.0
        
        let transparentRectPath = UIBezierPath(roundedRect: focusBounds, cornerRadius: 8)
        let strokePath = UIBezierPath(roundedRect: CGRect(x: focusBounds.origin.x + strokeWidth/2,
                                                          y: focusBounds.origin.y + strokeWidth/2,
                                                          width: focusBounds.width - strokeWidth,
                                                          height: focusBounds.height - strokeWidth),
                                      cornerRadius: 8)
        
        let overlayPath = UIBezierPath(rect: self.bounds)
        
        
        let fillLayer = CAShapeLayer()
        fillLayer.frame = self.bounds
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        
        overlayPath.append(transparentRectPath)
        
        fillLayer.path = overlayPath.cgPath
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.5).cgColor
        
        layer.addSublayer(fillLayer)
        
        UIColor.white.setStroke()
        strokePath.lineWidth = strokeWidth
        strokePath.stroke()
        
        self.bringSubviewToFront(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
