//
//  TSMyFriendListCell.swift
//  ThinkSNS +
//
//  Created by 刘邦海 on 2017/12/25.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

protocol TSMyFriendListCellDelegate: class {
    func chatWithUserName(userName: String)
}

class TSMyFriendListCell: UITableViewCell {

    weak var delegate: TSMyFriendListCellDelegate?
    /// 头像
    var avatarImageView: AvatarView!
    /// 昵称
    var nameLabel: UILabel!
    /// 简介
    var introLabel: UILabel!
    /// 聊天按钮
    var chatButton: UIButton!
    var chatUserName: String = ""

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.creatSubView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func creatSubView() {
        avatarImageView = AvatarView(origin: CGPoint(x: 10, y: 15), type: .width38(showBorderLine: false), animation: false)
        self.addSubview(avatarImageView)

        nameLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: 15, width: ScreenWidth - avatarImageView.right - 15, height: 17.5))
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.textAlignment = NSTextAlignment.left
        self.addSubview(nameLabel)
        chatButton = UIButton(frame: CGRect(x: ScreenWidth - 45, y: 0, width: 45, height: 70))
        chatButton.setTitle(nil, for: .normal)
        chatButton.setImage(UIImage.set_image(named: "ico_chat"), for: .normal)
        chatButton.addTarget(self, action: #selector(chatButtonClick(button:)), for: UIControl.Event.touchUpInside)
        self.addSubview(chatButton)
        let width = ScreenWidth - avatarImageView.right - 90 // - (15 - 65 - 10)
        introLabel = UILabel(frame: CGRect(x: avatarImageView.right + 15, y: nameLabel.bottom + 7.5, width: width, height: 14))
        introLabel.font = UIFont.systemFont(ofSize: 14)
        introLabel.textColor = UIColor(hex: 0x999999)
        introLabel.textAlignment = NSTextAlignment.left
        self.addSubview(introLabel)

        let lineView = UIView(frame: CGRect(x: 0, y: 67, width: ScreenWidth, height: 0.5))
        lineView.backgroundColor = UIColor(hex: 0xededed)
        self.addSubview(lineView)
    }

    func setUserInfoData(model: UserInfoModel) {
        avatarImageView.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
        avatarImageView.avatarInfo = model.avatarInfo()
        // 用户名
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(model.userIdentity)", username: nil, originalName: model.name, label: nameLabel)

        // 简介
        introLabel.text = model.shortDesc
        chatUserName = model.username
    }

    @objc func chatButtonClick(button: UIButton) {
        delegate?.chatWithUserName(userName: chatUserName)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
