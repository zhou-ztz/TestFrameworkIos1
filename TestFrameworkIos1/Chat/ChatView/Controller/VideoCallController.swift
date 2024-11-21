//
//  VideoCallController.swift
//  Yippi
//
//  Created by Khoo on 17/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import Toast
import NERtcSDK
//import NIMPrivate

class VideoCallController: NetChatViewController /*, FUItemsViewDelegate*/ {
    
    @IBOutlet weak var bigVideoView: UIImageView!
    @IBOutlet weak var smallVideoView: UIView!
    @IBOutlet var hungUpBtn: UIButton!
    @IBOutlet var acceptBtn: UIButton!
    @IBOutlet var refuseBtn: UIButton!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var muteBtn: UIButton!
    @IBOutlet var switchModelBtn: UIButton!
    @IBOutlet var switchCameraBtn: UIButton!
    @IBOutlet var disableCameraBtn: UIButton!
    @IBOutlet var filterBtn: UIButton!
    @IBOutlet var stickerBtn: UIButton!
    @IBOutlet var connectingLabel: UILabel!
    @IBOutlet var netStatusView: VideoChatNetStatusView!
    //acceptLabel declineLabel
    @IBOutlet var usernameLabel: UILabel!
 
    @IBOutlet weak var cameraDisableImage: UIImageView!
    
    @IBOutlet var videoCallLabel: UILabel!
    @IBOutlet var muteLabel: UILabel!
    @IBOutlet var cameraOffLabel: UILabel!
    @IBOutlet var recordLabel: UILabel!
    @IBOutlet var videoIsPauseLabel: UILabel!
    @IBOutlet var userProfile: UIImageView!

    
    var cameraType: NERtcCameraPosition = .front
    var localVideoLayer: CALayer?
    var oppositeCloseVideo = false

    
    //var remoteGLView: NTESGLView?

    var localView: UIView? = UIView()
    weak var localPreView: UIView?
    var calleeBasy = false
    var isWaitForConnecting = false

    var overLayView: UIView?
    var connected = false
    var previewView: PreviewView?
    var isUsingFrontCameraPreview = false
    
    var remoteView: UIView? = UIView()
    
    var removeCanvas: NERtcVideoCanvas?
    var localCanvas: NERtcVideoCanvas?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }


    // 销毁道具
    deinit {
//        FUManager.shared.destoryItems()
    }

    // MARK: ----- 以上FaceUnity

    convenience init(callInfo: NetCallChatInfo?) {
        self.init(nibName: nil, bundle: nil)
        self.callInfo = callInfo!
        self.callInfo.isMute = false
        self.callInfo.useSpeaker = false
        self.callInfo.disableCammera = false
    }


    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        isUsingFrontCameraPreview = true

        UserDefaults.standard.set(false, forKey: Constants.ShowFrontOrBackCameraKey)
        UserDefaults.standard.synchronize()

        let userNameStr = NIMSDKManager.shared.getCurrentLoginUserName()
        let compareStr = callInfo.caller

        cameraDisableImage.image = UIImage.set_image(named: "btn_camera_pressed")
        
        muteLabel.text = "mute".localized
        switchCameraBtn.isHidden = self.callInfo.callType == .audio
        switchCameraBtn.setImage(UIImage.set_image(named: "btn_turn"), for: .normal)
        
        cameraOffLabel.text =  self.callInfo.callType == .video ? "camera_off".localized : "speaker".localized
        let image = self.callInfo.callType == .video ? UIImage.set_image(named: "btn_camera_video_normal") : UIImage.set_image(named: "btn_speaker_normal")
        let selectImage = self.callInfo.callType == .video ? UIImage.set_image(named: "btn_camera_video_pressed") : UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        videoCallLabel.text = self.callInfo.callType == .video ? "Video Call".localized : "Voice Call".localized
        smallVideoView.isHidden = true
        cameraOffLabel.adjustsFontSizeToFitWidth = true

        let refuse_image = UIImage.set_image(named: "icon_decline")
        refuseBtn.setBackgroundImage(refuse_image, for: .normal)

        let accept_image = self.callInfo.callType == .video ? UIImage.set_image(named: "icon_accept_video") : UIImage.set_image(named: "icon_accept")
        acceptBtn.setBackgroundImage(accept_image, for: .normal)

        let hangUp_image = UIImage.set_image(named: "icon_reject")
        hungUpBtn.setBackgroundImage(hangUp_image, for: .normal)
        hungUpBtn.addTarget(self, action: #selector(hangup), for: .touchUpInside)
        
        let mute_image = UIImage.set_image(named: "btn_mute_normal")
        muteBtn.setBackgroundImage(mute_image, for: .normal)
        muteBtn.setBackgroundImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)

        let sticker_image = UIImage.set_image(named: "camera_btn_sticker_video")
        stickerBtn.setBackgroundImage(sticker_image, for: .normal)

        let filter_image = UIImage.set_image(named: "camera_btn_filter_video")
        filterBtn.setBackgroundImage(filter_image, for: .normal)

        if (userNameStr == compareStr) == false {
            let nick = SessionUtil.showNick(callInfo.caller, in: nil)
            LocalRemarkName.getRemarkName(userId: nil, username: callInfo.caller, originalName: nick, label: usernameLabel)
        }


        connectingLabel.adjustsFontSizeToFitWidth = true
        let switchModelText =  self.callInfo.callType == .video ? "avchat_switch_to_audio".localized : "avchat_switch_to_video".localized
        switchModelBtn.setTitle(switchModelText, for: .normal)
        switchModelBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        switchModelBtn.setImage(UIImage.set_image(named: "ic_switch_video"), for: .normal)
        
        if callInfo.caller == NIMSDK.shared().loginManager.currentAccount() {
            connectingLabel.text = "avchat_wait_receive".localized
        } else {
            connectingLabel.text = self.callInfo.callType == .audio ? "invite_you_to_voice_call".localized : "calling_in_video".localized
        }

        initUI()
        tabBarController?.tabBar.isHidden = true

    }

    func initUI() {
        refuseBtn.layer.cornerRadius = 0.5 * refuseBtn.bounds.size.width
        acceptBtn.layer.cornerRadius = 0.5 * acceptBtn.bounds.size.width
        userProfile.layer.cornerRadius = 0.5 * userProfile.bounds.size.width
        userProfile.layer.masksToBounds = true
        refuseBtn.isExclusiveTouch = true
        acceptBtn.isExclusiveTouch = true
        
        remoteView?.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
        bigVideoView.addSubview(remoteView!)
        localView?.frame = smallVideoView.bounds
        smallVideoView.addSubview(localView!)
    }


    // MARK: - Call Life
    override func startByCaller() {
        super.startByCaller()
        startInterface()
    }

    override func startByCallee() {
        super.startByCallee()
        waitToCallInterface()
    }

    override func onCalling() {
        super.onCalling()
        videoCallingInterface()
    }

    override func waitForConnecting() {
        super.waitForConnecting()
        connectingInterface()
    }

    override func onCalleeBusy() {
        calleeBasy = true
        localPreView?.removeFromSuperview()
    }

    // MARK: - Interface
    //正在接听中界面
    func startInterface() {

//        let peerUid = (callInfo.caller == NIMSDK.shared().loginManager.currentAccount()) ? callInfo.callee : callInfo.caller
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(peerUid ?? "")
//        userProfile.image = info.avatarImage
//        let nick = SessionUtil.showNick(peerUid, in: nil)
//        LocalRemarkName.getRemarkName(userId: nil, username: peerUid, originalName: nick, label: usernameLabel)
//
//        connectingLabel.text = "calling_pls_wait".localized
//
//        acceptBtn.isHidden = true
//        refuseBtn.isHidden = true
//        //acceptLabel.isHidden = true
//        //declineLabel.isHidden = true
//        smallVideoView.isHidden = true
//        switchModelBtn.isHidden = true
//        videoIsPauseLabel.isHidden = true
//        videoIsPauseLabel.isHidden = true
//
//        hungUpBtn.isHidden = false
//        connectingLabel.isHidden = false
//        switchCameraBtn.isHidden = false
//        muteBtn.isHidden = false
//        disableCameraBtn.isHidden = false
//
//        muteBtn.isEnabled = false
//        disableCameraBtn.isEnabled = false
//        isWaitForConnecting = false
//
//
//        hungUpBtn.removeTarget(self, action: nil, for: .touchUpInside)
//        hungUpBtn.addTarget(self, action: #selector(hangup), for: .touchUpInside)
//        
//        overLayView?.isHidden = true
//        
//        localView?.isHidden = self.callInfo.callType == .audio
//        remoteView?.isHidden = self.callInfo.callType == .audio
//        self.setLocalVideo(videoView: remoteView!, enable: self.callInfo.callType == .video)
//        if self.callInfo.callType == .video {
//            bigVideoView.isHidden = false
//            //smallVideoView.isHidden = false
//            
//        }else {
//            bigVideoView.isHidden = true
//            smallVideoView.isHidden = true
//            switchCameraBtn.isHidden = true
//            
//        }
//        
//
//        #if TARGET_IPHONE_SIMULATOR
//        //do nothing
//        stickerBtn.isHidden = true
//        filterBtn.isHidden = true
//        #else
////        demoBar?.isHidden = shouldDisableFaceUnity
////        stickerPadView?.isHidden = shouldDisableFaceUnity
//        stickerBtn.isHidden = shouldDisableFaceUnity
//        filterBtn.isHidden = shouldDisableFaceUnity
//
//        #endif
//        
        

    }

    func waitToCallInterface () {
//        let peerUid = (callInfo.caller == NIMSDK.shared().loginManager.currentAccount()) ? callInfo.callee : callInfo.caller
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(peerUid ?? "")
//        userProfile.image = info.avatarImage
//
//        let nick = SessionUtil.showNick(peerUid, in: nil)
//        usernameLabel.text = nick
//        connectingLabel.text = self.callInfo.callType == .video ? "calling_in_video".localized : "calling_in_voice".localized
//        LocalRemarkName.getRemarkName(userId: nil, username: peerUid, originalName: nick, label: usernameLabel)
//
//        hungUpBtn.isHidden = true
//        smallVideoView.isHidden = true
//        muteBtn.isHidden = true
//        //disableCameraBtn.isHidden = true
//        //switchModelBtn.isHidden = true
//        videoIsPauseLabel.isHidden = true
//
//        muteLabel.isHidden = false
//        cameraOffLabel.isHidden = false
//       // recordLabel.isHidden = false
//        muteBtn.isHidden = false
//        disableCameraBtn.isHidden = false
//        acceptBtn.isHidden = false
//        refuseBtn.isHidden = false
//        //acceptLabel.isHidden = false
//       // declineLabel.isHidden = false
//        switchCameraBtn.isHidden = self.callInfo.callType == .audio
//        localView?.isHidden = self.callInfo.callType == .audio
//        remoteView?.isHidden = self.callInfo.callType == .audio
//        if self.callInfo.callType == .video {
//            self.setLocalVideo(videoView: remoteView!, isPreView: true)
//        }
//        
//        overLayView?.isHidden = true
//        isWaitForConnecting = true
//
//        muteBtn.isEnabled = false
//        disableCameraBtn.isEnabled = false
//
//        #if TARGET_IPHONE_SIMULATOR
//        //do nothing
//        stickerBtn.isHidden = true
//        filterBtn.isHidden = true
//        #else
//        stickerBtn.isHidden = true
//        filterBtn.isHidden = true
//
//        #endif

    }

    //连接对方界面
    func connectingInterface() {
        isWaitForConnecting = false
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        //acceptLabel.isHidden = true
        //declineLabel.isHidden = true
        hungUpBtn.isHidden = false
        usernameLabel.isHidden = true
        connectingLabel.isHidden = false
        connectingLabel.text = "connecting".localized
        switchModelBtn.isHidden = true
        switchCameraBtn.isHidden = true
        muteBtn.isHidden = true
        disableCameraBtn.isHidden = true
        videoIsPauseLabel.isHidden = true
        hungUpBtn.removeTarget(self, action: nil, for: .touchUpInside)
        hungUpBtn.addTarget(self, action: #selector(hangup), for: .touchUpInside)

//        demoBar?.isHidden = true
//        stickerPadView?.isHidden = true
        stickerBtn.isHidden = shouldDisableFaceUnity
        filterBtn.isHidden = shouldDisableFaceUnity
    }


    override func videoCallingInterface () {
        userProfile.isHidden = self.callInfo.callType == .video
        usernameLabel.isHidden = self.callInfo.callType == .video
//        let status = NIMAVChatSDK.shared().netCallManager.netStatus(peerUid)
       // netStatusView.refresh(withNetState: status)
        videoCallLabel.isHidden = self.callInfo.callType == .video
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        //acceptLabel.isHidden = true
        //declineLabel.isHidden = true
        hungUpBtn.isHidden = false
        connectingLabel.isHidden = true
        muteBtn.isEnabled = true
        disableCameraBtn.isEnabled = true
        videoIsPauseLabel.isHidden = true

        muteBtn.isHidden = false
        smallVideoView.isHidden = self.callInfo.callType == .audio
        switchCameraBtn.isHidden = self.callInfo.callType == .audio
        disableCameraBtn.isHidden = false
        switchModelBtn.isHidden = false

        muteBtn.isSelected = false
        self.disableCameraBtn.isSelected = false
        NERtcEngine.shared().setLoudspeakerMode(self.callInfo.callType == .video)
        NERtcEngine.shared().switchCamera(with: .front)
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().muteLocalVideo(false, streamType: .mainStream)
        callInfo.isMute = false
        isUsingFrontCameraPreview = true
        callInfo.disableCammera = false
        let switchText = self.callInfo.callType == .video ? "avchat_switch_to_audio".localized : "avchat_switch_to_video".localized
        switchModelBtn.setTitle(switchText, for: .normal)
        hungUpBtn.removeTarget(self, action: nil, for: .touchUpInside)
        hungUpBtn.addTarget(self, action: #selector(hangup), for: .touchUpInside)
        isWaitForConnecting = false
       // previewView?.teardownAVCapture()
        connected = true
        localView?.isHidden = self.callInfo.callType == .audio
        remoteView?.isHidden = self.callInfo.callType == .audio
        self.setLocalVideo(videoView: localView!,enable: self.callInfo.callType == .video)
  
    }

    //切换接听中界面(语音)
    func audioCallingInterface() {

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.75)
        UIView.setAnimationTransition(.flipFromRight, for: view, cache: false)
        UIView.commitAnimations()
        self.callInfo.callType = .audio
        userProfile.isHidden = false
        usernameLabel.isHidden = false
        switchCameraBtn.isHidden = true
        switchModelBtn.setTitle("avchat_switch_to_video".localized, for: .normal)
        self.disableCameraBtn.isSelected = false
        NERtcEngine.shared().setLoudspeakerMode(false)
        NERtcEngine.shared().muteLocalAudio(false)
        muteBtn.isSelected = false
        callInfo.isMute = false
        callInfo.useSpeaker = false
        cameraOffLabel.text =  "speaker".localized
        let image =  UIImage.set_image(named: "btn_speaker_normal")
        let selectImage =  UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        remoteView?.isHidden = true
        localView?.isHidden = true
        if remoteView != nil {
            remoteView?.removeFromSuperview()
        }
        if localView != nil {
            localView?.removeFromSuperview()
        }
        
        self.smallVideoView.isHidden = true
       
        
    }
    //切换接听中界面(视频)
    func videoCallingChange() {
        self.callInfo.callType = .video
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationCurve(.easeInOut)
        UIView.setAnimationDuration(0.75)
        UIView.setAnimationTransition(.flipFromRight, for: view, cache: false)
        UIView.commitAnimations()
        self.smallVideoView.isHidden = false
        bigVideoView.isHidden = false
        remoteView?.isHidden = false
        localView?.isHidden = false
        if localView == nil {
            localView = UIView(frame: smallVideoView.bounds)
        }
        smallVideoView.addSubview(localView!)
        if remoteView == nil {
            remoteView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
        }
        if let userId = self.oppositeUserID , removeCanvas == nil{
            self.setRemoteVideo(userID: userId)
        }
        
        bigVideoView.addSubview(remoteView!)
        localCanvas?.container = localView
        removeCanvas?.container = remoteView
        
        cameraOffLabel.text =  self.callInfo.callType == .video ? "camera_off".localized : "speaker".localized
        let image = self.callInfo.callType == .video ? UIImage.set_image(named: "btn_camera_video_normal") : UIImage.set_image(named: "btn_speaker_normal")
        let selectImage = self.callInfo.callType == .video ? UIImage.set_image(named: "btn_camera_video_pressed") : UIImage.set_image(named: "btn_speaker_pressed")
        disableCameraBtn.setImage(image, for: .normal)
        disableCameraBtn.setImage(selectImage, for: .selected)
        
        self.videoCallingInterface()
    }
    
    override func onResponseVideoMode() {
        let alert = UIAlertController(title: nil, message: "request_switching".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "rejected".localized, style: .cancel, handler: { (action) in
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.rejectToVideo.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            let request = NIMSignalingControlRequest()
            request.channelId = self.channelInfo?.channelId ?? ""
            request.customInfo = customInfo
            request.accountId = self.callInfo.peerUid ?? ""
            NIMSDK.shared().signalManager.signalingControl(request) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }else{
                    self.view.makeToast(
                        String("rejected"),
                        duration: 2,
                        position: CSToastPositionCenter)
                }
            }
            
            
        }))
        alert.addAction(UIAlertAction(title: "accept_session".localized, style: .default, handler: { (action) in
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.agreeToVideo.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            let request = NIMSignalingControlRequest()
            request.channelId = self.channelInfo?.channelId ?? ""
            request.customInfo = customInfo
            request.accountId = self.callInfo.peerUid ?? ""
            NIMSDK.shared().signalManager.signalingControl(request) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }else{
                    self.videoCallingChange()
                }
                    
            }
            
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func setLocalVideo(videoView: UIView, isPreView: Bool = false , enable: Bool = true){
        if localCanvas == nil {
            localCanvas = NERtcVideoCanvas()
        }
        localCanvas?.container = videoView
        localCanvas?.renderMode = .cropFill
        localCanvas?.mirrorMode = .enabled
        NERtcEngine.shared().setupLocalVideoCanvas(localCanvas)
        if isPreView {
            //预览
            NERtcEngine.shared().startPreview(.mainStream)
        }else {
            //以开启本地视频主流采集并发送
            NERtcEngine.shared().enableLocalVideo(enable, streamType: .mainStream)
        }
        
    }
    
    override func stopPreview(){
        NERtcEngine.shared().stopPreview(.mainStream)
    }
    
    override func setRemoteVideo(userID: UInt64){
        if removeCanvas == nil {
            removeCanvas = NERtcVideoCanvas()
        }
        removeCanvas?.container = remoteView
        removeCanvas?.renderMode = .cropFill
        removeCanvas?.mirrorMode = .enabled
        NERtcEngine.shared().setupRemoteVideoCanvas(removeCanvas, forUserID: userID)
        
    }
    //订阅远端视频
    override func subscribeRemoteVideo(userID: UInt64, profile: NERtcVideoProfileType){
        
        NERtcEngine.shared().subscribeRemoteVideo(true, forUserID: userID, streamType: .high)
    }
    
    override func userMutedRemoteVideo(userID: UInt64, muted: Bool){
        if muted {
            if remoteView != nil {
                remoteView?.removeFromSuperview()
            }
        }else{
            if remoteView == nil {
                remoteView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight))
            }
            bigVideoView.addSubview(remoteView!)
            removeCanvas?.container = remoteView
            removeCanvas?.renderMode = .cropFill
            removeCanvas?.mirrorMode = .enabled
            NERtcEngine.shared().setupRemoteVideoCanvas(removeCanvas, forUserID: userID)
        }
    }

    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == self.bigVideoView && connected {
          //  hideAllViews()
        } else {

        }
    }
    
    // MARK: - IBAction
    @IBAction func acceptOrRefuse(toCall sender: Any) {
        if let button = sender as? UIButton {
            let accept = button == self.acceptBtn
            self.response(accept)
        }
    }

    @IBAction func mute(_ sender: Bool) {
        callInfo.isMute = !callInfo.isMute!
        player?.volume = !callInfo.isMute! ? 1 : 0
        muteBtn.isSelected = callInfo.isMute!
        NERtcEngine.shared().muteLocalAudio(self.callInfo.isMute ?? false)
    }

    @IBAction func switchCamera(_ sender: Any) {
        isUsingFrontCameraPreview = !isUsingFrontCameraPreview
        switchCameraBtn.isSelected = isUsingFrontCameraPreview
        cameraType = isUsingFrontCameraPreview ? .back : .front
        NERtcEngine.shared().switchCamera(with: cameraType)

    }

    @IBAction func disableCammera(_ sender: Any) {
        if self.callInfo.callType == .video {
            callInfo.disableCammera = !callInfo.disableCammera!
            NERtcEngine.shared().muteLocalVideo(callInfo.disableCammera ?? false, streamType: .mainStream)
            disableCameraBtn.isSelected = callInfo.disableCammera!
            if callInfo.disableCammera == true {
                if localView != nil {
                    localView?.removeFromSuperview()
                }
            } else {
                if localView == nil {
                    localView = UIView(frame: smallVideoView.bounds)
                }
                smallVideoView.addSubview(localView!)
                localCanvas?.container = localView
                localCanvas?.renderMode = .cropFill
                localCanvas?.mirrorMode = .enabled
                NERtcEngine.shared().setupLocalVideoCanvas(localCanvas)
            }
            
        }else{
            self.callInfo.useSpeaker = !self.callInfo.useSpeaker!
            self.disableCameraBtn.isSelected = self.callInfo.useSpeaker ?? false
            NERtcEngine.shared().setLoudspeakerMode(self.callInfo.useSpeaker ?? false)
        }
        
    }

    @IBAction func switchCallingModel(_ sender: Any) {
        if self.callInfo.callType == .video {
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.toAudio.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            let request = NIMSignalingControlRequest()
            request.channelId = self.channelInfo?.channelId ?? ""
            request.customInfo = customInfo
            request.accountId = self.callInfo.peerUid ?? ""
            NIMSDK.shared().signalManager.signalingControl(request) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }else{
                    self.switchToAudio()
                }
            }
            
        }else {
            let data: [String: Any] = [:]
            let dict = ["type": NERtChangeType.toVideo.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            let request = NIMSignalingControlRequest()
            request.channelId = self.channelInfo?.channelId ?? ""
            request.customInfo = customInfo
            request.accountId = self.callInfo.peerUid ?? ""
            NIMSDK.shared().signalManager.signalingControl(request) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }else{
                    self.view.makeToast("request_switching_sent".localized, duration: 2, position: CSToastPositionCenter)
                }
            }
        }
        
    }

    // M80TimerHolderDelegate
    override func onTimerFired(holder: TimerHolder) {
        super.onTimerFired(holder: holder)
        if holder == self.timer {
            self.durationLabel.text = self.durationDesc()
        }
        
    }

    func hideAllViews() {
        let hideOrShow = !hungUpBtn.isHidden
//
//        #if TARGET_IPHONE_SIMULATOR
//            // Do nothing
//        #else
//        if demoBar?.isHidden == true && stickerPadView?.isHidden == true {

            filterBtn.isHidden = hideOrShow
            stickerBtn.isHidden = hideOrShow
            //acceptLabel.isHidden = hideOrShow
            hungUpBtn.isHidden = hideOrShow
            muteBtn.isHidden = hideOrShow
            switchCameraBtn.isHidden = hideOrShow
            disableCameraBtn.isHidden = hideOrShow
            switchModelBtn.isHidden = hideOrShow
            muteLabel.isHidden = hideOrShow
            cameraOffLabel.isHidden = hideOrShow
           // recordLabel.isHidden = hideOrShow
            hungUpBtn.isHidden = hideOrShow

            disableCameraBtn.isHidden = hideOrShow

            netStatusView.isHidden = hideOrShow
            durationLabel.isHidden = hideOrShow
//        } else if demoBar?.isHidden == false || stickerPadView?.isHidden == false {
//            UIView.animate(withDuration: 0.4, animations: {
//                self.demoBar?.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: 200)
//                self.stickerPadView?.frame = CGRect(x: 0, y: self.view.frame.size.height, width: self.view.frame.size.width, height: 280)
//            }) { finished in
//                self.demoBar?.isHidden = true
//                self.stickerPadView?.isHidden = true
//            }
//        }
//
//        #endif
    }


    override func switchToAudio() {
        audioCallingInterface()
 
    }
    override func switchToVideo(){
        videoCallingChange()
    }



}




