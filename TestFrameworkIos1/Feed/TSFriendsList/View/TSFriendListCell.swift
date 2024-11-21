//
//  TSFriendListCell.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSFriendListCellDelegate: class {
    func cell(userId: Int, chatName: String)
}

class TSFriendListCell: UITableViewCell {

    static let identifier = "TSFriendListCell"

    weak var delegate: TSFriendListCellDelegate?

    var userIdString: Int? = 0
    var chatUserName: String? = ""

    /// 头像
    @IBOutlet weak var buttonForAvatar: AvatarView!
    /// 关注按钮
    @IBOutlet weak var buttonForFollow: UIButton!
    /// 用户名
    @IBOutlet weak var labelForName: UILabel!
    /// 简介
    @IBOutlet weak var labelForIntro: UILabel!

    // MARK: - Public
    func setInfo(model: UserInfoModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
    
        buttonForAvatar.avatarInfo = model.avatarInfo()
        buttonForFollow.setImage(UIImage.set_image(named: "ico_chat"), for: .normal)

        labelForName.text = model.name
        labelForIntro.text = model.shortDesc
        userIdString = model.userIdentity
        chatUserName = model.name
    }

    // MARK: - IBAction

    /// 点击了关注按钮
    @IBAction func followButtonTaped() {
        delegate?.cell(userId: userIdString!, chatName: chatUserName!)
    }
}
