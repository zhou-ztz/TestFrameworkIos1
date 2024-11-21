//
//  TSConversationTableViewCell.swift
//  Thinksns Plus
//
//  Created by lip on 2017/2/27.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  聊天会话列表 cell

import UIKit
//import NIMPrivate
import NIMSDK

let kTSConversationTableViewCellDefaltHeight: CGFloat = 67

protocol TSConversationTableViewCellDelegate: class {
    /// 用户的头像被点击
    func headButtonDidPress(for userId: Int)
    // func messageUnreadCount(total: Int)
}

class TSConversationTableViewCell: TSTableViewCell {
    @IBOutlet weak var namewith: NSLayoutConstraint!
    @IBOutlet weak var headerButton: AvatarView!
    @IBOutlet weak var nameLabel: TSLabel!
    @IBOutlet weak var contentLabel: TSLabel!
    @IBOutlet weak var timeLabel: TSLabel!
    weak var delegate: TSConversationTableViewCellDelegate?
    let countButtton = TSButton(type: .custom)
    
    let stackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 10
    }
    var statusIcon = UIImageView()
    var screenGroup = UIImageView()
    var pinIcon = UIImageView(image: UIImage.set_image(named: "iconsPinGrey"))
    var muteIcon = UIImageView(image: UIImage.set_image(named: "iconsVolumeGrey"))
    var currentIndex: Int = 0
    var hidScreenGroup: Bool = true
    var avatarInfo: AvatarInfo!
    var totalCount = [Int]()
    
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
            countButtton.isHidden = realConversationInfo.unreadCount == 0 ? true : false
            let unreadCount = realConversationInfo.unreadCount > 99 ? 99 : realConversationInfo.unreadCount
            updateButtonFrame(unreadCount: unreadCount)
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
            
            print("real conver \(realConversationInfo.unreadCount)")
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
            //let info = NIMBridgeManager.sharedInstance().getUserInfo(realSession.sessionId)
            if realSession.sessionType == NIMSessionType.team {
                nameLabel.text = NIMSDK.shared().teamManager.team(byId: realSession.sessionId)?.teamName
            } else {
//                nameLabel.text = NIMKitUtil.showNick(realSession.sessionId, in: realSession)
            }
            countButtton.isHidden = value.unreadCount == 0
            updateButtonFrame(unreadCount: value.unreadCount)
            if let lastMessage = value.lastMessage {
                self.contentForRecentSession(value)
                
                if let attributedText = contentLabel.attributedText, attributedText.string.isEmpty == false {
                    timeLabel.isHidden = false
//                    timeLabel.text = NIMKitUtil.showTime(lastMessage.timestamp, showDetail: false)
                } else {
                    timeLabel.isHidden = true
                }
            } else {
                timeLabel.isHidden = true
                contentLabel.attributedText = nil
                contentLabel.text = ""
            }
            let timeWith = timeLabel.text?.size(maxSize: CGSize(width: ScreenWidth, height: 17), font: UIFont.systemFont(ofSize: 17)).width
            namewith.constant = ScreenWidth - timeWith! - 15 - headerButton.right - 15
            nameLabel.updateConstraints()
            
            let avatarInfo = AvatarInfo()
            self.headerButton.avatarInfo = avatarInfo
            
            verifyUser(session: realSession)
            headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
            
//            if NTESSessionUtil.recentSessionIsMark(value, type: .top) == true {
//                pinIcon.makeVisible()
//            } else {
//                pinIcon.makeHidden()
//            }
            
            if value.session?.sessionType == .team {
                let state = needNotifyForGroup(sessionId: realSession.sessionId)
                if state.rawValue == 1 {
                    muteIcon.makeVisible()
                } else {
                    muteIcon.makeHidden()
                }
            } else {
                if needNotifyForUser(sessionId: realSession.sessionId) {
                    muteIcon.makeHidden()
                } else {
                    muteIcon.makeVisible()
                }
            }
        }
        
        get {
            return _session
        }
    }
    // 会话内容
    private var _messageContent: NSMutableAttributedString?
    var messageContent: NSMutableAttributedString? {
        set {
            _messageContent = newValue
            guard let value = newValue else { return }
            DispatchQueue.main.async {
                self.contentLabel.attributedText = newValue
            }
        }
        get {
            return _messageContent
        }
    }
    
    func needNotifyForUser(sessionId: String) -> Bool {
        return NIMSDK.shared().userManager.notify(forNewMsg: sessionId)
    }
    
    func needNotifyForGroup(sessionId: String) -> NIMTeamNotifyState  {
        return NIMSDK.shared().teamManager.notifyState(forNewMsg: sessionId)
    }
    
    func verifyUser(session: NIMSession){
        let type = session.sessionType
        switch type {
        case .team:
            self.headerButton.avatarPlaceholderType = .group
            self.headerButton.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: session.sessionId, isTeam: true)
        case .P2P:
            self.headerButton.avatarPlaceholderType = .unknown
            self.headerButton.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: session.sessionId)
        default:
            break
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
            
//            if let username = value.from {
////                let info = NIMBridgeManager.sharedInstance().getUserInfo(username)
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
//            }
            
            countButtton.makeHidden()
            let timeWith = timeLabel.text?.size(maxSize: CGSize(width: ScreenWidth, height: 17), font: UIFont.systemFont(ofSize: 17)).width
            namewith.constant = ScreenWidth - timeWith! - 15 - headerButton.right - 15
            nameLabel.updateConstraints()
        }
        
        get {
            return _message
        }
    }
    
    static let cellReuseIdentifier = "TSConversationTableViewCell"
    private let pulseIndicator = IMSendMsgIndicator(radius: 8.0, color: TSColor.main.theme)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerButton.layoutIfNeeded()
        let unreadCount = self.session?.unreadCount ?? 0
        var width: CGFloat = unreadCount > 9 ? 20 : 18
        if unreadCount > 99 {
            width = 22
        }
        //countButtton.frame = CGRect(x: (UIScreen.main.bounds.width - 14.5 - width), y: 38, width: width, height: 15)
        //countButtton.frame = CGRect(x: 0, y: 0, width: width, height: 10)
        countButtton.titleLabel?.font = .systemFont(ofSize: 10.0, weight: .regular)
//        if NTESSessionUtil.recentSessionIsMark(self.session, type: .top) == true {
//            //countButtton.frame = CGRect(x: (pinIcon.frame.origin.x - width + 50), y: 38, width: width, height: 15)
//        }
        countButtton.layer.cornerRadius = countButtton.frame.size.height * 0.5
        statusIcon.frame = CGRect(x: 63, y: 40, width: 14, height: 14)//UIImageView.init(frame: CGRect.init(x: 63, y: 40, width: 14, height: 14))
        statusIcon.image = UIImage.set_image(named: "msg_box_remind")
        statusIcon.layer.masksToBounds = true
        statusIcon.layer.cornerRadius = 7
        //screenGroup.frame = CGRect(x: ScreenWidth - 14 - 15, y: 40, width: 14, height: 14)
        //screenGroup.image = UIImage.set_image(named: "ico_newslist_shield")
        
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(muteIcon)
        stackView.addArrangedSubview(pinIcon)
        stackView.addArrangedSubview(countButtton)
        
        stackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalTo(contentLabel.centerY)
        }
        
        muteIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        pinIcon.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        
        countButtton.snp.makeConstraints {
            $0.width.height.equalTo(width)
        }
        
        pulseIndicator.frame = CGRect(x: 0, y: 0, width: 24, height: 20)
        pulseIndicator.centerY = contentLabel.centerY
        pulseIndicator.layoutIfNeeded()
    }
    
    private func customUI() {
        headerButton.buttonForAvatar.addTarget(self, action: #selector(headerButtonAction), for: .touchUpInside)
        headerButton.circleCorner()
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: TSFont.UserName.navigation.rawValue)
        nameLabel.textColor = TSColor.main.content
        //nameLabel.lineBreakMode = .byTruncatingMiddle
        
        contentLabel.font = UIFont.systemFont(ofSize: TSFont.SubText.subContent.rawValue)
        contentLabel.textColor = TSColor.normal.minor
        
        timeLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        timeLabel.textColor = TSColor.normal.disabled
        self.selectionStyle = .default
        pulseIndicator.isHidden = true
        self.contentView.addSubview(pulseIndicator)
    }
    
    class func nib() -> UINib {
        return UINib(nibName: cellReuseIdentifier, bundle: nil)
    }
    
    @objc func headerButtonAction() {
        //修改头像点击事件，会话列表页点击头像也是跳转到聊天室，并不是跳到个人主页
        self.delegate?.headButtonDidPress(for: currentIndex)
    }
    
    func updateButtonFrame(unreadCount: Int) {
        let unreadCountStr = unreadCount > 99 ? "99+" : String(unreadCount)
        countButtton.setTitle(unreadCountStr, for: .normal)
        countButtton.sizeToFit()
        if countButtton.superview == nil {
            countButtton.isUserInteractionEnabled = false
            countButtton.backgroundColor = TSColor.main.theme
            countButtton.clipsToBounds = true
            countButtton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
            countButtton.setTitleColor(.white, for: .normal)
            contentView.addSubview(countButtton)
        }
        countButtton.centerY = contentLabel.centerY
    }
}

extension TSConversationTableViewCell {
    func appendName(session: NIMRecentSession, content: String) -> String {
        var text = content
        
//        if let session1 = session.session, session1.sessionType != .P2P, let lastMessage = session.lastMessage {
//            if let nickName = NTESSessionUtil.showNick(lastMessage.from, in: lastMessage.session), let from = lastMessage.from {
//                if from == NIMSDK.shared().loginManager.currentAccount() {
//                    text = "You".localized + " : " + text
//                } else {
//                    text = nickName.isEmpty ? "" : nickName + ": " + text
//                }
//            }
//        }
        
        return text
    }
    
    func contentForRecentSession(_ session: NIMRecentSession) {
        var text: String = "recent_msg_unknown".localized
        messageContent = NSMutableAttributedString(string: text)
        guard let lastMessage = session.lastMessage else { 
            return
        }
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
                } else if object.notificationType == .team {
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
            guard let object = lastMessage.messageObject as? NIMCustomObject, let attachment = object.attachment else { return  }
            
            if attachment.isKind(of: IMSnapchatAttachment.self) {
                text = "sc".localized
            } else if attachment.isKind(of: IMContactCardAttachment.self) {
                text = "recent_msg_desc_contact".localized
            } else if attachment.isKind(of: IMRPSAttachment.self) {
                text = "recent_msg_desc_guess".localized
            } else if attachment.isKind(of: IMStickerAttachment.self) {
                text = "recent_msg_desc_sticker".localized
            } 
//            else if attachment.isKind(of: NTESWhiteboardAttachment.self) {
//                text = "recent_msg_desc_whiteboard".localized
//            } 
            else if attachment.isKind(of: IMEggAttachment.self) {
                text = "recent_msg_desc_redpacket".localized
            } else if attachment.isKind(of: IMStickerCardAttachment.self) {
                text = "recent_msg_desc_sticker_collection".localized
            } else if attachment.isKind(of: IMSocialPostAttachment.self) {
                text = "recent_msg_desc_attachment".localized
            } else if attachment.isKind(of: IMVoucherAttachment.self) {
                text = "recent_msg_desc_voucher".localized
            } 
//            else if attachment.isKind(of: NTESRedPacketTipAttachment.self) {
//                if let attach = attachment as? NTESRedPacketTipAttachment {
//                    text = attach.formatedMessage()
//                }
//            }
            else if attachment.isKind(of: IMAnnouncementAttachment.self) {
                if let attach = attachment as? IMAnnouncementAttachment {
                    text = attach.message
                }
            } else if attachment.isKind(of: IMReplyAttachment.self) {
                if let attach = attachment as? IMReplyAttachment {
                    text = attach.content
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
            } else if attachment.isKind(of: IMWhiteboardAttachment.self) {
                text = "recent_msg_desc_whiteboard".localized
            }
        default:
            text = "recent_msg_unknown".localized
            break
        }
        
        text = appendName(session: session, content: text)
        
        messageContent = NSMutableAttributedString(string: text)
        self.checkNeedAtTip(recent: session)
        self.checkOnlineState(recent: session)
        self.checkMsgIsSending(recent: session)
    }
    
    //是否@某人
    func checkNeedAtTip(recent: NIMRecentSession) {
        var content = messageContent
        let atTip = NSAttributedString(string: "\("recent_msg_desc_tag_by_other".localized) ", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        
//        if NTESSessionUtil.recentSessionIsMark(recent, type: .at) {
//            content?.insert(atTip, at: 0)
//            messageContent = content
//            return
//        }
//        
//        if let session = recent.session {
//            NIMSDK.shared().conversationManager.allUnreadMessages(in: session, completion: { error, messages in
//                if error == nil, let messages = messages as? [NIMMessage] {
//                    if let message = messages.first(where: { $0.remoteExt?["mentionAll"] != nil }) {
//                        content?.insert(atTip, at: 0)
//                        self.messageContent = content
//                        return
//                    }
//                }
//            })
//        }
    }

    func checkOnlineState(recent: NIMRecentSession) {
        var content = messageContent
//        if let session = recent.session, session.sessionType == .P2P {
//            guard let state = NTESSessionUtil.onlineState(session.sessionId, detail: false) else {
//                return
//            }
//            
//            if state.count > 0 {
//                let format = String(format: "[%@]", state)
//                let atTip = NSAttributedString(string: format, attributes: nil)
//                content?.insert(atTip, at: 0)
//                messageContent = content
//            }
//        }
    }
    
    //消息发送中时插入图片
    func checkMsgIsSending(recent: NIMRecentSession) {
        guard let lastMessage = recent.lastMessage else {
            pulseIndicator.stopAnimating()
            return
        }
        if lastMessage.isReceivedMsg == false, lastMessage.deliveryState == .delivering {
            pulseIndicator.startAnimating()
            pulseIndicator.isHidden = false
            //            pulseIndicator.snp.makeConstraints { make in
            //                make.left.equalTo(63)
            //                make.height.equalTo(20)
            //                make.width.equalTo(24)
            //            }
            pulseIndicator.frame = CGRect(x: 63, y: 0, width: 24, height: 20)
            contentLabel.snp.removeConstraints()
            contentLabel.snp.makeConstraints { make in
                make.left.equalTo(87)
                make.top.equalTo(self.nameLabel.snp_bottom).offset(5)
                make.right.equalTo(-78)
            }
            pulseIndicator.centerY = contentLabel.centerY
            pulseIndicator.layoutIfNeeded()
        } else {
            pulseIndicator.stopAnimating()
            pulseIndicator.isHidden = true
            contentLabel.snp.removeConstraints()
            contentLabel.snp.makeConstraints { make in
                make.left.equalTo(63)
                make.top.equalTo(self.nameLabel.snp_bottom).offset(5)
                make.right.equalTo(-78)
            }
        }
    }
}
