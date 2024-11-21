//
//  ChatMemberCell.swift
//  Yippi
//
//  Created by Yong Tze Ling on 07/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage

class ChatMemberCell: UICollectionViewCell, BaseCellProtocol {
    
    @IBOutlet weak var memberImage: UIImageView!
    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var userTypeIcon: UIImageView!
    @IBOutlet weak var memberTypeLabel: UILabel!
    @IBOutlet weak var memberTypeLabelView: UIView!
    var userInfo: TSNIMUserInfo?
    /// 屏幕比例
    @IBOutlet weak var imageBackgroundView: UIView!
    
    let scale = UIScreen.main.scale

    override func awakeFromNib() {
        super.awakeFromNib()
        memberName.textAlignment = NSTextAlignment.center
        memberName.font = UIFont.systemFont(ofSize: 12)
        memberName.textColor = TSColor.normal.minor
        
        memberImage.layer.masksToBounds = true
        memberImage.circleCorner()
        memberImage.layer.borderColor = UIColor.white.cgColor
        memberImage.layer.borderWidth = 2
        memberImage.contentMode = .scaleAspectFit
        
        imageBackgroundView.layer.masksToBounds = true
        imageBackgroundView.circleCorner()
        imageBackgroundView.backgroundColor = .clear
        
        memberTypeLabel.textColor = UIColor.white
        memberTypeLabel.sizeToFit()
        
        memberTypeLabelView.layer.cornerRadius = memberTypeLabel.frame.size.height / 2
        memberTypeLabelView.layer.borderColor = UIColor.white.cgColor
        memberTypeLabelView.layer.borderWidth = 1
        memberTypeLabelView.sizeToFit()
        memberTypeLabelView.makeHidden()

        userTypeIcon.contentMode = .scaleAspectFit
        userTypeIcon.makeVisible()
    }

    func setData(_ member: TeamMember) {
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: member.memberInfo?.userId ?? "")

        if member.isAdd {
            addMemberView()
        } else if member.isReduce {
            removeMemberView()
        } else if member.isViewMore {
            viewMore()
        } else {
            userTypeIcon.makeVisible()
            memberName.alpha = 1

            // MARK: REMARK NAME
            LocalRemarkName.getRemarkName(userId: nil, username: member.memberInfo?.userId ?? "", originalName: avatarInfo.nickname ?? NIMSDKManager.shared.getNimKitInfo(userId: member.memberInfo!.userId ?? "", type: .showName), label: self.memberName)
            
            memberImage.sd_setImage(with: URL(string: avatarInfo.avatarURL.orEmpty),
                                    placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"),
                                    completed: nil)
            userTypeIcon.sd_setImage(with: URL(string: avatarInfo.verifiedIcon))
            
            if let memberinfo = member.memberInfo {
                switch memberinfo.type {
                case .manager:
                    memberTypeLabelView.makeVisible()
                    memberTypeLabel.text = "team_admin".localized
                    memberTypeLabelView.layer.backgroundColor = AppTheme.orange.cgColor
                case .owner:
                    memberTypeLabelView.makeVisible()
                    memberTypeLabel.text = "team_creator".localized
                    memberTypeLabelView.layer.backgroundColor = AppTheme.aquaBlue.cgColor
                default:
                    memberTypeLabelView.makeHidden()
                }
            }
        }
    }
    
    func addMemberView() {
        userTypeIcon.makeHidden()
        memberName.alpha = 0
        memberTypeLabelView.makeHidden()
        memberImage.image = UIImage.set_image(named: "btn_chatdetail_add")
    }
    
    func removeMemberView() {
        userTypeIcon.makeHidden()
        memberName.alpha = 0
        memberTypeLabelView.makeHidden()
        memberImage.image = UIImage.set_image(named: "btn_chatdetail_reduce")
    }
    
    func viewMore() {
        userTypeIcon.makeHidden()
        memberName.alpha = 0
        memberTypeLabelView.makeHidden()
        memberImage.image = UIImage.set_image(named: "btn_chatdetail_more")
    }
}
