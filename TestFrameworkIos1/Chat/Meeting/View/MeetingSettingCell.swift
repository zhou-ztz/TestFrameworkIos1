//
//  MeetingSettingCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/7.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MeetingSettingCell: UITableViewCell {
    
    /// 头像
    var avatarImageView: AvatarView!
    /// 昵称
    var nameLabel: UILabel!
    var model: ContactData!
    
    lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hexString: "#F7F8FA")
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .white
        self.setUI()
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUI(){
        self.addSubview(backView)
        backView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(4)
        }
        
        avatarImageView = AvatarView(type: .width38(showBorderLine: false), animation: false)
        backView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.width.equalTo(38)
            make.left.equalTo(28)
        }
        nameLabel = UILabel()
        nameLabel.textColor = UIColor(hex: 0x333333)
        nameLabel.font = UIFont.systemFont(ofSize: 14)
        nameLabel.textAlignment = NSTextAlignment.left
        backView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp_right).offset(15)
            $0.centerY.equalToSuperview()
        }
    }
    
    func setData(model: ContactData){
        self.model = model
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = model.imageUrl
        avatarInfo.verifiedIcon = model.verifiedIcon
        avatarInfo.verifiedType = model.verifiedType
        avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarInfo.type = .normal(userId: model.userId)
        avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
        avatarImageView.avatarInfo = avatarInfo
        if model.isTeam {
            if let team = NIMSDK.shared().teamManager.team(byId: model.userName) {
                nameLabel.text = model.displayname + "(\(team.memberNumber))"
            }
            
        }else{
            // MARK: REMARK NAME
            if model.userId == -1 {
                LocalRemarkName.getRemarkName(userId: nil, username: model.userName, originalName: model.displayname, label: nameLabel)
            } else {
                LocalRemarkName.getRemarkName(userId: String(model.userId), username: nil, originalName: model.displayname, label: nameLabel)
            }
        }
        
    }

}
