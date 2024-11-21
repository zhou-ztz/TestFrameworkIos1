//
//  ContactMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 10/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import ActiveLabel
import NIMSDK
class ContactMessageContentView: BaseContentView {
    let leftSeparatorColor = UIColor(red: 216.0/255.0, green: 216.0/255.0, blue: 216.0/255.0, alpha: 1)
    let rightSeparatorColor = UIColor(hex: 0xD9D9D9)//UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1)
    
    lazy var profileView: AvatarView = {
        let view = AvatarView(type: .custom(avatarWidth: 50, showBorderLine: false))
        let avatar = AvatarInfo()
        avatar.avatarPlaceholderType = .unknown
        view.avatarInfo = avatar
        return view
    }()
    let buttonForVerified = UIButton(type: .custom)
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = UIColor(hex: 0x4A5553)
        label.text = "Contact"
        label.numberOfLines = 1
        return label
    }()
    
    lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = leftSeparatorColor
        return view
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 1
        return label
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming
        
        let imageNameStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
        }
        imageNameStackView.addArrangedSubview(profileView)
        imageNameStackView.addArrangedSubview(nameLabel)
        
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
        
        profileView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
        }
        profileView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        profileView.buttonForAvatar.layer.cornerRadius = 25
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
            make.left.equalToSuperview().offset(showLeft ? 20:10)
            make.right.equalToSuperview().offset(showLeft ? -8:-18)
        }
    }
    
    func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMContactCardAttachment
        let memberId = attachment.memberId
        
        let avatarIcon = NIMSDKManager.shared.getAvatarIcon(userId: memberId)
        let avatarinfo = AvatarInfo()
        
        // By Kit Foong (Added Task Group to wait get user info finish task)
        let group = DispatchGroup()
        group.enter()
        
        if avatarIcon.avatarURL?.isEmpty == false {
            avatarinfo.avatarURL = avatarIcon.avatarURL
            group.leave()
        } else {
            // By Kit Foong (Added get user info api when avatar url is empty)
            DispatchQueue.main.async {
                TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [memberId]) { [weak self] (results, msg, status) in
                    guard status else {
                        avatarinfo.avatarURL = ""
                        group.leave()
                        return
                    }
                    
                    if let model = results?.first {
                        avatarinfo.avatarURL = model.avatarUrl ?? ""
                        avatarinfo.verifiedIcon =  model.verificationIcon ?? ""
                        avatarinfo.verifiedType = model.verificationType ?? ""
                    } else {
                        avatarinfo.avatarURL = ""
                    }
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) {
            if avatarinfo.verifiedIcon.isEmpty {
                avatarinfo.verifiedIcon = avatarIcon.verifiedIcon
            }
            
            if avatarinfo.verifiedType.isEmpty {
                avatarinfo.verifiedType = avatarIcon.verifiedType
            }

            self.profileView.avatarInfo = avatarinfo
            
            // By Kit Foong (Use memberId when the nickname is nil)
            let userName = avatarIcon.nickname ?? memberId
            
            LocalRemarkName.getRemarkName(userId: nil, username: NIMSDKManager.shared.getNimKitInfo(userId: memberId), originalName: userName, label: self.nameLabel)
            if userName == nil {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                    self.showHeaderImage(memberId: memberId)
                }
            }
        }
    }
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.contactCardTapped(self.model)
    }
    
    //TODO: 头像及名字不显示问题临时解决方法 ，多调用一次
    func showHeaderImage(memberId: String) {
        let avatarinfo = NIMSDKManager.shared.getAvatarIcon(userId: memberId)
        self.profileView.avatarInfo = avatarinfo
                
        LocalRemarkName.getRemarkName(userId: nil, username: NIMSDKManager.shared.getNimKitInfo(userId: memberId), originalName: avatarinfo.nickname ?? memberId, label: self.nameLabel)
    }
}
