//
//  BlackListCell.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/4/19.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit

class BlackListCell: AbstractRankingListTableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?, userInfo: UserInfoModel) {
        super.init(style: style, reuseIdentifier: reuseIdentifier, userInfo: userInfo)
        self.rankNumberLable?.isHidden = true
        self.headerImageButton?.buttonForAvatar.setImage(nil, for: .normal)
        self.praiseLabel?.isHidden = true
        self.praiseButton?.layer.cornerRadius = 10
        self.praiseButton?.layer.borderColor = AppTheme.red.cgColor
        self.praiseButton?.layer.borderWidth = 1
        self.praiseButton?.setTitle("filter_remove".localized, for: .normal)
        self.praiseButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.praiseButton?.sizeToFit()
        self.praiseButton?.setTitleColor(AppTheme.red, for: .normal)
        self.praiseButton?.snp.remakeConstraints({ (make) in
            make.right.equalTo(self.contentView.snp.right).offset(-10)
            make.centerY.equalTo(self.contentView.snp.centerY)
            make.size.equalTo(CGSize(width: self.praiseButton!.size.width, height: 25))
        })
    }

    override func followTouch(_ btn: TSButton) {
        self.delegate?.cell(self, operateBtn: self.praiseButton!, indexPathRow: self.indexPathRow)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.userInfo.userIdentity == (CurrentUserSessionInfo?.userIdentity)! {
            praiseButton?.isHidden = true
        } else {
            praiseButton?.isHidden = false
        }
        self.headerImageButton?.avatarInfo.type = .normal(userId: self.userInfo.userIdentity)
        self.nickNameLabel?.text = self.userInfo.name
        self.contentLabel?.text = self.userInfo.shortDesc
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
