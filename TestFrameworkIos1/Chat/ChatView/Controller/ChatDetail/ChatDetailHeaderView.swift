// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SDWebImage
import NIMSDK
class ChatDetailHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var container: UIView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    var inviteHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = AppTheme.white
        self.inviteButton.setImage(UIImage.set_image(named: "btn_chatdetail_add"), for: .normal)

        self.avatar.circleCorner()
        self.avatar.clipsToBounds = true
        self.avatar.isUserInteractionEnabled = true
        self.avatar.image = UIImage.set_image(named: "IMG_pic_default_secret")
        
        self.verifiedIcon.contentMode = .scaleAspectFit
        self.verifiedIcon.makeVisible()

        self.userName.font = UIFont.systemFont(ofSize: 13)
        self.userName.textColor = AppTheme.darkGrey
        self.userName.textAlignment = .center
    }

    func configure(session: NIMSession) {
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: session.sessionId)
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: session.sessionId, username: nil, originalName: avatarInfo.nickname, label: self.userName)

        if !avatarInfo.verifiedIcon.isEmpty {
            self.verifiedIcon.sd_setImage(with: URL(string: avatarInfo.verifiedIcon), completed: nil)
        }
        
        self.avatar.sd_setImage(with: URL(string: avatarInfo.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"), context: [.storeCacheType : SDImageCacheType.memory.rawValue])
    }
    
    @IBAction func inviteButtonDidTapped(_ sender: Any) {
        self.inviteHandler?()
    }
}
