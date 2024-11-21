//
//  MiniProgramMessageContentView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/15.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MiniProgramMessageContentView: BaseContentView {
    lazy var iconImage: UIImageView = {
        let iconImage = UIImageView()
        iconImage.contentMode = .scaleAspectFit
        iconImage.backgroundColor = .white
        return iconImage
    }()
    
    lazy var descriptionLabel: UILabel = {
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: FontSize.defaultLocationDefaultFontSize)
//        descriptionLabel.aut = true
        descriptionLabel.textColor = .gray
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.numberOfLines = 2
        descriptionLabel.backgroundColor = .clear
        return descriptionLabel
    }()
    
    lazy var tLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: FontSize.defaultTextFontSize, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        return titleLabel
    }()
    
    var tapRecognizer: UITapGestureRecognizer!
    
    lazy var activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .gray)
        activityView.hidesWhenStopped = true
        activityView.startAnimating()
        return activityView
    }()
    
    lazy var background: UIView = {
        let background = UIView()
        background.layer.masksToBounds = true
        background.backgroundColor = .white
        background.layer.borderColor = UIColor(hex: 0xaee0ff).cgColor
        background.layer.borderWidth = 1
        return background
    }()
    
    var socialShareContent: UIStackView!
    var shareDescContent: UIStackView!
    var imageCacheShare: UIImage!
    var customObject: NIMCustomObject!
    var attachment: IMMiniProgramAttachment!
    
    lazy var contentStackView: UIStackView = {
        let contentStackView = UIStackView()
        contentStackView.axis = .vertical
        //contentStackView.distribution = .fill
        contentStackView.alignment = .leading;
        contentStackView.spacing = 3
        contentStackView.addArrangedSubview(self.tLabel)
        contentStackView.addArrangedSubview(self.descriptionLabel)
        return contentStackView
    }()
    
    lazy var mpTextLabel: UILabel = {
        let mpTextLabel = UILabel()
        mpTextLabel.lineBreakMode = .byTruncatingTail
        mpTextLabel.numberOfLines = 1
        mpTextLabel.textColor = AppTheme.blue
        mpTextLabel.font = UIFont.systemFont(ofSize: 14)
        let image = NSTextAttachment()
        image.image =  UIImage.set_image(named: "ic_chat_mini_program")
        image.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        let imageStr = NSAttributedString(attachment: image)
        let fullStr = NSMutableAttributedString(string: "view_mini_program".localized)
        fullStr.insert(imageStr, at: 0)
        fullStr.insert(NSAttributedString(string: " "), at: 1)
        mpTextLabel.attributedText = fullStr
        return mpTextLabel
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        self.addSubview(self.background)
        self.background.addSubview(self.iconImage)
        self.background.addSubview(self.mpTextLabel)
        self.background.addSubview(self.contentStackView)
        self.addSubview(self.activityView)

        self.background.layer.masksToBounds = true
        self.background.layer.cornerRadius = 10
        
        self.addSubview(timeTickStackView)
        self.iconImage.isHidden = false
        self.descriptionLabel.isHidden = true
        guard let object = messageModel.nimMessageModel?.messageObject as? NIMCustomObject , let attach = object.attachment as? IMMiniProgramAttachment else {
            return
        }
        customObject = object
        attachment = attach
        
        if !self.isDescNil() {
            self.descriptionLabel.isHidden = false
        }
        
        if self.isMP() {
            self.descriptionLabel.isHidden = false
            self.tLabel.isHidden = false
            self.iconImage.isHidden = false
        }
        
        DispatchQueue.global().async {
            if let localExt = messageModel.nimMessageModel?.localExt as? [String: String] {
                self.updateUI(title: localExt["title"]!, image: localExt["image"]!, desc: localExt["description"]!)
            } else {
                self.updateUI(title: self.attachment.title, image: self.attachment.imageURL, desc: self.attachment.desc)
            }
        }

        background.backgroundColor = .white
        background.layer.borderColor = (messageModel.nimMessageModel?.isOutgoingMsg)! ? UIColor(hex: 0xaee0ff).cgColor : UIColor(hex: 0xeaeaea).cgColor
        background.layer.masksToBounds = true
        background.layer.cornerRadius = 10
        self.tLabel.sizeToFit()
       
        self.iconImage.snp.makeConstraints { (make) in
            make.leading.equalTo(0).offset(6)
            make.top.equalTo(0).offset(6)
            make.width.height.equalTo(60)
        }
        self.iconImage.layer.masksToBounds = true
        self.iconImage.layer.cornerRadius = 15
        self.iconImage.clipsToBounds = false

        self.descriptionLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(34)
        }
        self.descriptionLabel.numberOfLines = 2;
        self.descriptionLabel.sizeToFit()

        self.tLabel.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.height.equalTo(17)
        }

        self.contentStackView.snp.makeConstraints { (make) in
            make.top.equalTo(6)
            make.left.equalTo(72)
            make.height.equalTo(60)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        self.mpTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.iconImage.snp_bottomMargin).offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(17)
            make.trailing.equalToSuperview()
            make.left.equalTo(6)
        }
        
        self.activityView.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.iconImage.snp_centerXWithinMargins)
            make.centerY.equalTo(self.iconImage.snp_centerYWithinMargins)
        }
        
        self.background.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            let isgo = messageModel.nimMessageModel?.isOutgoingMsg
            make.left.equalToSuperview().offset(isgo ?? false ?  5 :  14)
            make.right.equalToSuperview().offset(isgo ?? false ?  -14 :  -5)
            make.bottom.equalToSuperview().offset( -22)
            make.width.equalTo(230)
        }
        self.timeTickStackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-2)
            make.height.equalTo(20)
            make.right.equalToSuperview().offset(-16)
        }
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchUpInside))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    func updateUI(title: String, image: String, desc: String) {
        DispatchQueue.main.async {
            self.iconImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "default_image"))
            self.tLabel.text = title
            self.descriptionLabel.text = desc
            self.activityView.stopAnimating()
        }
    }
    
    func isDescNil() -> Bool {
        if self.attachment.desc == "" {
            return true
        } else {
            return false
        }
    }

    func isMP() -> Bool {
        if self.attachment.desc.isEmpty && self.attachment.imageURL.isEmpty && self.attachment.title.isEmpty {
            return true
        }
        return false
    }
    
    @objc func onTouchUpInside(){
        guard let attachment = self.attachment else {
            return
        }
        if attachment.isKind(of: IMMiniProgramAttachment.self) {
            self.delegate?.MiniProgramMessageTapped(model)
        }
    }
}
