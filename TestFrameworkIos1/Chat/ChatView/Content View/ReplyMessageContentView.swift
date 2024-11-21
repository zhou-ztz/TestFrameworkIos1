//
//  ReplyMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 03/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ActiveLabel
import SDWebImage
import NIMSDK
//import NIMPrivate

class ReplyMessageContentView: BaseContentView {
    lazy var imageView: SDAnimatedImageView = {
        let imageView = SDAnimatedImageView()
        imageView.image = UIImage.set_image(named: "icon_voice_call")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.semibold(FontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x0D57BC)
        label.text = ""
        label.numberOfLines = 1
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x4a4a4a)
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    
    lazy var imgTextContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.backgroundColor = .white
        return view
    }()
    
    lazy var replyContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        view.backgroundColor = UIColor(hex: 0x0D57BC)
        view.round3Corners()
        return view
    }()
    
    lazy var wholeContentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func basicUISetup(messageModel: MessageData) {
        let atSide = !self.timeShowAtBottom(messageModel: messageModel)
        
        let textStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 11
        }
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(titleLabel)
        
        imgTextContentView.addSubview(imageView)
        imgTextContentView.addSubview(textStackView)
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(imgTextContentView)
        replyContentView.addSubview(contentView)
        
        wholeContentView.addSubview(replyContentView)
        wholeContentView.addSubview(messageLabel)
        wholeContentView.addSubview(timeTickStackView)
        self.addSubview(wholeContentView)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(messageViewDidTap))
        replyContentView.addGestureRecognizer(tapAction)
        
        let message = messageModel.nimMessageModel!
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMReplyAttachment
        
        imageView.snp.makeConstraints { make in
            if attachment.messageType == "2" {
                make.width.equalTo(17)
                make.height.equalTo(28)
            } else {
                make.width.height.equalTo(48)
            }
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            
            if !imageView.isHidden {
                make.top.bottom.greaterThanOrEqualToSuperview()
            }
        }
        
        textStackView.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            if imageView.isHidden {
                make.left.equalToSuperview()
            } else {
                make.left.equalTo(imageView.snp.right).offset(8)
            }
            make.centerY.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(8)
            make.right.equalToSuperview()
        }
        
        imgTextContentView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview().inset(8)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.right.bottom.equalToSuperview()
            make.left.equalToSuperview().inset(4)
        }
        
        replyContentView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(messageLabel.snp.top).offset(-8)
        }
        
        messageLabel.snp.makeConstraints { make in
            if atSide {
                make.left.bottom.equalToSuperview()
            } else {
                make.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top).offset(-8)
            }
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            
            if atSide {
                make.left.greaterThanOrEqualTo(messageLabel.snp.right).inset(-8)
            }
        }
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        
        contentView.backgroundColor = showLeft ? UIColor(hex: 0xf0f0f0) : UIColor(hex: 0xd5eeff)
        
        basicUISetup(messageModel: messageModel)
        wholeContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 18:8)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
    }
    
    func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMReplyAttachment
        
        let defaultImage = UIImage.set_image(named: "default_image")
        
        self.descriptionLabel.isHidden = false
        self.descriptionLabel.text = attachment.message
        
        self.imageView.sd_setImage(with: URL(string: attachment.image), placeholderImage: defaultImage, completed: nil)
        
//        let me = NIMSDK.shared().loginManager.currentAccount()
//        if attachment.username == me {
//            self.nameLabel.text = "you".localized.capitalized
//        } else {
//            let info: NIMKitInfo = NIMBridgeManager.sharedInstance().getUserInfo(attachment.name.lowercased() == "Nickname".lowercased() ? attachment.username : attachment.name)
//            self.nameLabel.text = info.showName
//        }
        
        var mutableAttributedString = attachment.content.attributonString().setTextFont(14).setlineSpacing(0)
        
        if let ext = message.remoteExt {
            if let usernames = ext["usernames"] as? [String], usernames.count > 0 {
                mutableAttributedString = self.formMentionNamesContent(content: mutableAttributedString, usernames: usernames)
            }
            
            if let mentionAll = ext["mentionAll"] as? String {
                mutableAttributedString = self.formMentionAllContent(content: mutableAttributedString, mentionAll: mentionAll)
            }
        }
        
        self.messageLabel.attributedText = mutableAttributedString
        
        switch NIMMessageType(rawValue: Int(attachment.messageType) ?? -1) {
        case .text:
            self.imageView.isHidden = true
            self.titleLabel.isHidden = true
            self.descriptionLabel.text = attachment.message
            break
        case .image:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = true
            
            self.titleLabel.text = "image".localized
            self.imageView.contentMode = .scaleToFill
            break
        case .audio:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = true
            
            self.imageView.image = UIImage.set_image(named: "icon_reply_message_audio")
            self.imageView.contentMode = .scaleAspectFit
            break
        case .video:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = true
            
            if (attachment.videoURL == "") {
                self.imageView.sd_setImage(with: URL(string: attachment.image), placeholderImage: defaultImage, completed: nil)
            } else {
                self.imageView.sd_setImage(with: URL(string: attachment.videoURL), placeholderImage: defaultImage, completed: nil)
            }
            self.imageView.contentMode = .scaleToFill
            
            self.titleLabel.text = "video".localized
            break
        case .location:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = false
            
            self.imageView.image = UIImage.set_image(named: "ic_map_default")
            self.titleLabel.text = "location".localized
            break
        case .file:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = false
            
            let fileType = URL(fileURLWithPath: attachment.message).pathExtension
            let fileInfo = SendFileManager.fileIcon(with:fileType)
            self.imageView.image = fileInfo.icon
            self.titleLabel.text = fileInfo.type
            break
        case .custom:
            self.customAttachment(attachment: attachment)
            break
        default:
            break
        }
    }
    
    func customAttachment(attachment: IMReplyAttachment) {
        switch CustomMessageType(rawValue: Int(attachment.messageCustomType) ?? -1) {
        case .Sticker:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = true
            break
        case .ContactCard:
            self.imageView.isHidden = false
            self.titleLabel.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.text = "contact".localized
            let defaultImage = UIImage.set_image(named: "IMG_pic_default_secret")
            self.imageView.sd_setImage(with: URL(string: attachment.image), placeholderImage: defaultImage, completed: nil)
            self.imageView.roundCorner(24)
            break
        case .Reply:
            self.imageView.isHidden = true
            self.titleLabel.isHidden = true
            self.descriptionLabel.isHidden = false
            break
        case .StickerCard:
            self.imageView.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text = "rw_yippi_sticker".localized
            break
        case .SocialPost:
            self.imageView.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text =  "link".localized
            break
        case .Voucher:
            self.imageView.isHidden = false
            self.descriptionLabel.isHidden = false
            self.titleLabel.isHidden = false
            self.titleLabel.text =  "rw_voucher_text".localized
            break
        default:
            break
        }
    }
    
    private func timeShowAtBottom(messageModel: MessageData) -> Bool {
        let tempContentLabel = messageLabel
        let tempTimeLabel = timeLabel
        if let messageTimeInterval = messageModel.messageTime {
            tempTimeLabel.text = messageTimeInterval.messageTimeString()
        }
        
        var atBottom = false
        let maxSize = CGSize(width: ScreenWidth - 90, height: CGFloat(Float.infinity))
        let contentLabelSize = tempContentLabel.sizeThatFits(maxSize)
        let timeLabelSize = tempTimeLabel.sizeThatFits(maxSize)
        if contentLabelSize.width + timeLabelSize.width + 30 > ScreenWidth - 150 || contentLabelSize.height > 30 {
            atBottom = true
        }
        return atBottom
    }
    
    @objc func messageViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.replyMessageTapped(self.model)
    }
}

extension UIView {
    func roundCorners(_ frame: CGRect) {
        let path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft, .topRight, .bottomRight], cornerRadii: CGSize(width: 10, height: 10))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = UIColor(hex: 0x0D57BC).cgColor
        
        self.layer.mask = mask
        self.layer.masksToBounds = true
    }
    
    func round3Corners() {
        self.backgroundColor = UIColor(hex: 0x0D57BC)
        self.layer.cornerRadius = 10
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
        self.layer.masksToBounds = true
    }
}

