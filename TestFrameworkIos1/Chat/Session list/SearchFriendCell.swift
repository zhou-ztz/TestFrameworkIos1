//
//  SearchFriendCell.swift
//  Yippi
//
//  Created by Khoo on 02/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate

class SearchFriendCell: TSTableViewCell {
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var nameLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
    var statusIcon = UIImageView()
    var screenGroup = UIImageView()
    var currentIndex: Int = 0
    var hidScreenGroup: Bool = true
    var avatarInfo: AvatarInfo!

    var verifiedIcon: String?
    var verifiedType: String?
    var avatar: String?
    
    var userId: String?
    {
        set{
            
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(newValue ?? "")
            
//            nameLabel.text = info.showName == "" ? newValue : info.showName
            
            TSUserNetworkingManager().getUsersInfo(usersId: [], userNames: [newValue ?? ""]) { (userinfoModels, msg, status) in
                if status {
                    if let userinfo = userinfoModels?.first {
                        let avatarInfo = AvatarInfo()
                        avatarInfo.avatarURL = userinfo.avatarUrl ?? ""
                        self.headerButton.avatarInfo = avatarInfo
                    }
                }
            }
            headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
            
        }
        get {
            return self.userId
        }
    }
          
    static let cellReuseIdentifier = "SearchFriendCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        statusIcon.frame = CGRect(x: 63, y: 40, width: 14, height: 14)//UIImageView.init(frame: CGRect.init(x: 63, y: 40, width: 14, height: 14))
        statusIcon.image = UIImage.set_image(named: "msg_box_remind")
        statusIcon.layer.masksToBounds = true
        statusIcon.layer.cornerRadius = 7
        screenGroup.frame = CGRect(x: ScreenWidth - 14 - 15, y: 40, width: 14, height: 14)
        screenGroup.image = UIImage.set_image(named: "ico_newslist_shield")
    }

    private func customUI() {
        headerButton.circleCorner()

        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.navigation.rawValue)
        nameLabel.textColor = TSColor.main.content
        nameLabel.lineBreakMode = .byTruncatingMiddle
        self.selectionStyle = .gray
    }

    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }

    @objc func headerButtonAction() {
        //修改头像点击事件，会话列表页点击头像也是跳转到聊天室，并不是跳到个人主页
        self.delegate?.headButtonDidPress(for: currentIndex)
    }
}

