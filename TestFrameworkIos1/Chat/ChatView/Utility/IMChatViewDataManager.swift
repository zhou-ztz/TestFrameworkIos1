//
//  IMChatViewDataManager.swift
//  Yippi
//
//  Created by Tinnolab on 22/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
//import NIMPrivate

class IMChatViewDataManager {
    var currentSession: NIMSession
    var unreadCount: Int = 0
    var isSecretMessage: Bool = false
    var secretMessageDuration: Int = 0
    var lastMessage: NIMMessage?
    /// 记录是否需要去服务器拉取消息
    var isNeedFetchMessageForService: Bool = false
    
    init(session: NIMSession, unreadCount: Int) {
        self.currentSession = session
        self.unreadCount = unreadCount
    }
    
    func collectionMsgType(_ message: NIMMessage) -> MessageCollectionType {
        let msgType = message.messageType
        switch msgType {
        case .text:
            return MessageCollectionType.text
        case .image:
            return MessageCollectionType.image
        case .audio:
            return MessageCollectionType.audio
        case .video:
            return MessageCollectionType.video
        case .location:
            return MessageCollectionType.location
        case .notification:
            return MessageCollectionType.unknown
        case .file:
            return MessageCollectionType.file
        case .tip:
            return MessageCollectionType.unknown
        case .robot:
            return MessageCollectionType.unknown
        case .custom:
            if let messageObject = message.messageObject as? NIMCustomObject, let attachment = messageObject.attachment  {
                if attachment.isKind(of: IMContactCardAttachment.self) {
                    return MessageCollectionType.nameCard
                } else if attachment.isKind(of: IMStickerCardAttachment.self) {
                    return MessageCollectionType.sticker
                } else if attachment.isKind(of: IMSocialPostAttachment.self) {
                    return MessageCollectionType.link
                } else if attachment.isKind(of: IMMiniProgramAttachment.self) {
                    return MessageCollectionType.miniProgram
                } else if attachment.isKind(of: IMVoucherAttachment.self) {
                    return MessageCollectionType.voucher
                } else if attachment.isKind(of: IMMeetingRoomAttachment.self) {
                    return MessageCollectionType.meeting
                } else if attachment.isKind(of: IMEggAttachment.self) {
                    return MessageCollectionType.egg
                } else if attachment.isKind(of: IMRPSAttachment.self) {
                    return MessageCollectionType.rps
                }   
            }
        default:
            return MessageCollectionType.unknown
        }
        return MessageCollectionType.unknown
    }
    
    func collectionMsgData(_ message: NIMMessage, isType: Bool = false) -> String? {
        guard let session = message.session else {
            return nil
        }
        var sessionType = "P2P"
        if session.sessionType != .P2P {
            sessionType = "Team"
        }
        //, "time": message.timestamp
        var dict: [String: Any] = ["sessionId": session.sessionId, "sessionType": sessionType, "content": message.text ?? "", "fromAccount": message.from ?? ""]
        if isType {
            dict["type"] = collectionMsgType(message).rawValue
        }
        var dictttt = NSDictionary()
        dictttt = dict as NSDictionary
        guard let messageObject = message.messageObject else {
            let data = try? JSONSerialization.data(withJSONObject: dictttt, options: [.prettyPrinted])
            guard let jsonStr = String(data: data!, encoding: .utf8) else {
                return nil
            }
            return jsonStr
        }
        
        var dictStr = "{}"
        if let object = messageObject as? NIMImageObject {
            let ext = NSString(string: object.thumbPath ?? "")
            let imageAttachment = IMImageCollectionAttachment(md5: object.md5 ?? "", url: object.url ?? "", size: object.fileLength, h: object.size.height , w: object.size.width , name: object.displayName ?? "", ext: ext.pathExtension, sen: "nim_default_im", path: object.path ?? "", force_upload: false )
            dictStr = imageAttachment.encode()
            
        }
        
        if let object = messageObject as? NIMAudioObject {
            let ext = NSString(string: object.path ?? "")
            let audioAttachment = IMAudioCollectionAttachment(md5: object.md5 ?? "", url: object.url ?? "", size: 0, dur: object.duration , ext: ext.pathExtension )
            dictStr = audioAttachment.encode()
        }
        
        if let object = messageObject as? NIMVideoObject {
            let ext = NSString(string: object.path ?? "")
            let videoAttachment = IMVideoCollectionAttachment(md5: object.md5 ?? "", url: object.url ?? "", size: object.fileLength, dur: object.duration, h: object.coverSize.height , w: object.coverSize.width , name: object.displayName ?? "", ext: ext.pathExtension, coverUrl: object.coverUrl ?? "")
            dictStr = videoAttachment.encode()
        }
        
        if let object = messageObject as? NIMLocationObject {
            let location = IMLocationCollectionAttachment(title: object.title ?? "", lat: object.latitude, lng: object.longitude)
            dictStr = location.encode()
        }
        
        if let object = messageObject as? NIMFileObject {
            let ext = NSString(string: object.path ?? "")
            let fileAttachment = IMFileCollectionAttachment(md5: object.md5 ?? "", url: object.url ?? "", size: object.fileLength, sence: "nim_msg" , name: object.displayName ?? "", ext: ext.pathExtension )
            dictStr = fileAttachment.encode()
        }
        
        if let object = messageObject as? NIMCustomObject{
            if let attachment = object.attachment {
                dictStr = attachment.encode()
            }
        }
        
        dict["attachment"] = dictStr
        let data = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted])
        guard let jsonStr = String(data: data!, encoding: .utf8) else {
            return nil
        }
        print("jsonStr = \(jsonStr)")
        return jsonStr
    }
    
    func contentView(_ message: MessageData) -> BaseContentView {
        let msgType = message.nimMessageModel?.messageType
        switch msgType {
        case .text:
            if message.nimMessageModel?.messageObject is NIMTipObject {
                return InfoMessageContentView(messageModel: message)
            }
            return TextContentView(messageModel: message)
        case .image:
            if message.messageList.count >= 4 {
                // if message count more than 4 mean is stack image
                return MultiImageMessageContentView(messageModel: message)
            }
            return VideoImageMessageContentView(messageModel: message)
        case .audio:
            return VoiceMessageContentView(messageModel: message)
        case .video:
            return VideoImageMessageContentView(messageModel: message)
        case .location:
            return LocationContentView(messageModel: message)
        case .notification:
            return InfoMessageContentView(messageModel: message)
        case .file:
            return FilesMessageContentView(messageModel: message)
        case .tip:
            return InfoMessageContentView(messageModel: message)
        case .robot:
            return UnknownMessageContentView(messageModel: message)
        case .custom:
            let messageObject =  message.nimMessageModel?.messageObject
            if (messageObject is NIMCustomObject) {
                if let attach = (messageObject as! NIMCustomObject).attachment {
                    print("attach = \(attach)")
                    if let attachment = attach as? IMMessageContentInfo {
                        return attachment.cellContent(message)
                    }
                    
                    return UnknownMessageContentView(messageModel: message)
                }
            }
            return UnknownMessageContentView(messageModel: message)
        case .none:
            return UnknownMessageContentView(messageModel: message)
        case .some(_):
            return UnknownMessageContentView(messageModel: message)
        }
    }
    
    func updateIsSecretMessage(_ on: Bool, duration: Int) {
        isSecretMessage = on
        secretMessageDuration = duration
    }
    //messageId 查询本地 message
    func fetchMessageInDB(messageIds: [String]) -> [NIMMessage]?{
        let messages = NIMSDK.shared().conversationManager.messages(in: self.currentSession, messageIds: messageIds)
        return messages
    }
}

extension IMChatViewDataManager {
    func sendMessage(_ message: NIMMessage, _ mentionUser: [String]? = nil) {
        let messageToSend = self.generateMessage(message, mentionUser ?? [])
        
        do {
            try NIMSDK.shared().chatManager.send(messageToSend, to: self.currentSession)
        } catch {
            
        }
    }
    
    // By Kit Foong (Update message session id and type into apns payload)
    func updateApnsPayloadBySessonId(_ message: NIMMessage, _ sessionIdString: String, _ isTeam: Bool) -> NIMMessage {
        var sessionId: String = ""
        var sessionType: Int = 0
        
        sessionType = isTeam ? 1 : 0
        
        if (sessionType == 0) {
            sessionId =  NIMSDK.shared().loginManager.currentAccount() ?? ""
        } else {
            sessionId = sessionIdString
            let setting = NIMMessageSetting()
            setting.teamReceiptEnabled = true
            message.setting = setting
        }
        
        if sessionId.isEmpty == false {
            var parameters: String = ""
            parameters = String(format: "{\"sessionID\": \"%@\", \"sessionType\": \"%@\"}", sessionId, sessionType.stringValue)
            print(parameters)
            
            if let data = parameters.data(using: String.Encoding.utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    print(json)
                    message.apnsPayload = json
                } catch {
                    print("Something went wrong")
                }
            }
        }
        
        return message
    }
    
    func updateApnsPayload(_ message: NIMMessage) -> NIMMessage {
        var sessionId: String = ""
        var sessionType: Int = 0
        
        switch self.currentSession.sessionType {
        case .P2P:
            sessionType = 0
            sessionId = NIMSDK.shared().loginManager.currentAccount() ?? ""
            break;
        case .team:
            sessionType = 1
            sessionId = self.currentSession.sessionId
            let setting = NIMMessageSetting()
            setting.teamReceiptEnabled = true
            message.setting = setting
            break;
        default:
            break;
        }
        
        if sessionId.isEmpty == false {
            var parameters: String = ""
            parameters = String(format: "{\"sessionID\": \"%@\", \"sessionType\": \"%@\"}", sessionId, sessionType.stringValue)
            print(parameters)
            
            if let data = parameters.data(using: String.Encoding.utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    print(json)
                    message.apnsPayload = json
                } catch {
                    print("Something went wrong")
                }
            }
        }
        
        return message
    }
    
    func generateMessage(_ message: NIMMessage, _ mentionUser: [String]) -> NIMMessage {
        var remoteExt: [String: Any] = [:]
        if isSecretMessage {
            remoteExt = ["secretChatTimer": self.secretMessageDuration]
            if mentionUser.count > 0{
                remoteExt = ["secretChatTimer": self.secretMessageDuration, "usernames": mentionUser, ]
            }
            message.apnsContent = "Secret message"
            message.remoteExt = remoteExt
            message.setting?.apnsWithPrefix = true
            message.setting?.historyEnabled = false
            message.setting?.syncEnabled = false
        }
                
        if mentionUser.count > 0 {
            var isMentionAll: Bool = mentionUser.contains(where: { $0 == "rw_text_all_people".localized })
            remoteExt["usernames"] = mentionUser
            
            if isMentionAll {
                remoteExt["mentionAll"] = "rw_text_all_people".localized
            }
            
            //message.apnsContent = "Mentions"
            message.remoteExt = remoteExt

            message.setting?.apnsWithPrefix = true
            message.setting?.historyEnabled = false
            message.setting?.syncEnabled = false
            let apnsOption = NIMMessageApnsMemberOption()
            apnsOption.userIds = isMentionAll ? nil : mentionUser
            apnsOption.forcePush = true
            let userId = NIMSDK.shared().loginManager.currentAccount()
//            let info: NIMKitInfo = NIMBridgeManager.sharedInstance().getUserInfo(userId)
//            apnsOption.apnsContent = message.text
//            //apnsOption.apnsContent = String(format: "tagged_you".localized, info.showName)
//            message.apnsMemberOption = apnsOption
        }
        
        return self.updateApnsPayload(message)
    }
    
    func textMessage(with text: String) -> NIMMessage {
        let textMessage = NIMMessage()
        textMessage.text = text
        return textMessage
    }
    
    func imageMessage(with image: UIImage? = nil, imagePath: String? = nil, isFullImage: Bool? = false) -> NIMMessage? {
        var imageObj: NIMImageObject? = nil
        
        if let img = image {
            imageObj = NIMImageObject(image: img, scene: NIMNOSSceneTypeMessage)
        }
        
        if let path = imagePath {
            imageObj = NIMImageObject(filepath: path, scene: NIMNOSSceneTypeMessage)
        }
        
        guard let imageObject = imageObj else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: Date())
        imageObject.displayName = dateString
        
        let option = NIMImageOption()
        if isFullImage! {
            option.compressQuality = 1.0
        } else {
            option.compressQuality = 0.8
        }
        imageObject.option = option
        
        let message = NIMMessage()
        message.messageObject = imageObject
        message.apnsContent = "sent_a_img".localized
        
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        
        return message
    }
    
    func videoMessage(with videoPath: String) -> NIMMessage {
        let videoObj: NIMVideoObject = NIMVideoObject(sourcePath: videoPath, scene: NIMNOSSceneTypeMessage)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: Date())
        videoObj.displayName = String(format: "sent_a_video_by", dateString)
        
        let message = NIMMessage()
        message.messageObject = videoObj
        message.apnsContent = "sent_a_video_msg".localized
        
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        
        return message
    }
    
    func audioMessage(with audioFile: String) -> NIMMessage {
        let audioObject = NIMAudioObject(sourcePath: audioFile)
        let message = NIMMessage()
        message.messageObject = audioObject
        message.apnsContent = "sent_a_voice_msg".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        return message
    }
    
    func fileMessage(with filePath: String? = nil, fileData: Data? = nil, extensionString: String? = nil) -> NIMMessage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = dateFormatter.string(from: Date())
        
        var fileObject: NIMFileObject? = nil
        
        let url = URL(fileURLWithPath: filePath ?? "")
        let fileName: String = url.lastPathComponent ?? ""
        if let filepath = filePath {
            fileObject = NIMFileObject(sourcePath: filepath)
            fileObject?.displayName = fileName
        }
        
        if let filedata = fileData, let ext = extensionString {
            fileObject = NIMFileObject(data: filedata, extension: ext)
            fileObject?.displayName = "\(UUID().uuidString.md5).\(ext)"
        }
        
        let message = NIMMessage()
        message.messageObject = fileObject
        message.apnsContent = "sent_a_file".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        message.text = fileName
        return message
    }
    
    func rpsMessage() -> NIMMessage {
        let value = arc4random() % 3 + 1
        let attachment = IMRPSAttachment()
        attachment.value = Int(value)
        
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = "sent_a_caiquan".localized
        return message
    }
    
//    func locationMessage(with location: NIMKitLocationPoint) -> NIMMessage {
//        let locationObject = NIMLocationObject(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, title: location.title)
//        
//        let message = NIMMessage()
//        message.messageObject = locationObject
//        message.apnsContent = "send_location".localized
//        return message
//    }
    
    func snapMessage(with image: UIImage? = nil, imagePath: String? = nil) -> NIMMessage {
        let attachment = IMSnapchatAttachment()
        
        if let image = image {
            attachment.snapMessage(image)
        }
        if let path = imagePath {
            attachment.snapMessage(path)
        }
        
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = "sent_a_snap".localized
        
        let setting: NIMMessageSetting = NIMMessageSetting()
        setting.historyEnabled = false
        setting.roamingEnabled = false
        setting.syncEnabled    = false
        message.setting = setting
        
        return message
    }
    
    func stickerMessage(with bundleId: String, stickerUrl: String, stickerId: String) -> NIMMessage {
        let attachment = IMStickerAttachment()
        attachment.chartletId = stickerUrl
        attachment.stickerId = stickerId
        attachment.chartletCatalog = bundleId
        
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = "tt".localized
        
        return message
    }
    
    func contactCardMessage(with memberId: String) -> NIMMessage {
        let attachment = IMContactCardAttachment()
        attachment.memberId = memberId
        
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = "recent_msg_desc_contact".localized
        message.text = NIMSDKManager.shared.getAvatarIcon(userId: memberId).nickname ?? ""
        
        return message
    }
    
    func tipMessage(with tipString: String) -> NIMMessage {
        let message = NIMMessage()
        let tipObject = NIMTipObject()
        message.messageObject = tipObject
        message.text = tipString
        let setting = NIMMessageSetting()
        setting.apnsEnabled = false
        setting.shouldBeCounted = false
        message.setting = setting
        return message
    }
    
    func eggMessage(with rid: Int, tid: String? = nil, uid: [String]? = nil, messageStr: String) -> NIMMessage? {
        let attachment = IMEggAttachment()
        attachment.eggId = "\(rid)"
        attachment.senderId = NIMSDK.shared().loginManager.currentAccount()
        attachment.message = messageStr
        
        if let tid = tid {
            attachment.tid = tid
        }
        
        let uids = NSMutableArray()
        if let uid = uid {
            for item in uid {
                uids.add(item)
            }
        }
        attachment.uids = uids
        
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = NSLocalizedString("title_send_egg", comment: "")
        
        let setting = NIMMessageSetting()
        message.setting = setting
        message.text = messageStr
        
        return message
    }
    
    func replyMessage(with attachment: IMReplyAttachment) -> NIMMessage {
        let message = NIMMessage()
        let object = NIMCustomObject()
        object.attachment = attachment
        message.messageObject = object
        message.apnsContent = attachment.message
        message.text = attachment.content
        return message
    }
    
    func socialPostMessage(link: String, contentUrl: String) -> NIMMessage {
        let attachment = IMSocialPostAttachment()
        attachment.socialPostMessage(linkUrl: link, contentUrl: contentUrl)
        
        let message = NIMMessage()
        let object = NIMCustomObject()
        object.attachment = attachment
        message.messageObject = object
        
        return message
    }
    
    func translateMessage(_ data: MessageData, with result: String) -> MessageData {
        guard let message = data.nimMessageModel else { return data }
        var messageText = message.text
        if let object = message.messageObject as? NIMCustomObject, let oriAttachment = object.attachment as? IMReplyAttachment {
            messageText = oriAttachment.content
        }
        
        let attachment = IMTextTranslateAttachment()
        attachment.oriMessageId = message.messageId
        attachment.originalText = messageText ?? ""
        attachment.translatedText = result
        attachment.isOutgoingMsg = message.isOutgoingMsg
        
        let newMessage = NIMMessage()
        let object = NIMCustomObject()
        object.attachment = attachment
        newMessage.messageObject = object
        
        let setting = NIMMessageSetting()
        setting.historyEnabled = false
        setting.roamingEnabled = false
        
        newMessage.setting = setting
        newMessage.localExt = [
            "translated_message": NSNumber(value: true)
        ]
        return MessageData(newMessage)
    }
    
    func updateTranslateMessage(for data: MessageData, with result: String) -> MessageData {
        ((data.nimMessageModel?.messageObject as? NIMCustomObject)?.attachment as? IMTextTranslateAttachment)?.translatedText = result
        return data
    }
}

extension TimeInterval {
    func messageTime(showDetail: Bool) -> String? {
        //今天的时间
        let nowDate = Date()
        let msgDate = Date(timeIntervalSince1970: self)
        var result: String? = nil
        
        let components = Set<Calendar.Component>([.year, .month, .day, .weekday, .hour, .minute])
        let nowDateComponents = Calendar.current.dateComponents(components, from: nowDate)
        let msgDateComponents = Calendar.current.dateComponents(components, from: msgDate)
        
        let hour = msgDateComponents.hour
        let OnedayTimeIntervalValue: Double = 24 * 60 * 60 //一天的秒数
        
        result = self.getPeriodOfTime(hour!, withMinute: msgDateComponents.minute!)
        
        let isSameMonth = (nowDateComponents.year == msgDateComponents.year) && (nowDateComponents.month == msgDateComponents.month)
        let isSameYear = nowDateComponents.year == msgDateComponents.year
        
        if isSameMonth && (nowDateComponents.day == msgDateComponents.day) {
            //同一天,显示时间
            result = "chatroom_text_today".localized
        } else if isSameMonth && (nowDateComponents.day == (msgDateComponents.day! + 1)) {
            //昨天
            result = "chatroom_yesterday".localized
        } else if isSameMonth && (nowDateComponents.day == (msgDateComponents.day! + 2)) {
            //前天
            result = "chatroom_twodaysago".localized
        } else if nowDate.timeIntervalSince(msgDate) < 7 * OnedayTimeIntervalValue {
            //一周内
            let weekDay = SessionUtil.weekdayStr(msgDateComponents.weekday ?? 1)
            result = weekDay
        } else if isSameYear && Double(nowDate.timeIntervalSince(msgDate)) > (7 *  OnedayTimeIntervalValue) {
            //一年内
            let formatter = DateFormatter()
            formatter.dateFormat = "LLL"
            let month = formatter.string(from: msgDate)
            let dateDay = msgDateComponents.day.orZero
            let day = String(format: "chatroom_same_year_format".localized, month, dateDay)
            result = day
        } else {
            //显示日期
            let formatter = DateFormatter()
            formatter.dateFormat = "LLL"
            let month = formatter.string(from: msgDate)
            let dateDay = msgDateComponents.day.orZero
            let dateYear = msgDateComponents.year.orZero
            let day = String(format: "chatroom_different_year_format".localized, dateYear, month, dateDay)
            result = day
        }
        return result
    }
    
    private func getPeriodOfTime(_ time: Int, withMinute minute: Int) -> String? {
        let totalMin = time * 60 + minute
        var showPeriodOfTime = ""
        if totalMin > 0 && totalMin <= 5 * 60 {
            showPeriodOfTime = "chatroom_text_morning".localized
        } else if totalMin > 5 * 60 && totalMin < 12 * 60 {
            showPeriodOfTime = "chatroom_text_am".localized
        } else if totalMin >= 12 * 60 && totalMin <= 18 * 60 {
            showPeriodOfTime = "chatroom_text_pm".localized
        } else if (totalMin > 18 * 60 && totalMin <= (23 * 60 + 59)) || totalMin == 0 {
            showPeriodOfTime = "chatroom_text_night".localized
        }
        return showPeriodOfTime
    }
}
