//
//  IMStickerCollectionCell.swift
//  Yippi
//
//  Created by Khoo on 13/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

protocol EmojiItemTappedDelegate: class {
  func emojiItemTapped(emojiText: String)
}

class IMStickerCollectionCell: UICollectionViewCell {
    weak var delegate : EmojiItemTappedDelegate?
    
    var imageView: StickerImageView = StickerImageView()
    var bgView = UIView()
    var icon = UIImageView()
    var tilLab = UILabel()
    var emojiLabel: UILabel = UILabel() {
        didSet {
            let emojiMut = NSMutableAttributedString()
            emojiLabel.numberOfLines = 1
            emojiLabel.adjustsFontSizeToFitWidth = true
            emojiLabel.minimumScaleFactor = 0.8
            emojiLabel.attributedText = emojiMut
        }
    }
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView = StickerImageView(frame: CGRect(x: 0,y: 0, width: self.width,height: self.height))
        emojiLabel = UILabel(frame: CGRect(x: 0,y: 0, width: self.width, height: self.height))
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews () {
        imageView.center = CGPoint(x: self.width/2, y: self.height/2)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        self.addSubview(imageView)
        
        emojiLabel.textAlignment = .center
        self.addSubview(emojiLabel)
        self.bgView.isHidden = true
        self.bgView.backgroundColor = .white
        self.addSubview(self.bgView)
        self.bgView.frame = CGRect(x: 0, y: 0,width: self.frame.size.width, height: self.frame.size.height)
        icon.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        icon.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2 )
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal)
        bgView.addSubview(icon)
        tilLab.frame = CGRect(x: 0, y: self.frame.size.height - 24,width: self.frame.size.width, height: 14)
        tilLab.text = "Custom sticker".localized
        tilLab.textColor = .black
        tilLab.font = UIFont.systemFont(ofSize: 10)
        tilLab.textAlignment = .center
        bgView.addSubview(tilLab)
        
        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: self.frame.size.height), isPostFeed: false)
        emojiView.delegate = self
        self.addSubview(emojiView)
    }
    
    public func setViewNightMode(isNight: Bool) {
        if isNight {
            self.icon.image = UIImage.set_image(named: "plus")?.withRenderingMode(.alwaysOriginal)
            self.tilLab.textColor = .white
            self.emojiView.backgroundColor = AppTheme.materialBlack
            self.bgView.backgroundColor = AppTheme.materialBlack
        } else {
            self.icon.image = UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal)
            self.tilLab.textColor = .black
            self.emojiView.backgroundColor = .white
            self.bgView.backgroundColor = .white
        }
    }
}

extension IMStickerCollectionCell: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.delegate?.emojiItemTapped(emojiText: emoji)
    }
}
