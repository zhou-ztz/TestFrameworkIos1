//
//  AudioCallController.swift
//  Yippi
//
//  Created by Khoo on 17/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import Toast
import NERtcSDK
import NIMSDK
//import NIMPrivate
class AudioCallController: NetChatViewController {
    
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var switchVideoBtn: UIButton!
    @IBOutlet var muteBtn: UIButton!
    @IBOutlet var speakerBtn: UIButton!
    @IBOutlet var hangUpBtn: UIButton!
    @IBOutlet var connectingLabel: UILabel!
    @IBOutlet var voiceCallLabel: UILabel!
    @IBOutlet var refuseBtn: UIButton!
    @IBOutlet var acceptBtn: UIButton!
    @IBOutlet var netStatusView: VideoChatNetStatusView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var declineLabel: UILabel!
    @IBOutlet var acceptLabel: UILabel!
    @IBOutlet var userProfile: UIImageView!
    @IBOutlet var muteLabel: UILabel!
    @IBOutlet var speakerLabel: UILabel!
    
    convenience init(callInfo: NetCallChatInfo) {
        self.init(nibName: nil, bundle: nil)
        self.callInfo = callInfo
        self.callInfo.isMute = false
        self.callInfo.disableCammera = false
        self.callInfo.useSpeaker = false
        //NIMAVChatSDK.shared().netCallManager.switch(.audio)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        callInfo.callType = .audio
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.post(name: NSNotification.Name("BackgroundSoundShouldStop"), object: nil)
        
        let userNameStr = NIMSDKManager.shared.getCurrentLoginUserName()
        let compareStr = callInfo.caller

        muteLabel.text = "mute".localized
        speakerLabel.text = "speaker".localized
        //acceptLabel.text = String("accept_session")
        //declineLabel.text = String("reject_session")
        switchVideoBtn.setTitle("avchat_switch_to_video".localized, for: .normal)
        switchVideoBtn.setImage(UIImage.set_image(named: "ic_switch_video"), for: .normal)
        //
        muteBtn.setBackgroundImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        muteBtn.setBackgroundImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        
        let refuse_image = UIImage.set_image(named: "icon_decline")
        refuseBtn.setBackgroundImage(refuse_image, for: .normal)

        let accept_image = UIImage.set_image(named: "icon_accept")
        acceptBtn.setBackgroundImage(accept_image, for: .normal)

        let hangUp_image = UIImage.set_image(named: "icon_reject")
        hangUpBtn.setBackgroundImage(hangUp_image, for: .normal)

        switchVideoBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        
        if (userNameStr == compareStr) == false {
            let nick = SessionUtil.showNick(self.callInfo.caller, in: nil)
            LocalRemarkName.getRemarkName(userId: nil, username: self.callInfo.caller, originalName: nick, label: self.usernameLabel)
        }
        usernameLabel.adjustsFontSizeToFitWidth = true
        connectingLabel.adjustsFontSizeToFitWidth = true

        if (callInfo.caller == NIMSDK.shared().loginManager.currentAccount()) {
            connectingLabel.text = "avchat_wait_receive".localized
        } else {
            connectingLabel.text = "invite_you_to_voice_call".localized
        }

        initUI()
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    func initUI () {
        refuseBtn.layer.cornerRadius = 0.5 * refuseBtn.bounds.size.width
        acceptBtn.layer.cornerRadius = 0.5 * acceptBtn.bounds.size.width
        hangUpBtn.layer.cornerRadius = 0.5 * hangUpBtn.bounds.size.width
        userProfile.layer.cornerRadius = 0.5 * userProfile.bounds.size.width
        userProfile.layer.masksToBounds = true
        hangUpBtn.layer.masksToBounds = true
        refuseBtn.isExclusiveTouch = true
        acceptBtn.isExclusiveTouch = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Call Life
    override func startByCaller () {
        super.startByCaller()
        self.startInterface()
    }
    
    override func startByCallee() {
        super.startByCallee()
        waitToCallInterface()
    }

    override func onCalling() {
        super.onCalling()
        audioCallingInterface()
    }

    override func waitForConnecting() {
        super.onCalling()
        connectingInterface()
    }
    
    // MARK: Interface
    func startInterface () {
//        let peerUid = self.callInfo.caller ?? "" == NIMSDK.shared().loginManager.currentAccount() ? self.callInfo.callee : self.callInfo.caller
//        
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(peerUid ?? "")
//        self.userProfile.image = info.avatarImage
//        
//        let nick = SessionUtil.showNick(peerUid, in: nil)
//        LocalRemarkName.getRemarkName(userId: nil, username: peerUid, originalName: nick, label: self.usernameLabel)
//        
//        hangUpBtn.isHidden = false
//        muteBtn.isHidden = false
//        speakerBtn.isHidden = false
//        durationLabel.isHidden = true
//        switchVideoBtn.isHidden = true
//        connectingLabel.isHidden = false
//        usernameLabel.isHidden = false
//        connectingLabel.text = "calling_pls_wait".localized
//        refuseBtn.isHidden = true
//        acceptBtn.isHidden = true
//        //declineLabel.isHidden = true
//        //acceptLabel.isHidden = true
//        muteLabel.isHidden = false
//        speakerLabel.isHidden = false
//
//        muteBtn.isEnabled = false
//        speakerBtn.isEnabled = true
    }
    
    func waitToCallInterface () {
//        let peerUid = self.callInfo.caller ?? "" == NIMSDK.shared().loginManager.currentAccount() ? self.callInfo.callee : self.callInfo.caller
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(peerUid ?? "")
//        self.userProfile.image = info.avatarImage
//        
//        hangUpBtn.isHidden = true
//        durationLabel.isHidden = true
//        switchVideoBtn.isHidden = true
//        connectingLabel.isHidden = false
//        let nick = SessionUtil.showNick(peerUid, in: nil)
//        LocalRemarkName.getRemarkName(userId: nil, username: peerUid, originalName: nick, label: self.usernameLabel)
//
//        connectingLabel.text = "calling_in_voice".localized
//        refuseBtn.isHidden = false
//        acceptBtn.isHidden = false
//        //declineLabel.isHidden = false
//        //acceptLabel.isHidden = false
//
//        muteLabel.isHidden = false
//        speakerLabel.isHidden = false
//        muteBtn.isHidden = false
//        speakerBtn.isHidden = false
//
//        muteBtn.isEnabled = false
//        speakerBtn.isEnabled = false
    }
    
    func connectingInterface () {
        hangUpBtn.isHidden = false
        muteBtn.isHidden = true
        speakerBtn.isHidden = true
        durationLabel.isHidden = true
        switchVideoBtn.isHidden = true
        connectingLabel.isHidden = false
        connectingLabel.text = "connecting".localized
        refuseBtn.isHidden = true
        acceptBtn.isHidden = true
        //declineLabel.isHidden = true
        //acceptLabel.isHidden = true
        muteLabel.isHidden = true
        speakerLabel.isHidden = true
    }
    
    func audioCallingInterface () {
//        let peerUid = self.callInfo.caller ?? "" == NIMSDK.shared().loginManager.currentAccount() ? self.callInfo.callee : self.callInfo.caller
//        let info = NIMBridgeManager.sharedInstance().getUserInfo(peerUid ?? "")
//        self.userProfile.image = info.avatarImage
//
//        let nick = SessionUtil.showNick(peerUid, in: nil)
//
//        LocalRemarkName.getRemarkName(userId: nil, username: peerUid, originalName: nick, label: self.usernameLabel)
//
//        //self.netStatusView.refresh(withNetState: )
//        
//        voiceCallLabel.isHidden = true
//        hangUpBtn.isHidden = false
//        muteBtn.isHidden = false
//        speakerBtn.isHidden = false
//        durationLabel.isHidden = false
//        switchVideoBtn.isHidden = false
//        usernameLabel.isHidden = false
//        connectingLabel.isHidden = true
//        refuseBtn.isHidden = true
//        acceptBtn.isHidden = true
//        //declineLabel.isHidden = true
//        //acceptLabel.isHidden = true
//        muteBtn.isSelected = callInfo.isMute ?? false
//        speakerBtn.isSelected = callInfo.useSpeaker ?? false
//        muteLabel.isHidden = false
//        speakerLabel.isHidden = false
//
//        muteBtn.isEnabled = true
//        speakerBtn.isEnabled = true
    }
    
    override func videoCallingInterface () {
      let vc = VideoCallController(callInfo: callInfo)
      vc.shouldDisableFaceUnity = shouldDisableFaceUnity
      navigationController?.pushViewController(vc, animated: false)
      var vcs = navigationController?.viewControllers
      vcs?.removeAll { $0 as AnyObject === self as AnyObject }
      if let vcs = vcs {
          navigationController?.viewControllers = vcs
      }
    }
    
    
    // MARK: IBaction
    @IBAction func hangup(_ sender: Any) {
        hangup()
    }
    
    @IBAction func acceptToCall(_ sender: Any) {
        if let button = sender as? UIButton {
            let accept = button == self.acceptBtn
            self.response(accept)
        }
    }
    
    @IBAction func mute(_ sender: Any) {
        self.callInfo.isMute = !self.callInfo.isMute!
        self.muteBtn.isSelected = self.callInfo.isMute ?? false
        NERtcEngine.shared().muteLocalAudio(self.callInfo.isMute ?? false)
        
        muteBtn = sender as? UIButton
        
        if muteBtn.tag == 1 {
            muteBtn.tag = 0
            muteLabel.text = "mute".localized
        } else {
            muteBtn.tag = 1
            muteLabel.text = "cancel_muted".localized
        }
    }
    
    @IBAction func userSpeaker(_ sender: Any) {
        self.callInfo.useSpeaker = !self.callInfo.useSpeaker!
        self.speakerBtn.isSelected = self.callInfo.useSpeaker ?? false
        NERtcEngine.shared().setLoudspeakerMode(self.callInfo.useSpeaker ?? false)
    }
    
    @IBAction func switchToVideoMode(_ sender: Any) {
        view.makeToast("request_switching_sent".localized, duration: 2, position: CSToastPositionCenter)
        let request = NIMSignalingControlRequest()
        request.channelId = self.callInfo.channelId ?? ""
        request.customInfo = "toVideo"
        request.accountId = self.callInfo.peerUid ?? ""
        NIMSDK.shared().signalManager.signalingControl(request)
       // NIMAVChatSDK.shared().netCallManager.control(self.callInfo.callID!, type: NIMNetCallControlType.toVideo)
    }
    
    
    
    
    // NIMNetCallManagerDelegate
//    override func onControl(_ callID: UInt64, from user: String, type control: NIMNetCallControlType) {
//        super.onControl(callID, from: user, type: control)
//
//        switch control {
//        case .toVideo:
//            self.onResponseVideoMode()
//            break
//        case .agreeToVideo:
//            self.videoCallingInterface()
//            break
//        case .rejectToVideo:
//            view.makeToast("switching_reject_video".localized, duration: 2, position: CSToastPositionCenter)
//        default:
//            break
//        }
//    }
    
    
//    override func onCallEstablished(_ callID: UInt64) {
//        if self.callInfo.callID == callID {
//            super.onCallEstablished(callID)
//            self.durationLabel.isHidden = false
//            self.durationLabel.text = self.durationDesc()
//        }
//    }
    
    override func onTimerFired(holder: TimerHolder) {
        super.onTimerFired(holder: holder)
        self.durationLabel.text = self.durationDesc()
    }
    
//    func onNetStatus(_ status: NIMNetCallNetStatus, user: String) {
//        if user == self.peerUid {
//            self.netStatusView.refresh(withNetState: status)
//        }
//    }
    
    // MARK: Misc
    
//    override func onResponseVideoMode() {
//        let alert = UIAlertController(title: nil, message: "request_switching".localized, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "rejected".localized, style: .cancel, handler: { (action) in
//            let request = NIMSignalingControlRequest()
//            request.channelId = self.callInfo.channelId ?? ""
//            request.customInfo = "rejectToVideo"
//            request.accountId = self.callInfo.peerUid ?? ""
//            NIMSDK.shared().signalManager.signalingControl(request)
//        //    NIMAVChatSDK.shared().netCallManager.control(self.callInfo.callID!, type: NIMNetCallControlType.rejectToVideo)
//            self.view.makeToast(
//                String("rejected"),
//                duration: 2,
//                position: CSToastPositionCenter)
//            
//        }))
//        alert.addAction(UIAlertAction(title: "accept_session".localized, style: .default, handler: { (action) in
//            let request = NIMSignalingControlRequest()
//            request.channelId = self.callInfo.channelId ?? ""
//            request.customInfo = "agreeToVideo"
//            request.accountId = self.callInfo.peerUid ?? ""
//            NIMSDK.shared().signalManager.signalingControl(request)
//         //   NIMAVChatSDK.shared().netCallManager.control(self.callInfo.callID!, type: NIMNetCallControlType.agreeToVideo)
//            self.videoCallingInterface()
//            
//        }))
//        
//        self.present(alert, animated: true, completion: nil)
//    }

}
