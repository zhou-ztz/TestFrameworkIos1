//
//  MeetNewUserInfoTipsCell.swift
//  Yippi
//
//  Created by Tinnolab on 19/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit


class MeetNewUserInfoTipsCell: UITableViewCell, BaseCellProtocol {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatarView: AvatarView!
    @IBOutlet weak var infoBackgroundView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    
    var showUserProfile: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.font = UIFont.systemFont(ofSize: 14.0)
        usernameLabel.textColor = UIColor(red: 102, green: 102, blue: 102)
        usernameLabel.text = "meet_user_congrat_tip".localized
        usernameLabel.textAlignment = .center
        usernameLabel.numberOfLines = 2
        
        
        infoBackgroundView.backgroundColor = UIColor(red: 249, green: 249, blue: 249)
        infoBackgroundView.layer.masksToBounds = true
        infoBackgroundView.layer.cornerRadius = infoBackgroundView.height/2.5
        infoBackgroundView.layer.borderWidth = 1
        infoBackgroundView.layer.borderColor = UIColor(red: 235, green: 235, blue: 235).cgColor
        
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        infoLabel.textColor = AppTheme.brownGrey
        infoLabel.text = "meet_user_unsure_what_tip".localized
    }
    
    func updateData(userId: String, userInfo: AvatarInfo) {
        userAvatarView.avatarInfo = userInfo
        self.userAvatarView.buttonForAvatar.addAction { [weak self] in
            self?.showUserProfile?(userId)
        }
    }
}
