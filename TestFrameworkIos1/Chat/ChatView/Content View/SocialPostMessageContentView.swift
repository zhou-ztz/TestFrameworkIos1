//
//  SocialPostMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 10/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel
import SDWebImage

class SocialPostMessageContentView: BaseContentView {
    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.image = UIImage.set_image(named: "default_image")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var playImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ico_video_play_list")
        return view
    }()
    
    lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var liveLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTextFontSize)
        label.textColor = .white
        label.backgroundColor = .red
        label.text = "text_live".localized
        label.numberOfLines = 1
        label.textAlignment = .left
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var dataView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0, weight: .semibold)
        label.textColor = UIColor(hex: 0x242424)
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        return label
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10.0, weight: .regular)
        label.textColor = UIColor(hex: 0x808080)
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    lazy var contentLabel: ActiveLabel = {
        let infoLbl = ActiveLabel()
        infoLbl.font = AppTheme.Font.regular(FontSize.defaultFontSize)
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 0
        infoLbl.enabledTypes = [.mention, .hashtag, .url]
        return infoLbl
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.roundCorner(10)
        return view
    }()

    var attachment: IMSocialPostAttachment!
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        dataSetup(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        liveLabel.sizeToFit()
        
        dataView.addSubview(displayImage)
        dataView.addSubview(loadingView)
        dataView.addSubview(playImage)
        dataView.addSubview(liveLabel)
        
        displayImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        playImage.snp.makeConstraints { make in
            make.width.height.equalTo(42)
            make.center.equalToSuperview()
        }
        
        liveLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(5)
            make.width.equalTo(liveLabel.width + 8)
        }
            
        let labelView = UIView()
        labelView.addSubview(titleLabel)
        labelView.addSubview(infoLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }

        let socialPostStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 5
        }
        socialPostStackView.addArrangedSubview(dataView)
        socialPostStackView.addArrangedSubview(labelView)
        
        dataView.snp.makeConstraints { make in
            make.width.equalTo(119)
            make.height.equalTo(86)
        }
        
        labelView.snp.makeConstraints { make in
            make.width.equalTo(131)
            make.height.equalTo(86)
        }
        
        backgroundView.addSubview(socialPostStackView)
        
        backgroundView.backgroundColor = showLeft ? UIColor(hex: 0xf9f9f9) : UIColor(hex: 0xeef8ff)
        backgroundView.applyBorder(color: showLeft ? UIColor(hex: 0xeaeaea) : UIColor(hex: 0xaee0ff), width: 1)
        labelView.backgroundColor = showLeft ? UIColor(hex: 0xf9f9f9) : UIColor(hex: 0xeef8ff)
        
        socialPostStackView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.alignment = .trailing
        }
        
        self.addSubview(wholeStackView)
        wholeStackView.addArrangedSubview(backgroundView)
        wholeStackView.addArrangedSubview(contentLabel)
        wholeStackView.addArrangedSubview(timeTickStackView)
        
        wholeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 14:5)
            make.right.equalToSuperview().offset(showLeft ? -5:-14)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(backgroundView.snp.bottom).offset(10)
            make.height.greaterThanOrEqualTo(24)
        }
        
        contentLabel.layoutIfNeeded()
        self.layoutIfNeeded()
    }
    
    private func dataSetup(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        attachment = object.attachment as? IMSocialPostAttachment
        
        self.loadingView.startAnimating()
        displayImage.isHidden = !self.needShowImage()
        liveLabel.isHidden = !self.isLiveVideo()
        playImage.isHidden = !self.isVideo()
        infoLabel.isHidden = self.isDescNil()

        if isMetaData() {
            infoLabel.isHidden = false
            titleLabel.isHidden = false
            displayImage.isHidden = false
        }
        
        titleLabel.text = attachment.postUrl
        if let localExt = message.localExt, let title = localExt["title"] as? String, let desc = localExt["description"] as? String, let image = localExt["image"] as? String {
            self.updateUI(image: image, title: attachment.postUrl, desc: desc)
        } else {
            if attachment.imageURL != "" || attachment.title != "" || attachment.desc != "" {
                guard let decodedUrl = attachment.postUrl.removingPercentEncoding else {
                    return
                }
                
                HTMLManager.shared.removeHtmlTag(htmlString: attachment.desc, completion: { [weak self] (content, _) in
                    guard let self = self else { return }
                    self.updateUIWithContent(image: attachment.imageURL, title: attachment.title, desc: content, content:decodedUrl)
                })
            } else {
                URLParser.parse(attachment.postUrl, completion: { title, description, imageUrl in
                    DispatchQueue.main.async {
                        self.updateUI(image: imageUrl, title: self.attachment.postUrl, desc: description)
                        let msg = message
                        msg.localExt = ["title":title,
                                        "description":description,
                                        "image":imageUrl]
                        
                        NIMSDK.shared().conversationManager.update(msg, for: msg.session!, completion: nil)
                    }
                })
            }
        }
    }
    
    private func updateUI(image: String, title: String, desc: String) {
        self.displayImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "default_image"), completed: nil)
        self.titleLabel.text = title
        self.infoLabel.text = desc
        self.contentLabel.isHidden = true
        self.loadingView.stopAnimating()
    }
    
    private func updateUIWithContent(image: String, title: String, desc: String, content: String) {
        self.displayImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage.set_image(named: "default_image"), completed: nil)
        self.titleLabel.text = title
        self.infoLabel.text = desc
        self.contentLabel.isHidden = false
        self.contentLabel.text = content
        self.loadingView.stopAnimating()
    }
    
    private func isLiveVideo() -> Bool {
        if attachment.contentType == "live" {
            return true
        } else {
            return false
        }
    }

    private func isDescNil() -> Bool {
        if (attachment.desc == "") && attachment.postUrl.lowercased().contains("yippi") {
            return true
        } else {
            return false
        }
    }
    
    private func needShowImage() -> Bool {
        if attachment.postUrl.lowercased().contains("yippi") && (attachment.imageURL == "") {
            return false
        } else {
            return true
        }
    }

    private func isMetaData() -> Bool {
        if (attachment.title == "") && (attachment.desc == "") && (attachment.imageURL == "") {
            return true
        } else {
            return false
        }
    }

    private func isVideo() -> Bool {
        if attachment.contentType == "dynamic_video" {
            return true
        } else {
            return false
        }
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.socialPostTapped(self.model)
    }
}

