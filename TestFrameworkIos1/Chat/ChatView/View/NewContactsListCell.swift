//
//  NewContactsListCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/4/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

protocol NewContactsListCellCellDelegate: class {
    func chatButtonClick(chatbutton: UIButton, userModel: ContactData)
}

class NewContactsListCell: UITableViewCell {

    weak var friendsListDelegate: NewContactsListCellCellDelegate?
    /// 头像
    var avatarImageView: AvatarView! = AvatarView(type: .width38(showBorderLine: false), animation: false)
    /// 昵称
    var nameLabel: UILabel!
    /// 聊天按钮
    var chatButton: UIButton!
    
    var userInfo: UserInfoModel? = nil
    var currentChooseArray: [ContactData] = []
    var originData = NSMutableArray()
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 15
        $0.distribution = .fill
        $0.alignment = .center
    }
    
    var contactData: ContactData? {
        didSet {
            guard let model = contactData else { return }

            let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.userName)
            avatarInfo.avatarPlaceholderType = model.isTeam ? .group : .unknown
            avatarInfo.type = .normal(userId: model.userId)
            avatarImageView.avatarPlaceholderType = model.isTeam ? .group : .unknown
            avatarImageView.avatarInfo = avatarInfo
            
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


            for (_, element) in currentChooseArray.enumerated() {
                let userinfo: ContactData = element as! ContactData
                if userinfo.userName == model.userName {
                    chatButton.isSelected = true
                    chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
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
    
    var team: NIMTeam? {
        didSet {
            guard let model = team else { return }
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = model.avatarUrl
            
            avatarInfo.avatarPlaceholderType =  .group

            avatarImageView.avatarPlaceholderType =  .group
            avatarImageView.avatarInfo = avatarInfo
           
            nameLabel.text = model.teamName ?? ""
            chatButton.isSelected = false

            for (_, element) in currentChooseArray.enumerated() {
                let userinfo: ContactData = element as! ContactData
                if userinfo.userName == model.teamId {
                    chatButton.isSelected = true
                    chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
                    break
                }
            }
        }
    }
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        creatSubView()
    }

    func creatSubView() {
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.bottom.right.equalTo(0)
            make.left.equalTo(18)
            
        }
        chatButton = UIButton()

        chatButton.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: UIControl.State.selected)
        chatButton.setImage(UIImage.set_image(named: "icon_accessory_normal"), for: .normal)//
        chatButton.addTarget(self, action: #selector(changeButtonStatus), for: UIControl.Event.touchUpInside)
        stackView.addArrangedSubview(chatButton)
        chatButton.snp.makeConstraints { make in
            make.height.width.equalTo(18)

        }

        chatButton.isSelected = false

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

    
    @objc func changeButtonStatus() {
        guard let data = contactData else { return }
        friendsListDelegate?.chatButtonClick(chatbutton: chatButton, userModel: data)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
