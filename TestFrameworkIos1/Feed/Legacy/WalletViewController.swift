//
//  WalletViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 27/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import Hero

class VerticalView: UIView {
    
    var type: MoreItem?
    
    private static let kHeight: CGFloat = 8.0
    
    private let stackview = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 7
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let label = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: AppTheme.black))
        $0.textAlignment = .center
//        $0.numberOfLines = 1
//        $0.lineBreakMode = .byClipping
    }
    
    private let icon = UIImageView().configure {
        $0.contentMode = .center
        $0.backgroundColor = UIColor(hex: 0xF1F7FE)
        $0.clipsToBounds = true
        $0.roundCorner(25)
    }
    
    private let badge = UIView().configure {
        $0.backgroundColor = TSColor.main.warn
        $0.layer.cornerRadius = VerticalView.kHeight / 2
    }
    
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        self.isUserInteractionEnabled = true
        
        addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(icon)
        
        stackview.addArrangedSubview(label)
        
        
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        icon.image = image
        label.text = title
        
        icon.snp.makeConstraints { make in
            make.height.width.equalTo(50)
        }
        
        if image == nil {
            icon.backgroundColor = .clear
        }
    }
    
    func customiseLabel() {
        label.setFontSize(with: 12, weight: .medium)
        label.textColor = AppTheme.darkGrey
    }
    
    func setBadge(_ count: Int) {
        
        if badge.superview == nil {
            addSubview(badge)
            badge.snp.makeConstraints {
                $0.width.equalTo(VerticalView.kHeight)
                $0.height.equalTo(VerticalView.kHeight)
                $0.top.equalToSuperview()
                $0.centerX.equalToSuperview().offset(20)
            }
        }
        
        badge.isHidden = count == 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
