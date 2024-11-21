//
//  StickerCardMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 08/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import ActiveLabel
import SDWebImage

class StickerCardMessageContentView: BaseContentView {
    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    
    lazy var stickerImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "default_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x4A5553)
        label.text = "rw_yippi_sticker".localized
        label.numberOfLines = 1
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = leftSeparatorColor
        return view
    }()
    
    lazy var stickerNameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    lazy var stickerDescLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultNicknameSmallFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 2
        return label
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
        
        let textStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 2
        }
        textStackView.addArrangedSubview(stickerNameLabel)
        textStackView.addArrangedSubview(stickerDescLabel)
        
        let imageNameStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        imageNameStackView.addArrangedSubview(stickerImage)
        imageNameStackView.addArrangedSubview(textStackView)

        let typeTimeStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        typeTimeStackView.addArrangedSubview(typeLabel)
        typeTimeStackView.addArrangedSubview(timeTickStackView)
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .center
        }
        wholeStackView.addArrangedSubview(imageNameStackView)
        wholeStackView.addArrangedSubview(separatorView)
        wholeStackView.addArrangedSubview(typeTimeStackView)
        
        separatorView.backgroundColor = showLeft ? leftSeparatorColor : rightSeparatorColor
        stickerImage.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        separatorView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
        }
        imageNameStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
        }
        typeTimeStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
        }
        self.addSubview(wholeStackView)
        wholeStackView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 9:0)
            make.right.equalToSuperview().offset(showLeft ? -0:-9)
        }
    }
    
    func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMStickerCardAttachment
        
        self.stickerImage.sd_setImage(with: URL(string: attachment.bundleIcon), completed: nil)
        self.stickerNameLabel.text = attachment.bundleName
        self.stickerDescLabel.text = attachment.bundleDescription
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.stickerCardTapped(self.model)
    }
}
