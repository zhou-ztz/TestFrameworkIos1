//
//  SessionUtil.swift
//  Yippi
//
//  Created by Khoo on 19/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NEMeetingKit
import AVFoundation
import NIMSDK
//import NIMPrivate
class InfoFetchOption: NSObject {
    var session: NIMSession?
    var message: NIMMessage?
    var forbidaAlias: Bool?
    
    override init() {
        super.init()
    }
}

let OnedayTimeIntervalValue: Double = 24 * 60 * 60 //一天的秒数

private let NTESRecentSessionAtMark = "NTESRecentSessionAtMark"
private let NTESRecentSessionTopMark = "NTESRecentSessionTopMark"

enum RecentSessionMarkType : Int {
    // @ 标记
    case at
    // 置顶标记
    case top
}

class SessionUtil: NSObject {
   static func getImageSize(withImageOriginSize originSize: CGSize, minSize imageMinSize: CGSize, maxSize imageMaxSize: CGSize) -> CGSize {
        var size: CGSize = CGSize(width: 0, height: 0)
        let imageWidth = originSize.width
        let imageHeight = originSize.height
        let imageMinWidth = imageMinSize.width
        let imageMinHeight = imageMinSize.height
        let imageMaxWidth = imageMaxSize.width
        let imageMaxHeight = imageMaxSize.height

        if imageWidth > imageHeight {
            //宽图
            size.height = imageMinHeight //高度取最小高度
            size.width = imageWidth * imageMinHeight / imageHeight
            if size.width > imageMaxWidth {
                size.width = imageMaxWidth
            }
        } else if imageWidth < imageHeight {
            //高图
            size.width = imageMinWidth
            size.height = imageHeight * imageMinWidth / imageWidth
            if size.height > imageMaxHeight {
                size.height = imageMaxHeight
            }
        } else {
            //方图
            if imageWidth > imageMaxWidth {
                size.width = imageMaxWidth
                size.height = imageMaxHeight
            } else if imageWidth > imageMinWidth {
                size.width = imageWidth
                size.height = imageHeight
            } else {
                size.width = imageMinWidth
                size.height = imageMinHeight
            }
        }

        return size
    }


    static func isTheSameDay(_ currentTime: TimeInterval, compareTime older: DateComponents?) -> Bool {
        let calendar = Calendar.current
        let current = calendar.dateComponents([ .day, .month, .day, .hour, .minute], from: Date(timeIntervalSinceNow: currentTime))

        return current.year == older?.year && current.month == older?.month && current.day == older?.day
    }

    static var weekdayStrDaysOfWeekDict: [AnyHashable : Any]? = nil

    static func weekdayStr(_ dayOfWeek: Int) -> String? {
        weekdayStrDaysOfWeekDict = [
            NSNumber(value: 1): "chatroom_text_sunday".localized,
            NSNumber(value: 2): "chatroom_text_monday".localized,
            NSNumber(value: 3): "chatroom_text_tuesday".localized,
            NSNumber(value: 4): "chatroom_text_wednesday".localized,
            NSNumber(value: 5): "chatroom_text_thursday".localized,
            NSNumber(value: 6): "chatroom_text_friday".localized,
            NSNumber(value: 7): "chatroom_text_saturday".localized
        ]
        return weekdayStrDaysOfWeekDict?[NSNumber(value: dayOfWeek)] as? String
    }

    static func string(from messageTime: TimeInterval, components: Set<Calendar.Component>) -> DateComponents? {
        let dateComponents = Calendar.current.dateComponents(components, from: Date(timeIntervalSince1970: messageTime))
        return dateComponents
    }

    static func showNick(_ uid: String?, in session: NIMSession?) -> String? {
        var nickname: String? = nil
//        if session?.sessionType == NIMSessionType.team {
//            let member = NIMSDK.shared().teamManager.teamMember(uid ?? "", inTeam: session?.sessionId ?? "")
//        }
//        if (nickname?.count ?? 0) == 0 {
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(uid ?? "")
//            nickname = info.showName
//            
//        }
        return nickname
    }
    
    //接收时间格式化
    static func showTime(_ msglastTime: TimeInterval, showDetail: Bool) -> String? {
        let nowDate = Date()
        let msgDate = Date(timeIntervalSince1970: msglastTime)
        var result: String? = nil
        let components = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute])
        let nowDateComponents = Calendar.current.dateComponents(components, from: nowDate)
        let msgDateComponents = Calendar.current.dateComponents(components, from: msgDate)
        
        var hour = msgDateComponents.hour ?? 0
        
        result = SessionUtil.getPeriodOfTime(hour, withMinute: msgDateComponents.minute ?? 0) ?? ""
        
        if hour > 12 {
            hour = hour - 12
        }
        
        let isInternationalFormat = result?.lowercased() == "am" || result?.lowercased() == "pm"
        
        if nowDateComponents.day == msgDateComponents.day {
            if isInternationalFormat {
                result = "\(hour):\(msgDateComponents.minute)\(result)"
            } else {
                result = "\(result) \(hour):\(msgDateComponents.minute)"
            }
        } else if nowDateComponents.day == msgDateComponents.day ?? 0 + 1 {
            if isInternationalFormat {
                //result = showDetail ? String(format: "chatroom_yesterday_with_format_int1".localized, String(msgDateComponents.minute), String(result ?? 0)) : "chatroom_yesterday".localized
            } else {
                //result = showDetail ? weekDay.appendin
                //result = showDetail ? String(format: "chatroom_yesterday_with_format".localized, String(result ?? 0), String(hour) String(msgDateComponents.minute)) : "chatroom_yesterday".localized
            }
        } else {
            let day = "\(String(describing: msgDateComponents.year))-\(String(describing: msgDateComponents.month))-\(String(describing: msgDateComponents.day))"
            
            if isInternationalFormat {
                result = showDetail ? day.appending("\(hour):\(String(describing: msgDateComponents.minute)) \(String(describing: result))") : day
            } else {
                result = showDetail ? day.appending("\(String(describing: result))\(hour):\(msgDateComponents.minute)") : day
            }
        }
        
        return result
    }
        
    static func getPeriodOfTime(_ time: Int, withMinute minute: Int) -> String? {
        let totalMin = time * 60 + minute
        var showPeriodOfTime = ""
        if totalMin > 0 && totalMin <= 5 * 60 {
            showPeriodOfTime = String("chatroom_text_morning")
        } else if totalMin > 5 * 60 && totalMin < 12 * 60 {
            showPeriodOfTime = String("chatroom_text_am")
        } else if totalMin >= 12 * 60 && totalMin <= 18 * 60 {
            showPeriodOfTime = String("chatroom_text_pm")
        } else if (totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0 {
            showPeriodOfTime = String("chatroom_text_night")
        }
        return showPeriodOfTime
    }

    func session(withInputURL inputURL: URL?, outputURL: URL?, blockHandler handler: @escaping (AVAssetExportSession?) -> Void) {
        guard let inputURL = inputURL else { return }
        
        let asset = AVURLAsset(url: inputURL)
        let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        
        session?.outputURL = outputURL
        session?.outputFileType = .mp4
        session?.shouldOptimizeForNetworkUse = true
        session?.exportAsynchronously(completionHandler: {
            handler(session)
        })
    }
    
    static func dictByJsonData (data: Data?) -> [String:String]? {
        let dict: [String:String]? = nil
        if let data = data{
            var _: Error? = nil
            do {
                let decoder = try JSONSerialization.jsonObject(
                    with: data,
                    options: [])
                if let dict = decoder as? [String:String] {
                    return dict
                }
            } catch {
                return nil
            }
        }
        return dict
    }
    
    static func dictByJsonString (jsonString: String) -> [String:String]? {
        if jsonString.count < 0 {
            return nil
        }
        
        let data = jsonString.data(using: .utf8)
        return SessionUtil.dictByJsonData(data: data)
    }
    
    static func tipOnMessageRevoked (notification: NIMRevokeMessageNotification?) -> String {
        var tip = ""
        repeat {
            if let notification = notification {
                let session: NIMSession = notification.session
                if session.sessionType == NIMSessionType.team {
                    tip = self.tipTitleFromMessageRevokeNotificationTeam(notification: notification)
                    break
                }
            } else {
                tip = "you".localized
            }
        } while false
        
        return String(format: "revoke_msg".localized, tip)
    }
    
    static func tipTitleFromMessageRevokeNotificationTeam (notification: NIMRevokeMessageNotification) -> String {
        var tipTitle = ""
        
        repeat {
            let fromUid = notification.messageFromUserId
            let operatorUid = notification.fromUserId
            let revokeBySender = operatorUid == fromUid
            let fromMe = fromUid == NIMSDK.shared().loginManager.currentAccount()
            
            if revokeBySender && fromMe {
                tipTitle = "you".localized
                break
            }
            
            let session = notification.session
            let option = InfoFetchOption()
            option.session = session
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(fromUid)
            
            if revokeBySender {
                //tipTitle = info,showName
                break
            }
            
            let member = NIMSDK.shared().teamManager.teamMember(operatorUid, inTeam: session.sessionId)
            
//            if member?.type == NIMTeamMemberType.owner {
//                tipTitle = "team_creator".localized.appending(info.showName)
//            } else if member?.type == NIMTeamMemberType.manager {
//                tipTitle = "team_admin".localized.appending(info.showName)
//            }
        } while false
        
        return tipTitle
    }
    
    func checkYidunAntiSpamIsEmpty(_ message: NIMMessage) -> Bool {
        if let yidunAntiSpamRes = message.yidunAntiSpamRes, yidunAntiSpamRes.isEmpty == false {
            return false
        }
        
        if let localExt = message.localExt, let yidunAntiSpamRes = localExt["yidunAntiSpamRes"] as? String, yidunAntiSpamRes.isEmpty == false {
            return false
        }
        
        return true
    }
    
    func canMessageBeForwarded (_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        if !message.isReceivedMsg && message.deliveryState == .failed {
            return false
        }
        
        if let ext = message.remoteExt {
            //let ext:[String:Any] = message.remoteExt ??
            let duration = ext["secretChatTimer"] as? Int
            
            if duration != 0 {
                return false
            }

            return true
        }
        
        let messageObject = message.messageObject
        
        if messageObject is NIMCustomObject {
            let attach = (message.messageObject as? NIMCustomObject)?.attachment as? IMMessageContentInfo
            return attach?.canBeForwarded() ?? false
        }
        
        if messageObject is NIMNotificationObject {
            return false
        }
        
        if messageObject is NIMTipObject {
            return false
        }
        
        if messageObject is NIMRobotObject {
            if let robotObject = messageObject as? NIMRobotObject {
                return !robotObject.isFromRobot
            }
            return false
        }
        
        return true
    }
    
    func canMessageBeCancelled(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        return canMessageBeRevoked(message) && message.deliveryState == NIMMessageDeliveryState.delivering && message.messageType != NIMMessageType.text
    }

    func canMessageBeRevoked(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        let canRevokeMessageByRole = canRevokeMessage(byRole: message)
        let isDeliverFailed = !message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryState.failed
        if !canRevokeMessageByRole || isDeliverFailed {
            return false
        }
        weak var messageObject = message.messageObject
        if (messageObject is NIMTipObject) || (messageObject is NIMNotificationObject) {
            return false
        }
        //自定义消息的删除
//        if messageObject is NIMCustomObject {
//            var attach = (message.messageObject as? NIMCustomObject)?.attachment as? IMMessageContentInfo
//            return attach?.canBeRevoked() ?? false
//        }
        return true
    }
    
    func canRevokeMessage(byRole message: NIMMessage) -> Bool {
        let isFromMe = message.from == NIMSDK.shared().loginManager.currentAccount()
        let isToMe = message.session?.sessionId == NIMSDK.shared().loginManager.currentAccount()

        var isRobotMessage = false
        weak var messageObject = message.messageObject
        if messageObject is NIMRobotObject {
            let robotObject = messageObject as? NIMRobotObject
            isRobotMessage = robotObject?.isFromRobot ?? false
        }
        return isFromMe && !isToMe && !isRobotMessage
    }
    
    func canMessageBeCopy(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        var copyText = false
        let ext = message.remoteExt ?? [:]
        
        if ext["usernames"] != nil {
            copyText = true
        }
        
        if message.messageType == NIMMessageType.text {
            copyText = true
        }

        if message.messageType == NIMMessageType.robot {
            let robotObject = message.messageObject as? NIMRobotObject
            copyText = !(robotObject?.isFromRobot)!
        }
        
        if message.messageType == NIMMessageType.custom {
            let object = message.messageObject as! NIMCustomObject
            
            if object.attachment is IMReplyAttachment {
                let attachment = object.attachment as? IMReplyAttachment
                if (attachment?.content == "") || attachment == nil || (!(attachment?.messageType == "0") && !(attachment?.messageType == "1") && !(attachment?.messageType == "100") && !(attachment?.messageType == "2")) {
                    copyText = false
                } else {
                    copyText = true
                }
            }
            
            if object.attachment is IMContactCardAttachment {
                copyText = false
            }
            
            if object.attachment is IMMiniProgramAttachment {
                copyText = false
            }
            
            if object.attachment is IMMessageContentInfo {
                copyText = false
            }
        }
        
        return copyText
    }
    
    func canMessageBeTranslated(_ messageModel: MessageData) -> Bool {
        if (messageModel.isTranslated ?? false) {
            return false
        }
        
        guard let message = messageModel.nimMessageModel else { return false }
        
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        let messageObject = message.messageObject
        if message.messageType == NIMMessageType.text {
            return true
        } else if messageObject is NIMCustomObject {
            let attach = (message.messageObject as? NIMCustomObject)?.attachment as? IMMessageContentInfo
            return attach?.canBeTranslated() ?? false
        } else {
            return false
        }
    }
    
    func canMessageBeVoiceToText(_ messageModel: MessageData) -> Bool {
        guard let message = messageModel.nimMessageModel else { return false }
        
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        return messageModel.nimMessageModel!.messageType == NIMMessageType.audio
    }
    
    func canStickerCollectionBeOpened(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        if message.deliveryState == NIMMessageDeliveryState.failed {
            return false
        }
        
        weak var messageobject = message.messageObject
        if (messageobject is NIMCustomObject) {
            if let object = messageobject as? NIMCustomObject , let attach = object.attachment as? IMStickerAttachment {
                if attach.chartletCatalog == "-1" {
                    return false
                }
                
                return true
            }
        }
        return false
    }
    
    func canMessageBeDeleted(_ message: NIMMessage) -> Bool {
        let messageObject = message.messageObject
        if messageObject is NIMTipObject {
            return false
        }

        if messageObject is NIMCustomObject {
            let object = message.messageObject as? NIMCustomObject
            let attachment = object?.attachment

            if attachment is IMTextTranslateAttachment {
                return false
            }
        }
        return true
    }
    
    func canMessageBeReplied(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        if !message.isReceivedMsg && message.deliveryState == NIMMessageDeliveryState.failed {
            return false
        }
        
        let messageobject = message.messageObject
        
        if messageobject is NIMImageObject {
            
        }
        
        if let object = messageobject as? NIMCustomObject {
            let attach = object.attachment as? IMMessageContentInfo
            return attach?.canBeReplied() ?? false
        }
        
        if messageobject is NIMNotificationObject {
            return false
        }
        if messageobject is NIMTipObject {
            return false
        }
        
        return true
    }
    
    func canMessageCollection(_ message: NIMMessage) -> Bool {
        if self.checkYidunAntiSpamIsEmpty(message) == false {
            return false
        }
        
        let messageObject = message.messageObject
        if messageObject is NIMTipObject {
            return false
        }
        if messageObject is NIMNotificationObject {
            return false
        }

        if message.messageType == .custom {
            if (messageObject is NIMCustomObject) {
                
                let object = message.messageObject as? NIMCustomObject
                let attachment = object?.attachment

                if attachment is IMMiniProgramAttachment {
                    return true
                }
                
                if attachment is IMSocialPostAttachment {
                    return true
                }
                
                if attachment is IMContactCardAttachment {
                    return true
                }
                
                if attachment is IMStickerCardAttachment {
                    return true
                }
                
                if attachment is IMVoucherAttachment {
                    return true
                }
                
                return false
            } else {
                return false
            }
        }
        return true
    }
    
    func canMessagePinned(_ message: NIMMessage) -> Bool {
        let messageObject = message.messageObject
        if messageObject is NIMTipObject {
            return false
        }
        if messageObject is NIMNotificationObject {
            return false
        }
        if message.messageType == .text || message.messageType == .image || message.messageType == .video
           || message.messageType == .audio || message.messageType == .file || message.messageType == .location{
            return true
        }

        if message.messageType == .custom {
            if let object = message.messageObject as? NIMCustomObject {
                let attachment = object.attachment
                if attachment is IMMeetingRoomAttachment {
                    return true
                }
                if attachment is IMContactCardAttachment {
                    return true
                }
                if attachment is IMRPSAttachment {
                    return true
                }
                if attachment is IMEggAttachment {
                    return true
                }
                return false
            }
        }
        return false
    }
    
    func formatAutoLoginMessage(_ error: NSError?) -> String? {
        var message: String? = nil
        if let err = error {
            message = String(format: "auto_login_failed".localized, err.localizedDescription)
        }
        
//        let domain = err.domain
//        let code = err.code ?? 0
//        if domain == NIMLocalErrorDomain {
//            if code ==  Int(NIMLocalErrorCode.autoLoginRetryLimit) {
//                message = "auto_login_limit".localized
//            }
//        } else if domain == NIMRemoteErrorDomain {
//            if code == Int(NIMRemoteErrorCode.codeInvalidPass) {
//                message = "wrong_password".localized
//            } else if code == Int(NIMRemoteErrorCode.codeExist) {
//                message = "currently_login_manual".localized
//            }
//        }
        
        return message
    }
    
    func netcallNotificationFormatedMessage(_ object: NIMNotificationObject) -> String {
        let content = object.content as! NIMNetCallNotificationContent
        var text = "unknown_message".localized
        switch content.eventType {
        case NIMNetCallEventType.miss:
            text = "chatroom_miss_call".localized
        case NIMNetCallEventType.bill:
            text = "text_duration".localized
            let duration = content.duration
            let durationDesc = String(format: " %02d:%02d", Int(duration) / 60, Int(duration ?? 0) % 60)
            text = text + durationDesc
        case NIMNetCallEventType.reject:
            text = "chatroom_rejected".localized
        case NIMNetCallEventType.noResponse:
            text = "chatroom_miss_call".localized
        default:
            break
        }
        return text
        //
    }
    
    func netcallNotificationFormatedMessage1(_ attachment: IMCallingAttachment) -> String {
        var text = "unknown_message".localized
        switch attachment.eventType {
        case .miss:
            text = "chatroom_miss_call".localized
        case .bill:
            text = "text_duration".localized
            let duration = attachment.duration
            let durationDesc = String(format: " %02d:%02d", Int(duration) / 60, Int(duration ?? 0) % 60)
            text = text + durationDesc
        case .reject:
            text = "chatroom_rejected".localized
        case .noResponse:
            text = "chatroom_miss_call".localized
        default:
            break
        }
        return text
    }
    
    func teamNotificationFormatedMessage(_ message: NIMMessage) -> String {
        let object = message.messageObject as? NIMNotificationObject
        let content = object?.content as! NIMTeamNotificationContent
        var formatedMessage = "unknown_message".localized
        
        let source = self.teamNotificationSourceName(message)
        let targets = self.teamNotificationTargetNames(message)
        let targetText: String = (targets.count > 1 ? targets.joined(separator: ",") : (targets.first)) ?? ""
        let teamName = self.teamNotificationTeamShowName(message)
        
        switch content.operationType {
            
        case NIMTeamOperationType.invite:
            var str: String = ""
            if let firstObject = targets.first {
                str = String(format: "chatroom_team_invitation_one_to_one".localized, source, firstObject)
            }
            if targets.count > 1 {
                str = str + String(format: "chatroom_team_waiting_people".localized, targets.count)
            }
            str = str + String(format: "chatroom_team_enter_group".localized, teamName)
            formatedMessage = str
            
        case NIMTeamOperationType.dismiss:
            formatedMessage = String(format: "chatroom_team_person_dismiss_group".localized, source, teamName)

        case NIMTeamOperationType.kick:
            var str: String = ""
            if let firstObject = targets.first {
                str = String(format: "chatroom_team_person_do_something".localized, source, firstObject)
            }
            if targets.count > 1 {
                str = str + String(format: "chatroom_team_waiting_people".localized, targets.count)
            }
            str = str + String(format: "chatroom_team_moving_from".localized, teamName)
            formatedMessage = str

        case NIMTeamOperationType.update:
            formatedMessage = String(format: "chatroom_team_update_info".localized, source, teamName)
    
        case NIMTeamOperationType.leave:
            formatedMessage = String(format: "chatroom_team_leave".localized, source, teamName)
            
        case NIMTeamOperationType.applyPass:
            if source == targetText {
                //说明是以不需要验证的方式进入
                formatedMessage = String(format: "chatroom_team_joined".localized, source, teamName)
            } else {
                formatedMessage = String(format: "chatroom_team_approval".localized, source, targetText)
            }
            
        case NIMTeamOperationType.transferOwner:
            formatedMessage = String(format: "chatroom_team_update_admin".localized, source, targetText)
        
        case NIMTeamOperationType.addManager:
            formatedMessage = String(format: "chatroom_team_add_admin".localized, targetText)
        
        case NIMTeamOperationType.removeManager:
            formatedMessage = String(format: "chatroom_team_remove_as_admin".localized, targetText)
        
        case NIMTeamOperationType.acceptInvitation:
            formatedMessage = String(format: "chatroom_team_accept_invite_group".localized, source, targetText)

        case NIMTeamOperationType.mute:
            let mute = false
            let muteStr = mute ? "chatroom_team_group_mute".localized : "group_unmute".localized
            let str = targets.joined(separator: ",")
            formatedMessage = String(format: "chatroom_team_get_mute".localized, str, source, muteStr)
        }
        
        return formatedMessage
    }
    
    func teamNotificationSourceName(_ message: NIMMessage) -> String {
        var source: String = ""
        let object = message.messageObject as? NIMNotificationObject
        let content = object?.content as? NIMTeamNotificationContent
        let currentAccount = NIMSDK.shared().loginManager.currentAccount()
        if content?.sourceID == currentAccount {
            source = "you".localized
        } else {
            source = SessionUtil.showNick(content?.sourceID!, in: message.session) ?? ""
        }
        return source
    }
    
    func teamNotificationTargetNames(_ message: NIMMessage) -> [String] {
        var targets: [String] = []
        let object = message.messageObject as? NIMNotificationObject
        let content = object?.content as? NIMTeamNotificationContent
        let currentAccount = NIMSDK.shared().loginManager.currentAccount()
        if let targetIDs = content?.targetIDs {
            for item in targetIDs {
                if item == currentAccount {
                    targets.append("you".localized)
                } else {
                    if let targetShowName = SessionUtil.showNick(item, in: message.session) {
                    targets.append(targetShowName)
                    }
                }
            }
        }
        return targets
    }
    
    func teamNotificationTeamShowName(_ message: NIMMessage) -> String {
        guard let sessionId = message.session?.sessionId else { return "" }
        let team = NIMSDK.shared().teamManager.team(byId: sessionId)
        let teamName = team?.type == NIMTeamType.normal ? "normal_team".localized : "chatroom_text_advance_group".localized
        return teamName
    }
    
    func chatroomNotificationFormatedMessage(_ message: NIMMessage) -> String {
        return ""
    }
    
    //自定义更多菜单的子按钮
    func configMoreMenus(options: NEMeetingOptions) {
        // 1. 创建更多菜单列表构建类，列表默认包含："邀请"、"聊天"
        var moreMenus = NEMenuItems.defaultMoreMenuItems() as! [NEMeetingMenuItem]
        
        // 2. 添加一个多选菜单项
        let newItem = NESingleStateMenuItem()
        newItem.itemId = 1000
        newItem.visibility = .VISIBLE_TO_HOST_ONLY
        newItem.singleStateItem = NEMenuItemInfo()
        newItem.singleStateItem.icon = "private-invite"
        newItem.singleStateItem.text = "meeting_private".localized
    
        moreMenus.append(newItem)
        // 3. 配置完成，设置参数字段
        options.fullMoreMenuItems = moreMenus
    }
    
    //获取群成员userId
    func fetchMembersTeam(teamId: String, completed: @escaping (([String])-> Void)){
        NIMSDK.shared().teamManager.fetchTeamMembers(teamId) { error, members in
            if let members = members {
                var memberIds = [String]()
                for member in members{
                    memberIds.append(member.userId ?? "")
                }
                completed(memberIds)
            }
        }
    }
    
    //从Yidun Label Id 获取lokalise
    func getLabelByYiDunId(id: Int) -> String {
        var label : String = ""
        
        switch id {
        case 100:
            label += "yidun_label_type_100".localized
        case 200:
            label += "yidun_label_type_200".localized
        case 260:
            label += "yidun_label_type_260".localized
        case 300:
            label += "yidun_label_type_300".localized
        case 400:
            label += "yidun_label_type_400".localized
        case 500:
            label += "yidun_label_type_500".localized
        case 600:
            label += "yidun_label_type_600".localized
        case 700:
            label += "yidun_label_type_700".localized
        case 900:
            label += "yidun_label_type_900".localized
        case 1100:
            label += "yidun_label_type_1100".localized
        default: break
        }
        return label
    }
    
    func showYiDunAlertMessage(jsonString: String) {
        if let data = jsonString.data(using: .utf8) {
            do {
                let jsonDecoder = JSONDecoder()
                let yidun = try jsonDecoder.decode(YiDunAntiSpamRes.self, from: data)
                if let ext = yidun.ext.last, let label = ext.antispam.labels.first {
                    var temp = "\("yidun_message_sensitive_content".localized)[\(ext.antispam.censorType):\(label.level)] \(self.getLabelByYiDunId(id: label.label))"
                    let alert = TSAlertController(title: "Error".localized, message: temp, style: .alert,  hideCloseButton: true, animateView: false, allowBackgroundDismiss: false)
                    let action = TSAlertAction(title: "text_got_it".localized, style: TSAlertActionStyle.default) { [weak self] (action) in
                        
                    }
                    
                    UIApplication.topViewController()?.presentPopup(alert: alert, actions: [action])
                }
            } catch {
                debugPrint(error.localizedDescription)
            }
        }
    }
    /// 查询服务器pinned list 同步到本地
    func synchronizeServiceToLocal(){
        /// 查询服务器pinned list
//        NIMSDK.shared().chatExtendManager.loadStickTopSessionInfos {[weak self] (error, infos) in
//            if let error = error {
//                print("Error: \(error)")
//                return
//            }
//            if let infosDictionary = infos as? [NIMSession: NIMStickTopSessionInfo] {
//                for (session, info) in infosDictionary {
//                    
//                    NTESSessionUtil.addRecentSessionMark(session, type: .top)
//                }
//            }
//        }
    }
}
