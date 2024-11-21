//
//  CallDetailHeaderTableViewCell.swift
//  Yippi
//
//  Created by Wong Jin Lun on 28/03/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class CallDetailHeaderTableViewCell: UITableViewCell, BaseCellProtocol {

    @IBOutlet weak var yippiIdLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var avatarImageView: AvatarView!
    var _username: String = ""
    var username: String {
        set {
            let _username = newValue
            let nick = SessionUtil.showNick(_username, in: nil)
            self.usernameLabel.text = nick
            
            self.avatarImageView.avatarPlaceholderType = .unknown
            self.avatarImageView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: _username)
        }
        
        get {
            return _username
        }
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.font = AppTheme.Font.semibold(18)
        yippiIdLabel.font = AppTheme.Font.regular(12)
        yippiIdLabel.textColor = .gray
        
        self.usernameLabel.text = username
    }
    
    func setUserInfo(userId: Int, groupType: String) {
        self.yippiIdLabel.text = String(format: "Yippi ID: %d", userId)
        
        if groupType == "group" {
            let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: String(userId ?? 0) ?? "", isTeam: true)
            self.avatarImageView.avatarInfo = avatarInfo
            self.usernameLabel.text = avatarInfo.nickname
        }
    }
}
