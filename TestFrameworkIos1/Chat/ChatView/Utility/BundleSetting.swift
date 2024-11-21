//
//  BundleSetting.swift
//  Yippi
//
//  Created by Khoo on 18/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class BundleSetting: NSObject {
    
    static let sharedConfigInstance: BundleSetting? = {
        var instance = BundleSetting()
        return instance
    }()
    
    class func sharedConfig() -> Self {
        // `dispatch_once()` call was converted to a static variable initializer
        return sharedConfigInstance as! Self
    }
    
    override init() {
        super.init()
        checkSocks5DefaultSetting()
    }
    
    func checkSocks5DefaultSetting() {
        let settingBundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle")
        let plistPath = URL(fileURLWithPath: settingBundlePath ?? "").appendingPathComponent("Root.plist").absoluteString
        let plistDict = NSDictionary(contentsOfFile: plistPath)
        let preferences = plistDict?.value(forKey: "PreferenceSpecifiers") as? [NSDictionary]
        let userDefaults = UserDefaults.standard
        
        for setting in preferences ?? [] {
            guard let setting = setting as? [AnyHashable : Any] else {
                continue
            }
            // 如果NSUserDefaults里有，则优先使用UserDefaults里的
            let key = setting["Key"] as? String
            
            if key != nil && (key?.count ?? 0) > 0 && key?.contains("socks5") ?? false {
                // 从Plist中获取值填充
                let value = setting["DefaultValue"]
                if value != nil {
                    userDefaults.set(value, forKey: key ?? "")
                }
            }
        }
    }
    
    func removeSessionWhenDeleteMessages() -> Bool {
        return (UserDefaults.standard.object(forKey: "enabled_remove_recent_session") as? NSNumber)?.boolValue ?? false
    } //删除消息时是否同时删除会话项
    
    func dropTableWhenDeleteMessages() -> Bool {
        return (UserDefaults.standard.object(forKey: "enabled_drop_msg_table") as? NSNumber)?.boolValue ?? false
    } //删除消息的同时是否删除消息表
    
    func localSearchOrderByTimeDesc() -> Bool {
        return (UserDefaults.standard.object(forKey: "local_search_time_order_desc") as? NSNumber)?.boolValue ?? false
    } //本地搜索消息顺序 YES表示按时间戳逆序搜索,NO表示按照时间戳顺序搜索
    
    func autoRemoveRemoteSession() -> Bool {
        return (UserDefaults.standard.object(forKey: "auto_remove_remote_session") as? NSNumber)?.boolValue ?? false
    } //删除会话时是不是也同时删除服务器会话 (防止漫游)
    
    func autoRemoveSnapMessage() -> Bool {
        return (UserDefaults.standard.object(forKey: "auto_remove_snap_message") as? NSNumber)?.boolValue ?? false
    } //阅后即焚消息在看完后是否删除
    
    func needVerifyForFriend() -> Bool {
        return (UserDefaults.standard.object(forKey: "add_friend_need_verify") as? NSNumber)?.boolValue ?? false
    }
    
    func showFps() -> Bool {
        return (UserDefaults.standard.object(forKey: "show_fps_for_app") as? NSNumber)?.boolValue ?? false
    } //是否显示Fps
    
    func disableProximityMonitor() -> Bool {
        return (UserDefaults.standard.object(forKey: "disable_proxmity_monitor") as? NSNumber)?.boolValue ?? false
    } //贴耳的时候是否需要自动切换成听筒模式
    
    func enableRotate() -> Bool {
        return (UserDefaults.standard.object(forKey: "enable_rotate") as? NSNumber)?.boolValue ?? false
    } //支持旋转(仅组件部分，其他部分可能会显示不正常，谨慎开启)
    
    func usingAmr() -> Bool {
        return (UserDefaults.standard.object(forKey: "using_amr") as? NSNumber)?.boolValue ?? false
    } //使用amr作为录音
    
    func fileQuickTransferEnabled() -> Bool {
        let value = UserDefaults.standard.object(forKey: "enable_file_quick_transfer")
        if value != nil {
            return (value as? NSNumber)?.boolValue ?? false
        } else {
            return true
        }
    } //文件快传开关
    
    func ignoreTeamNotificationTypes() -> [String]? {
        var types: [String]? = nil
        if types == nil {
            let value = UserDefaults.standard.object(forKey: "ignore_team_types") as? String
            if (value != nil) {
                let typeDescription = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                if (typeDescription?.count ?? 0) != 0 {
                    types = typeDescription?.components(separatedBy: ",")
                }
            }
        }
        if types == nil {
            types = []
        }
        return types
        
        
    } //需要忽略的群通知类型
    
    func enableSyncWhenFetchRemoteMessages() -> Bool {
        return (UserDefaults.standard.object(forKey: "sync_when_remote_fetch_messages") as? NSNumber)?.boolValue ?? false
    } //拉取云消息时是否需要存储到本地
    
    func countTeamNotification() -> Bool {
        return (UserDefaults.standard.object(forKey: "count_team_notification") as? NSNumber)?.boolValue ?? false
    } //是否将群通知计入未读
    
    func maximumLogDays() -> Int {
        let object = UserDefaults.standard.object(forKey: "maximum_log_days")
        let days = object != nil ? (object as? NSNumber)?.intValue ?? 0 : 7
        return days
    } //日志最大存在天数
    
    func animatedImageThumbnailEnabled() -> Bool {
        return (UserDefaults.standard.object(forKey: "animated_image_thumbnail_enabled") as? NSNumber)?.boolValue ?? false
    }
    
    func serverRecordAudio() -> Bool {
        return (UserDefaults.standard.object(forKey: "server_record_audio") as? NSNumber)?.boolValue ?? false
    } //服务器录制语音
    
    func serverRecordVideo() -> Bool {
        return (UserDefaults.standard.object(forKey: "server_record_video") as? NSNumber)?.boolValue ?? false
    } //服务器录制视频
    
    func serverRecordWhiteboardData() -> Bool {
        return (UserDefaults.standard.object(forKey: "server_record_whiteboard_data") as? NSNumber)?.boolValue ?? false
    } //服务器录制白板数据
    
    func serverRecordHost() -> Bool {
        return (UserDefaults.standard.object(forKey: "server_record_host") as? NSNumber)?.boolValue ?? false
    } //服务端录制主讲人
    
    func serverRecordMode() -> Int {
        return (UserDefaults.standard.object(forKey: "server_record_mode") as? NSNumber)?.intValue ?? 0
    } //服务端录制模式
    
    func useSocks() -> Bool {
        return (UserDefaults.standard.object(forKey: "use_socks5") as? NSNumber)?.boolValue ?? false
    } //是否使用socks5代理
    
    func socks5Type() -> String? {
        return UserDefaults.standard.object(forKey: "socks5_type") as? String ?? ""
        
    } //socks5类型
    
    func socks5Addr() -> String {
        return UserDefaults.standard.object(forKey: "socks5_addr") as? String ?? ""
    } //socks5地址
    
    func socksUsername() -> String {
        return UserDefaults.standard.object(forKey: "socks5_username") as? String ?? ""
    } //用户名
    
    func socksPassword() -> String? {
        return UserDefaults.standard.object(forKey: "socks5_password") as? String ?? ""
    } //密码
    
    func useRTSSocks() -> Bool {
        return (UserDefaults.standard.object(forKey: "use_rts_socks5") as? NSNumber)?.boolValue ?? false
    } //白板是否使用socks5代理
    
    func socks5RTSType() -> String? {
        return UserDefaults.standard.object(forKey: "rts_socks5_type") as? String ?? ""
    } //白板socks5类型
    
    func socks5RTSAddr() -> String? {
        return UserDefaults.standard.object(forKey: "rts_socks5_addr") as? String ?? ""
    } //白板socks5地址
    
    func socksRTSUsername() -> String? {
        return UserDefaults.standard.object(forKey: "rts_socks5_username") as? String ?? ""
    } //白板用户名
    
    func socksRTSPassword() -> String? {
        return UserDefaults.standard.object(forKey: "rts_socks5_password") as? String ?? ""
        
    } //白板密码
    
//    func videochatVideoCrop() -> NIMNetCallVideoCrop {
//        return NIMNetCallVideoCrop(rawValue: (UserDefaults.standard.object(forKey: "videochat_video_crop") as? NSNumber)?.intValue ?? 0)!
//    } //视频画面裁剪比例
    
    func videochatAutoRotateRemoteVideo() -> Bool {
        return (UserDefaults.standard.object(forKey: "videochat_auto_rotate_remote_video") as? NSNumber)?.boolValue ?? false
    } //自动旋转视频聊天远端画面
    
    func videochatRemoteVideoContentMode() -> UIView.ContentMode {
        let setting = (UserDefaults.standard.object(forKey: "videochat_remote_video_content_mode") as? NSNumber)?.intValue ?? 0
        return (setting == 0) ? .scaleAspectFill : .scaleAspectFit
    } //对端画面的填充模式
    
//    func preferredVideoQuality() -> NIMNetCallVideoQuality {
//        let videoQualitySetting = (UserDefaults.standard.object(forKey: "videochat_preferred_video_quality") as? NSNumber)?.intValue ?? 0
//        if (videoQualitySetting >= NIMNetCallVideoQuality.qualityDefault.rawValue) && (videoQualitySetting <= NIMNetCallVideoQuality.quality720pLevel.rawValue) {
//            return NIMNetCallVideoQuality(rawValue: videoQualitySetting) ?? NIMNetCallVideoQuality.qualityDefault
//        }
//        return NIMNetCallVideoQuality.qualityDefault
//    } //期望的视频发送清晰度
//    
//    func startWithBackCamera() -> Bool {
//        return (UserDefaults.standard.object(forKey: "videochat_start_with_back_camera") as? NSNumber)?.boolValue ?? false
//    } //使用后置摄像头开始视频通话
//    
//    func perferredVideoEncoder() -> NIMNetCallVideoCodec {
//        let videoEncoderSetting = (UserDefaults.standard.object(forKey: "videochat_preferred_video_encoder") as? NSNumber)?.intValue ?? 0
//
//        if (videoEncoderSetting >= NIMNetCallVideoCodec.default.rawValue) && (videoEncoderSetting <= NIMNetCallVideoCodec.hardware.rawValue) {
//            return NIMNetCallVideoCodec(rawValue: NIMNetCallVideoCodec.RawValue(videoEncoderSetting)) ?? NIMNetCallVideoCodec.default
//        }
//        return NIMNetCallVideoCodec.default
//    } //期望的视频编码器
//
//    func perferredVideoDecoder() -> NIMNetCallVideoCodec {
//        let videoDecoderSetting = (UserDefaults.standard.object(forKey: "videochat_preferred_video_decoder") as? NSNumber)?.intValue ?? 0
//
//        if (videoDecoderSetting >= NIMNetCallVideoCodec.default.rawValue) && (videoDecoderSetting <= NIMNetCallVideoCodec.hardware.rawValue) {
//            return NIMNetCallVideoCodec(rawValue: NIMNetCallVideoCodec.RawValue(videoDecoderSetting)) ?? NIMNetCallVideoCodec.default
//        }
//        return NIMNetCallVideoCodec.default
//    } //期望的视频解码器
    
    func videoMaxEncodeKbps() -> Int {
        return (UserDefaults.standard.object(forKey: "videochat_video_encode_max_kbps") as? NSNumber)?.intValue ?? 0
    } //最大发送视频编码码率
    
    func localRecordVideoKbps() -> Int {
        return (UserDefaults.standard.object(forKey: "videochat_local_record_video_kbps") as? NSNumber)?.intValue ?? 0
    } //本地录制视频码率
    
    func localRecordVideoQuality() -> Int {
        return Int((UserDefaults.standard.object(forKey: "") as? NSNumber)?.uintValue ?? 0)
    } //本地录制视频分辨率
    
    func autoDeactivateAudioSession() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "videochat_auto_disable_audiosession")
        
        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return true
        }
    } //自动结束AudioSession
    
    func audioDenoise() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "videochat_audio_denoise")
        
        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return true
        }
    } //降噪开关
    
    func voiceDetect() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "videochat_voice_detect")
        
        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return true
        }
    } //语音检测开关
    
    
    func preferHDAudio() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "videochat_prefer_hd_audio")

        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return false
        }
    }
    
//    func scene() -> NIMAVChatScene {
//        let setting = UserDefaults.standard.object(forKey: "avchat_scene")
//
//        if setting != nil {
//            return NIMAVChatScene(rawValue: (setting as? NSNumber)?.uintValue ?? 0) ?? NIMAVChatScene.default
//        } else {
//            return NIMAVChatScene.default
//        }
//    } //音视频场景设置
    
    func chatroomRetryCount() -> Int {
        let count = UserDefaults.standard.object(forKey: "chatroom_enter_retry_count")
        return count == nil ? 3 : (count as? NSNumber)?.intValue ?? 0
    } //进聊天室重试次数
    
    func autoFetchAttachment() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "auto_fetch_attachment")
        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return true
        }
    } //自动下载附件。（接收消息，刷新消息，自动拿历史消息时）
    
    func bypassStreamingServerRecord() -> Bool {
        let setting = UserDefaults.standard.object(forKey: "bypass_server_record")
        
        if setting != nil {
            return (setting as? NSNumber)?.boolValue ?? false
        } else {
            return false
        }
    } //互动直播服务器录制
    
//    func videoCaptureFormat() -> NIMNetCallVideoCaptureFormat {
//        let setting = UserDefaults.standard.object(forKey: "video_capture_format") as? Int
//        guard let settingValue = setting else { return .format420f}
//        return NIMNetCallVideoCaptureFormat(rawValue: settingValue) ?? .format420f
//    } //视频采集格式
//    
//    func bypassVideoMixMode() -> Int {
//        let setting = UserDefaults.standard.object(forKey: "bypass_mix_mode")
//
//        if setting != nil {
//            return Int((setting as? NSNumber)?.uintValue ?? 0)
//        } else {
//            return Int(NIMNetCallBypassStreamingMixMode.floatingRightVertical.rawValue)
//        }
//    } //合流混屏模式
    
    func bypassVideoMixCustomLayoutConfig() -> String? {
        let setting = UserDefaults.standard.object(forKey: "bypass_mix_layout_config") as? String
        
        return setting
    } //合流混屏自定义布局配置
  /*
    func description() -> String? {
        return String(format:
            """
            \n\n\n
            enabled_remove_recent_session %d\n" \
            local_search_time_order_desc %d\n" \
            auto_remove_remote_session %d\n" \
            auto_remove_snap_message %d\n" \
            add_friend_need_verify %d\n" \
            show app %d\n" \
            maximum log days %zd\n" \
            using amr %d\n" \
            ignore_team_types %@ \n" \
            server_record_audio %d\n" \
            server_record_video %d\n" \
            server_record_whiteboard_data %d\n" \
            videochat_video_crop %zd\n" \
            videochat_auto_rotate_remote_video %d \n" \
            videochat_preferred_video_quality %zd\n" \
            videochat_start_with_back_camera %zd\n" \
            videochat_preferred_video_encoder %zd\n" \
            videochat_preferred_video_decoder %zd\n" \
            videochat_video_encode_max_kbps %zd\n" \
            videochat_local_record_video_kbps %zd\n" \
            videochat_local_record_video_quality %zd\n" \
            videochat_auto_disable_audiosession %zd\n" \
            videochat_audio_denoise %zd\n" \
            videochat_voice_detect %zd\n" \
            videochat_prefer_hd_audio %zd\n"\
            avchat_scene %zd\n"\
            chatroom_retry_count %zd\n"\
            sync_when_remote_fetch_messages %zd\n"\
            bypass_mix_mode %zd\n"\
            \n\n\n
            """,
            removeSessionWhenDeleteMessages(),
            localSearchOrderByTimeDesc(),
            autoRemoveRemoteSession(),
            autoRemoveSnapMessage(),
            needVerifyForFriend(),
            showFps(),
            maximumLogDays(),
            usingAmr(),
            ignoreTeamNotificationTypes()?.description,
            serverRecordAudio(),
            serverRecordVideo(),
            serverRecordWhiteboardData(),
            videochatVideoCrop()?.description,
            videochatAutoRotateRemoteVideo(),
            preferredVideoQuality()?.description,
            startWithBackCamera(),
            perferredVideoEncoder()?.description,
            perferredVideoDecoder()?.description,
            videoMaxEncodeKbps(),
            localRecordVideoKbps(),
            localRecordVideoQuality(),
            autoDeactivateAudioSession(),
            audioDenoise(),
            voiceDetect(),
            preferHDAudio(),
            scene()?.description,
            chatroomRetryCount(),
            enableSyncWhenFetchRemoteMessages(),
            bypassVideoMixMode()
        )
    }
        */
        
}
