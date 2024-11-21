//
//  NetChatViewController.swift
//  Yippi
//
//  Created by Khoo on 17/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import NERtcSDK
import Photos
import Toast
import NIMSDK
import AssetsLibrary
import Alamofire

let DelaySelfStartControlTime = 10
//激活铃声后无人接听的超时时间
let NoBodyResponseTimeOut = 45

//周期性检查剩余磁盘空间
let DiskCheckTimeInterval = 10
//剩余磁盘空间不足的警告阈值
let MB = 1024 * 1024
let FreeDiskSpaceWarningThreshold = 10 * MB

class NetChatViewController: TSViewController{
    var callInfo: NetCallChatInfo = NetCallChatInfo()
    var player: AVAudioPlayer?
    
    lazy var peerUid: String = {
        if (callInfo.callee == NIMSDK.shared().loginManager.currentAccount()) {
            return callInfo.caller ?? ""
        } else {
            return callInfo.callee ?? ""
        }
    }()
    var shouldDisableFaceUnity: Bool = true
    
    var timer: TimerHolder?
    var chatRoom:[String]? = [String]()
    var recordWillStopForLackSpace: Bool?
    var userHangup: Bool? = false
    var calleeResponseTimer : TimerHolder?
    var calleeResponsed: Bool = false
    var successRecords: Int?
    var channelInfo: NIMSignalingChannelDetailedInfo?
    var oppositeUserID: UInt64?//对方的useriD
    var isCaller: Bool = false //是否发起方
    var meetingSeconds: Int = 0
    //记录第一次呼叫的类型
    var callType: NIMSignalingChannelType = .audio
    var callEventType: CallingEventType = .noResponse
    convenience init(callee: String) {
        self.init(nibName: nil, bundle: nil)
        self.peerUid = callee
        self.isCaller = true
        self.callInfo.callee = callee
        self.callInfo.caller = NIMSDK.shared().loginManager.currentAccount()
        self.callInfo.peerUid = self.peerUid
    }
    
    convenience init(caller: String, channelId: String, channelName: String, requestId: String) {
        self.init(nibName: nil, bundle: nil)
        self.peerUid = caller
        self.isCaller = false
        self.callInfo.caller = caller
        self.callInfo.callee = NIMSDK.shared().loginManager.currentAccount()
        self.callInfo.channelId = channelId
        self.callInfo.channelName = channelName
        self.callInfo.requestId = requestId
        self.callInfo.peerUid = self.peerUid
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        edgesForExtendedLayout = .all
        
        NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
        callInfo = NetCallChatInfo()
        
        //防止应用在后台状态，此时呼入，会走init但是不会走viewDidLoad,此时呼叫方挂断，导致被叫监听不到，界面无法消去的问题。
        NIMSDK.shared().signalManager.add(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NIMSDK.shared().signalManager.remove(self)
        DispatchQueue.global().async {
            NERtcEngine.destroy()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //继承TSViewController后重新设置页面背景颜色
        self.view.backgroundColor = UIColor(hex: 0x1E1E1E)
        initNERtc()
        callType = self.callInfo.callType
        self.afterCheckService()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.stop()
        UIApplication.shared.isIdleTimerDisabled = false
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func initNERtc(){
#if DEBUG
        let appKey = Constants.NIMKey
#else
        let appKey  = Constants.NIMKey
#endif
        let coreEngine = NERtcEngine.shared()
        let context = NERtcEngineContext()
        context.engineDelegate = self
        context.appKey = appKey
        coreEngine.setupEngine(with: context)
        
        NIMSDK.shared().signalManager.add(self)
        
        NERtcEngine.shared().adjustPlaybackSignalVolume(200)
        NERtcEngine.shared().adjustRecordingSignalVolume(200)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().subscribeAllRemoteAudio(true)
       
    }


    func afterCheckService () {
        if !self.isCaller {
            self.calleeResponseTimer = TimerHolder()
            self.calleeResponseTimer?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
            self.startByCallee()
        } else {
            
            self.startByCaller()
        }
    }
    
    func checkServiceEnable (completionHandler:@escaping (Bool) -> ()) {
        let audioStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
        let videoStatus: AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        if videoStatus == .restricted || videoStatus == .denied {
            
            let alertController = UIAlertController(title: nil, message: "rw_camera_limited_video_chat_fail".localized, preferredStyle: .alert)
            let DestructiveAction = UIAlertAction(title: "cancel".localized, style: .destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "title_settings".localized, style: .default) {
                (result : UIAlertAction) -> Void in
            }

            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            return
        }
        
        
        if audioStatus == .restricted || audioStatus == .denied {
            let alertController = UIAlertController(title: nil, message: "microphone_limited_chat_fail".localized, preferredStyle: .alert)
            let DestructiveAction = UIAlertAction(title: "rw_camera_limited_video_chat_fail".localized, style: .destructive) {
                (result : UIAlertAction) -> Void in
            }
            let okAction = UIAlertAction(title: "confirm".localized, style: .default) {
                (result : UIAlertAction) -> Void in
                completionHandler(false)
            }
            
            alertController.addAction(DestructiveAction)
            alertController.addAction(okAction)
            self.present(alertController, animated: true) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            return
        }
        
        AVAudioSession.sharedInstance().requestRecordPermission({ (granted) -> Void in
            DispatchQueue.main.async {
                if granted {
                    let mediaType = AVMediaType.video
                    let authStatus = AVCaptureDevice.authorizationStatus(for: mediaType)
                    
                    if authStatus == .restricted || authStatus == .denied {
                        let alertController = UIAlertController(title: nil, message: "rw_camera_limited_video_chat_fail".localized, preferredStyle: .alert)
                        let confirmBtn = UIAlertAction(title: "confirm".localized, style: .default) {
                            (result : UIAlertAction) -> Void in
                        }
                        alertController.addAction(confirmBtn)
                        self.present(alertController, animated: true) {
                            completionHandler(false)
                        }
                    } else {
                        completionHandler(true)
                    }
                } else {
                    let alertController = UIAlertController(title: nil, message: "microphone_limited_chat_fail".localized, preferredStyle: .alert)
                    let confirmBtn = UIAlertAction(title: "confirm".localized, style: .default) {
                        (result : UIAlertAction) -> Void in
                    }
                    alertController.addAction(confirmBtn)
                    self.present(alertController, animated: true) {
                        completionHandler(false)
                    }
                }
            }
        })
    }
    
    func checkFreeDiskSpace(){
        
        if self.callInfo.localRecording! {
            let freeSpace = 1000 * MB //uint64_t
           
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).map(\.path)
            guard let path = paths.last else {
                return
            }

        }
    }
    
    // MARK: Subclass Impl
    func startByCaller () {
        if self.callInfo.callType == .video {
            self.playConnectRing()
            self.doStartByCaller()
        } else {
            self.playConnectRing()
            weak var wself = self

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
               
                wself?.doStartByCaller()
            })

        }
    }
    
    func doStartByCaller () {
        
        self.callInfo.requestId = self.getChannelName(caller: self.callInfo.caller ?? "", callee: self.callInfo.callee ?? "")
        let data: [String: Any] = [:]
        let dict: [String : Any] = ["type": NERtCallingType.p2p.rawValue, "data": data]
        let customInfo = dict.toJSON
        let request = NIMSignalingCallExRequest()
        request.channelType = self.callInfo.callType
        request.accountId = self.callInfo.callee ?? ""
        request.requestId = self.callInfo.requestId ?? ""
        request.nertcChannelName = self.getChannelName(caller: self.callInfo.caller ?? "")
        request.customInfo = customInfo ?? ""
        request.offlineEnabled = true
        let push = NIMSignalingPushInfo()
        push.needPush = true
        push.needBadge = true
        push.pushTitle = self.callInfo.caller ?? ""
        push.pushContent = String(format: "call_request".localized, self.callInfo.callType.rawValue == NIMSignalingChannelType.audio.rawValue ? "msg_type_voice_call".localized : "msg_type_video_call".localized )
        request.push = push
        
        NIMSDK.shared().signalManager.signalingCallEx(request) {[weak self] error,  info in
            guard let self = self else {
               return
            }
            if let error = error {
                self.showError(message: error.localizedDescription)
                self.navigationController?.view.makeToast(
                    String("connection_fail"),
                    duration: 2,
                    position: CSToastPositionCenter)
                self.dismiss(nil)
            }else{ 
                if let info = info {
                    self.calleeResponseTimer = TimerHolder()
                    self.calleeResponseTimer?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
                    self.channelInfo = info
                    self.joinChannel()
                    let callType: CallType = self.callInfo.callType == .audio ? CallType.voice : CallType.video
                    //self.startCallStoreApi(yunxiId: info.channelId, from: self.callInfo.caller ?? "", to: self.callInfo.callee ?? "", callType: callType, startCall: Date().toFormat("yyyy-MM-dd'T'HH:mm:ss.ssssssZ"), groupType: CallGroupType.individual.rawValue)
                }
   
            }
        }
    }
    
    func startByCallee () {
        
        self.playReceiverRing()
    }
    
    @objc func hangup () {
        
        userHangup = true
        self.player?.stop()
        self.timer?.stopTimer()
        self.calleeResponseTimer?.stopTimer()
        if calleeResponsed {
            self.callEventType = .bill
            //关闭频道
            self.closeChannel(isCallApi: true)
        }else{
            guard let requestId = self.callInfo.requestId, let channelId = channelInfo?.channelId   else {
                self.dismiss()
                return
            }
            //取消邀请
            let request = NIMSignalingCancelInviteRequest()
            request.channelId = channelId
            request.accountId = self.peerUid ?? ""
            request.requestId = requestId
            NIMSDK.shared().signalManager.signalingCancelInvite(request) {[weak self] error in
                guard let self = self else {
                   return
                }
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }else{
                    
                }
                self.callEventType = .miss
                self.leavlChannel()
                //self.callLogPatcheApi(yunxiId: channelId, action: CallActionType.missed, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.individual)
            }
            
            
        }

    }
    
    func response(_ accept: Bool) {
        calleeResponseTimer?.stopTimer()
        self.player?.stop()
        if accept {
            
            guard let channelId = self.callInfo.channelId ,let requestId = self.callInfo.requestId else {
                return
            }
            let request = NIMSignalingJoinAndAcceptRequest()
            request.channelId = channelId
            request.accountId = self.callInfo.caller ?? ""
            request.requestId = requestId

            NIMSDK.shared().signalManager.signalingJoinAndAccept(request) { [weak self] error, info in
                if let error = error {
                    self?.showError(message: error.localizedDescription ?? "")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0){
                        self?.dismiss()
                    }
                }else{
                    if let info = info {
                        self?.channelInfo = info
                        self?.calleeResponsed = true
                        self?.joinChannel(isResponse: true)
                        
                        print("info = \(info)")
                        self?.callLogPatcheApi(yunxiId: channelId, action: CallActionType.accept, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.individual)
                    }
                    
                }
            }
            self.waitForConnecting()
        } else {
            //拒绝邀请
            guard let channelId = self.callInfo.channelId, let requestId = self.callInfo.requestId else {
                return
            }
            
            let request = NIMSignalingRejectRequest()
            request.channelId = channelId
            request.accountId = self.callInfo.caller ?? ""
            request.requestId = requestId
            NIMSDK.shared().signalManager.signalingReject(request) { error in
                //self.callLogPatcheApi(yunxiId: channelId, action: CallActionType.reject, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.individual)
                self.dismiss {}
            }
            
        }
    }
    //关闭频道
    func closeChannel(isCallApi: Bool = false){
        let request = NIMSignalingCloseChannelRequest()
        request.channelId = channelInfo?.channelId ?? ""
        
        NIMSDK.shared().signalManager.signalingCloseChannel(request) { error in
            if let error = error {
                
            }else {
                if isCallApi {
                    let action: CallActionType = self.callEventType == .noResponse ? CallActionType.missed : CallActionType.end
                    //self.callLogPatcheApi(yunxiId: request.channelId, action: action, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.individual)
                }
                
            }
            self.leavlChannel()
        }
        
    }
    
    func dismiss(_ completion: (() -> Void)? = nil) {
        checkAndDismiss(completion)
    }
    
    func checkAndDismiss (_ completion: (() -> Void)? = nil) {
    
        if navigationController is TSNavigationController {
            let transition = CATransition()
            transition.duration = 0.25
            transition.timingFunction = CAMediaTimingFunction(name: .default)
            transition.type = .push
            transition.subtype = .fromBottom
            navigationController?.view.layer.add(transition, forKey: nil)
            navigationController?.isNavigationBarHidden = false
            navigationController?.popViewController(animated: false)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(transition.duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if self.isCaller {
                    self.sendCallMessage(callType: self.callType, eventType: self.callEventType, duration: TimeInterval(self.meetingSeconds))
                }
            })
            
        } else {
            self.dismiss(animated: true) {
                if self.isCaller {
                    self.sendCallMessage(callType: self.callType, eventType: self.callEventType, duration: TimeInterval(self.meetingSeconds))
                }
            }
        }
    }
    
    func onCalling () {
        
    }
    
    func waitForConnecting () {
        
    }
    
    func onCalleeBusy () {
        
    }
    
    
    // MARK: Ring
    func playConnectRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "yippi_ringtone", withExtension: "wav")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playHangUpRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playOnCallRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playTimeoutRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "video_chat_tip_ended", withExtension: "aac")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playReceiverRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "yippi_ringtone", withExtension: "wav")
        do {
            if let url = url {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                try AVAudioSession.sharedInstance().setActive(true)
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    
    func playSenderRing () {
        self.player?.stop()
        let url = Bundle.main.url(forResource: "yippi_ringtone", withExtension: "mp3")
        do {
            if let url = url {
                player = try AVAudioPlayer(contentsOf: url)
                player?.numberOfLoops = 20
                player?.play()
            }
        } catch {
            
        }
    }
    //音视频2.0
    func joinChannel(isResponse: Bool = false){
        let member = self.channelInfo?.members.first(where: {$0.accountId == NIMSDK.shared().loginManager.currentAccount()})
        if let uid = member?.uid , let token = self.channelInfo?.nertcToken, let channelName = self.channelInfo?.channelName{
            let result = NERtcEngine.shared().joinChannel(withToken: token, channelName: channelName, myUid: uid) {[weak self] error, a, b, c in
                if let error = error {
                    self?.showError(message: error.localizedDescription ?? "")
                    self?.closeChannel()
                    self?.dismiss()
                }else{
                    if isResponse {
                        self?.stopPreview()
                        self?.meetingSeconds = 0
                        self?.timer = TimerHolder()
                        self?.timer?.startTimer(seconds: 1, delegate: self!, repeats: true)
                        self?.onCalling()
                    }
                }
            }
        }
        
        
    }
    func leavlChannel(){
        NERtcEngine.shared().leaveChannel()
        self.dismiss()
    }
    //远端视频
    func setRemoteVideo(userID: UInt64){
        
    }
    //订阅远端视频
    func subscribeRemoteVideo(userID: UInt64, profile: NERtcVideoProfileType){
        
    }
    //监听到对方禁止视频
    func userMutedRemoteVideo(userID: UInt64, muted: Bool){
    }
    //停止预览
    func stopPreview(){
        
    }
    
    func onResponseVideoMode(){}
    func videoCallingInterface(){}
    func switchToAudio(){}
    func switchToVideo(){}
    
    func getChannelName(caller: String, callee: String = "")-> String{
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let name = (caller + callee + String(timeStamp))
        return name.md5
    }
    
    func sendCallMessage(callType: NIMSignalingChannelType = .audio, eventType: CallingEventType, duration: TimeInterval = 0){
        let nick = SessionUtil.showNick(NIMSDK.shared().loginManager.currentAccount(), in: nil)
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        let attachment = IMCallingAttachment()
        attachment.callType = callType
        attachment.eventType = eventType
        attachment.duration = duration
        customObject.attachment = attachment
        message.messageObject = customObject
        let setting = NIMMessageSetting()
        setting.apnsEnabled = false
        message.setting = setting
        let session = NIMSession(self.callInfo.peerUid ?? "", type: .P2P)
        try? NIMSDK.shared().chatManager.send(message, to: session)
    }
    
    func durationDesc() -> String? {
        return String(format: "%02d:%02d", meetingSeconds / 60, meetingSeconds % 60)
    }
    //发起呼叫
    func startCallStoreApi(yunxiId: String, from: String, to: String, callType: CallType = .voice, startCall: String, groupType: String){
        CallRequest().startCallStore(yunxiId: yunxiId, from: from, to: to, callType: callType, startCall: startCall, groupType: groupType) { model in
            
        } onFailure: { error in
            
        }

    }
    ///
    func callLogPatcheApi(yunxiId: String, action: CallActionType, actionTime: String, groupType: CallGroupType){
        CallRequest().callLogPatch(yunxiId: yunxiId, action: action, actionTime: actionTime, groupType: groupType) {
            
        } onFailure: { error in
            
        }

    }
    
}


extension NetChatViewController: TimerHolderDelegate {
    @objc func onTimerFired(holder: TimerHolder) {
        if holder == self.timer {
            self.meetingSeconds = meetingSeconds + 1
//            if self.meetingSeconds == Int(NoBodyResponseTimeOut) {
//                if !calleeResponsed {
//                    self.callEventType = .noResponse
//                    self.player?.stop()
//                    self.timer?.stopTimer()
//                    view.makeToast("no_answer_call".localized, duration: 2, position: CSToastPositionCenter)
//                    self.closeChannel()
//                }
//            }
        }else if holder == self.calleeResponseTimer {
            
            if !calleeResponsed {
                calleeResponseTimer?.stopTimer()
                self.player?.stop()
                if isCaller {
                    self.callEventType = .noResponse
                    view.makeToast("no_answer_call".localized, duration: 2, position: CSToastPositionCenter)
                    self.closeChannel(isCallApi: true)
                }else {
                    navigationController?.view.makeToast("timeout_answer".localized, duration: 2, position: CSToastPositionCenter)
                    self.dismiss()
                }
                
            }
        }
        
    }
}


extension NetChatViewController: NIMSignalManagerDelegate{
    func nimSignalingOnlineNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        
        switch eventType {
        case .invite:
            break
        case .cancelInvite:
            if !calleeResponsed { //没接听
                calleeResponseTimer?.stopTimer()
                self.player?.stop()
                self.dismiss {}
            }
            
        case .close:
            callEventType = .bill
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            self.closeChannel()
        case .reject:
            callEventType = .reject
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    let msg = type == "isCallBusy" ? "avchat_peer_busy".localized : "chatroom_rejected".localized
                    self.view.makeToast(msg, duration: 2, position: CSToastPositionCenter)
                }
            }
            self.closeChannel()
        case .leave:
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            self.closeChannel()
        case .accept:
            calleeResponseTimer?.stopTimer()
            calleeResponsed = true
            self.player?.stop()
            self.meetingSeconds = 0
            self.timer = TimerHolder()
            self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
            self.onCalling()
            
        case .contrl:
            
            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                if let type = customInfo["type"] as? String {
                    switch NERtChangeType(rawValue: type) {
                    case .toAudio:
                        self.switchToAudio()
                    case .toVideo:
                        self.onResponseVideoMode()
                    case .agreeToVideo:
                        self.switchToVideo()
                    case .rejectToVideo:
                        self.view.makeToast("switching_reject_video".localized, duration: 2, position: CSToastPositionCenter)
                    default:
                        break
                    }
                    
                }
            }
            
        default:
            break
        }
        
    }
     /*在线多端同步通知

     @param eventType 信令操作事件类型：这里只有接受和拒绝
     @param notifyResponse 信令通知回调数据
     @discussion 用于通知信令相关的多端同步通知。比如自己在手机端接受邀请，PC端会同步收到这个通知  NIMSignalingEventType 5-6有效
     */
    func nimSignalingMultiClientSyncNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        
        switch eventType {
        case .reject:
            //其他端拒绝了邀请
            self.player?.stop()
            self.calleeResponseTimer?.stopTimer()
            self.dismiss()
            break
        case .accept:
            //其他端接受了邀请
            self.player?.stop()
            self.calleeResponseTimer?.stopTimer()
            self.dismiss()
            
            break
        default:
            break
        }
    }

}

extension NetChatViewController: NERtcEngineDelegateEx{
    
    func onNERtcEngineConnectionStateChange(with state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        self.oppositeUserID = userID
        
        self.setRemoteVideo(userID: userID)
    }
    
    func onNERtcEngineUserSubStreamAudioDidStart(_ userID: UInt64) {
        
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        
        self.subscribeRemoteVideo(userID: userID, profile: profile)
        
    }
    
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {
        
    }
    //对方关闭摄像机
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
        self.userMutedRemoteVideo(userID: userID, muted: muted)
    }
    
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        callEventType = .bill
        self.timer?.stopTimer()
        self.player?.stop()
        self.dismiss()
    }
    
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        if reason != .neRtcSessionLeaveNormal {
            self.player?.stop()
            timer?.stopTimer()
            calleeResponseTimer?.stopTimer()
            callEventType = .bill
            self.closeChannel(isCallApi: true)
        }
    }
    
    
    
}
