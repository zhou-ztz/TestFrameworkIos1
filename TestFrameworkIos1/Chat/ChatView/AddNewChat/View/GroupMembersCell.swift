//
//  GroupMembersCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


class GroupMembersCell: UITableViewCell {
    /// 头像
    var avatarImageView: AvatarView! = AvatarView(type: .width38(showBorderLine: false), animation: false)
    /// 昵称
    var nameLabel: UILabel!
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 15
        $0.distribution = .fill
        $0.alignment = .center
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatSubView() {
        let bview = UIView()
        bview.backgroundColor =  UIColor(hex: 0xF7F8FA)
        bview.layer.cornerRadius = 10
        bview.clipsToBounds = true
        self.addSubview(bview)
        bview.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(0)
            make.right.equalTo(-15)
            make.bottom.equalTo(-8)
        }
        bview.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(0)
            make.left.equalTo(25)
            
        }
        
        stackView.addArrangedSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.width.height.equalTo(38)
        }
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textAlignment = NSTextAlignment.left
        
        stackView.addArrangedSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.right.equalTo(0)
        }
    }

    func setData(model: ContactData){
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.imageUrl
        avatarInfo.verifiedIcon = model.verifiedIcon
        avatarInfo.verifiedType = model.verifiedType
        avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarInfo.type = .normal(userId: model.userId)
        avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarImageView.avatarInfo = avatarInfo
        // MARK: REMARK NAME
        if model.userId == -1 {
            LocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: nameLabel)
        } else {
            LocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: nameLabel)
        }
        
    }
}
