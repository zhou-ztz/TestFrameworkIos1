//
//  BaseContentView.swift
//  Yippi
//
//  Created by Tinnolab on 01/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import ActiveLabel

protocol ContentViewDelegate: class {
    func contactCardTapped(_ message: MessageData)
    func stickerCardTapped(_ message: MessageData)
    func socialPostTapped(_ message: MessageData)
    func imageTapped(_ message: MessageData)
    func videoTapped(_ message: MessageData)
    func locationTapped(_ message: MessageData)
    func eggTapped(_ message: MessageData)
    func retryTextTranslate(_ message: MessageData)
    func fileTapped(_ message: MessageData)
    func meetingTapped(_ message: MessageData)
    func replyMessageTapped(_ message: MessageData)
    func snapMessageTapped(_ message: MessageData, baseView: UIView, isEnd: Bool)
    func MiniProgramMessageTapped(_ message: MessageData)
    func stickerPRSTapped(_ message: MessageData)
    func AnnouncementTapped(_ url: String?)
    func voiceTapped(_ message: MessageData, contentView: VoiceMessageContentView)
    func startVoiceUI(_ message: MessageData, contentView: VoiceMessageContentView)
    func textUrlTapped(_ url: String?)
    func selectionLanguageTapped(_ message: MessageData)
    func whiteboardTapped(_ message: MessageData)
    func unknownTapped()
    func voucherTapped(_ message: MessageData)
}

class BaseContentView: UIView {
    weak var delegate: ContentViewDelegate?
    
    let defaultSenderImage = UIImage.set_image(named: "senderMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let defaultReceiverImage = UIImage.set_image(named: "receiverMessage")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    let senderRedPacket = UIImage.set_image(named: "pink_bubble_right")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 18), resizingMode: .stretch)
    let receiverRedPacket = UIImage.set_image(named: "pink_bubble_left")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 18, bottom: 10, right: 10), resizingMode: .stretch)
    
    let urlPattern = "<{0,1}(((https|http)?://)?([a-z0-9_-]+[.])|(www.))" + "\\w+[.|\\/]([a-z0-9\\-]{0,})?[[.]([a-z0-9\\-]{0,})]+((/[\\S&&[^,;\\u4E00-\\u9FA5]]+)+)?([.][a-z0-9\\-]{0,}+|/?)>{0,1}"
    
    lazy var bubbleImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = defaultReceiverImage
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(9)
        label.textColor = UIColor(hexString: "#808080")
        label.text = "00:00"
        label.isHidden = true
        return label
    }()
    
    lazy var tickImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "unreadTick")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var timeTickStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 5
            stack.distribution = .fill
            stack.alignment = .bottom
        }
        return stackView
    }()
    
    lazy var pinendImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "MdOutlinePushPin")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    var model: MessageData = MessageData(type: .headerTip)

    init(messageModel: MessageData) {
        self.model = messageModel
        super.init(frame: .zero)
        commonInit()
        
        let showReadLabel = messageModel.showReadLabel ?? false
        tickImage.isHidden = !showReadLabel
        
        let showLeft = messageModel.type == .incoming
        if messageModel.isRedPacket ?? false {
            bubbleImage.image = showLeft ? receiverRedPacket : senderRedPacket
        } else {
            bubbleImage.image = showLeft ? defaultReceiverImage : defaultSenderImage
        }
        
        if let messageTimeInterval = messageModel.messageTime {
            timeLabel.isHidden = false
            timeLabel.text = messageTimeInterval.messageTimeString()
        }
        timeLabel.isHidden = false
        bubbleImage.isHidden = false
        
        tickImage.image = messageModel.nimMessageModel!.isRemoteRead ? UIImage.set_image(named: "readTick") : UIImage.set_image(named: "unreadTick")
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.backgroundColor = .clear
        self.addSubview(bubbleImage)
        bubbleImage.snp.makeConstraints { make in
            make.width.height.centerX.centerY.equalToSuperview()
        }
        tickImage.snp.makeConstraints { make in
            make.width.height.equalTo(15)
        }
        pinendImage.snp.makeConstraints { make in
            make.width.height.equalTo(15)
        }
        timeTickStackView.addArrangedSubview(timeLabel)
        timeTickStackView.addArrangedSubview(pinendImage)
        timeTickStackView.addArrangedSubview(tickImage)
        
        let tapAction = UITapGestureRecognizer(target: self, action: #selector(contentViewDidTap))
        self.addGestureRecognizer(tapAction)
        pinendImage.isHidden = !model.isPinned
    }
    
    @objc func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        
    }
    
    func setPinendImage(isPinned: Bool = false){
        pinendImage.isHidden = !isPinned
    }

    func formMentionNamesContent(content: NSMutableAttributedString, usernames: [String]) -> NSMutableAttributedString {
        var mutableAttributedString = content
        
        if usernames.count > 0 {
            for var item in usernames {
                let nickName = NIMSDKManager.shared.getDisplayNameByUsername(username: item)
                guard let regex = try? NSRegularExpression(pattern: "@\(nickName)", options: []) else { return mutableAttributedString }
                let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                                                     range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
                ) { (matchResult, _, stop) -> () in
                    if let match = matchResult {
                        mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: AppTheme.primaryColor, range: match.range)
                    }
                }
            }
        }
        
        return mutableAttributedString
    }
    
    func formMentionAllContent(content: NSMutableAttributedString, mentionAll: String) -> NSMutableAttributedString {
        var mutableAttributedString = content
        
        guard let regex = try? NSRegularExpression(pattern: "@\(mentionAll)", options: []) else { return mutableAttributedString }
        let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                                             range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
        ) { (matchResult, _, stop) -> () in
            if let match = matchResult {
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: AppTheme.primaryColor, range: match.range)
            }
        }
        
        return mutableAttributedString
    }
    
    func formUrlContent(content: NSMutableAttributedString) -> NSMutableAttributedString {
        var mutableAttributedString = content
        
        guard let regex = try? NSRegularExpression(pattern: urlPattern, options: []) else { return mutableAttributedString }
        let matches = regex.enumerateMatches(in: mutableAttributedString.string,
                range: NSRange(mutableAttributedString.string.startIndex..<mutableAttributedString.string.endIndex, in: mutableAttributedString.string)
        ) { (matchResult, _, stop) -> () in
            if let match = matchResult {
                let url = mutableAttributedString.string.subString(with: match.range)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.blue, range: match.range)
                mutableAttributedString.addAttributes([NSAttributedString.Key.link: url], range: match.range)
            }
        }
        
        return mutableAttributedString
    }
}

extension TimeInterval {
    func messageTimeString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let df = DateFormatter()
        //df.dateFormat = "MM-dd HH:mm"
        df.dateFormat = "hh:mm a"
        return df.string(from: date)

    }
}
