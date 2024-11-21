//
//  HomepageHeaderView.swift
//  Yippi
//
//  Created by ming jie on 20/02/2020.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

import UIKit
import SDWebImage

class ReplyChatView: UIView {
    
    /// Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var chatContent: UILabel!
    @IBOutlet weak var textContentView: UIView!
    @IBOutlet weak var replyButton: GradientButton!
    @IBOutlet weak var stickerImageView: SDAnimatedImageView!
    @IBOutlet weak var stickerSender: UILabel!
    @IBOutlet weak var stickerContentView: UIView!
    
    var didTapReplyButton: EmptyClosure?
    
    init() {
        super.init(frame: .zero)
        setupUI()
        configureReplyButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
        configureReplyButton()
    }
    
    private func setupUI() {
        
        Bundle.main.loadNibNamed(String(describing: ReplyChatView.self), owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.addSubview(contentView)

        textContentView.roundCorner(10)
        stickerContentView.roundCorner(10)
    }
    
    func setUpChatContent(senderName:String, content:String, isSticker:Bool) {
        if isSticker {
            textContentView.makeHidden()
            stickerContentView.makeVisible()
            
            stickerSender.textColor = AppTheme.secondaryColor
            stickerSender.numberOfLines = 3
            stickerSender.lineBreakMode = NSLineBreakMode.byWordWrapping
            stickerSender.text = senderName + ": "
            stickerSender.sizeToFit()
            
            stickerImageView.sd_imageIndicator = SDWebImageActivityIndicator.white
            stickerImageView.sd_setImage(with: URL(string: content), completed: nil)
            stickerImageView.shouldCustomLoopCount = true
            stickerImageView.animationRepeatCount = 0
            stickerImageView.backgroundColor = .clear
        
        }
        else {
            chatContent.textColor = .black
            chatContent.text = senderName + ": " + content
            
            let string: NSMutableAttributedString = NSMutableAttributedString(string: chatContent.text!)
            string.setColorForText(textToFind: senderName + ": ", withColor: AppTheme.secondaryColor)
            chatContent.attributedText = string
            
            chatContent.numberOfLines = 4
            chatContent.lineBreakMode = NSLineBreakMode.byWordWrapping
            chatContent.sizeToFit()
            
            textContentView.makeVisible()
            stickerContentView.makeHidden()
            stickerImageView.image = nil
        }
    }
    
    private func configureReplyButton() {
        replyButton.leftGradientColor = UIColor(hexString: "#FFD246")
        replyButton.rightGradientColor = UIColor(hexString: "#F4A80C")
        replyButton.cornerRadius = replyButton.height/2
        replyButton.clipsToBounds = true
        replyButton.setTitle("longclick_msg_reply".localized, for: .normal)
        replyButton.throttle(.touchUpInside, interval: 0.2) { [weak self] in
            guard let self = self else { return }
            self.didTapReplyButton?()
        }
    }
    
}

extension NSMutableAttributedString {
    func setColorForText(textToFind: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range != nil {
            self.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
}
