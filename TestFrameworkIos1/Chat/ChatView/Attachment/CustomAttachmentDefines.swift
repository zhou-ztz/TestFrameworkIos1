//
//  CustomAttachmentDefines.swift
//  Yippi
//
//  Created by Tinnolab on 07/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
//MARK: - Attachment Keys
let CMType = "type"
let CMData = "data"
let CMInfo = "info"

//ShareAttachment Keys
let CMShareID           = "contentId"
let CMShareImage        = "IMAGE_URL"
let CMShareTitle        = "TITLE"
let CMShareDescription  = "DESC"
let CMShareURL          = "LINK_URL"
let CMShareContentType  = "CONTENT_TYPE"
let CMShareContentUrl  = "CONTENT_URL"

//StickerCardAttachment
let CMStickerBundleId       = "bundle_id"
let CMStickerName           = "bundle_name"
let CMStickerIconImage      = "bundle_icon"
let CMStickerDiscription    = "bundle_description"
let CMRStickerURL           = "bundle_url"

//EggAttachment
let CMEggId        = "rid"
let CMEggSendId    = "senderId"
let CMEggOpenId    = "tid"
let CMEggMessage   = "message"
let CMEggUIDs      = "uids"     //用户列表

//MessageReply
let CMReplyMessage  = "replyMessage"
let CMReplyContent  = "replyContent"
let CMReplyName     = "replyName"
let CMReplyUserName = "replyUserName"
let CMReplyImageURL = "replyImageURL"
let CMReplyMessageID    = "replyMessageID"
let CMReplyMessageType  = "replyMessageType"
let CMReplyThumbPath    = "replyImageThumbPath"
let CMReplyThumbURL     = "replyImageThumbURL"
let CMReplyMessageCustomType = "replyMessageCustomType"

//RPS
let CMValue = "value"

//Snapchat
let CMURL   = "url"
let CMMD5   = "md5"
let CMFIRE  = "fired"

// ContactCard
let CMContactCard = "memberId"

//Sticker
let CMCatalog   = "catalog"      //贴图类别
let CMChartlet  = "chartlet"     //贴图表情ID
let CMStickerId  = "stickerId"     //自定义贴图表情ID CMStickerId

// TextTranslate
let CMOriginalMessageId = "originalMessageId"
let CMOriginalMessage   = "originalMessage"
let CMTranslatedMessage = "translatedMessage"
let CMTranslatedMessageIsOutgoing = "translatedMessageIsOutgoing"

//Whiteboard
let CMCommand   = "command"
let CMRoomID    = "room_id"  //聊天室id
let CMUIDs      = "uids"     //用户列表

// 直播礼物
let CMPresentType           = "present"
let CMPresentCount          = "count"

let CMLiveTipAmount         = "amount"
let CMLiveUserName          = "receiverName"
let CMLiveDisplayname       = "receiverDisplayName"
let CMLiveTipType           = "type"
let CMLiveRewardId          = "rewardId"
let CMLiveRewardImage       = "rewardImageUrl"
let CMLiveRewardAnimation   = "rewardAnimationUrl"
let CMLiveSenderDisplayname = "senderDisplayName"

// LiveTreasureAttachment
let CMTreasureId                = "redpacket_id"
let CMTreasureStartTime         = "start_time"
let CMTreasureEndTime           = "end_time"
let CMTreasureStatus            = "status"
let CMTreasureCountdown         = "countdown"
let CMTreasureTheme             = "treasureTheme"
let CMTreasureSubscriberOnly    = "subscriber_only"

// LivePinnedMessage
let CMPinnedMessageFeedId       = "feedId"
let CMPinnedMessageCommentId    = "commentId"
let CMPinnedMessageContentType  = "content_type"
let CMPinnedMessageBody         = "body"
let CMPinnedMessageIdClient     = "msgid_client"
let CMIsPinned                  = "pinned"

// MeetAttachment
let CMMeetEventType       = "event_type"
let CMMeetTargetId = "target_id"
let CMMeetSourceId   = "source_id"
let CMMeetExpireTime    = "expire_time"
let CMMeetNickname = "nickname"
let CMMeetBadgeURL     = "badge_url"
let CMMeetAvatarURL     = "avatar_url"
let CMMeetRoomId     = "room_id"

//MIniProgramAttachment
let CMAppId = "appId"
let CMPath = "path"
let CMMPAvatar = "avatar"
let CMMPTitle = "title"
let CMMPDesc = "description"
let CMMPType = "CONTENT_TYPE"

// IMAnnoucementAttachment Keys
let CMAnnoucementName      =     "name"
let CMAnnoucementImageUrl  =     "url"
let CMAnnoucementLinkUrl   =     "link_url"

// WhiteBoard
let CMWhiteBoardChannel = "channel"
let CMWhiteBoardCreator = "creator"

// Meeting Room
let CMMeetingId = "meetingId"
let CMMeetingNum = "meetingNum"
let CMMeetingShortNum = "meetingShortNum"
let CMMeetingPassword = "password"
let CMMeetingStatus = "status"
let CMMeetingSubject = "subject"
let CMMeetingType = "type"
let CMRoomArchiveId = "roomArchiveId"
let CMRoomUuid = "roomUuid"

// IMCalling
let CMCallType      =     "callType"
let CMEventType     =     "eventType"
let CMCallDuration  =     "duration"


enum IMCustomMeetingCommand: Int {
    case Unknown              = 0
    case NotifyActorsList     = 1//主持人通知所有有权限发言的用户列表，聊天室消息，需要携带uids
    case AskForActors         = 2//参与者询问其他人是否有权限发言，聊天室消息
    case ActorReply           = 3//有发言权限的人反馈，点对点消息，需要携带uids
    case RaiseHand            = 10//参与者向主持人申请发言权限，点对点消息
    case EnableActor          = 11//主持人开启参与者的发言请求，点对点消息
    case DisableActor         = 12//主持人关闭某人发言权限，点对点消息
    case CancelRaiseHand      = 13//参与者向主持人取消申请发言权限，点对点消息
}

enum CustomMessageType: Int {
    case RPS               = 1     //剪子石头布
    case Snapchat          = 2     //阅后即焚
    case Sticker           = 3     //贴图表情
    case ContactCard       = 5     //名片
    case Egg               = 6     // 彩蛋
    case Announcement      = 7     // Ads or Announcement
    case Like              = 9     //点赞
    case Reply             = 12    // Message Reply
    case StickerCard       = 100
    case SocialPost        = 101
    case MeetingControl    = 103
    case LiveTip           = 104   // 直播的打赏
    case LiveTreasure      = 105   //播主发的箱子
    case Translate         = 106   //text translate
    case Meet              = 108
    case MiniProgram       = 109
    case LivePinnedMessage = 111
    case LiveLuckyBag      = 112
    case Voucher           = 113
    case WhiteBoard        = 201
    case MeetingRoom       = 202
    case VideoCall         = 203 // 音视频通话
    case Unknown           = -1
}

enum CustomRPSValue: Int {
    case Unknown    = 0
    case Rock       = 1//石头
    case Scissor    = 2//剪子
    case Paper      = 3//布
}

enum MeetNewFriendEventType: Int {
    case unknown    = 0
    case requested  = 1
    case accept     = 2
    case reject     = 3
    case joinRoom   = 4
}

//收藏信息类型
enum MessageCollectionType: Int {
    //主要附件
    case unknown     = -1
    case all         = 0
    case text        = 1
    case image       = 2
    case audio       = 3
    case video       = 4
    case location    = 5
    case file        = 6
    //自定义附件
    case nameCard    = 100 //名片
    case sticker     = 101 //贴图
    case link        = 102 //链接
    case miniProgram = 103 //小程序
    //case reply       = 104
    case meeting       = 104 //会议
    case egg         = 105
    case rps         = 106
    case voucher     = 107 //Voucher
}

//音视频通话事件类型
enum CallingEventType: Int {
    case noResponse = 0 // 对方无人接听
    case miss       = 1 // 未接电话
    case bill       = 2 //电话回单
    case reject     = 3 //对方拒接电话
}

protocol IMMessageContentInfo {
    func cellContent(_ message: MessageData) -> BaseContentView
    func canBeRevoked() -> Bool
    func canBeForwarded() -> Bool
    func canBeTranslated() -> Bool
    func canBeReplied() -> Bool
}

extension IMMessageContentInfo {
    func shouldShowAvatar() -> Bool {
        return false
    }
}
