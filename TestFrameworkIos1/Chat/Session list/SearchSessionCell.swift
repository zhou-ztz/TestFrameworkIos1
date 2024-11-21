//
//  SearchMessageContentCell.swift
//  Yippi
//
//  Created by Khoo on 02/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK


class SearchSessionCell: TSTableViewCell {
    @IBOutlet weak var namewith: NSLayoutConstraint!
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var nameLabel: TSLabel!
    @IBOutlet weak var contentLabel: TSLabel!
    @IBOutlet weak var timeLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
    var statusIcon = UIImageView()
    var screenGroup = UIImageView()
    var pinIcon = UIImageView(image: UIImage.set_image(named: "ic_home_pintotop"))
    var currentIndex: Int = 0
    var hidScreenGroup: Bool = true
    var avatarInfo: AvatarInfo!
    
    var verifiedIcon: String?
    var verifiedType: String?
    var avatar: String?
    private var _isnewUser: Bool?
    var isnewUser: Bool? {
        set {
            _isnewUser = newValue
        }
        get {
            return _isnewUser
        }
    }
    private var _avatarSizeType: AvatarType?
    var avatarSizeType: AvatarType? {
        set {
            _avatarSizeType = newValue
            headerButton.showBoardLine = false
            headerButton.frame.size = newValue?.size ?? .zero
        }
        get {
            return _avatarSizeType
        }
    }
    
    /// 会话信息
    private var _conversationInfo: TSConversationObject?
    var conversationInfo: TSConversationObject? {
        set {
            _conversationInfo = newValue
            guard let realConversationInfo = newValue else {
                return
            }
            nameLabel.text = realConversationInfo.incomingUserName
            contentLabel.text = realConversationInfo.latestMessage
            if let latestMessageDate = realConversationInfo.latestMessageDate {
                timeLabel.isHidden = false
                timeLabel.text = TSDate().dateString(.normal, nsDate: latestMessageDate)
            } else {
                timeLabel.isHidden = true
            }
            if realConversationInfo.isSendingLatestMessage.value == false {
                // 如果最新一条消息发送失败
                contentLabel.text = "msg_fail_to_sent_tips".localized
            }
        }
        get {
            return _conversationInfo
        }
    }
    
    /// NIM会话
    private var _session: NIMRecentSession?
    var session: NIMRecentSession? {
        set {
            _session = newValue
            guard let value = newValue, let realSession = value.session else {
                return
            }
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(realSession.sessionId)
//            
//            if realSession.sessionType == NIMSessionType.team {
//                nameLabel.text = NIMSDK.shared().teamManager.team(byId: realSession.sessionId)?.teamName
//            } else {
//                nameLabel.text = info.showName
//            }
            if let lastMessage = value.lastMessage {
                contentLabel.text = self.contentForRecentSession(value)
                timeLabel.isHidden = false
                timeLabel.text = TSDate().dateString(.normal, nsDate: NSDate(timeIntervalSince1970: lastMessage.timestamp))
            } else {
                timeLabel.isHidden = true
            }
            let timeWith = timeLabel.text?.size(maxSize: CGSize(width: ScreenWidth, height: 17), font: UIFont.systemFont(ofSize: 17)).width
            namewith.constant = ScreenWidth - timeWith! - 15 - headerButton.right - 15
            nameLabel.updateConstraints()
            
            let avatarInfo = AvatarInfo()
            self.headerButton.avatarInfo = avatarInfo
            
            TSUserNetworkingManager().getUsersInfo(usersId: [], userNames: [realSession.sessionId]) { (userinfoModels, msg, status) in
                if status {
                    if let userinfo = userinfoModels?.first {
                        avatarInfo.avatarURL = userinfo.avatarUrl ?? ""
                        self.headerButton.avatarInfo = avatarInfo
                    }
                }
            }
            
            headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
            
            contentView.addSubview(pinIcon)
//            if NTESSessionUtil.recentSessionIsMark(value, type: .top) == true {
//                pinIcon.makeVisible()
//            } else {
//                pinIcon.makeHidden()
//            }
        }
        
        get {
            return _session
        }
    }
    
    /// NIM chat history
    private var _message: NIMMessage?
    var message: NIMMessage? {
        set {
            _message = newValue
            guard let value = newValue else {
                return
            }
            
            if let username = value.from {
//                let info = NIMBridgeManager.sharedInstance().getUserInfo(username)
//                
//                nameLabel.text = info.showName
//                
//                // MARK: REMARK NAME
//                LocalRemarkName.getRemarkName(userId: nil, username: "\(username)", originalName: info.showName, label: nameLabel)
//                
//                contentLabel.text = value.text
//                timeLabel.text = TSDate().dateString(.normal, nsDate: NSDate(timeIntervalSince1970: value.timestamp))
//                avatar = info.avatarUrlString
//                let avatarInfo = AvatarInfo()
//                avatarInfo.avatarURL = avatar
//                headerButton.avatarInfo = avatarInfo
            }
            
            let timeWith = timeLabel.text?.size(maxSize: CGSize(width: ScreenWidth, height: 17), font: UIFont.systemFont(ofSize: 17)).width
            namewith.constant = ScreenWidth - timeWith! - 15 - headerButton.right - 15
            nameLabel.updateConstraints()
        }
        
        get {
            return _message
        }
    }
    
    static let cellReuseIdentifier = "SearchSessionCell"
    
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
        pinIcon.frame = CGRect(x: (UIScreen.main.bounds.width - 25.5 - width / 2), y: 0, width: 15, height: 15)
        pinIcon.centerY = contentLabel.centerY
    }
    
    private func customUI() {
        headerButton.circleCorner()
        
        nameLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.navigation.rawValue)
        nameLabel.textColor = TSColor.main.content
        nameLabel.lineBreakMode = .byTruncatingMiddle
        
        contentLabel.font = UIFont.systemFont(ofSize: TSFont.UserName.listPulse.rawValue)
        contentLabel.textColor = TSColor.normal.minor
        
        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
        
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

extension SearchSessionCell {
    func contentForRecentSession(_ session: NIMRecentSession) -> String {
        var text: String = "recent_msg_unknown".localized
        guard let lastMessage = session.lastMessage else { return text }
        switch lastMessage.messageType {
        case .image:
            text = "recent_msg_desc_picture".localized
        case .text, .tip:
            text = lastMessage.text.orEmpty
        case .file:
            text = "recent_msg_desc_file".localized
        case .video:
            text = "recent_msg_desc_video".localized
        case .audio:
            text = "recent_msg_desc_audio".localized
        case .location:
            text = "recent_msg_desc_location".localized
        case .notification:
            if let object = lastMessage.messageObject as? NIMNotificationObject {
                if object.notificationType == .netCall {
                    if let content = object.content as? NIMNetCallNotificationContent, content.callType == .audio {
                        text = "recent_msg_desc_voice_call".localized
                    } else {
                        text = "recent_msg_desc_video_call".localized
                    }
                }
                
                if object.notificationType == .team {
                    if let sessionId = lastMessage.session?.sessionId {
                        if let team = NIMSDK.shared().teamManager.team(byId: sessionId) {
                            if team.type == .normal {
                                text = "recent_msg_desc_team_msg".localized
                            } else {
                                text = "recent_msg_desc_group_msg".localized
                            }
                        }
                    }
                }
            }
        case .robot:
            let object = lastMessage.messageObject as! NIMRobotObject
            text = object.isFromRobot ? "recent_msg_desc_robot_msg".localized : lastMessage.text.orEmpty
        case .custom:
            guard let object = lastMessage.messageObject as? NIMCustomObject, let attachment = object.attachment else { return text }
            
            if attachment.isKind(of: IMSnapchatAttachment.self) {
                text = "sc".localized
            } else if attachment.isKind(of: IMContactCardAttachment.self) {
                text = "recent_msg_desc_contact".localized
            } else if attachment.isKind(of: IMRPSAttachment.self) {
                text = "recent_msg_desc_guess".localized
            } else if attachment.isKind(of: IMStickerAttachment.self) {
                text = "recent_msg_desc_sticker".localized
            } else if attachment.isKind(of: IMEggAttachment.self) {
                text = "recent_msg_desc_redpacket".localized
            } else if attachment.isKind(of: IMStickerCardAttachment.self) {
                text = "recent_msg_desc_sticker_collection".localized
            } else if attachment.isKind(of: IMSocialPostAttachment.self) {
                text = "recent_msg_desc_attachment".localized
            } else if attachment.isKind(of: IMVoucherAttachment.self) {
                text = "recent_msg_desc_voucher".localized
            } else if attachment.isKind(of: IMReplyAttachment.self) {
                if let attach = attachment as? IMReplyAttachment {
                    text = attach.message
                }
            } else if attachment.isKind(of: IMMiniProgramAttachment.self) {
                text = "recent_msg_desc_attachment".localized
            } else if attachment.isKind(of: IMMeetingRoomAttachment.self) {
                text = "recent_msg_desc_meeting".localized
            } else if attachment.isKind(of: IMCallingAttachment.self) {
                text = "recent_msg_desc_voice_call".localized
                if let attach = attachment as? IMCallingAttachment {
                    if attach.callType == .audio {
                        text = "recent_msg_desc_voice_call".localized
                    } else {
                        text = "recent_msg_desc_video_call".localized
                    }
                }
            }
            else if attachment.isKind(of: IMWhiteboardAttachment.self) {
                text = "recent_msg_desc_whiteboard".localized
            }
//            if let nickName = NTESSessionUtil.showNick(lastMessage.from, in: lastMessage.session) {
//                text = nickName.isEmpty ? "" : nickName + ": " + text
//            }
        default:
            text = "recent_msg_unknown".localized
            break
        }
        
        return text
    }
}

