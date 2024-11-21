//
//  StickerRPSMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 12/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel
import SDWebImage

class StickerRPSMessageContentView: BaseContentView {
    
    lazy var imageView: EmojiImageView = {
        let imageView = EmojiImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 2
            stack.distribution = .fill
            stack.alignment = .trailing
        }
        return stackView
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(timeTickStackView)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(115)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 8:0)
            make.right.equalToSuperview().offset(showLeft ? 0:-8)
        }
        self.bubbleImage.isHidden = true
    }
    
    func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        if object.attachment is IMStickerAttachment {
            let attachment = object.attachment as! IMStickerAttachment
            if attachment.chartletId.hasPrefix("http://") || attachment.chartletId.hasPrefix("https://") {
                gifDisplay(attachment)
            } else {
                self.imageView.image = UIImage()
            }
        } else {
            let attachment = object.attachment as! IMRPSAttachment
            self.imageView.image = self.rpsImage(attachment)
        }
        
    }
    
    func gifDisplay(_ attachment: IMStickerAttachment) {
        self.imageView.image = nil
        self.imageView.imageUrl = URL(string: attachment.chartletId) as NSURL?
        self.imageView.sd_setImage(with: URL(string: attachment.chartletId), completed: nil)
        self.imageView.sd_imageIndicator = self.sd_imageIndicator
        self.imageView.shouldCustomLoopCount = true
        self.imageView.animationRepeatCount = 0
    }
    
    func rpsImage(_ attachment: IMRPSAttachment) -> UIImage? {
        var image: UIImage?
        let rpsValue = CustomRPSValue(rawValue: attachment.value)
        switch rpsValue {
        case .Scissor:
            image = UIImage.set_image(named: "custom_msg_jan")
        case .Rock:
            image = UIImage.set_image(named: "custom_msg_ken")
        case .Paper:
            image = UIImage.set_image(named: "custom_msg_pon")
        default:
            break
        }
        return image
    }
    
    override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.stickerPRSTapped(self.model)
    }
}

class EmojiImageView: SDAnimatedImageView {
    var imageUrl: NSURL?
}
