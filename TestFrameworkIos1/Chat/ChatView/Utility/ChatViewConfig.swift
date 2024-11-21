//
//  ChatViewConfig.swift
//  Yippi
//
//  Created by Tinnolab on 17/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK

@objc enum MediaItem: Int {
    case album = 0
    case camera = 1
    case file = 2
    case redpacket = 3
    case videoCall = 4
    case voiceCall = 5
    case sendCard = 6
    case whiteBoard = 7
    case sendLocation = 8
    case voiceToText = 9
    case rps = 10
    case collectMessage = 11 //收藏的消息
    case secretMessage = 12
    
    var info: (title: String, icon: UIImage?) {
        switch self {
        case .album:
            return ("album".localized, UIImage.set_image(named: "album"))
        case .camera:
            return ("camera".localized, UIImage.set_image(named: "camera"))
        case .file:
            return ("media_title_files".localized, UIImage.set_image(named: "file"))
        case .redpacket:
            return ("input_panel_redpacket".localized, UIImage.set_image(named: "redpacket"))
        case .videoCall:
            return ("msg_type_video_call".localized, UIImage.set_image(named: "videoCall"))
        case .voiceCall:
            return ("msg_type_voice_call".localized, UIImage.set_image(named: "voiceCall"))
        case .sendCard:
            return ("input_panel_name_card".localized, UIImage.set_image(named: "contactIM"))
        case .whiteBoard:
            return ("input_panel_whiteboard".localized, UIImage.set_image(named: "whiteboard"))
        case .sendLocation:
            return ("input_panel_location".localized, UIImage.set_image(named: "location_new"))
        case .voiceToText:
            return ("speech_to_text_title".localized, UIImage.set_image(named: "voiceInput"))
        case .rps:
            return ("input_panel_guess".localized, UIImage.set_image(named: "rps"))
        case .collectMessage:
            return ("input_panel_fav_msg".localized, UIImage.set_image(named: "favoriteMessage"))
        case .secretMessage:
            return ("msg_tips_secret_msg".localized, UIImage.set_image(named: "iconTimer"))
        default:
            return ("album".localized, UIImage.set_image(named: "album"))
        }
    }
}

protocol ChatViewConfig {
    ///  每隔多久显示一条消息
    func messageInterval() -> TimeInterval
    ///  每次抓取的消息个数
    func messageLimit() -> Int
    ///  录音的最大时长
    func recordMaxDuration() -> TimeInterval
    ///  输入框的占位符
    func placeholder() -> String?
    ///  输入框能容纳的最大字符长度
    func inputMaxLength() -> Int
//    ///  输入按钮类型，请填入 NIMInputBarItemType 枚举，按顺序排列。不实现则按默认排列。
//    func inputBarItemTypes() -> [NSNumber]?
    ///  可以显示在点击输入框“+”按钮之后的多媒体按钮
    func mediaItems() -> [MediaItem]?
    ///  禁用贴图表情
//    func charlets() -> [NIMInputEmoticonCatalog]?
    ///  是否禁用输入控件
    func disableInputView() -> Bool
    ///  是否禁用音频轮播
    func disableAutoPlayAudio() -> Bool
    ///  是否禁用在贴耳的时候自动切换成听筒模式
    func disableProximityMonitor() -> Bool
    ///  在进入会话的时候是否禁止自动去拿历史消息,默认打开
    func autoFetchWhenOpenSession() -> Bool
    /// 自动下载附件。（接收消息，刷新消息，自动拿历史消息时）
    func autoFetchAttachment() -> Bool
    ///  会话页是否禁止显示新到的消息，用于显示消息历史的特定会话页，默认不禁止
    func disableReceiveNewMessages() -> Bool
    ///  这次消息时候需要做已读回执的处理
    func shouldHandleReceipt(for message: NIMMessage?) -> Bool
    ///  是否禁用进入会话自动标记会话已读，如果禁用，请自行调用 SDK markAllMessagesReadInSession 接口维护未读数。
    func disableAutoMarkMessageRead() -> Bool
    ///  输入框是否禁用 @ 功能
    func disableAt() -> Bool
    ///  录音类型
    func recordType() -> NIMAudioType
    ///  会话聊天背景更换接口
    func sessionBackgroundImage() -> UIImage?
    ///  发送按钮图片
    func sendButtonImage() -> UIImage?
}
