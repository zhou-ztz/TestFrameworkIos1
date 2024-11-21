//
//  VideoCallingContentView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/30.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import ActiveLabel
import Foundation

class VideoCallingContentView: BaseContentView {

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
            stack.spacing = 8
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
            make.height.greaterThanOrEqualTo(24)
        }
        
        contentStackView.snp.makeConstraints { make in
            if atSide {
                make.top.left.bottom.equalToSuperview()
                make.right.equalTo(timeTickStackView.snp.left).offset(-8)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top).offset(-8)
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
            make.left.equalToSuperview().offset(showLeft ? 20:10)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
        tickImage.isHidden = true
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
        imageView.isHidden = false
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMCallingAttachment
        var image = ""
        var text = "unknown_message".localized
        if attachment.callType == .video {
            image = "icon_video_call"
        }else {
            image = "icon_voice_call"
        }
        text = SessionUtil().netcallNotificationFormatedMessage1(attachment)
        imageView.image = UIImage.set_image(named:image)
        infoLabel.text = text
        
        
    }

}
