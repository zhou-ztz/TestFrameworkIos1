//
//  InfoMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 02/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel

class InfoMessageContentView: BaseContentView {
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "icon_voice_call")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentView: UIView = {
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
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming

        let atSide = !self.timeShowAtBottom(messageModel: messageModel)
        
        let contentStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 5
        }
        contentStackView.addArrangedSubview(imageView)
        contentStackView.addArrangedSubview(infoLabel)
        
        contentView.addSubview(contentStackView)
        contentView.addSubview(timeTickStackView)
        self.addSubview(contentView)
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(20)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(27)
        }
        
        contentStackView.snp.makeConstraints { make in
            if atSide {
                make.top.left.bottom.equalToSuperview()
                make.right.equalTo(timeTickStackView.snp.left).offset(-8)
                make.height.equalTo(27)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top).offset(-8)
                make.height.equalTo(27)
            }
        }
        
        timeTickStackView.alignment = .fill
        
        timeTickStackView.snp.makeConstraints { make in
            if atSide {
                make.top.right.bottom.equalToSuperview()
            } else {
                make.bottom.right.equalToSuperview()
            }
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 8:10)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
    }
    
    private func timeShowAtBottom(messageModel: MessageData) -> Bool {
        let tempContentLabel = infoLabel
        let tempTimeLabel = timeLabel
        if let messageTimeInterval = messageModel.messageTime {
            tempTimeLabel.text = messageTimeInterval.messageTimeString()
        }
        
        var atBottom = false
        let maxSize = CGSize(width: ScreenWidth - 110, height: CGFloat(Float.infinity))
        let contentLabelSize = tempContentLabel.sizeThatFits(maxSize)
        let timeLabelSize = tempTimeLabel.sizeThatFits(maxSize)
        if contentLabelSize.width + timeLabelSize.width + 30 > ScreenWidth - 170 || contentLabelSize.height > 30 {
            atBottom = true
        }
        return atBottom
    }

    func dataUpdate(messageModel: MessageData) {
        imageView.isHidden = true
        guard let message = messageModel.nimMessageModel else { return }
        
        if message.messageType == NIMMessageType.notification {
            let object = message.messageObject as! NIMNotificationObject
            var text = "unknown_message".localized
            var image = ""
            switch object.notificationType {
            case .netCall:
                imageView.isHidden = false
                text = SessionUtil().netcallNotificationFormatedMessage(object)
                if let content = object.content as? NIMNetCallNotificationContent, content.callType == .audio {
                    image = "icon_voice_call"
                } else {
                    image = "icon_video_call"
                }
                
                imageView.image = UIImage.set_image(named:image)
            case .team:
                text = SessionUtil().teamNotificationFormatedMessage(message)
                break
            case .chatroom:
                text = SessionUtil().chatroomNotificationFormatedMessage(message)
                break
            default:
                break
            }
            infoLabel.text = text
        }
        else if message.messageType == NIMMessageType.tip {
            infoLabel.text = message.text
        }
    }
}
