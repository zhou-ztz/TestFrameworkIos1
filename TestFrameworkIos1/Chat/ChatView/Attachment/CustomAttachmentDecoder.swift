//
//  CustomAttachmentDecoder.swift
//  Yippi
//
//  Created by Tinnolab on 13/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class CustomAttachmentDecoder: NSObject, NIMCustomAttachmentCoding {
    func decodeAttachment(_ content: String?) -> NIMCustomAttachment? {
        guard let _content = content, let data = _content.data(using: .utf8) else { return nil }
        
        do {
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary {
                print(dict)
                let tt = dict.object(forKey: CMType) as? Int ?? Int(dict.object(forKey: CMType) as? String ?? "-1")
                let type = CustomMessageType(rawValue: tt ?? -1)
                let data = dict.object(forKey: CMData) as? NSDictionary ?? NSDictionary()
                let info = dict.object(forKey: CMInfo) as? NSDictionary ?? NSDictionary()
                
                switch type {
                case .RPS:
                    let attachment = IMRPSAttachment()
                    attachment.value = data.jsonInt(CMValue)
                    return attachment
                case .Snapchat:
                    let attachment = IMSnapchatAttachment()
                    attachment.md5 = data.jsonString(CMMD5)
                    attachment.url = data.jsonString(CMURL)
                    attachment.isFired = dict.jsonBool(CMFIRE)
                    return attachment
                case .Sticker:
                    let attachment = IMStickerAttachment()
                    attachment.chartletCatalog = data.jsonString(CMCatalog)
                    attachment.stickerId = data.jsonString(CMStickerId)
                    attachment.chartletId = data.jsonString(CMChartlet)
                    return attachment
                case .ContactCard:
                    let attachment = IMContactCardAttachment()
                    attachment.memberId = data.jsonString(CMContactCard)
                    return attachment
                case .Egg:
                    let attachment = IMEggAttachment()
                    attachment.eggId = data.jsonString(CMEggId)
                    attachment.senderId = data.jsonString(CMEggSendId)
                    attachment.tid = data.jsonString(CMEggOpenId)
                    attachment.message = data.jsonString(CMEggMessage)
                    if let uids = data.jsonArray(CMEggUIDs) {
                        attachment.uids = uids
                    }
                    return attachment
                case .Like:
                    let attachment = IMLikeAttachment()
                    return attachment
                case .Reply:
                    let attachment = IMReplyAttachment()
                    attachment.message = data.jsonString(CMReplyMessage)
                    attachment.content = data.jsonString(CMReplyContent)
                    attachment.name = data.jsonString(CMReplyName)
                    attachment.username = data.jsonString(CMReplyUserName)
                    attachment.image = data.jsonString(CMReplyImageURL)
                    attachment.messageID = data.jsonString(CMReplyMessageID)
                    attachment.videoURL = data.jsonString(CMReplyThumbURL)
                    attachment.messageType = data.jsonString(CMReplyMessageType)
                    attachment.messageCustomType = data.jsonString(CMReplyMessageCustomType)
                    return attachment
                case .StickerCard:
                    let attachment = IMStickerCardAttachment()
                    attachment.bundleID = data.jsonString(CMStickerBundleId)
                    attachment.bundleIcon = data.jsonString(CMStickerIconImage)
                    attachment.bundleName = data.jsonString(CMStickerName)
                    attachment.bundleDescription = data.jsonString(CMStickerDiscription)
                    attachment.bundleUrl = data.jsonString(CMRStickerURL)
                    return attachment
                case .SocialPost:
                    let attachment = IMSocialPostAttachment()
                    attachment.postUrl = data.jsonString(CMShareURL)
                    attachment.imageURL = data.jsonString(CMShareImage)
                    attachment.title = data.jsonString(CMShareTitle)
                    attachment.desc = data.jsonString(CMShareDescription)
                    attachment.contentType = data.jsonString(CMShareContentType)
                    attachment.contentUrl = data.jsonString(CMShareContentUrl)
                    return attachment
                case .LiveTip:
                    let attachment = LiveTipAttachment()
                    attachment.amount = data.jsonString(CMLiveTipAmount)
                    attachment.username = data.jsonString(CMLiveUserName)
                    attachment.displayname = data.jsonString(CMLiveDisplayname)
                    attachment.type = data.jsonInt(CMLiveTipType)
                    attachment.rewardId = data.jsonInt(CMLiveRewardId)
                    attachment.rewardImageUrl = data.jsonString(CMLiveRewardImage)
                    attachment.rewardAnimationUrl = data.jsonString(CMLiveRewardAnimation)
                    attachment.senderDisplayName = data.jsonString(CMLiveSenderDisplayname)
                    return attachment
                case .LiveTreasure:
                    let attachment = LiveTreasureAttachment()
                    attachment.treasureId = data.jsonString(CMTreasureId)
                    attachment.startTime = data.jsonString(CMTreasureStartTime)
                    attachment.endTime = data.jsonString(CMTreasureEndTime)
                    attachment.status = data.jsonInt(CMTreasureStatus)
                    attachment.countdown = data.jsonDouble(CMTreasureCountdown)
                    attachment.treasureTheme = data.jsonDict(CMTreasureTheme)
                    attachment.isSubscriberOnly = data.jsonBool(CMTreasureSubscriberOnly)
                    return attachment
                case .LiveLuckyBag:
                    let attachment = LiveLuckyBagAttachment()
                    attachment.treasureId = data.jsonString(CMTreasureId)
                    attachment.startTime = data.jsonString(CMTreasureStartTime)
                    attachment.endTime = data.jsonString(CMTreasureEndTime)
                    attachment.status = data.jsonInt(CMTreasureStatus)
                    attachment.countdown = data.jsonDouble(CMTreasureCountdown)
                    attachment.treasureTheme = data.jsonDict(CMTreasureTheme)
                    attachment.isSubscriberOnly = data.jsonBool(CMTreasureSubscriberOnly)
                    return attachment
                case .LivePinnedMessage:
                    let attachment = LivePinnedMessageAttachment()
                    attachment.feedId = data.jsonInt(CMPinnedMessageFeedId)
                    attachment.commentId = data.jsonInt(CMPinnedMessageCommentId)
                    attachment.contentType = data.jsonString(CMPinnedMessageContentType)
                    attachment.body = data.jsonString(CMPinnedMessageBody)
                    attachment.msgIdClient = data.jsonString(CMPinnedMessageIdClient)
                    attachment.pinned = data.jsonBool(CMIsPinned)
                    return attachment
                case .Meet:
                    let attachment = MeetAttachment()
                    attachment.eventType = MeetNewFriendEventType(rawValue: data.jsonInt(CMMeetEventType)) ?? .unknown
                    attachment.targetId = data.jsonString(CMMeetTargetId)
                    attachment.sourceId = data.jsonString(CMMeetSourceId)
                    attachment.expireTime = data.jsonDouble(CMMeetExpireTime)
                    attachment.nickname = data.jsonString(CMMeetNickname)
                    attachment.badgeURL = data.jsonString(CMMeetBadgeURL)
                    attachment.avatarURL = data.jsonString(CMMeetAvatarURL)
                    attachment.roomId = data.jsonString(CMMeetRoomId)
                    return attachment
                case .MiniProgram:
                    let attachment = IMMiniProgramAttachment()
                    attachment.appId = data.jsonString(CMAppId)
                    attachment.title = data.jsonString(CMMPTitle)
                    attachment.path = data.jsonString(CMPath)
                    attachment.desc = data.jsonString(CMMPDesc)
                    attachment.imageURL = data.jsonString(CMMPAvatar)
                    attachment.contentType = data.jsonString(CMMPType)
                    return attachment
                case .Announcement:
                    let attachment = IMAnnouncementAttachment()
                    attachment.message = dict.jsonString(CMAnnoucementName)
                    attachment.imageUrl = dict.jsonString(CMAnnoucementImageUrl)
                    attachment.linkUrl = dict.jsonString(CMAnnoucementLinkUrl)
                    return attachment
                case .Voucher:
                    let attachment = IMVoucherAttachment()
                    attachment.postUrl = data.jsonString(CMShareURL)
                    attachment.imageURL = data.jsonString(CMShareImage)
                    attachment.title = data.jsonString(CMShareTitle)
                    attachment.desc = data.jsonString(CMShareDescription)
                    attachment.contentType = data.jsonString(CMShareContentType)
                    attachment.contentUrl = data.jsonString(CMShareContentUrl)
                    return attachment
                case .WhiteBoard:
                    let attachment = IMWhiteboardAttachment()
                    attachment.channel = data.jsonString(CMWhiteBoardChannel)
                    return attachment
                case .MeetingRoom:
                    let attachment = IMMeetingRoomAttachment()
                    attachment.meetingId = data.jsonString(CMMeetingId)
                    attachment.meetingNum = data.jsonString(CMMeetingNum)
                    attachment.meetingShortNum = data.jsonString(CMMeetingShortNum)
                    attachment.meetingPassword = data.jsonString(CMMeetingPassword)
                    attachment.meetingStatus = data.jsonString(CMMeetingStatus)
                    attachment.meetingSubject = data.jsonString(CMMeetingSubject)
                    attachment.meetingType = data.jsonInt(CMMeetingType)
                    attachment.roomArchiveId = data.jsonString(CMRoomArchiveId)
                    attachment.roomUuid = data.jsonString(CMRoomUuid)
                    return attachment
                case .VideoCall:
                    let attachment = IMCallingAttachment()
                    attachment.callType = NIMSignalingChannelType(rawValue: Int(data.jsonString(CMCallType)) ?? 1) ?? .audio
                    attachment.eventType = CallingEventType(rawValue: Int(data.jsonString(CMEventType)) ?? 0) ?? .miss
                    attachment.duration = Double(data.jsonString(CMCallDuration)) ?? 0
                    return attachment
                case .VideoCall:
                    let attachment = IMCallingAttachment()
                    attachment.callType = NIMSignalingChannelType(rawValue: Int(data.jsonString(CMCallType)) ?? 1) ?? .audio
                    attachment.eventType = CallingEventType(rawValue: Int(data.jsonString(CMEventType)) ?? 0) ?? .miss
                    attachment.duration = Double(data.jsonString(CMCallDuration)) ?? 0
                    return attachment
                default:
                    return nil
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        return nil
    }
}

extension NSDictionary {
    func jsonInt(_ key: String) -> Int {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.intValue ?? 0
        }
        return 0
    }
    
    func jsonDouble(_ key: String) -> Double {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.doubleValue ?? 0.0
        }
        return 0.0
    }
    
    func jsonString(_ key: String) -> String {
        let object = self.object(forKey: key)
        if object is String {
            return object as? String ?? ""
        } else if object is NSNumber {
            if let object = object {
                return "\(object)"
            }
            return ""
        }
        return ""
    }
    
    func jsonBool(_ key: String) -> Bool {
        let object = self.object(forKey: key)
        if (object is String) || (object is NSNumber) {
            return (object as? NSNumber)?.boolValue ?? false
        }
        return false
    }
    
    func jsonDict(_ key: String) -> NSDictionary? {
        let object = self.object(forKey: key)
        if (object is NSDictionary) {
            return object as? NSDictionary
        }
        return nil
    }
    
    func jsonArray(_ key: String) -> NSArray? {
        let object = self.object(forKey: key)
        if (object is NSArray)  {
            return object as? NSArray
        }
        return nil
    }
}
