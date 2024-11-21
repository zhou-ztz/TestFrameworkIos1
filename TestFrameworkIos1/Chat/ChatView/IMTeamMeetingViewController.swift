//
//  IMTeamMeetingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/10.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NERtcSDK
import Alamofire
import Toast
import SVProgressHUD
import NIMSDK
import AVFoundation


enum TeamMeetingRoleType: Int {
    case TeamMeetingRoleCaller = 0 //发起者
    case TeamMeetingRoleCallee     //受邀请者
}

class IMTeamMeetingCallerInfo: NSObject {
    var members: [String] = []
    var teamId: String = ""
}

class IMTeamMeetingCalleeInfo: NSObject {
    var members: [String] = []
    var teamId: String = ""
    var requestId: String = ""
    var caller: String = ""
    var channelId: String = ""
    var channelName: String?
}

class IMTeamMeetingViewController: UIViewController {
    let rowsInSection = 9
    let durationLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 22, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
    }
    
    let titleL: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 17, color: .white))
        $0.textAlignment = .center
        $0.text = "Group Video Call".localized
    }
    let callingMembers: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 27, color: .white))
        $0.textAlignment = .center
        $0.text = "连接中，请稍候..."
    }

    let callingInfoLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 20, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "连接中，请稍候..."
    }

    let muteLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 16, color: .white))
        $0.textAlignment = .center
        $0.text = "mute".localized
    }

    let cameraOffLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 16, color: .white))
        $0.textAlignment = .center
        $0.text = "group_open_camera".localized
    }

    let cameraSwitchButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "btn_turn"), for: .normal)
        $0.isHidden = true
    }

    let cameraDisableButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "btn_camera_group_video_normal"), for: .normal)
        $0.setImage(UIImage.set_image(named: "btn_camera_group_video_selected"), for: .selected)
        $0.isEnabled = false
    }

    let acceptBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "icon_accept_video"), for: .normal)
    }

    let refuseBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "icon_decline"), for: .normal)
    }

    let muteButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        $0.setImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        $0.isEnabled = false
    }

    let hangupButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "icon_reject"), for: .normal)
        $0.isHidden = true
    }

    let inviteBtn: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "ic_group_add"), for: .normal)
        $0.isHidden = true
    }
    
    var player: AVAudioPlayer?
    var netStatusView: VideoChatNetStatusView?
    var team: NIMTeam?
    var enableSpeaker: Bool = false
    var role: TeamMeetingRoleType = .TeamMeetingRoleCaller
    //发起者信息
    var callerInfo: IMTeamMeetingCallerInfo?
    //邀请的成员列表
    var invitedMembers: [IMMeetingMember] = []
    //接受的信息
    var calleeInfo: IMTeamMeetingCalleeInfo?

    //邀请成员的requestId列表
    var requestIdList: [String] = []
    var meetingSeconds: Int = 0
    var channelId: String?
    var channelInfo: NIMSignalingChannelDetailedInfo?
    var isResponse: Bool = false //是否有人已经接受邀请
    var timer: TimerHolder?
    var timerCallee: TimerHolder? //呼叫超时记录
    var startTime: TimeInterval? //开始时间
    var cameraType: NERtcCameraPosition = .front
    var notificaionSender: ChatCustomSysNotificationSender?
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(IMTeamMeetingCollectionViewCell.self, forCellWithReuseIdentifier: "IMTeamMeetingCollectionViewCell")
        collection.backgroundColor = .clear
        collection.isHidden = true
        return collection
    }()

    lazy var callingCollectionView: UICollectionView = {
        let layout = IMContactViewLayout()
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(IMTeamMeetingPreviewCell.self, forCellWithReuseIdentifier: "IMTeamMeetingPreviewCell")
        
        collection.backgroundColor = .clear
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()

    
    convenience init(info: IMTeamMeetingCallerInfo, session: NIMSession?) {
        self.init(nibName: nil, bundle: nil)
        self.callerInfo = info
        self.role = .TeamMeetingRoleCaller
        self.setupMembers(members: info.members, teamId: info.teamId)
    }
    
    convenience init(channelInfo: IMTeamMeetingCalleeInfo) {
        self.init(nibName: nil, bundle: nil)
        self.calleeInfo = channelInfo
        self.role = .TeamMeetingRoleCallee
        self.setupMembers(members: channelInfo.members, teamId: channelInfo.teamId)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        timer = TimerHolder()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        notificaionSender = ChatCustomSysNotificationSender()
        NIMSDK.shared().signalManager.add(self)
        self.initNERtc()
        self.initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    deinit {
        NIMSDK.shared().signalManager.remove(self)
        DispatchQueue.global().async {
            NERtcEngine.destroy()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        coreEngine.enableAudioVolumeIndication(true, interval: 100, vad: true)
        NIMSDK.shared().signalManager.add(self)
    
        NERtcEngine.shared().muteLocalAudio(false)
        NERtcEngine.shared().subscribeAllRemoteAudio(true)
        //以开启本地视频主流采集并发送
        NERtcEngine.shared().enableLocalVideo(true, streamType: .mainStream)
        
    }
    
    func initUI(){
        self.view.backgroundColor = UIColor(hexString: "0x1b1e20")
        self.view.addSubview(self.titleL)
        self.titleL.snp_makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(TSStatusBarHeight)
        }
        self.view.addSubview(self.inviteBtn)
        self.inviteBtn.snp_makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(TSStatusBarHeight)
        }
        self.inviteBtn.addTarget(self, action: #selector(inviteMemberAction), for: .touchUpInside)
        self.view.addSubview(self.cameraSwitchButton)
        self.cameraSwitchButton.addTarget(self, action: #selector(switchCamera), for: .touchUpInside)
        self.cameraSwitchButton.snp_makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalTo(TSStatusBarHeight)
        }
        
        self.view.addSubview(self.collectionView)
        self.collectionView.snp_makeConstraints { make in
            make.right.equalTo(-8)
            make.left.equalTo(8)
            make.height.equalTo(self.view.width - 16)
            make.top.equalTo(self.inviteBtn.snp_bottom).offset(8)
        }
        self.collectionView.layoutIfNeeded()
        
        
        self.view.addSubview(self.callingCollectionView)
        self.callingCollectionView.snp_makeConstraints { make in
            make.right.equalTo(-8)
            make.left.equalTo(8)
            make.height.equalTo(166)
            make.top.equalTo(self.inviteBtn.snp_bottom).offset(8)
        }
        
        self.view.addSubview(self.callingMembers)
        self.callingMembers.snp_makeConstraints { make in
            make.right.equalTo(-20)
            make.left.equalTo(20)
            make.top.equalTo(self.callingCollectionView.snp_bottom).offset(2)
        }
        self.view.addSubview(self.callingInfoLabel)
        self.callingInfoLabel.snp_makeConstraints { make in
            make.right.equalTo(-20)
            make.left.equalTo(20)
            make.top.equalTo(self.callingMembers.snp_bottom).offset(8)
        }
        
        self.view.addSubview(self.refuseBtn)
        self.refuseBtn.snp_makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        self.refuseBtn.addTarget(self, action: #selector(refuseCall), for: .touchUpInside)
        
        self.view.addSubview(self.acceptBtn)
        self.acceptBtn.snp_makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        self.acceptBtn.addTarget(self, action: #selector(acceptCall), for: .touchUpInside)
        self.view.addSubview(self.hangupButton)
        self.hangupButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.hangupButton.snp_makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-TSBottomSafeAreaHeight - 8)
        }
        
        self.view.addSubview(self.muteLabel)
        self.muteLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self.refuseBtn.snp_centerX)
            make.bottom.equalTo(self.refuseBtn.snp_top).offset(-12)
        }
        
        self.view.addSubview(self.cameraOffLabel)
        self.cameraOffLabel.snp_makeConstraints { make in
            make.centerX.equalTo(self.acceptBtn.snp_centerX)
            make.bottom.equalTo(self.refuseBtn.snp_top).offset(-12)
        }
        
        self.view.addSubview(self.muteButton)
        self.muteButton.snp_makeConstraints { make in
            make.width.height.equalTo(50)
            make.left.equalTo(59)
            make.bottom.equalTo(self.muteLabel.snp_top).offset(-4)
        }
        self.muteButton.addTarget(self, action: #selector(mute), for: .touchUpInside)
        
        self.view.addSubview(self.cameraDisableButton)
        self.cameraDisableButton.snp_makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalTo(-59)
            make.bottom.equalTo(self.cameraOffLabel.snp_top).offset(-4)
        }
        self.cameraDisableButton.addTarget(self, action: #selector(cameraDisable), for: .touchUpInside)
        self.view.addSubview(self.durationLabel)
        self.durationLabel.snp_makeConstraints { make in
            make.width.equalTo(200)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.cameraDisableButton.snp_top).offset(-8)
        }
        self.callingMembers.text = ""
        self.callingMembers.adjustsFontSizeToFitWidth = true
        var i: Int = 0
        for member in self.invitedMembers{
            if (member.userId.count > 0)
            {
                var nick = SessionUtil.showNick(member.userId, in: nil)
               
                if i == self.invitedMembers.count - 1 {
                    self.callingMembers.text = self.callingMembers.text?.appending(nick ?? "")
                }else {
                    nick =  nick?.appending(",")
                    self.callingMembers.text = self.callingMembers.text?.appending(nick ?? "")
                }
                i = i + 1
            }
        }
        
        self.callingCollectionView.reloadData()

        if self.role == .TeamMeetingRoleCaller {
            self.callingInfoLabel.text = "waiting_for_respond".localized
            self.showCallingButtons()
            self.reserveMeetting()

        }else {
            self.playRevicer()
            self.timerCallee = TimerHolder()
            self.timerCallee?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
            self.callingInfoLabel.text = "calling_in_video".localized
            self.showReceiverButtons()
  
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.present(alertController, animated: true) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
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
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.present(alertController, animated: true) {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
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
    //
    func reserveMeetting(){
        
        let name = self.getChannelName(caller: NIMSDK.shared().loginManager.currentAccount())
        //创建频道
        let request = NIMSignalingCreateChannelRequest()
        request.channelType = .video
        request.channelName = name
        
        NIMSDK.shared().signalManager.signalingCreateChannel(request) {[weak self] (error, info) in
            guard let self = self else {
                return
            }
            if let error = error {
                self.showError(message: error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                    self.dismiss()
                }
            }else {
                if let info = info {
                    self.channelId = info.channelId
                    //加入频道
                    let requestJoin = NIMSignalingJoinChannelRequest()
                    requestJoin.channelId = info.channelId
                    requestJoin.nertcChannelName = info.channelName
                    
                    NIMSDK.shared().signalManager.signalingJoinChannel(requestJoin) { error1, detailedInfo in
                        if let error1 = error1 {
                            self.showError(message: error1.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                                self.closeChannel()
                                self.dismiss()
                            }
                        }else {
                            if let detailedInfo = detailedInfo as? NIMSignalingChannelDetailedInfo {
                                self.channelInfo = detailedInfo
                                
                                self.joinChannel()
                                
                                //邀请成员
                                self.signaInvite(members: self.invitedMembers)
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    //关闭频道
    func closeChannel(){
        guard let channelId = self.channelInfo?.channelId else {
            return
        }
        let request = NIMSignalingCloseChannelRequest()
        request.channelId = channelId
        NIMSDK.shared().signalManager.signalingCloseChannel(request) { error in
            if let error = error {
                //self.showError(message: error.localizedDescription)
            }
           
            self.leavlChannel()
        }
        
    }
    //邀请成员
    func signaInvite(members: [IMMeetingMember], isFirst: Bool = true){
        guard let info = self.channelInfo else {
            return
        }
        self.requestIdList.removeAll()
        var userIds: [String] = []
        for member in members {
            userIds.append(member.userId)
        }
        if isFirst {
            self.timerCallee = TimerHolder()
            self.timerCallee?.startTimer(seconds: TimeInterval(NoBodyResponseTimeOut), delegate: self, repeats: false)
        }
        for member in members {
            if member.userId == NIMSDK.shared().loginManager.currentAccount() {
                requestIdList.append("")
                continue
            }
            let data: [String: Any] = ["teamId": self.callerInfo?.teamId, "members": userIds]
            let dict = ["type": NERtCallingType.team.rawValue, "data": data] as [String : Any]
            let customInfo = dict.toJSON
            let requestId = self.getChannelName(caller: NIMSDK.shared().loginManager.currentAccount(), callee: member.userId)
            let inviteRequest = NIMSignalingInviteRequest()
            inviteRequest.channelId = info.channelId
            inviteRequest.accountId = member.userId
            inviteRequest.requestId = requestId
            inviteRequest.customInfo = customInfo
            inviteRequest.offlineEnabled = true
            let push = NIMSignalingPushInfo()
            push.needPush = true
            push.needBadge = true
            push.pushTitle = NIMSDK.shared().loginManager.currentAccount()
            push.pushContent = String(format: "calling_you".localized, member.userId)
            inviteRequest.push = push
            
            NIMSDK.shared().signalManager.signalingInvite(inviteRequest) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                } else {
                    //guard let teamId = self.callerInfo?.teamId else {return}
                    //self.startCallStoreApi(yunxiId: info.channelId, from: NIMSDK.shared().loginManager.currentAccount(), to: teamId, startCall: Date().toFormat("yyyy-MM-dd'T'HH:mm:ss.ssssssZ"), groupType: CallGroupType.group.rawValue)
                }
            }
            requestIdList.append(requestId)
        }
        
        //发送提示消息
        let nick = SessionUtil.showNick(NIMSDK.shared().loginManager.currentAccount(), in: nil)
        let message = NIMMessage()
        let tipObject = NIMTipObject()
        message.messageObject = tipObject
        message.text = String(format: "opponent_request_video".localized, nick ?? "")
        let setting = NIMMessageSetting()
        setting.apnsEnabled = false
        setting.shouldBeCounted = false
        message.setting = setting
        if let teamId = team?.teamId {
            let session = NIMSession(teamId, type: .team)
            try? NIMSDK.shared().chatManager.send(message, to: session)
        }
        
    }
    
    func showCallingButtons(){
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangupButton.isHidden = false
        self.collectionView.isHidden = true
    }
    
    func showReceiverButtons() {
        acceptBtn.isHidden = false
        refuseBtn.isHidden = false
        hangupButton.isHidden = true
        self.callingCollectionView.isHidden = false
        self.collectionView.isHidden = true
    }
    //同意接通UI
    func showCalled(){
        self.collectionView.isHidden = false
        self.callingCollectionView.isHidden = true
        muteButton.isEnabled = true
        cameraDisableButton.isEnabled = true
        acceptBtn.isHidden = true
        refuseBtn.isHidden = true
        hangupButton.isHidden = false
        self.callingMembers.isHidden = true
        self.callingInfoLabel.isHidden = true
        inviteBtn.isHidden = false
        cameraSwitchButton.isHidden = false
    }
        
    
    //房间成员
    private func setupMembers(members: [String], teamId: String)
    {
        invitedMembers.removeAll()
        for uid in members {
            let member = IMMeetingMember()
            member.userId = uid
            if uid == NIMSDK.shared().loginManager.currentAccount() {
                if role == .TeamMeetingRoleCaller {
                    member.isJoined = true
                }else {
                    member.isJoined = false
                }
            }
            invitedMembers.append(member)
        }
        
        team = NIMSDK.shared().teamManager.team(byId: teamId)
        enableSpeaker = true
    }
    
    func findMemberWithIndexPath(indexPath: IndexPath) -> IMMeetingMember?
    {
        let index = indexPath.section * self.rowsInSection + indexPath.row
        if self.invitedMembers.count > index {
            return self.invitedMembers[index]
        }
        return nil
    }
    
    func findMemberWithUserId(_ userId: String) -> IMMeetingMember?
    {
        if let index = self.invitedMembers.firstIndex(where: {$0.userId == userId}){
            return self.invitedMembers[index]
        }
        return nil
    }
    func findIndexPathWithMember(member: IMMeetingMember) -> IndexPath?{
        if let index = self.invitedMembers.firstIndex(of: member) {
            return IndexPath(row: index, section: 0)
        }
        return nil
    }
    
    
    func checkCondition() -> Bool{
        if (!NetworkReachabilityManager()!.isReachable) {
            showError(message: "network_is_not_available".localized)
            return false
        }
        if self.invitedMembers.count > 9{
            showError(message: "text_whiteboard_exceed_limit_user".localized)
            return false
        }
        return true
    }
    //MARK: action
    //拒绝
    @objc func refuseCall(){
        self.player?.stop()
        self.timerCallee?.stopTimer()
        guard let calleeInfo = self.calleeInfo else {
            self.dismiss()
            return
        }
        
        let request = NIMSignalingRejectRequest()
        request.channelId = calleeInfo.channelId
        request.accountId = calleeInfo.caller
        request.requestId = calleeInfo.requestId
        NIMSDK.shared().signalManager.signalingReject(request) { error in
            if let error = error {
                self.dismiss()
            }else{
                //self.callLogPatcheApi(yunxiId: calleeInfo.channelId, action: CallActionType.reject, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                self.dismiss()
            }
        }
        
    }
    //接受
    @objc func acceptCall(){
        self.player?.stop()
        self.timerCallee?.stopTimer()
        self.joinMeeting()
        self.showCalled()

    }
    @objc func inviteMemberAction(){
        if self.checkCondition() {
            guard let teamID = team?.teamId else {
                return
            }
            
            NIMSDK.shared().teamManager.fetchTeamMembers(teamID) {[weak self] (error, teamMembers) in
                guard let self = self , let members = teamMembers else {
                    return
                }
                var memberIds = [String]()
                var currentUserID = NIMSDK.shared().loginManager.currentAccount()
                for member in members{
                    if let member1 = self.invitedMembers.first(where: {$0.userId == member.userId}) {
                        
                    }else{
                        memberIds.append(member.userId ?? "")
                    }
                    
                }
                
                let config = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: false, enableRecent: false, enableRobot: false, maximumSelectCount: 9 - self.invitedMembers.count, members: memberIds, enableButtons: false, allowSearchForOtherPeople: true)
                
                let contactsPickerVC = ContactsPickerViewController(configuration: config, finishClosure: { (contacts) in
                    guard let contacts = contacts as? [ContactData]  else {return}
                    var members = [IMMeetingMember]()
                    for contact in contacts {
                        let member = IMMeetingMember()
                        member.userId = contact.userName
                        member.state = .IMMeetingMemberStateConnecting
                       // self.invitedMembers.append(member)
                        members.append(member)
                    }
                    self.signaInvite(members: members, isFirst: false)

                })
                let nav = TSNavigationController(rootViewController: contactsPickerVC)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            
            
        }
    }
    @objc func switchCamera(){
        cameraType = cameraType == .front ? .back : .front
        NERtcEngine.shared().switchCamera(with: cameraType)
    }
    @objc func close(){
        if self.role == .TeamMeetingRoleCaller {
            if isResponse {
                timer?.stopTimer()
                timerCallee?.stopTimer()
                self.player?.stop()
                //离开频道
                guard let channelInfo = self.channelInfo else {
                    self.dismiss()
                    return
                }
                let request = NIMSignalingLeaveChannelRequest()
                request.channelId = channelInfo.channelId
                
                NIMSDK.shared().signalManager.signalingLeaveChannel(request) { error in
                    if let error = error {
                        self.showError(message: error.localizedDescription)
                    }
                    //self.callLogPatcheApi(yunxiId: channelInfo.channelId, action: CallActionType.end, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                    self.leavlChannel()
                    
                }
            }else{
                timer?.stopTimer()
                timerCallee?.stopTimer()
                self.player?.stop()
                var i = 0
                for member in invitedMembers {
                    if requestIdList.count > i {
                        let requestId = requestIdList[i]
                        i = i + 1
                        if member.userId == NIMSDK.shared().loginManager.currentAccount() {
                            continue
                        }
                        
                        let request = NIMSignalingCancelInviteRequest()
                        request.channelId = self.channelInfo?.channelId ?? ""
                        request.accountId = member.userId
                        request.requestId = requestId
                        NIMSDK.shared().signalManager.signalingCancelInvite(request) { error in
                            if let error = error {
                                //self.showError(message: error.localizedDescription)
                            }
                            //self.callLogPatcheApi(yunxiId: self.channelInfo?.channelId ?? "", action: CallActionType.missed, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                            if i == self.requestIdList.count  {
                                self.closeChannel()
                            }
                            
                        }
                        
                    }
                    
                }
                self.isResponse = true
                
            }
            
        }else{
            timer?.stopTimer()
            timerCallee?.stopTimer()
            self.player?.stop()
            //离开频道
            guard let calleeInfo = self.calleeInfo else {
                self.dismiss()
                return
            }
            let request = NIMSignalingLeaveChannelRequest()
            request.channelId = calleeInfo.channelId
            
            NIMSDK.shared().signalManager.signalingLeaveChannel(request) { error in
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }
                //self.callLogPatcheApi(yunxiId: calleeInfo.channelId, action: CallActionType.end, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                self.leavlChannel()
                
            }
        }
        
        
    }
    //关闭音频
    @objc func mute(){
        muteButton.isSelected = !muteButton.isSelected
        NERtcEngine.shared().muteLocalAudio(muteButton.isSelected)
    }
    //关闭相机
    @objc func cameraDisable(){
        cameraDisableButton.isSelected = !cameraDisableButton.isSelected
        NERtcEngine.shared().muteLocalVideo(!cameraDisableButton.isSelected, streamType: .mainStream)
        if let member = self.invitedMembers.first(where: {$0.userId == NIMSDK.shared().loginManager.currentAccount()}) {
            member.isOpenLocalVideo = cameraDisableButton.isSelected
            if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                cell.setLocalVideo(enable: cameraDisableButton.isSelected, model: member)
                cell.canvasViewMueted(enable: !cameraDisableButton.isSelected, model: member)
            }
        }
        
    }
    
    func dismiss(){
        
        if let topController = TSViewController.topMostController {
            if topController.isKind(of: ContactsPickerViewController.self) {
                self.dismiss(animated: true) {
                    self.dismiss(animated: true)
                }
            }else{
                self.dismiss(animated: true)
            }
        }else{
            self.dismiss(animated: true)
        }
        
        
    }
    
    func joinMeeting(){
        guard let channleInfo = self.calleeInfo  else {
            return
        }
        
        let request = NIMSignalingJoinAndAcceptRequest()
        request.channelId = channleInfo.channelId
        request.accountId = channleInfo.caller
        request.requestId = channleInfo.requestId
        NIMSDK.shared().signalManager.signalingJoinAndAccept(request) {[weak self] error, info in
            guard let self = self else {
                return
            }
            if let error = error {
                self.showError(message: error.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5){
                    self.dismiss()
                }
            }else{
                if let info = info as? NIMSignalingChannelDetailedInfo {
                    self.channelInfo = info
                    self.joinChannel()
                    //self.callLogPatcheApi(yunxiId: channleInfo.channelId, action: CallActionType.accept, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                }

            }
        }
        
    }
    
    //音视频2.0
    func joinChannel(){
        let member = self.channelInfo?.members.first(where: {$0.accountId == NIMSDK.shared().loginManager.currentAccount()})
        if let uid = member?.uid {
            let result = NERtcEngine.shared().joinChannel(withToken: self.channelInfo?.nertcToken ?? "", channelName: self.channelInfo?.channelName ?? "", myUid: uid) {[weak self] error, a, b, c in
                guard let self = self else {
                    return
                }
                if let error = error {
                    self.showError(message: error.localizedDescription ?? "")
                    self.closeChannel()
                    self.dismiss()
                }else{

                    if let info = self.channelInfo{
                        //默认禁止视频
                        NERtcEngine.shared().muteLocalVideo(true, streamType: .mainStream)
                        
                        for member in info.members {
                            if let model = self.invitedMembers.first(where: {$0.userId == member.accountId}) {
                                model.uid = member.uid
                                model.isJoined = true
                            }else{
                                let model = IMMeetingMember()
                                model.userId = member.accountId
                                model.uid = member.uid
                                model.isJoined = true
                                self.invitedMembers.append(model)
                            }
                        }
                    }
                    if self.role == .TeamMeetingRoleCallee { //接受者
                        DispatchQueue.main.async{
                            self.startTimer()
                            self.showCalled()
                            self.isResponse = true
                            self.collectionView.reloadData()
                        }

                    }else {

                        self.playConnectRing()
                    }

                }
            }
        }
        
        
    }
    func leavlChannel(){
        NERtcEngine.shared().leaveChannel()
        self.dismiss()
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
    
    func playRevicer () {
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
    
    func getChannelName(caller: String, callee: String = "")-> String{
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        let name = (caller + callee + String(timeStamp))
        return name.md5
    }
    
    
    func durationDesc() -> String? {
        return String(format: "%02d:%02d", meetingSeconds / 60, meetingSeconds % 60)
    }
    
    func startTimer()
    {
        meetingSeconds = 0
        timer = TimerHolder()
        timer?.startTimer(seconds: 1, delegate: self, repeats: true)
       
    }
    
    func checkForTimeoutCallee(){
        var connectedCount: Int = 0
        var indexPaths: [IndexPath] = []
        var members = [IMMeetingMember]()
        for member in invitedMembers {
            if member.isJoined { //还没有进入房间
                connectedCount = connectedCount + 1
            } else {
                members.append(member)
                if let indexPath = self.findIndexPathWithMember(member: member) {
                    indexPaths.append(indexPath)
                }
            }
        }
        
        for member in members {
            if let index = self.invitedMembers.firstIndex(where: {$0.userId == member.userId}) {
                self.invitedMembers.remove(at: index)
            }
        }
        
        //如果有人接受状态
        if isResponse {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
                self.collectionView.reloadData()
            }
            
        }
        
        if  connectedCount <= 1 {
            self.timer?.stopTimer()
            self.player?.stop()
            if self.role == .TeamMeetingRoleCaller {
                self.presentingViewController?.view.makeToast("no_answer_call".localized, duration: 2, position: CSToastPositionCenter)
                //self.callLogPatcheApi(yunxiId: self.channelInfo?.channelId ?? "", action: CallActionType.missed, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                self.closeChannel()
            }else {
                if isResponse {
                    //self.callLogPatcheApi(yunxiId: self.channelInfo?.channelId ?? "", action: CallActionType.missed, actionTime: Date().toFormat("YYYY-MM-dd HH:mm:ss"), groupType: CallGroupType.group)
                    self.closeChannel()
                }
            }
            
            
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
extension IMTeamMeetingViewController: TimerHolderDelegate {
    @objc func onTimerFired(holder: TimerHolder) {
        if holder == self.timer {
            meetingSeconds = meetingSeconds + 1
            if meetingSeconds == Int(NoBodyResponseTimeOut) {
                self.checkForTimeoutCallee()
            }
            self.durationLabel.text = self.durationDesc()
        }else if holder == self.timerCallee {
            
            self.timerCallee?.stopTimer()
            self.player?.stop()
            if self.role == .TeamMeetingRoleCaller {
                self.checkForTimeoutCallee()
            }else {
                self.presentingViewController?.view.makeToast("timeout_answer".localized, duration: 2, position: CSToastPositionCenter)
                self.dismiss()
            }
            
            
        }
        
    }
}

extension IMTeamMeetingViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.callingCollectionView {
            return CGSize(width: 90, height: 90)
        }
        
        var width: CGFloat  = collectionView.width / 3
        var height: CGFloat = width
        return CGSize(width: width - 4, height: height - 4)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == self.callingCollectionView {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
        return  UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
}

extension IMTeamMeetingViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return self.rowsInSection
        }else{
            if self.invitedMembers.count > 4 {
                return 4
            }
            return self.invitedMembers.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.callingCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IMTeamMeetingPreviewCell", for: indexPath) as! IMTeamMeetingPreviewCell
            cell.team = self.team
            
            let member = self.findMemberWithIndexPath(indexPath: indexPath)
             
            if let member = member {
                cell.loadCallingUser(user: member.userId, number: invitedMembers.count, index: indexPath.row)
            }
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IMTeamMeetingCollectionViewCell", for: indexPath) as! IMTeamMeetingCollectionViewCell
            cell.team = self.team
            if let member = self.findMemberWithIndexPath(indexPath: indexPath) {
                
                if member.isJoined {
                    cell.refreshWithModel(model: member)
                }else {
                    cell.refrehWithConnecting(user: member.userId)
                }
            }else {
                cell.refreshWithEmpty()
            }
            
            return cell
        }
        
    }
    
    
    
}


extension IMTeamMeetingViewController: NIMSignalManagerDelegate{

    func nimSignalingOnlineNotify(_ eventType: NIMSignalingEventType, response notifyResponse: NIMSignalingNotifyInfo) {
        DispatchQueue.main.async{
            
            switch eventType {
            case .cancelInvite:
                if let info = notifyResponse as? NIMSignalingCancelInviteNotifyInfo {
                    if self.channelInfo?.channelId == nil { //没有加入任何频道
                        self.timer?.stopTimer()
                        self.player?.stop()
                        self.dismiss()
                    }
                }
                
            case .close:
                self.timer?.stopTimer()
                self.player?.stop()
                self.leavlChannel()
                
            case .reject:
                if let info = notifyResponse as? NIMSignalingRejectNotifyInfo {
                    if let member = self.invitedMembers.first(where: {$0.userId == info.fromAccountId}){
                        
                        if self.isResponse { //如果有人接受邀请了
                            if let indexPath = self.findIndexPathWithMember(member: member){
                                self.invitedMembers.removeAll(where: {$0.userId == info.fromAccountId})
                                self.collectionView.reloadData()
                                
                            }else {
                                self.invitedMembers.removeAll(where: {$0.userId == info.fromAccountId})
                            }
                        }else {
                            self.invitedMembers.removeAll(where: {$0.userId == info.fromAccountId})
                        }
                        
                        if self.invitedMembers.count <= 1 {
                            self.timer?.stopTimer()
                            self.timerCallee?.stopTimer()
                            self.player?.stop()
                            if let data = notifyResponse.customInfo.data(using: .utf8), let customInfo = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                if let type = customInfo["type"] as? String {
                                    let msg = type == "isCallBusy" ? "avchat_peer_busy".localized : "chatroom_rejected".localized
                                    self.presentingViewController?.view.makeToast(msg, duration: 2, position: CSToastPositionCenter)
                                }
                            }
                            self.closeChannel()
                            
                        }
                        
                        
                    }
                    
                    
                
                }

                break
            case .leave:
                
                if let info = notifyResponse as? NIMSignalingLeaveNotifyInfo {

                    if let member = self.invitedMembers.first(where: {$0.userId == info.fromAccountId}), let indexPath = self.findIndexPathWithMember(member: member){
                        self.invitedMembers.removeAll(where: {$0.userId == info.fromAccountId})
                        self.collectionView.reloadData()

                    }
                }
                //如果房间内只有一个人，主动关闭房间
                if self.invitedMembers.count <= 1 {
                    self.timer?.stopTimer()
                    self.player?.stop()
                    self.closeChannel()

                }
                break
            case .join:
                if let info = notifyResponse as? NIMSignalingJoinNotifyInfo {

                    if let member = self.invitedMembers.first(where: {$0.userId == info.member.accountId}) {
                        //已在房间
                        member.uid = info.member.uid
                        member.isJoined = true

                        if let indexPath = self.findIndexPathWithMember(member: member) {
                            self.collectionView.performBatchUpdates {
                                self.collectionView.reloadItems(at: [indexPath])
                            }
                        }

                    }else{

                        let model = IMMeetingMember()
                        model.userId = info.member.accountId
                        model.uid = info.member.uid
                        model.isJoined = true
                        self.invitedMembers.append(model)
                        let indexPath = IndexPath(row: self.invitedMembers.count - 1, section: 0)
                        self.collectionView.performBatchUpdates {
                            self.collectionView.reloadItems(at: [indexPath])
                        }

                    }

                }
                break
            case .accept:
                if !self.isResponse {
                    self.timerCallee?.stopTimer()
                    self.startTimer()
                    self.player?.stop()
                    self.isResponse = true
                    self.showCalled()
                    self.collectionView.reloadData()
                    
                }

                
            default:
                break
            }
            
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
           self.timerCallee?.stopTimer()
           self.dismiss()
           break
       case .accept:
           //其他端接受了邀请
           self.player?.stop()
           self.timerCallee?.stopTimer()
           self.dismiss()
           break
       default:
           break
       }
   }


}


extension IMTeamMeetingViewController: NERtcEngineDelegateEx{
    
    func onNERtcEngineConnectionStateChange(with state: NERtcConnectionStateType, reason: NERtcReasonConnectionChangedType) {
        
    }
    
    func onNERtcEngineUserDidJoin(withUserID userID: UInt64, userName: String) {
        if let member = self.invitedMembers.first(where: {$0.uid == userID}) {
            if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                cell.setRemoteView(enable: true, model: member)
                
            }
        }
       
    }
    
    func onNERtcEngineUserSubStreamAudioDidStart(_ userID: UInt64) {
        
    }
    
    func onNERtcEngineUserVideoDidStart(withUserID userID: UInt64, videoProfile profile: NERtcVideoProfileType) {
        if let member = self.invitedMembers.first(where: {$0.uid == userID}) {
            member.isOpenLocalVideo = true
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
                if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                    cell.setRemoteView(enable: true, model: member)
                    cell.subscribeRemoteVideo(userID: member.uid)
                    cell.canvasViewMueted(enable: !member.isOpenLocalVideo, model: member)

                }
            }
            
            
        }
        
        
    }
    
    func onNERtcEngineUserVideoDidStop(_ userID: UInt64) {

    }
    
   
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool, streamType: NERtcStreamChannelType) {
    
        if let member = self.invitedMembers.first(where: {$0.uid == userID}) {
            member.isOpenLocalVideo = !muted
            if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                if muted {
                    cell.canvasViewMueted(enable: true, model: member)
                }else {
                    cell.setRemoteView(enable: true, model: member)
                    cell.subscribeRemoteVideo(userID: member.uid)
                    cell.canvasViewMueted(enable: false, model: member)
                }
                
            }
        }
    }
    
    func onNERtcEngineUser(_ userID: UInt64, videoMuted muted: Bool) {
        
    }
    //本地异常离开
    func onNERtcEngineDidDisconnect(withReason reason: NERtcError) {
        print("reason = \(reason)")
        self.timer?.stopTimer()
        self.player?.stop()
        self.dismiss()
        
        
    }
    //本端离开
    func onNERtcEngineDidLeaveChannel(withResult result: NERtcError) {
        
    }
    //远端离开
    func onNERtcEngineUserDidLeave(withUserID userID: UInt64, reason: NERtcSessionLeaveReason) {
        
        if reason != .neRtcSessionLeaveNormal {
            if let member = self.invitedMembers.first(where: {$0.uid == userID}), let indexPath = self.findIndexPathWithMember(member: member){
                self.invitedMembers.removeAll(where: {$0.uid == userID})
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadItems(at: [indexPath])
                }
            }
            //如果房间内只有一个人，主动关闭房间
            if self.invitedMembers.count <= 1 {
                self.timer?.stopTimer()
                self.player?.stop()
                self.closeChannel()
                
            }
        }
     
    }
    
    func onNERtcEngineRejoinChannel(_ result: NERtcError) {
        
    }
    //音量
    func onLocalAudioVolumeIndication(_ volume: Int32, withVad enableVad: Bool) {
        if let member = self.invitedMembers.first(where: {$0.userId == NIMSDK.shared().loginManager.currentAccount()}) {
            member.volume = volume
            if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                
                cell.refreshWidthVolume(volume: member.volume)
                
            }
        }
        
    }
    //远端音量
    func onRemoteAudioVolumeIndication(_ speakers: [NERtcAudioVolumeInfo]?, totalVolume: Int32) {
        if let speakers = speakers {
            for speaker in speakers {
                if let member = self.invitedMembers.first(where: {$0.uid == speaker.uid}) {
                    member.volume = Int32(speaker.volume)
                    if let indexPath = self.findIndexPathWithMember(member: member), let cell = self.collectionView.cellForItem(at: indexPath) as? IMTeamMeetingCollectionViewCell{
                        cell.refreshWidthVolume(volume: member.volume)
                        
                    }
                }
            }
           
        }
    }
    
    
    
}

