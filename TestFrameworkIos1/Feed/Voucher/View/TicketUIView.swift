//
//  TicketView.swift
//  RewardsLink
//
//  Created by Kit Foong on 06/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//
import UIKit

public class TicketUIView: UIView {
    private let leftCircle = UIView(frame: .zero)
    private let rightCircle = UIView(frame: .zero)

    public var circleY: CGFloat = 0
    public var circleRadius: CGFloat = 0
    public var needLeftCircle: Bool = false
    public var needRightCircle: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(leftCircle)
        addSubview(rightCircle)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        addSubview(leftCircle)
        addSubview(rightCircle)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        leftCircle.frame = CGRect(x: -circleRadius, y: circleY,
                                  width: circleRadius * 2 , height: circleRadius * 2)
        leftCircle.layer.masksToBounds = true
        leftCircle.layer.cornerRadius = circleRadius
        leftCircle.backgroundColor = .clear
        
        rightCircle.frame = CGRect(x: bounds.width - circleRadius, y: circleY,
                                   width: circleRadius * 2 , height: circleRadius * 2)
        rightCircle.layer.masksToBounds = true
        rightCircle.layer.cornerRadius = circleRadius
        rightCircle.backgroundColor = .clear
        
        leftCircle.isHidden = !needLeftCircle
        rightCircle.isHidden = !needRightCircle
    }
}

