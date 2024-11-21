//
//  SettingData.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

enum SettingType: String {
    case mediaDocuments = "photo_video_files"
    case groupIcon = "set_group_avatar"
    case groupName = "group_name"
    case groupQrcode = "group_qr_code"
    case myNickname = "group_nickname"
    case groupIntro = "group_introduce"
    case groupAnnouncement = "group_announcement"
    case groupType = "group_type"
    case groupWhoCanInvite = "group_who_can_invite"
    case groupWhoCanEdit = "group_who_can_edit"
    case groupInviteeApproval = "group_invitee_approval"
    case searchMessage = "chatinfo_search_message"
    case muteNotification = "chatinfo_mute_notification"
    case pinTop = "chatinfo_set_chat_on_top"
    case clearChat = "chatinfo_clear_chat"
    case leaveGroup = "group_leave"
    case transferGroup = "group_transfer"
    case chatWallpaper = "chat_wallpaper"
    case dismissGroup = "group_dismiss"
    case clearAndDeleteChat = "clear_and_delete"
    case none
}

class SettingData {

    var selector: Selector
    var titleColor: UIColor?
    var switchValue: Bool?
    var detailValue: String?
    var imageUrl: String?
    var isButton: Bool {
        switch settingType {
        case .leaveGroup, .transferGroup, .dismissGroup, .clearAndDeleteChat:
            return true
        default:
            return false
        }
    }
    var settingType: SettingType
    var clickable: Bool = true
    
    var name: String {
        return settingType.rawValue.localized
    }
    
    init(type: SettingType, selector: Selector) {
        self.settingType = type
        self.selector = selector
    }
    
    convenience init(type: SettingType, selector: Selector, titleColor: UIColor? = nil) {
        self.init(type: type, selector: selector)
        self.titleColor = titleColor
    }
    
    convenience init(type: SettingType, selector: Selector, switchValue: Bool? = false) {
        self.init(type: type, selector: selector)
        self.switchValue = switchValue
    }
    
    convenience init(type: SettingType, selector: Selector, detailValue: String? = nil) {
        self.init(type: type, selector: selector)
        self.detailValue = detailValue
    }
    
    convenience init(type: SettingType, selector: Selector, detailValue: String? = nil, clickable: Bool = true) {
        self.init(type: type, selector: selector)
        self.detailValue = detailValue
        self.clickable = clickable 
    }
    
    convenience init(type: SettingType, selector: Selector, imageUrl: String? = nil) {
        self.init(type: type, selector: selector)
        self.imageUrl = imageUrl
    }
    
    func toButton(_ delegate: UIViewController) -> UIButton {
        let button = UIButton(type: .custom)
        button.applyStyle(.custom(text: self.name, textColor: .red, backgroundColor: .clear, cornerRadius: 0))
        button.contentHorizontalAlignment = .left
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0,left: 16,bottom: 0,right: 5)
        button.addTarget(delegate, action: self.selector, for: .touchUpInside)
        return button
    }
    
    func toSettingView(_ delegate: UIViewController) -> ChatSettingView {
        return ChatSettingView(settingData: self, delegate: delegate)
    }
}


class TeamMember: NIMTeamMember {
    
    var isAdd: Bool
    var isReduce: Bool
    var isViewMore: Bool
    var memberInfo: NIMTeamMember?
    
    init(memberInfo: NIMTeamMember? = nil, isAdd: Bool = false, isReduce: Bool = false, isViewMore: Bool = false) {
        self.isAdd = isAdd
        self.isReduce = isReduce
        self.memberInfo = memberInfo
        self.isViewMore = isViewMore
    }
    
    convenience init(memberInfo: NIMTeamMember) {
        self.init(memberInfo: memberInfo, isAdd: false, isReduce: false)
    }
}

class IMNoticationData: NSObject {
    var headerTitle: String
    var footerTitle: String
    var contentTitle: String
    var detailTitle: String
    var extraInfo: Bool
    var userInteraction: Bool
    var forbidSelect: Bool = true
    var centerFooter: Bool
    init(headerTitle: String, footerTitle: String, contentTitle: String, extraInfo: Bool, userInteraction: Bool, forbidSelect: Bool, centerFooter: Bool, detailTitle: String) {
        self.headerTitle = headerTitle
        self.footerTitle = footerTitle
        self.contentTitle = contentTitle
        self.extraInfo = extraInfo
        self.userInteraction = userInteraction
        self.forbidSelect = forbidSelect
        self.centerFooter = centerFooter
        self.detailTitle = detailTitle
    }
}

class LikesCommentsFeedData: NSObject {
    var headerTitle: String
    var contentTitle: String
    var itemSelect: Bool = false
    init(headerTitle: String, contentTitle: String, itemSelect: Bool) {
        self.headerTitle = headerTitle
        self.contentTitle = contentTitle
        self.itemSelect = itemSelect

    }
}
