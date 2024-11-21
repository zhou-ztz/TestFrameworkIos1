//
//  IMNotificationCenter.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/2.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import AVFoundation
//音视频通话呼叫类型
enum NERtCallingType: String {
    case team = "teamCall"
    case p2p  = "p2pCall"
}
//1v1音视频通话 切换类型
enum NERtChangeType: String {
    case toAudio       = "toAudio" //视频切换音频
    case toVideo       = "toVideo" //音频切换视频请求
    case agreeToVideo  = "agreeToVideo" //同意
    case rejectToVideo = "rejectToVideo" // 拒绝
}

class IMNotificationCenter: NSObject {
    
    static let sharedCenter = IMNotificationCenter()
    
    let NTESCustomNotificationCountChanged = "NTESCustomNotificationCountChanged"
    let NTESSecretChatResponded = "NTESSecretChatResponded"
    let NTESWhiteboardResponded = "NTESWhiteboardResponded"
    
    
    var player: AVAudioPlayer! //播放提示音
   // var notifier: NTESAVNotifier!
    
    public func start(){
        
    }
    
    public func dismissOrExitGroup(teamId: String){
        
    }
    
    override init() {
        super.init()
        NIMSDK.shared().signalManager.add(self)
    }
    
    deinit {
        NIMSDK.shared().signalManager.remove(self)
        
    }
    
    
    func shouldResponseBusy() -> Bool{
        guard let topController = TSViewController.topMostController  else { return true }
        return topController.isKind(of: IMWhiteboardCallingViewController.self)
        || topController.isKind(of: ChatWhiteboardViewController.self)
        || topController.isKind(of: IMTeamMeetingViewController.self)
        || topController.isKind(of: VideoCallController.self)
        || topController.isKind(of: NetChatViewController.self)
    }
    
    func shouldAutoRejectCall() -> Bool {
        var should = false
        let apnsManager = NIMSDK.shared().apnsManager
        guard let setting = apnsManager.currentSetting() else { return false }
        //免打扰关闭
        if !setting.noDisturbing {
            let defaults = UserDefaults.standard
            if !defaults.dictionaryRepresentation().keys.contains(where: {$0 == Constants.VoiceOrVideoMuteNotificationKey}) {
                defaults.set(true, forKey: Constants.VoiceOrVideoMuteNotificationKey)
            }
        }else {
            UserDefaults.standard.set(false, forKey: Constants.VoiceOrVideoMuteNotificationKey)
        }
        
        //音视频通话
        let voiceCallNotification = UserDefaults.standard.bool(forKey: Constants.VoiceOrVideoMuteNotificationKey)
        should = !voiceCallNotification
        if setting.noDisturbing {
            let date = Date()
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let now = (components.hour ?? 0) * 60 + (components.minute ?? 0)
            let start = setting.noDisturbingStartH * 60 + setting.noDisturbingStartM
            let end = setting.noDisturbingEndH * 60 + setting.noDisturbingEndM
            
            //当天区间
            if (end > start && end >= now && now >= start)
            {
                should = true
            }
            //隔天区间
            else if(end < start && (now <= end || now >= start))
            {
                should = true
            }
        }

        return should
    }
    
    //拒绝邀请- 信令
    func unAcceptInvited(channelId: String, caller: String, requestId: String){
        let data: [String: Any] = [:]
        let dict = ["type": "isCallBusy", "data": data] as [String : Any]
        let customInfo = dict.toJSON
        let request = NIMSignalingRejectRequest()
        request.channelId = channelId
        request.accountId = caller
        request.requestId = requestId
        request.customInfo = customInfo
        NIMSDK.shared().signalManager.signalingReject(request) { error in
            
        }
    }
    /// 跳转音视频
    private func presentCalls(types: NIMSignalingChannelType, caller: String, channelId: String, channelName: String, requestId: String) {
        if VideoPlayer.shared.isPlaying { VideoPlayer.shared.stop() }
        guard let topVC = TSViewController.topMostController else {
            return
        }
        
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: topVC, completion: {
            switch (types) {
            case .video:
                DispatchQueue.main.async {
                    let vc = VideoCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
                    vc.callInfo.callType = .video
                    topVC.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
                }
                
            case .audio:
                DispatchQueue.main.async {
                    let vc = VideoCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
                    vc.callInfo.callType = .audio
                    topVC.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
                }
                
            default: break
            }
        })
    }

    ///群呼
    @objc func presentTeamCall(data: [String : Any], notifyResponse: NIMSignalingInviteNotifyInfo){
        
        if VideoPlayer.shared.isPlaying { VideoPlayer.shared.stop() }
        guard let topVC = TSViewController.topMostController else {
            return
        }
        let channelInfo = IMTeamMeetingCalleeInfo()
        channelInfo.requestId = notifyResponse.requestId
        channelInfo.channelId = notifyResponse.channelInfo.channelId
        channelInfo.channelName = notifyResponse.channelInfo.channelName
        channelInfo.caller = notifyResponse.fromAccountId
        channelInfo.teamId = (data["teamId"] as? String) ?? ""
        channelInfo.members = (data["members"] as? [String]) ?? []
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: topVC, completion: {
            DispatchQueue.main.async {
                let vc = IMTeamMeetingViewController(channelInfo: channelInfo)
                topVC.present(vc.fullScreenRepresentation, animated: true, completion: nil)
            }
        })
        
        
    }
}


extension IMNotificationCenter: NIMSignalManagerDelegate{
    
    func nimSignalingOfflineNotify(_ notifyResponse: [NIMSignalingNotifyInfo]) {
        
        if let notifyResponse = notifyResponse.first {
            
            switch notifyResponse.eventType {
            case .invite:
                guard let notifyResponse = notifyResponse as? NIMSignalingInviteNotifyInfo else {
                    return
                }
                if self.shouldResponseBusy() || self.shouldAutoRejectCall() {
                    self.unAcceptInvited(channelId: notifyResponse.channelInfo.channelId, caller: notifyResponse.fromAccountId, requestId: notifyResponse.requestId)
                    return
                }
                if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                    if let type = customInfo["type"] as? String {
                        switch NERtCallingType(rawValue: type) {
                        case .team:
                            if let data = customInfo["data"] as? [String : Any] {
                                self.presentTeamCall(data: data, notifyResponse: notifyResponse)
                            }
                            
                            
                        case .p2p:
                            self.presentCalls(types: notifyResponse.channelInfo.channelType, caller: notifyResponse.fromAccountId, channelId: notifyResponse.channelInfo.channelId, channelName: notifyResponse.channelInfo.channelName, requestId: notifyResponse.requestId)

                        default:
                            break
                        }
                        
                    }
                }
            default:
                break
            }
        }
        
        
        
    }
    func nimSignalingMembersSyncNotify(_ notifyResponse: NIMSignalingChannelDetailedInfo) {
        
    }
    func nimSignalingChannelsSyncNotify(_ notifyResponse: [NIMSignalingChannelDetailedInfo]) {
        
    }
    func nimSignalingOnlineNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        
        switch eventType {
        case .invite:
        
            guard let notifyResponse = notifyResponse as? NIMSignalingInviteNotifyInfo else {
                return
            }
            if self.shouldResponseBusy() || self.shouldAutoRejectCall() {
                self.unAcceptInvited(channelId: notifyResponse.channelInfo.channelId, caller: notifyResponse.fromAccountId, requestId: notifyResponse.requestId)
                return
                
            }
            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    switch NERtCallingType(rawValue: type) {
                    case .team:
                        print("notifyResponse = \(notifyResponse)")
                        if let data = customInfo["data"] as? [String : Any] {
                            self.presentTeamCall(data: data, notifyResponse: notifyResponse)
                        }
                    case .p2p:
                        self.presentCalls(types: notifyResponse.channelInfo.channelType, caller: notifyResponse.fromAccountId, channelId: notifyResponse.channelInfo.channelId, channelName: notifyResponse.channelInfo.channelName, requestId: notifyResponse.requestId)
                    default:
                        break
                    }
                    
                }
            }
            
    
            
        default:
            break
        }
        
    }
    func nimSignalingMultiClientSyncNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        
    }
    
}
