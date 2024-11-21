//
//  ContactTableViewCell.swift
//  Yippi
//
//  Created by Kit Foong on 14/06/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class NewContactTableViewCell: UITableViewCell {
    static let cellReuseIdentifier = "NewContactTableViewCell"
    
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var onClickAction: EmptyClosure?
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        selectionStyle = .none
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
    }
    
    // MARK: - Public
    func setInfo(model: UserInfoModel) {
        // 头像
        avatarView.avatarInfo = model.avatarInfo()
        // 用户名
        LocalRemarkName.getRemarkName(userId: "\(model.userIdentity)", username: nil, originalName: model.name, label: usernameLabel)
        
        actionButton.layer.borderWidth = 2
        actionButton.layer.borderColor = AppTheme.red.cgColor
        actionButton.roundCorner(5)
        actionButton.setTitleColor(AppTheme.red)
        messageButton.setTitle("")
        
        // 邀请按钮
        if model.relationshipWithCurrentUser?.texts.localizedString != nil {
            guard let relationship = model.relationshipWithCurrentUser else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            switch relationship.status {
            case .eachOther:
                messageButton.makeVisible()
                actionButton.makeHidden()
                break
            case .follow:
                messageButton.makeHidden()
                actionButton.makeVisible()
                actionButton.setTitle("followed".localized)
                break
            case .unfollow:
                messageButton.makeHidden()
                actionButton.makeVisible()
                actionButton.setTitle("display_follow".localized)
                break
            default:
                messageButton.makeHidden()
                actionButton.makeHidden()
                break
            }
        } else {
            messageButton.makeHidden()
            actionButton.makeHidden()
        }
    }
    
    func setContactInfo(model: ContactModel) {
        // 头像
        avatarView.avatarInfo = AvatarInfo()
        let avatarImage = model.avatar == nil ? UIImage.set_image(named: "IMG_pic_default_secret")! : model.avatar!
        avatarView.buttonForAvatar.setImage(avatarImage, for: .normal)
        // 用户名
        usernameLabel.text = model.name
        // 邀请按钮
        messageButton.makeHidden()
        actionButton.makeVisible()
        
        actionButton.layer.borderWidth = 2
        actionButton.layer.borderColor = AppTheme.red.cgColor
        actionButton.roundCorner(5)
        actionButton.setTitleColor(AppTheme.red)
        actionButton.setTitle("invite".localized)
    }
    
    func setContactData(model: ContactData) {
        // 邀请按钮
        messageButton.makeHidden()
        actionButton.makeHidden()
        avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.userName)
        
        // MARK: REMARK NAME
        if model.userId == -1 {
            LocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: usernameLabel)
        } else {
            LocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: usernameLabel)
        }
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        self.onClickAction?()
    }
    
    @IBAction func messageAction(_ sender: Any) {
        self.onClickAction?()
    }
}
