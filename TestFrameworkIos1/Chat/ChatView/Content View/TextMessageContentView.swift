//
//  TextMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 08/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import ActiveLabel

class TextContentView: BaseContentView {
    lazy var contentLabel: UITextView = {
        let infoLbl = UITextView()
        infoLbl.font = AppTheme.Font.regular(FontSize.defaultFontSize)
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.textContainer.maximumNumberOfLines = 0
        infoLbl.isScrollEnabled = false
        infoLbl.backgroundColor = .clear
        infoLbl.isSelectable = false
        infoLbl.isEditable = false
        infoLbl.linkTextAttributes = [.foregroundColor: UIColor.blue]
        return infoLbl
    }()
    
//    lazy var contentLabel: ActiveLabel = {
//        let infoLbl = ActiveLabel()
//        infoLbl.font = AppTheme.Font.regular(FontSize.defaultFontSize)
//        infoLbl.textColor = .black
//        infoLbl.text = ""
//        infoLbl.textAlignment = .left
//        infoLbl.numberOfLines = 0
//        infoLbl.enabledTypes = [.mention, .hashtag, .url]
//        infoLbl.mentionColor = AppTheme.primaryBlueColor
//        return infoLbl
//    }()
    
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
        self.removeGestures()
        let showLeft = messageModel.type == .incoming
        
        var mutableAttributedString = (messageModel.nimMessageModel?.text ?? "").attributonString().setTextFont(14).setlineSpacing(0)

        if let ext = messageModel.nimMessageModel?.remoteExt {
            if let usernames = ext["usernames"] as? [String], usernames.count > 0 {
                mutableAttributedString = self.formMentionNamesContent(content: mutableAttributedString, usernames: usernames)
            }
            
            if let mentionAll = ext["mentionAll"] as? String {
                mutableAttributedString = self.formMentionAllContent(content: mutableAttributedString, mentionAll: mentionAll)
            }
        }
        
        mutableAttributedString = self.formUrlContent(content: mutableAttributedString)
            
        contentLabel.attributedText = mutableAttributedString
        
        let atSide = !self.timeShowAtBottom(messageModel: messageModel)
        
        contentView.addSubview(contentLabel)
        contentView.addSubview(timeTickStackView)
        self.addSubview(contentView)
        timeTickStackView.snp.makeConstraints { make in
            if atSide {
                make.top.right.bottom.equalToSuperview()
            } else {
                make.bottom.right.equalToSuperview()
            }
        }
        contentLabel.snp.makeConstraints { make in
            if atSide {
                make.bottom.left.equalToSuperview()
                make.top.equalToSuperview().offset(-10)
                make.right.equalTo(timeTickStackView.snp.left).offset(-8)
            } else {
                make.top.left.right.equalToSuperview()
                make.bottom.equalTo(timeTickStackView.snp.top)
            }
            make.height.greaterThanOrEqualTo(24)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 20:10)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
        
        timeTickStackView.alignment = .fill
        timeTickStackView.layoutIfNeeded()
        contentLabel.layoutIfNeeded()
        contentView.layoutIfNeeded()
        self.layoutIfNeeded()
        
//        contentLabel.handleURLTap({ url in
//            self.delegate?.textUrlTapped(url.absoluteString)
//        })
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
        let newLine = tempContentLabel.text.contains("\n")
        if (contentLabelSize.width + timeLabelSize.width + 30 > ScreenWidth - 150 || newLine) && (contentLabelSize.height > 30 || newLine)  {
            atBottom = true
        }
        return atBottom
    }
}


