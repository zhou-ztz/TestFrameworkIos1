//
//  MeetNewUserTextMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 08/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import ActiveLabel

class MeetNewUserTextMessageContentView: BaseContentView {

    lazy var contentLabel: ActiveLabel = {
        let infoLbl = ActiveLabel()
        infoLbl.font = UIFont.systemFont(ofSize: 14)
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 0
        return infoLbl
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming
        contentLabel.text = messageModel.nimMessageModel?.text

        let atSide = !self.timeShowAtBottom(messageModel: messageModel)

        contentView.addSubview(contentLabel)
        contentView.addSubview(timeTickStackView)
        self.addSubview(contentView)
        contentLabel.snp.makeConstraints { make in
            if atSide {
                make.top.left.bottom.equalToSuperview()
                make.right.equalTo(timeTickStackView.snp.left).offset(-8)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top).offset(-8)
            }
            make.height.greaterThanOrEqualTo(24)
        }
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
            make.left.equalToSuperview().offset(showLeft ? 18:8)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
    }
    
    private func timeShowAtBottom(messageModel: MessageData) -> Bool {
        let tempContentLabel = contentLabel
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
    
}
