//
//  ContactPickerCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 27/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


protocol ContactPickerCellDelegate: class {
    func chatButtonClick(chatbutton: UIButton, userModel: ContactData)
}

class ContactPickerCell: TSChatChooseFriendCell {
    
    weak var pickerDelegate: ContactPickerCellDelegate?
    var blurCover = UIView()
    var contactData: ContactData? {
        didSet {
            guard let model = contactData else { return }
            
            let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.userName, isTeam: model.isTeam)
            avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
            avatarInfo.type = .normal(userId: model.userId)
            avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
            avatarImageView.avatarInfo = avatarInfo
            
            if model.userName == "rw_text_all_people".localized {
                avatarImageView.avatarPlaceholderType = .unknown
                avatarImageView.avatarInfo = AvatarInfo()
            }
            
            if model.isTeam {
                nameLabel.text = model.displayname
            } else {
                // MARK: REMARK NAME
                if model.userId == -1 {
                    LocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: nameLabel)
                } else {
                    LocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: nameLabel)
                }
                
                if (nameLabel.text ?? "").isEmpty {
                    nameLabel.text = model.userName
                }
            }
            
            chatButton.isSelected = false
            chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
            if model.isBannedUser {
                blurCover.backgroundColor = UIColor.white.withAlphaComponent(0.7)
                addSubview(blurCover)
                blurCover.snp_makeConstraints { (make) in
                    make.edges.equalToSuperview()
                }
            }
            for (_, element) in currentChooseArray.enumerated() {
                let userinfo: ContactData = element as! ContactData
                if userinfo.userName == model.userName {
                    chatButton.isSelected = true
                    break
                }
            }
            
            for (_, origin) in originData.enumerated() {
                let userinfo: String = origin as! String
                if userinfo == model.userName {
                    chatButton.isSelected = true
                    chatButton.setImage(UIImage.set_image(named: "msg_box_choose_before"), for: UIControl.State.selected)
                    break
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        blurCover.backgroundColor = UIColor.clear
    }
    
    override func changeButtonStatus() {
        guard let data = contactData else { return }
        pickerDelegate?.chatButtonClick(chatbutton: chatButton, userModel: data)
    }
}

class ContactPickerHeaderButton: UIButton {
    
    var contact: ContactData?
}
