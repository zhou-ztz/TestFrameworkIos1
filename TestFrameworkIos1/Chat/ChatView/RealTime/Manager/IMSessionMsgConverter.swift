//
//  IMSessionMsgConverter.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/2/10.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMSessionMsgConverter: NSObject {
    
    static let shared = IMSessionMsgConverter()
    
    func msgWithText(text: String) -> NIMMessage? {
        let textMessage  = NIMMessage()
        textMessage.text  = text
        return textMessage
    }

    func msgWithImage(image: UIImage) -> NIMMessage {
        let imageObject = NIMImageObject(image: image)
        return self.generateImageMessage(imageObject: imageObject)!
    }
    func msgWithImagePath(path: String) -> NIMMessage {
        let imageObject = NIMImageObject(filepath: path)
        return self.generateImageMessage(imageObject: imageObject)!
    }
  
    func generateImageMessage(imageObject: NIMImageObject) -> NIMMessage? {
        let dateFormatter = DateFormatter()
        dateFormatter.date(from: "yyyy-MM-dd HH:mm")
        
        let dateString = dateFormatter.string(from: Date())
        imageObject.displayName = dateString
        let option = NIMImageOption()
        option.compressQuality  = 0.8
        imageObject.option = option
        let message = NIMMessage()
        message.messageObject   = imageObject
        message.apnsContent = "sent_a_img".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        return message
    }
    
    func msgWithAudio(filePath: String) -> NIMMessage? {
        let audioObject = NIMAudioObject(sourcePath: filePath)
        let message = NIMMessage()
        message.messageObject = audioObject
        message.apnsContent = "sent_a_voice_msg".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        return message
    }
    
    func msgWithVideo(filePath: String) -> NIMMessage? {
        let dateFormatter = DateFormatter()
        dateFormatter.date(from: "yyyy-MM-dd HH:mm")
        let dateString = dateFormatter.string(from: Date())
        let videoObject = NIMVideoObject(sourcePath: filePath)
        videoObject.displayName = "sent_a_video_by".localized + dateString
        let message = NIMMessage()
        message.messageObject = videoObject
        message.apnsContent = "sent_a_video_msg".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        return message
    }
    
//    func msgWithJenKenPon(attachment: NTESJanKenPonAttachment) -> NIMMessage? {
//        let message          = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = "sent_a_caiquan".localized
//        return message
//    }
//    
//    func msgWithSnapchatAttachment(attachment: NTESSnapchatAttachment) -> NIMMessage? {
//        let message          = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = "sent_a_snap".localized
//        
//        let setting = NIMMessageSetting()
//        setting.historyEnabled = false
//        setting.roamingEnabled = false
//        setting.syncEnabled    = false
//        message.setting = setting
//        return message
//    }
    
    func msgWithFilePath(path: String) -> NIMMessage? {
        let fileObject = NIMFileObject(sourcePath: path)
        let displayName     = URL(string: path)?.lastPathComponent
        fileObject.displayName    = displayName
        let message       = NIMMessage()
        message.messageObject     = fileObject
        message.apnsContent = "sent_a_file".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        message.text = displayName
        return message
    }

    func msgWithFileData(data: Data, extensionString: String) -> NIMMessage? {
        let fileObject = NIMFileObject(data: data, extension: extensionString)
        var displayName = ""
        if (!extensionString.isEmpty) {
            displayName     = UUID().uuidString.md5 + extensionString
        }else{
            displayName     = UUID().uuidString.md5
        }
        fileObject.displayName   = displayName
        let message       = NIMMessage()
        message.messageObject    = fileObject
        message.apnsContent = "sent_a_file".localized
        let setting = NIMMessageSetting()
        setting.scene = NIMNOSSceneTypeMessage
        message.setting = setting
        message.text = displayName
        return message
    }
    
    func msgWithChartletAttachment(attachment: IMStickerAttachment) -> NIMMessage?{
        let message          = NIMMessage()
        let customObject     = NIMCustomObject()
        customObject.attachment           = attachment
        message.messageObject             = customObject
        message.apnsContent = "tt".localized
        return message
    }

//    func msgWithContactCardAttachment(attachment: NTESContactCardAttachment) -> NIMMessage? {
//        let message          = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = "nc".localized
//        message.text = NIMSDKManager.shared.getAvatarIcon(userId: attachment.memberId).nickname ?? ""
//        return message
//    }
    
//    func msgWithWhiteboardAttachment(attachment: NTESWhiteboardAttachment) -> NIMMessage? {
//        let message          = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        let setting = NIMMessageSetting()
//        setting.apnsEnabled        = false
//        message.setting            = setting
//
//        return message
//    }


    func msgWithTip(tip: String) -> NIMMessage? {
        let message          = NIMMessage()
        let tipObject    = NIMTipObject()
        message.messageObject      = tipObject
        message.text               = tip
        let setting = NIMMessageSetting()
        setting.apnsEnabled        = false
        setting.shouldBeCounted    = false
        message.setting            = setting
        return message
    }

//    func msgWithRedPacket(attachment: NTESRedPacketAttachment) -> NIMMessage? {
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = "send_a_redpacket".localized
//        
//        let setting = NIMMessageSetting()
//        setting.historyEnabled     = false
//        message.setting            = setting
//        return message
//    }
//
//    func msgWithRedPacketTip(attachment: NTESRedPacketTipAttachment) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        
//        let setting = NIMMessageSetting()
//        setting.apnsEnabled        = false
//        setting.shouldBeCounted    = false
//        setting.historyEnabled     = false
//        message.setting            = setting
//        return message
//    }
//    
//    func msgWithEggAttachment(attachment: NTESEggAttachment) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = "title_send_egg".localized
//        
//        let setting = NIMMessageSetting()
//        setting.historyEnabled = false
//        setting.roamingEnabled = false
//        setting.syncEnabled    = false
//        message.setting = setting
//        message.text = attachment.message
//        
//        return message
//    }
//
//    func msgWithReplyMessage(attachment: NTESMessageReplyAttachment) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.apnsContent = attachment.message
//        message.text = attachment.content
//        return message
//    }
//    
//    func msgWithStickerCardAttachment(attachment: NTESStickerCardAttachment) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.text                      = attachment.bundleName
//        return message;
//    }
//
//    func msgWithShareAttachment(attachment: NTESShareAttachment) -> NIMMessage? {
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        return message
//    }
//
//    func msgWithMiniProgramAttachment(attachment: NTESMiniProgramAttachment) -> NIMMessage? {
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        return message
//    }
//
//    func msgWithSecretMessageAttachment(attachment: NTESSecretMessageAttachment) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        return message
//    }
//
//    func msgWithSecretMessageTextAttachment(attachment: NTESSecretMessageAttachment, text: String) -> NIMMessage? {
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//        message.text        = text
//        
//        return message
//    }
//
//    func msgWithSecretMessageTextAttachment(attachment: NTESSecretMessageAttachment, image: UIImage) -> NIMMessage? {
//        let  imageObject = NIMImageObject(image: image)
//        return self.generateImageMessage(imageObject: imageObject)!
//    }
//    
//    func msgWithMeetingControlAttachment(attachment: NTESMeetingControlAttachment) -> NIMMessage? {
//        let message             = NIMMessage()
//        let customObject        = NIMCustomObject()
//        customObject.attachment = attachment
//        message.messageObject   = customObject
//        
//        let setting = NIMMessageSetting()
//        setting.historyEnabled  = false
//        setting.roamingEnabled  = false
//        setting.syncEnabled     = false
//        setting.shouldBeCounted = false
//        setting.apnsEnabled     = false
//        message.setting = setting
//        
//        return message
//    }
//    
//    func msgWithLike() -> NIMMessage? {
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        let attachment = IMLikeAttachment()
//        customObject.attachment           = attachment
//        message.messageObject             = customObject
//
//        return message;
//    }
//
//    func msgWithPresent(type: Int) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        let attachment = NTESPresentAttachment()
//        attachment.presentType     = type
//        attachment.count           = 1
//        customObject.attachment    = attachment
//        message.messageObject      = customObject
//        return message
//    }
//    
//    func msgWithLiveTip(amount: String) -> NIMMessage?{
//        let message               = NIMMessage()
//        let customObject     = NIMCustomObject()
//        let attachment = NTESLiveTipAttachment()
//        attachment.amount          = amount
//        customObject.attachment    = attachment
//        message.messageObject      = customObject
//        return message
//    }
//
//    func msgWithTextTranslateMessage(message: NIMMessage , resultString: String) -> NIMMessage?{
//        var messageText = message.text
//        let object = message.messageObject as! NIMCustomObject
//        //100
//        if (message.messageType == .custom && ((object.attachment?.isKind(of: NTESMessageReplyAttachment.self)) != nil)) {
//             let attachment = object.attachment as! NTESMessageReplyAttachment
//            messageText = attachment.content
//        }
//        
//        let attachment = NTESTextTranslateAttachment()
//        
//        attachment.oriMessageId = message.messageId
//        attachment.originalText = messageText
//        attachment.translatedText = resultString
//        attachment.isOutgoingMsg = message.isOutgoingMsg
//        
//        let newMessage = NIMMessage()
//        let customObject = NIMCustomObject()
//        customObject.attachment = attachment
//        
//        let setting = NIMMessageSetting()
//        setting.historyEnabled  = false
//        setting.roamingEnabled  = false
//        setting.syncEnabled     = false
//        setting.shouldBeCounted = false
//        setting.apnsEnabled     = false
//       
//        newMessage.messageObject = customObject
//        newMessage.timestamp = message.timestamp
//        newMessage.setting = setting
//        newMessage.localExt = ["translated_message": true]
//       
//        return newMessage
//    }
//    
//    func msgWithUpdateTextTranslateMessage(message: NIMMessage, resultString: String) -> NIMMessage? {
//        let object = message.messageObject as! NIMCustomObject
//        let attachment = object.attachment as! NTESTextTranslateAttachment
//        
//        let newAttachment = attachment
//        newAttachment.translatedText = resultString
//        
//        let newMessage = message
//        let newCustomObject = NIMCustomObject()
//        newCustomObject.attachment = newAttachment
//        newMessage.messageObject = newCustomObject
//        
//        return newMessage
//    }
//

}
