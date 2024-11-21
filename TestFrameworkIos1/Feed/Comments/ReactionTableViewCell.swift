//
//  ReactionTableViewCell.swift
//  Yippi
//
//  Created by Francis Yeap on 02/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class ReactionTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var reactionImageView: UIImageView!
    
    private let avatarView = AvatarView(origin: .zero, type: .custom(avatarWidth: 31, showBorderLine: false), isFromReactionList: true)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        avatar.removeAllSubviews()
        avatar.addSubview(avatarView)
        avatarView.bindToEdges()
    }

    func setAvatar(urlPath: String, username: String, verifiedIcon: String?, userId: Int) {
        let avatarInfo = AvatarInfo(avatarURL: urlPath, verifiedInfo: nil)
        avatarInfo.verifiedIcon = verifiedIcon.orEmpty
        avatarInfo.verifiedType = "badge"
        avatarInfo.type = .normal(userId: userId)
        avatarView.avatarInfo = avatarInfo
    }
    
    func prepareUI(with theme: Theme) {
        self.captionLabel.textColor = AppTheme.brownGrey

        switch theme {
        case .white:
            self.nameLabel.textColor = .black
            self.contentView.backgroundColor = UIColor.white

        case .dark:
            self.nameLabel.textColor = .white
            self.contentView.backgroundColor = AppTheme.materialBlack
        }
    }
    
}
