//
//  TranslateMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 02/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel

class TranslateMessageContentView: BaseContentView {
    
    let rightBackgroundImg = UIImage.set_image(named: "rightTranslate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
    let leftBackgroundImg = UIImage.set_image(named: "leftTranslate")?.resizableImage(withCapInsets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), resizingMode: .stretch)
    
    lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = leftBackgroundImg
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named: "yippitranslate")
        return imageView
    }()
    
    lazy var yippiLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(10)
        label.textColor = .darkGray
        label.text = "text_translate".localized
        label.numberOfLines = 1
        return label
    }()
    
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultFontSize)
        label.textColor = .darkGray
        label.text = "translate"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 4
            stack.distribution = .fill
            stack.alignment = .leading
        }
        return stackView
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
        
        let message = messageModel.nimMessageModel!
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMTextTranslateAttachment
        textLabel.text = attachment.translatedText
        
        let showLeft = !attachment.isOutgoingMsg
        self.backgroundImageView.image = showLeft ? leftBackgroundImg : rightBackgroundImg

        let bottomStack = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 4
        }
        bottomStack.addArrangedSubview(imageView)
        bottomStack.addArrangedSubview(yippiLabel)

        contentStackView.addArrangedSubview(textLabel)
        contentStackView.addArrangedSubview(bottomStack)
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(contentStackView)
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }
        self.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 18:10)
            make.right.equalToSuperview().offset(showLeft ? -10:-18)
        }
        
        self.bubbleImage.isHidden = true
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.retryTextTranslate(self.model)
    }
}
