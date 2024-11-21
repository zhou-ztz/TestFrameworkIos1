//
//  IMStickerTabCollectionViewCell.swift
//  Yippi
//
//  Created by Khoo on 23/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class IMStickerTabCollectionViewCell: UICollectionViewCell {
    var imageView: StickerImageView!
    var emojiLabel: UILabel!
    var rightBorder: CALayer? = nil
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initViews () {
        imageView = StickerImageView(frame: CGRect(x: 2.5,y: 2.5, width: self.width-5,height: self.height-5))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.centerX = self.width/2
        imageView.backgroundColor = .clear
        
        self.contentView.addSubview(imageView)
        
        emojiLabel = UILabel(frame: CGRect(x: 2.5, y: 2.5, width: self.width - 5, height: self.height - 5))
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .clear
        
        self.contentView.addSubview(imageView)
    }
    
    func setupViews () {
        imageView.center = CGPoint(x: self.width/2, y: self.height/2)
//        imageView.contentMode = .scaleAspectFit
//        imageView.clipsToBounds = true
       // self.addSubview(imageView)
        
   //     emojiLabel.textAlignment = .center
       // self.addSubview(emojiLabel)
    }
    
    func addCellRightBorder(_ frame: CGRect) {
        var rightBorder = CALayer()
        rightBorder.backgroundColor = AppTheme.imStickerBorder.cgColor
        rightBorder.frame = CGRect(x: frame.size.width, y: 0, width: 1, height: frame.size.height)
        self.contentView.layer.addSublayer(rightBorder)
    }

    func setBgSelected(_ select: Bool) {
        if select == true {
            contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        } else {
            contentView.backgroundColor = UIColor.clear
        }
    }

    func configure(_ cellImage: UIImage?, icon cellIcon: URL?, isSelected: Bool, isNightMode: Bool) {
        if cellImage != nil && cellIcon == nil {
            imageView.image = cellImage
            imageView.shouldCustomLoopCount = true
            imageView.animationRepeatCount = 0
        } else if cellIcon != nil && cellImage == nil {
            imageView.sd_setImage(with: cellIcon)
            imageView.shouldCustomLoopCount = true
            imageView.animationRepeatCount = 0
        }
        
        if isNightMode {
            guard let sublayers = self.contentView.layer.sublayers else { return }
            
            for sublayer in sublayers where sublayer.isKind(of: CALayer.self) {
                sublayer.backgroundColor = UIColor.clear.cgColor
            }
        } else {
            addCellRightBorder(self.frame)
        }

        if isSelected == true {
            contentView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        } else {
            contentView.backgroundColor = UIColor.clear
        }
    }

}
