//
//  MessageReplyView.swift
//  Yippi
//
//  Created by Tinnolab on 06/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage
import NIMSDK
class MessageReplyView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var avatarOuterView: UIView!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var audioImageView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    
    var messageID: String?
    var messageType: String?
    var messageCustomType: String?
    var username: String?
    
    lazy var playBtnImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "icon_play_normal")
        image.isUserInteractionEnabled = false
        image.isHidden = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let bundle = Bundle(for: type(of: self))
        UINib(nibName: "MessageReplyView", bundle: bundle).instantiate(withOwner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        
        nicknameLabel.textColor = .black
        messageLabel.textColor = .gray
        
        imageView.layer.cornerRadius = 0
        imageView.clipsToBounds = false
        
        imageView.addSubview(playBtnImageView)
        playBtnImageView.snp.makeConstraints({make in
            make.width.height.equalTo(20)
            make.center.equalToSuperview()
        })
    }
    
    func configure(_ message: NIMMessage) {
        avatarOuterView.isHidden = false
        imageView.isHidden = false
        imageView.contentMode = .scaleAspectFit
        avatarView.isHidden = true
        
        messageCustomType = ""
        
        let senderName = message.isOutgoingMsg ? "you".localizedCapitalized : message.senderName
        username = message.from
        
        playBtnImageView.isHidden = true
        audioImageView.isHidden = true
        
        switch(message.messageType) {
        case NIMMessageType.image:
            if let imageObject = message.messageObject as? NIMImageObject, let url = URL(string: imageObject.url.orEmpty) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let imageData = data else { return }
                    
                    DispatchQueue.main.async {
                        self.messageLabel.isHidden = false
                        self.imageView.isHidden = false
                        self.messageLabel.text = "image".localized
                        self.imageView.image = UIImage(data: imageData)
                    }
                }.resume()
            }
            break
        case NIMMessageType.audio:
            guard let audioObject = message.messageObject as? NIMAudioObject else { return }
            
            var milliseconds = Float(audioObject.duration)
            milliseconds = milliseconds / 1000
            let currSeconds = Int(fmod(milliseconds, 60))
            let currMinute = Int(fmod((milliseconds / 60), 60))
            
            avatarOuterView.isHidden = true
            audioImageView.isHidden = false
            messageLabel.isHidden = false
            
            messageLabel.text = String(format: "%01d:%02d", currMinute, currSeconds)
            audioImageView.contentMode = .scaleAspectFit
            audioImageView.image = UIImage.set_image(named: "icon_reply_message_audio")
            break
        case NIMMessageType.video:
            if let videoObject = message.messageObject as? NIMVideoObject, let url = URL(string: videoObject.coverUrl.orEmpty) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let imageData = data else { return }
                    
                    DispatchQueue.main.async {
                        self.messageLabel.isHidden = false
                        self.imageView.isHidden = false
                        self.playBtnImageView.isHidden = false
                        self.messageLabel.text = "video".localized
                        self.imageView.image = UIImage(data: imageData)
                    }
                }.resume()
            }
            break
        case NIMMessageType.location:
            guard let locationObject = message.messageObject as? NIMLocationObject else { return }
            
            imageView.isHidden = false
            messageLabel.isHidden = false
            imageView.image = UIImage.set_image(named: "ic_map_default")
            messageLabel.text = locationObject.title
            break
        case NIMMessageType.file:
            guard let fileObject = message.messageObject as? NIMFileObject else { return }
            
            let fileType = URL(fileURLWithPath: fileObject.path ?? "").pathExtension
            let image = SendFileManager.fileIcon(with:fileType).icon
            imageView.isHidden = false
            messageLabel.isHidden = false
            imageView.image = image
            messageLabel.text = fileObject.displayName.orEmpty
            break
        case NIMMessageType.custom:
            guard let object = message.messageObject as? NIMCustomObject else { return }
            if object.attachment is IMContactCardAttachment {
                imageView.isHidden = true
                avatarView.isHidden = false
                
                let attachment = object.attachment as! IMContactCardAttachment
                
                let showName = NIMSDKManager.shared.getNimKitInfo(userId: attachment.memberId, type: .showName)
                avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: attachment.memberId)
                
                messageLabel.isHidden = false
                if !showName.isEmpty {
                    messageLabel.text = String(format: "reply_contact_im".localized, showName)
                }
                messageCustomType = String(format: "%ld", Int(CustomMessageType.ContactCard.rawValue))
            } else if object.attachment is IMReplyAttachment {
                let attachment = object.attachment as! IMReplyAttachment
                let message = attachment.content
                avatarOuterView.isHidden = true
                messageLabel.isHidden = false
                messageLabel.text = message
                messageCustomType = String(format: "%ld", Int(CustomMessageType.Reply.rawValue))
            } else if object.attachment is IMStickerAttachment {
                if let attachment = object.attachment as? IMStickerAttachment, let url = URL(string: attachment.chartletId) {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        guard let imageData = data else { return }
                        
                        DispatchQueue.main.async {
                            self.messageLabel.isHidden = false
                            self.imageView.isHidden = false
                            self.imageView.image = UIImage(data: imageData)
                            self.messageLabel.text = "title_sticker".localized
                            self.messageCustomType = String(format: "%ld", Int(CustomMessageType.Sticker.rawValue))
                        }
                    }.resume()
                }
            } else if object.attachment is IMStickerCardAttachment {
                if let attachment = object.attachment as? IMStickerCardAttachment, let url = URL(string: attachment.bundleIcon) {
                    URLSession.shared.dataTask(with: url) { (data, response, error) in
                        guard let imageData = data else { return }
                        
                        DispatchQueue.main.async {
                            self.imageView.isHidden = false
                            self.messageLabel.isHidden = false
                            self.imageView.image = UIImage(data: imageData)
                            self.messageLabel.text = attachment.bundleName
                            self.messageCustomType = String(format: "%ld", Int(CustomMessageType.StickerCard.rawValue))
                        }
                    }.resume()
                }
            } else if object.attachment is IMSocialPostAttachment {
                let attachment = object.attachment as! IMSocialPostAttachment
                imageView.isHidden = false
                messageLabel.isHidden = false
                imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: UIImage.set_image(named: "default_image_reply"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                
                messageLabel.text = attachment.title
                
                DispatchQueue.global(qos: .default).async(execute: {
                    //                        weak var weakSelf = self
                    if let localExt = message.localExt, let title = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.updateUI(title, image: image, desc: desc, message: message)
                    }
                })
                messageCustomType = String(format: "%ld", Int(CustomMessageType.SocialPost.rawValue))
            } else if object.attachment is IMMiniProgramAttachment {
                let attachment = object.attachment as! IMMiniProgramAttachment
                imageView.isHidden = false
                messageLabel.isHidden = false
                imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: UIImage.set_image(named: "default_image"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                
                messageLabel.text = attachment.title
                
                DispatchQueue.global(qos: .default).async(execute: {
                    //                        weak var weakSelf = self
                    if let localExt = message.localExt, let title = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.updateUI(title, image: image, desc: desc, message: message)
                    }
                })
                messageCustomType = String(format: "%ld", Int(CustomMessageType.MiniProgram.rawValue))
            }  else if object.attachment is IMVoucherAttachment {
                let attachment = object.attachment as! IMVoucherAttachment
                imageView.isHidden = false
                messageLabel.isHidden = false
                imageView.sd_setImage(with: URL(string: attachment.imageURL), placeholderImage: UIImage.set_image(named: "default_image_reply"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
                
                messageLabel.text = attachment.title
                
                DispatchQueue.global(qos: .default).async(execute: {
                    //                        weak var weakSelf = self
                    if let localExt = message.localExt, let title = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
                        self.updateUI(title, image: image, desc: desc, message: message)
                    }
                })
                messageCustomType = String(format: "%ld", Int(CustomMessageType.Voucher.rawValue))
            } else {
                avatarOuterView.isHidden = true
                messageLabel.isHidden = false
                messageLabel.text = message.text
            }
            break
        case .text:
            avatarOuterView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message.text
            break
        case .notification, .tip, .robot:
            avatarOuterView.isHidden = true
            messageLabel.isHidden = false
            messageLabel.text = message.text
            break
        default:
            break
        }
        
        let nick = SessionUtil.showNick(senderName, in: nil)
        let nameString = nick?.count == 0 ? senderName : nick
        
        LocalRemarkName.getRemarkName(userId: nil, username: senderName, originalName: nameString, label: self.nicknameLabel)
        
        messageID = message.messageId
        messageType = String(format: "%ld", message.messageType.rawValue)
    }
    
    func updateUI(_ title: String, image: String, desc: String, message: NIMMessage) {
        DispatchQueue.main.async(execute: { [self] in
            guard let object = message.messageObject as? NIMCustomObject else { return }
            
            self.imageView.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "default_image_reply"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
            self.messageLabel.text = desc
        })
    }
}
