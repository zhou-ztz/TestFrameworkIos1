//
//  WhiteBoardCallingCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/2.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit


class WhiteBoardCallingCell: UICollectionViewCell {
    
    var avatarImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.avatarImageView = UIImageView(frame:self.bounds)
//        self.avatarImageView.avatarPlaceholderType = .system
        self.addSubview(self.avatarImageView)
        self.avatarImageView.image = UIImage.set_image(named: "IMG_pic_default_secret")
        self.backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadCallingUser(user: String, number: Int, index: Int)
    {
        
        if (number > 4 && index == 3) {
            
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.width / 2
            self.avatarImageView.layer.masksToBounds = true
            
            let numberLabel = UILabel(frame: self.avatarImageView.frame)
            let numberText = "\(number - index)"
            numberLabel.text = numberText
    
            numberLabel.font = UIFont.systemFont(ofSize: 35)
            numberLabel.textColor = .white
            numberLabel.textAlignment = .center
            numberLabel.layer.cornerRadius = self.avatarImageView.width / 2
            numberLabel.layer.masksToBounds = true
            self.avatarImageView.addSubview(numberLabel)
            
        } else {
            self.avatarImageView.isHidden = false
            self.avatarImageView.layer.cornerRadius = self.avatarImageView.width / 2
            self.avatarImageView.layer.masksToBounds = true
            
            self.backgroundColor = .clear
           
            let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: user)
            self.avatarImageView.sd_setImage(with: URL(string: avatarInfo.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"), options: [], progress: nil, completed: nil)
            self.setNeedsLayout()
        }
    }
}
