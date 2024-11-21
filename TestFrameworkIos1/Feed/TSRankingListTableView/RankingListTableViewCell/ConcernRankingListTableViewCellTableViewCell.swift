//
//  ConcernRankingListTableViewCellTableViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  个人中心关注列表

import UIKit

class ConcernRankingListTableViewCellTableViewCell: AbstractRankingListTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, userInfo: UserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.rankNumberLable?.isHidden = true
        self.headerImageButton?.buttonForAvatar.setImage(nil, for: .normal)
        self.praiseLabel?.isHidden = true
    }

    override func followTouch(_ btn: TSButton) {
        self.delegate?.cell(self, operateBtn: self.praiseButton!, indexPathRow: self.indexPathRow)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.userInfo.userIdentity == (CurrentUser?.userIdentity)! {
            praiseButton?.isHidden = true
        } else {
            praiseButton?.isHidden = false
        }
        let likesCount: Int  = self.userInfo.likesCount
        
        self.praiseLabel?.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: ("点赞 ", TSColor.normal.minor, UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)), second: (likesCount.abbreviated as NSString, secondColor: TSColor.main.theme, UIFont.systemFont(ofSize: 14)))
        
        if let praiseTitles = userInfo.relationshipWithCurrentUser?.texts.rawValue.localized {
            
            self.praiseButton?.isHidden = false
            guard let _ = userInfo.relationshipWithCurrentUser else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            switch userInfo.relationshipWithCurrentUser?.status {
            case .follow:
                self.praiseButton?.setImage(UIImage.set_image(named: "icProfileFollowing"), for: .normal)
            case .eachOther:
                self.praiseButton?.setImage(UIImage.set_image(named: "icProfileChat"), for: .normal)
            case .unfollow:
                self.praiseButton?.setImage(UIImage.set_image(named: "icProfileNotFollowing"), for: .normal)
                
            default: self.praiseButton?.isHidden = true
            }
        } else {
            
            self.praiseButton?.isHidden = true
        }
        
        self.headerImageButton?.avatarInfo.type = .normal(userId: self.userInfo.userIdentity)
        
        // MARK: REMARK NAME
        LocalRemarkName.getRemarkName(userId: "\(self.userInfo.userIdentity)", username: nil, originalName: self.userInfo.name, label: self.nickNameLabel)
        
        
        self.contentLabel?.text = self.userInfo.shortDesc
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
