//
//  MeetingSettingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/7.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

import NEMeetingKit
import SVProgressHUD
import Toast
//import NIMPrivate
import NIMSDK

enum MeetingCreateType: Int {
    /*会议类型。
     1：使用随机号创建的即时会议。
     2：使用个人号创建的即时会议。
     3：使用随机号预约的会议。*/
    case random      = 1
    case personal    = 2
    case orderRandom = 3
}

class MeetingSettingViewController: UIViewController {
    
    
    var dataSource: [ContactData]
    lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("done".localized, for: .normal)
        btn.setTitleColor(AppTheme.red, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        return btn
    }()
    
    lazy var numL: UILabel = {
        let lab = UILabel()
        lab.textColor = UIColor(hex: "#212121")
        lab.font = UIFont.systemMediumFont(ofSize: 17)
        lab.textAlignment = .left
        lab.text = "Invited (15)".localized
        return lab
    }()
    
    var backStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .leading
    }
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 16
        $0.distribution = .fill
        $0.alignment = .leading
    }
    var meetingId: Int?
    var meetingNum: String?
    
    var passwordT: UITextField?
    var microphone: UISwitch!
    var camera: UISwitch!
    var priviteInvite: UISwitch!

    var meetingNameT: UITextField!
    
    //会议等级 0 免费 1 付过年费
    var meetingLevel: Int = 0
    //剩余会议时长
    var duration: Int = 0
    //会议人数限制
    var meetingNumlimit: Int = 50
    //开始时间
    var startTime: Int = 0
    //会议总时长
    var meetingTimeLimit: Int = 0
    
    var timer: TimerHolder?
    
    var roomUuid: Int = 0
    //记录 toast 是否弹出
    var leftNumber = false
    var maxNumber = false
    
    lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(MeetingSettingCell.self, forCellReuseIdentifier: "MeetingSettingCell")
        table.separatorStyle = .none
        table.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 73
        table.tableFooterView = UIView()
        table.tableHeaderView = UIView()
        return table
    }()
    var timeView: UIView?
    var timeLabel:  UILabel?
    //会议信息
    var meetingInfo: CreateMeetingInfo?
    var noAudio: Bool = false
    var noVideo: Bool = false
    
    init(data: [ContactData]) {
        self.dataSource = data
        super.init(nibName: nil, bundle: nil)
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let nav = self.navigationController as? TSNavigationController {
            nav.setCloseButton(backImage: true, titleStr: "dashboard_settings".localized)
        }
    
        if let service = NEMeetingKit.getInstance().getMeetingService() {
            service.add(self)
        }else{
            NIMSDKManager.shared.meetingKitConfig {
                NEMeetingKit.getInstance().getMeetingService()?.add(self)
            }
            
        }
        
        setUI()
        
    }
    
    deinit {
        self.timer?.stopTimer()
        self.timeView?.removeFromSuperview()
        NEMeetingKit.getInstance().getMeetingService()?.remove(self)
        
    }

    func setUI(){
        let num = dataSource.count
        numL.text = String(format: "invited_ios".localized, "(\(num))")
        
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextBtn)
        view.addSubview(backStackView)
        backStackView.bindToEdges()
        
        backStackView.addArrangedSubview(stackView)
        backStackView.addArrangedSubview(numL)
        backStackView.addArrangedSubview(tableView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
        }
        numL.snp.makeConstraints { make in
            make.left.equalTo(16)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        let nameView = self.createMeetingNameView()
        stackView.addArrangedSubview(nameView)
        nameView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        
        let view1 = createSettingView(title: "password".localized, tagT: 101, isTextField: true, tag: 0)
        let view2 = createSettingView(title: "microphone".localized, tagT: 0, isTextField: false, tag: 102)

        let view3 = createSettingView(title: "camera".localized, tagT: 0, isTextField: false, tag: 103)
        if let textF = view1.viewWithTag(101) as? UITextField {
            passwordT = textF
            //passwordT?.keyboardType = .numberPad
        }
        passwordT?.placeholder = "Not Set".localized
        if let switchview = view2.viewWithTag(102) as? UISwitch {
            microphone = switchview
            microphone.isOn = true
            noAudio = false
            microphone.addTarget(self, action: #selector(clickOnMicrophone(_:)), for: .valueChanged)
        }
        if let switchview = view3.viewWithTag(103) as? UISwitch {
            camera = switchview
            camera.isOn = false
            noVideo = true
            camera.addTarget(self, action: #selector(clickOnCamera(_:)), for: .valueChanged)
        }
        
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        stackView.addArrangedSubview(view3)
        
        let view4 = createSettingView(title: "meeting_private_invite".localized, tagT: 0, isOn: true, isTextField: false, tag: 104, content: "meeting_invite_invite_tip".localized)
        stackView.insertArrangedSubview(view4, at: 3)
        view4.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        if let switchview = view4.viewWithTag(104) as? UISwitch {
            priviteInvite = switchview
            priviteInvite.addTarget(self, action: #selector(clickOnInvite(_:)), for: .valueChanged)
        }
        view4.isHidden = self.meetingLevel != 1
        priviteInvite.isOn = self.meetingLevel == 1

        view1.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        view2.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(68)
        }
        view3.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(4)
            make.height.equalTo(68)
        }
        
        if self.meetingNameT.text?.count == 0 {
            self.nextBtn.isEnabled = false
            self.nextBtn.setTitleColor(.lightGray, for: .normal)
        }else{
            self.nextBtn.isEnabled = true
            self.nextBtn.setTitleColor(AppTheme.red, for: .normal)
        }
        
    }
    
    func createMeetingNameView() -> UIView {
        let bview = UIView()
        bview.backgroundColor = UIColor(hexString: "#F7F8FA")
        bview.layer.cornerRadius = 10
        bview.clipsToBounds = true
        
        meetingNameT = UITextField()
        meetingNameT.placeholder = "meeting_subject".localized
        meetingNameT.textColor = UIColor(hexString: "#808080")
        meetingNameT.font = UIFont.systemFont(ofSize: 14)
        bview.addSubview(meetingNameT)
        meetingNameT.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalTo(-20)
            make.height.equalTo(24)
        }
        meetingNameT.add(event: .editingChanged) { [weak self] in
            guard let self = self else{return}
            if self.meetingNameT.text?.count == 0 {
                self.nextBtn.isEnabled = false
                self.nextBtn.setTitleColor(.lightGray, for: .normal)
            }else{
                self.nextBtn.isEnabled = true
                self.nextBtn.setTitleColor(AppTheme.red, for: .normal)
            }
        }
        return bview
    }
    //meetingkit 登录
    func meetingkitLogin(username: String, password: String){
        NEMeetingKit.getInstance().login(username, token: password) { code, msg, result in
            if code == 0 {
                print("NEMeetingKit登录成功")
                self.createMeeting()
            }else {
                self.showError(message: msg ?? "")
            }
        }
    }
    
    func quertMeetingKitAccountInfo(){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        self.meetingkitLogin(username: userUuid ?? "", password: token ?? "")

    }
    
    @objc func nextAction(){
        self.view.endEditing(true)
        
        if meetingNameT.text?.count == 0 {
            
            return
        }
        
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                self.quertMeetingKitAccountInfo()
            }
        })
        
        
    }
    //创建会议
    func createMeeting(){
        let user = NIMSDK.shared().loginManager.currentAccount()
        var userDict: [String: String] = ["\(user)": "host"]
        var members: [String] = []
        var groupIds: [String] = []
        for source in dataSource {
            if !source.isTeam {
                userDict["\(source.userName)"] = "member"
                members.append(source.userName)
            }else{
                groupIds.append(source.userName)
            }
        }
        members.append(user)
        //遍历邀请的群成员
        for username in groupIds {
            SessionUtil().fetchMembersTeam(teamId: username) { users in
                members.append(contentsOf: users)
            }
        }
        //去重
        let members1 = Array(Set(members))
        
        let password = passwordT?.text ?? ""

        let dict: [String : Any]?  = ["type": MeetingCreateType.random.rawValue, "subject": meetingNameT.text ?? "", "password": password, "nickName": user, "roleBinds": userDict,
                                      "isPrivate": priviteInvite.isOn ? 1 : 0,
                                      "privateOption": ["members": members1, "groupIds": groupIds],
                                      "roomConfig": ["resource": [
                                        "whiteboard": true,
                                        "chatroom": true,
                                        "rtc": true,
                                        "live": false,
                                        "record": false,
                                        "sip": false
                                      ]],
                                      "roomProperties": [
                                        //"audioOff": ["value": "none"],
                                        //"videoOff": ["value": "none"]
                                      ]]
        SVProgressHUD.show(withStatus: "loading".localized)
        print("dict =\(dict)")
        CreateMeetingRequest.init(params: dict).execute { response in
            DispatchQueue.main.async {
                if let data = response {
                    self.meetingId = data.data.meetingId
                    self.meetingNum = data.data.meetingNum
                    self.meetingInfo = data.data
                    self.joinMeetingApi(meetingNum: self.meetingNum ?? "", data: data.data)
                }else{
                    SVProgressHUD.dismiss()
                }
                
            }
            
        } onError: { error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    ///加入会议 - sdk
    func joinInMeeting(data: CreateMeetingInfo, isPrivate: Bool = false){
        guard let meetingID = self.meetingNum else {
            SVProgressHUD.dismiss()
            return
        }
        let params = NEJoinMeetingParams() //会议参数
        params.meetingNum = meetingID
        params.displayName = NIMSDK.shared().loginManager.currentAccount()
        params.password = passwordT?.text ?? ""
        //会议选项，可自定义会中的 UI 显示、菜单、行为等
        let options = NEJoinMeetingOptions()
        options.noVideo = noVideo //入会时关闭视频，默认为 YES
        options.noAudio = noAudio //入会时关闭音频，默认为 YES
        options.noInvite = false                    //入会隐藏"邀请"按钮，默认为 NO
        options.noChat = false                      //入会隐藏"聊天"按钮，默认为 NO
        options.noWhiteBoard = false                               //入会隐藏白板入口，默认为 NO
        options.noGallery = false                                //入会隐藏设置"画廊模式"入口，默认为 NO
        options.noSwitchCamera = false                             //入会隐藏"切换摄像头"功能入口，默认为 NO
        options.noSwitchAudioMode = false                           //入会隐藏"切换音频模式"功能入口，默认为 NO
        options.noRename = false                                   //入会隐藏"改名"功能入口，默认为 NO
        options.showMeetingTime = false                            //设置入会后是否显示会议持续时间，默认为 NO
        
        options.noMinimize = true                                 //入会是否允许最小化会议页面，默认为 YES
        options.defaultWindowMode = NEMeetingWindowMode.gallery         //入会默认会议视图模式
        options.meetingIdDisplayOption = .DISPLAY_ALL  //设置会议中会议 ID 的显示规则，默认为全部显示
        options.noSip = false                                        //会议是否支持 SIP 用户入会，默认为 NO
        options.showMeetingRemainingTip = true                     //会议中是否开启剩余时间（秒）提醒，默认为 NO
        
        let chatroomConfig = NEMeetingChatroomConfig() //配置聊天室
        chatroomConfig.enableFileMessage = true //是否允许发送/接收文件消息，默认为 YES
        chatroomConfig.enableImageMessage = true //是否允许发送/接收图片消息，默认为 YES
        options.chatroomConfig = chatroomConfig
        //在MoreMenus里面添加自定义菜单
        if isPrivate {
            SessionUtil().configMoreMenus(options: options)
        }
 
        let meetingServce = NEMeetingKit.getInstance().getMeetingService()
        meetingServce?.joinMeeting(params, opts: options, callback: {[weak self] resultCode, resultMsg, result in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                guard let self = self else {
                    return
                }
                if resultCode == 0 {
                    print("会议加入成功")
                    self.leftNumber = false
                    self.maxNumber = false
                    if self.meetingLevel == 0 {
                        self.startTimerHolder()
                        
                    }
                    self.sendMessage(model: data)
                    guard let roomContext = NERoomKit.shared().roomService.getRoomContext(roomUuid: self.roomUuid.stringValue) else {
                          return
                    }
                    // 添加房间监听
                    roomContext.addRoomListener(listener: self)
                    
                }else {
                    self.showError(message: resultMsg ?? "")
                }
            }
        })
    }
    

    func createSettingView(title: String, tagT: Int, isOn: Bool = false, isTextField: Bool = false, tag: Int, content: String = "") -> UIView{

        let bview = UIView()
        bview.backgroundColor = UIColor(hexString: "#F7F8FA")
        bview.layer.cornerRadius = 10
        bview.clipsToBounds = true

        let stackview = UIStackView()
        stackview.spacing = 0
        stackview.axis = .vertical
        stackview.distribution = .fill
        bview.addSubview(stackview)
        stackview.snp.makeConstraints { make in
            make.left.equalTo(13)
            make.centerY.equalToSuperview()
        }

        let nameLabel = UILabel()
        nameLabel.textColor = .black
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        nameLabel.textAlignment = NSTextAlignment.left
        nameLabel.text = title

       // bview.addSubview(nameLabel)
        stackview.addArrangedSubview(nameLabel)
        
        if tag == 104 {
            let contentL = UILabel()
            contentL.textColor = .black
            contentL.font = UIFont.systemRegularFont(ofSize: 10)
            contentL.textAlignment = NSTextAlignment.left
            contentL.text = content
            stackview.addArrangedSubview(contentL)
            contentL.snp.makeConstraints { make in
                make.height.equalTo(15)
            }
        }

        let textField = UITextField()
        textField.textColor = UIColor(hexString: "#808080")
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textAlignment = .right
        textField.tag = tagT
        bview.addSubview(textField)
        textField.isHidden = !isTextField
        textField.isSecureTextEntry = true
        textField.keyboardType = .numberPad
        let switchB = UISwitch()
        switchB.tag = tag
        switchB.isOn = isOn
        switchB.tintColor = UIColor(hexString: "#C7C7C7")
        switchB.onTintColor = UIColor(hexString: "#69EC9D")
        if isOn {
            switchB.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            switchB.thumbTintColor = UIColor(hexString: "#808080")
        }
        
        bview.addSubview(switchB)
        switchB.isHidden = isTextField
        nameLabel.snp.makeConstraints { make in
            //make.left.equalTo(13)
            //make.centerY.equalToSuperview()
            make.height.equalTo(21)

        }
        
        textField.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
        }
        switchB.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
            make.width.equalTo(50)
            make.height.equalTo(25)
        }
        
        return bview
    }
    
    //发送IM信息
    func sendMessage(model: CreateMeetingInfo){
        
        for source in dataSource {
            let attachment = IMMeetingRoomAttachment()
            attachment.meetingId = "\(model.meetingId)"
            attachment.meetingNum = model.meetingNum
            attachment.meetingShortNum = model.meetingShortNum
            attachment.meetingPassword = model.settings?.roomInfo?.password ?? ""
            attachment.meetingStatus = "\(model.status)"
            attachment.meetingSubject = model.subject
            attachment.meetingType = model.type
            attachment.roomArchiveId = model.roomArchiveId
            attachment.roomUuid = model.roomUuid

            let message = NIMMessage()
            let customObject = NIMCustomObject()
            customObject.attachment = attachment
            message.messageObject = customObject
            message.apnsContent = "recent_msg_desc_meeting".localized
            var session: NIMSession!
            if !source.isTeam {
                session = NIMSession.init(source.userName, type: .P2P)
            }else{
                session = NIMSession.init(source.userName, type: .team)
            
            }
            do {
                try NIMSDK.shared().chatManager.send(message, to: session)
            } catch {
                
            }
                
            
        }
       
        
    }

    @objc func clickOnMicrophone(_ sender: UISwitch){
        if sender.isOn {
            noAudio = false
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            noAudio = true
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
        
    }
    @objc func clickOnCamera(_ sender: UISwitch){
        if sender.isOn {
            noVideo = false
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            noVideo = true
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
    }

    @objc func clickOnInvite(_ sender: UISwitch){
        if sender.isOn {
            sender.thumbTintColor = UIColor(hexString: "#0F7D56")
        }else{
            sender.thumbTintColor = UIColor(hexString: "#808080")
        }
    }

    
    //后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String, data: CreateMeetingInfo){
       
        JoinMeetingRequest.init(params: ["meetingNum" : meetingNum]).execute {model in
            self.roomUuid = model?.data.roomUuid ?? 0
            self.startTime = (model?.data.meetingInfo?.startTime ?? "").toInt()
            self.meetingTimeLimit = model?.data.meetingTimeLimit ?? 0
            DispatchQueue.main.async {
                let isPrivate: Bool = (model?.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                self.joinInMeeting(data: data, isPrivate: isPrivate)
            }
        } onError: {[weak self]  error in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
            }
            switch error {
                case .error(let msg, code: let errorCode):
                switch errorCode {
                case .meetingEndOrInexistence:
                    self?.showError(message: "meeting_ended".localized)
                case .meetingNumberLimit:
                    self?.showError(message: "meeeting_max_user_limit_reached".localized)
                default:
                self?.showError(message: error.localizedDescription)
                break
                }
                case .carriesMessage(let msg,let code, _):
                self?.showError(message: msg.localized)
                
                default:
                self?.showError(message: error.localizedDescription)
                break
            }
        
            
        }

    }
    
    //获取当前会议信息
    func getCurrentMeetingInfo(){
        
        NEMeetingKit.getInstance().getMeetingService()?.getCurrentMeetingInfo({ code, msg, info in
            print("info===\(info)")
            DispatchQueue.main.async {
                //self.meetingNumlimit - 5
                if info.userList.count == self.meetingNumlimit - 5 {
                    if self.leftNumber == false{
                        self.showMemberNum()
                    }
                    self.leftNumber = true
                }else if info.userList.count == self.meetingNumlimit{
                    if self.maxNumber == false{
                        self.showMemberNum(isLeft: false)
                    }
                    self.maxNumber = true
                }
            }
            
        })
    }
    
    func showMemberNum(isLeft: Bool = true){
        guard let vc = UIViewController.topMostController  else {
            return
        }
        if isLeft {
            
            vc.view.makeToast(String(format: "meeting_left_participants_ios".localized, "5"), duration: 3, position: CSToastPositionBottom)
        }else{
            vc.view.makeToast(String(format: "meeting_maximum_members_reached_ios".localized, "\(self.meetingNumlimit)"), duration: 3, position: CSToastPositionBottom)
        }
        
        
        
    }
    
    func startTimerHolder(){
        if self.timer != nil {
            self.timeView?.removeFromSuperview()
            self.timer?.stopTimer()
        }
        let now = Date().timeIntervalSince1970
       
        let dt = Int(now) - self.startTime / 1000
        
        self.duration = self.meetingTimeLimit * 60 - dt
        self.timer = TimerHolder()
        self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
        self.showTimeView()
    }
    
    
    func showTimeView(){
        guard let vc = UIViewController.topMostController  else {
            return
        }
        let nimute = self.duration / 60
        let s = self.duration % 60
        
        timeView = UIView()
        timeView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.13, alpha: 1)
        timeView?.layer.cornerRadius = 10
        timeView?.clipsToBounds = true
        vc.view.addSubview(timeView!)
        timeView?.isHidden = true
        timeLabel = UILabel()
        let nim = String(format: "%02d", nimute)
        let ss = String(format: "%02d", s)
        
        let timeStr = "\(nim):\(ss)"
        timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
        timeLabel?.textColor = .white
        timeLabel?.font = UIFont.systemFont(ofSize: 15)
        timeLabel?.textAlignment = .center
        timeView?.addSubview(timeLabel!)
        timeView?.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(26 + TSNavigationBarHeight)
            
        }
        timeLabel?.snp.makeConstraints { make in
            make.left.top.equalTo(3)
            make.right.bottom.equalTo(-3)
            make.height.equalTo(24)
        }
        
    }
}

extension MeetingSettingViewController: TimerHolderDelegate {
    func onTimerFired(holder: TimerHolder) {
        if self.duration > 0 {
            self.duration = self.duration - 1
            let nimute = self.duration / 60
            let s = self.duration % 60
            let nim = String(format: "%02d", nimute)
            let ss = String(format: "%02d", s)
            let timeStr = "\(nim):\(ss)"
            timeLabel?.text = String(format: "meeting_end_in_ios".localized, timeStr)
            if self.duration <= 5 * 60 {
                self.timeView?.isHidden = false
            }
            
           

        }else {
            self.timer?.stopTimer()
         
            let window = UIApplication.shared.keyWindow
            
            let bgView = MeetingEndView()
            bgView.backgroundColor = .black.withAlphaComponent(0.2)
            window?.addSubview(bgView)
            bgView.bindToEdges()
            bgView.okAction = {
                bgView.isHidden = true
                bgView.removeFromSuperview()
                self.timeView?.isHidden = true
                self.timeView?.removeFromSuperview()
                NEMeetingKit.getInstance().getMeetingService().leaveCurrentMeeting(false) { code, msg, info in
                    
                }
                
            }

            
        }
        
    }
    
    
}

extension MeetingSettingViewController: NERoomListener {
    func onMemberJoinRoom(members: [NERoomMember]) {
        
        //self.getCurrentMeetingInfo()
    }
    
    func onMemberLeaveRoom(members: [NERoomMember]) {
        //self.getCurrentMeetingInfo()
    }
    
    func onMemberJoinRtcChannel(members: [NERoomMember]) {
        if self.meetingLevel == 0 {
            self.getCurrentMeetingInfo()
        }
    }
    
}

extension MeetingSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingSettingCell", for: indexPath) as! MeetingSettingCell
        cell.selectionStyle = .none
        cell.setData(model: dataSource[indexPath.row])
        return cell
    }
    
    
    
}

extension MeetingSettingViewController: MeetingServiceListener {
    func onMeetingStatusChanged(_ event: NEMeetingEvent) {
        print("event.status = \(event.status)"); // ==5
        
        if event.status == 0 || event.status == 5 { //主动离开 或者 主持人关闭会议
            self.timer?.stopTimer()
            self.timeView?.removeFromSuperview()
            DispatchQueue.main.asyncAfter(deadline: Dispatch.DispatchTime.now() + 0.2){
                if let nav = self.navigationController {
                    for vc in nav.viewControllers {
                        if vc.isKind(of: MeetingListViewController.self) {
                            self.navigationController?.popToViewController(vc, animated: false)
                        }
                    }
                }
            }
            
            
        }
    }
    
//    func onInjectedMenuItemClick(_ clickInfo: NEMenuClickInfo, meetingInfo: NEMeetingInfo, stateController: @escaping NEMenuStateController) {
//        if clickInfo.itemId == 1000 {
//            //邀请好友
//            if let vc = UIApplication.topViewController() {
//                let invite = MeetingInviteViewController(meetingNum: self.meetingNum ?? "")
//                invite.view.backgroundColor = .white
//                let nav = TSNavigationController(rootViewController: invite)
//                nav.setCloseButton(backImage: true, titleStr: "meeting_private_invite".localized, customView: nil)
//                vc.present(nav.fullScreenRepresentation, animated: true)
//            }
//        }
//    }
    
    func onInjectedMenuItemClick(_ menuItem: NEMeetingMenuItem, meetingInfo: NEMeetingInfo) {
        
    }
}
