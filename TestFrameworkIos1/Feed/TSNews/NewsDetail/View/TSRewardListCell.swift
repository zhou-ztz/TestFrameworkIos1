//
//  TSRewardListCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
//import NIMPrivate
class TSRewardListCell: UITableViewCell {

    static let identifier = "TSRewardListCell"
    var rewardType: TSRewardType = .moment
    @IBOutlet weak var labelForTime: UILabel!
    @IBOutlet weak var labelForContent: UILabel!
    @IBOutlet weak var buttonForAvatar: AvatarView!

    func set(model: TSNewsRewardModel) {
        // 头像
        buttonForAvatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.user.sex)
        buttonForAvatar.avatarInfo = model.user.avatarInfo()
        // 内容
        var contentString = NSMutableAttributedString()

        if model.user.name.isEmpty {
            model.user.name = "default_delete_user_name".localized
        }

        switch self.rewardType {
        case .moment:
            contentString = NSMutableAttributedString(string: String(format: "noti_sys_rewarded_moment".localized, model.user.name))
        case .news:
            contentString = NSMutableAttributedString(string: String(format: "noti_sys_rewarded_event".localized, model.user.name))
        case .user:
            contentString = NSMutableAttributedString(string: String(format: "noti_sys_rewarded_user".localized, model.user.name))
        case .post:
            contentString = NSMutableAttributedString(string: String(format: "noti_sys_rewarded_post".localized, model.user.name))
        default:
            contentString = NSMutableAttributedString(string: String(format: "noti_sys_rewarded_moment".localized, model.user.name))
        }
//        labelForContent.attributedText = TSCommonTool.string(contentString, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: TSColor.main.content]], strings: [model.user.name])
//        // 时间 // TODO: 替换时间
//        labelForTime.text = TSDate().dateString(.normal, nsDate: model.createdDate)
    }

}
