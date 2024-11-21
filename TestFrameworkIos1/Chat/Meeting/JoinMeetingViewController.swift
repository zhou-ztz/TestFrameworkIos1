//
//  JoinMeetingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/2.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NEMeetingKit
import NERoomKit
//import NIMPrivate
import NIMSDK

let scale: CGFloat = 82.0 / (151.0 + 82.0)

class JoinMeetingViewController: TSViewController {
    
    
    lazy var logoImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.set_image(named: "cropped-yippi_logo")
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    lazy var logoL: UILabel = {
        let lab = UILabel()
        lab.text = "Meet"
        lab.textColor = UIColor(hex: "#28A8E0")
        lab.font = UIFont.boldSystemFont(ofSize: 30)
        return lab
    }()
    lazy var meetL: UILabel = {
        let lab = UILabel()
        lab.text = "meeting_code".localized
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 14)
        return lab
    }()
    
    lazy var codeT: UITextField = {
        let textF = UITextField()
        textF.backgroundColor = UIColor(hex: "#F5F5F5")//#808080
        textF.placeholder = "rw_meeting_id".localized
        textF.font = UIFont.systemRegularFont(ofSize: 14)
        textF.layer.cornerRadius = 10
        textF.clipsToBounds = true
        textF.leftViewMode = .always
        textF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        return textF
    }()
    
    lazy var joinBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("meeting_join".localized, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemMediumFont(ofSize: 17)
        btn.backgroundColor = UIColor(hex: 0xD1D1D1)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var settingsLabel: UILabel = {
        let lab = UILabel()
        lab.text = "settings".localized
        lab.textColor = .black
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        return lab
    }()
    
    lazy var muteStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var muteLabel: UILabel = {
        let label = UILabel()
        label.text = "mute".localized
        label.textColor = .black
        label.font = UIFont.systemRegularFont(ofSize: 14)
        return label
    }()
    
    lazy var cameraStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .horizontal
        return stack
    }()
    
    lazy var cameraLabel: UILabel = {
        let label = UILabel()
        label.text = "rw_turn_off_camera".localized
        label.textColor = .black
        label.font = UIFont.systemRegularFont(ofSize: 14)
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fill
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()
    
    var muteSwitch = UISwitch()
    var cameraSwitch = UISwitch()
    
    var meetingNum: String = ""
    var pop: JoiningVC?
    
    //会议是否付年费 0 无 1 已付
    var level: Int = 0
    //会议时长
    var meetingMemberLimit: Int = 0
    var meetingTimeLimit: Int = 0
    // 房间id
    var roomUuid: String = ""
    //开始时间
    var startTime: Int = 0
    //剩余会议时长
    var duration: Int = 0
    var timer: TimerHolder?
    
    var timeView: UIView?
    var timeLabel:  UILabel?
    //是否私密会议
    var isPrivate: Bool = false
    
    var isUnMute: Bool = false
    var isOnCamera: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if let nav = self.navigationController as? TSNavigationController {
            nav.setCloseButton(backImage: true, titleStr: "join_meeting".localized)
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
    
    func setUI(){
        self.view.addSubview(codeT)
        codeT.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(17)
            make.right.equalTo(-17)
            make.height.equalTo(68)
        }
        codeT.text = meetingNum
      
        self.view.addSubview(settingsLabel)
        settingsLabel.snp.makeConstraints { make in
            make.top.equalTo(codeT.snp.bottom).offset(16)
            make.left.equalTo(17)
        }
        
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(settingsLabel.snp.bottom).offset(12)
            make.left.equalTo(17)
            make.right.equalTo(-17)
        }
        
        stackView.addArrangedSubview(muteStackView)
        muteStackView.addArrangedSubview(muteLabel)
        muteLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview().offset(-25)
        }
        muteStackView.addArrangedSubview(muteSwitch)
        muteSwitch.isOn = isUnMute
        muteSwitch.addTarget(self, action: #selector(muteAction), for: .valueChanged)
        
        stackView.addArrangedSubview(cameraStackView)
        cameraStackView.addArrangedSubview(cameraLabel)
        cameraLabel.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.centerX.equalToSuperview().offset(-25)
        }
        cameraStackView.addArrangedSubview(cameraSwitch)
        cameraSwitch.isOn = isOnCamera
        cameraSwitch.addTarget(self, action: #selector(cameraAction), for: .valueChanged)
        
        self.view.addSubview(joinBtn)
        joinBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.view).inset(TSBottomSafeAreaHeight)
            make.left.equalTo(17)
            make.right.equalTo(-17)
            make.height.equalTo(55)
        }
        
        
        //加入会议
        joinBtn.addAction {
            self.view.endEditing(true)
            if self.codeT.text?.count == 0 {
                //self.showError(message: "请输入会议码".localized)
                return
            }
            TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
                DispatchQueue.main.async {
                    self.joinMeetingApi(meetingNum: self.codeT.text ?? "")
                }
            })
            
        }
        self.joinBtn.isEnabled = false
        codeT.add(event: .editingChanged) { [weak self] in
            guard let self = self else {return}
            if self.codeT.text?.count == 0 {
                self.joinBtn.isEnabled = false
                self.joinBtn.backgroundColor = UIColor(hex: 0xD1D1D1)
            }else{
                self.joinBtn.isEnabled = true
                self.joinBtn.backgroundColor = TSColor.main.theme
            }
        }
        
        
        
    }
    
    deinit {
        NEMeetingKit.getInstance().getMeetingService()?.remove(self)
        
    }
    
    //meetingkit 登录
    func meetingkitLogin(username: String, password: String, meeting: String){
        NEMeetingKit.getInstance().login(username, token: password) { [weak self] code, msg, result in
            self?.pop?.dismiss()
            if code == 0 {
                print("NEMeetingKit登录成功")
                self?.joinInMeeting(password: meeting)
            }else {
                self?.showError(message: msg ?? "")
            }
        }
    }
    
    
    func quertMeetingKitAccountInfo(password: String){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        self.meetingkitLogin(username: userUuid ?? "", password: token ?? "", meeting: password)
    }
   
    func showPasswordAlert(){
        let customView = MeetingPasswordView(titleStr: "Enter meeting password".localized, comfire: "Join".localized)
        let vc = TSAlertController(style: .popup(customview: customView), hideCloseButton: true)
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false, completion: nil)
        customView.dismissAction = {
            vc.dismiss()
        }
        customView.comfireAction = { (text) in
            vc.dismiss {
                self.quertMeetingKitAccountInfo(password: text)
                
            }
            
        }
    }
    
    ///加入会议
    func joinInMeeting(password: String){
        
        let params = NEJoinMeetingParams() //会议参数
        params.meetingNum = self.codeT.text ?? ""
        params.displayName = NIMSDK.shared().loginManager.currentAccount()
        params.password = password
        //会议选项，可自定义会中的 UI 显示、菜单、行为等
        let options = NEJoinMeetingOptions()
        options.noVideo = isOnCamera //入会时关闭视频，默认为 YES
        options.noAudio = isUnMute //入会时关闭音频，默认为 YES
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
        options.showMeetingRemainingTip = false                     //会议中是否开启剩余时间（秒）提醒，默认为 NO

        let chatroomConfig = NEMeetingChatroomConfig() //配置聊天室
        chatroomConfig.enableFileMessage = true //是否允许发送/接收文件消息，默认为 YES
        chatroomConfig.enableImageMessage = true //是否允许发送/接收图片消息，默认为 YES
        options.chatroomConfig = chatroomConfig
        if isPrivate {
            SessionUtil().configMoreMenus(options: options)
        }
        let meetingServce = NEMeetingKit.getInstance().getMeetingService()
        
        meetingServce?.joinMeeting(params, opts: options, callback: { [weak self] resultCode, resultMsg, result in
            guard let self = self else {
                return
            }
            if resultCode == 0 {
                
                if self.level == 0 {
                    self.startTimerHolder()
                }

            }
            else {
                self.showError(message: resultMsg ?? "")
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.pop?.dismiss()
            }
            
        })
        
    }
    
    //后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String){
        self.meetingNum = meetingNum
        pop = JoiningVC()
        pop?.show()
        JoinMeetingRequest.init(params: ["meetingNum" : meetingNum]).execute {model in
            self.level = model?.data.meetingLevel ?? 0
            self.roomUuid = (model?.data.roomUuid ?? 0).stringValue
            self.meetingTimeLimit = model?.data.meetingTimeLimit ?? 0
            self.meetingMemberLimit = model?.data.meetingMemberLimit ?? 0
            self.startTime = (model?.data.meetingInfo?.startTime ?? "").toInt()
            DispatchQueue.main.async {
                self.isPrivate = (model?.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                self.quertMeetingKitAccountInfo(password: "")
            }
        } onError: {[weak self]  error in
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self?.pop?.dismiss()
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
        let nim = String(format: "%02d", nimute)
        let ss = String(format: "%02d", s)
        timeView = UIView()
        timeView?.backgroundColor = UIColor(red: 0.93, green: 0.13, blue: 0.13, alpha: 1)
        timeView?.layer.cornerRadius = 10
        timeView?.clipsToBounds = true
        vc.view.addSubview(timeView!)
        timeView?.isHidden = true
        timeLabel = UILabel()
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
    
    @objc func muteAction(mySwitch: UISwitch) {
        if mySwitch.isOn {
            isUnMute = true
        } else {
            isUnMute = false
        }
    }
    
    @objc func cameraAction(mySwitch: UISwitch) {
        if mySwitch.isOn {
            isOnCamera = true
        } else {
            isOnCamera = false
        }
    }

}

extension JoinMeetingViewController: TimerHolderDelegate {
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
                NEMeetingKit.getInstance().getMeetingService()?.leaveCurrentMeeting(false) { code, msg, info in
                    
                }
                
            }
        }
        
    }
    
    
}

extension JoinMeetingViewController: NERoomListener {
    func onMemberJoinRoom(members: [NERoomMember]) {
        
    }
    
    func onMemberLeaveRoom(members: [NERoomMember]) {
        
    }
    
}


class MeetingPasswordView: UIView {
    
    /// 点击取消的回调
    var dismissAction: (() -> Void)?
    /// 点击确定的回调
    var comfireAction: ((String) -> Void)?
    /// 标题
    var titleString: String = ""
    var comfireString: String = ""
    var cancelString: String = ""
    
    lazy var passwordT: UITextField = {
        let textF = UITextField()
        textF.backgroundColor = UIColor(hex: "#F5F5F5")
        textF.placeholder = "password here"
        textF.font = UIFont.systemRegularFont(ofSize: 14)
        textF.layer.cornerRadius = 10
        textF.clipsToBounds = true
        textF.leftViewMode = .always
        textF.textColor = UIColor(hex: "#808080")
        textF.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 10))
        return textF
    }()
    
    lazy var titleL: UILabel = {
        let lab = UILabel()
        lab.text = "Enter meeting password"
        lab.textColor = UIColor(hex: "#212121")
        lab.font = UIFont.boldSystemFont(ofSize: 17)
        lab.textAlignment = .center
        return lab
    }()
    
    lazy var wrongL: UILabel = {
        let lab = UILabel()
        lab.text = "Oppss.. the password is incorrect"
        lab.textColor = UIColor(hex: "#ED2121")
        lab.font = UIFont.systemRegularFont(ofSize: 14)
        lab.textAlignment = .left
        lab.isHidden = true
        return lab
    }()
    var cancelBtn = UIButton()
    var joinBtn = UIButton()
    
    var stackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 4
        $0.distribution = .fill
        $0.alignment = .leading
    }
    var buttonView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 7
        $0.distribution = .fillEqually
        $0.alignment = .center
    }

    init(titleStr: String, comfire: String, cancel: String = "cancel".localized){
        super.init(frame: UIScreen.main.bounds)
        titleString = titleStr
        comfireString = comfire
        cancelString = cancel
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        let spaceView = UIView()
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(18)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.bottom.equalTo(-5)
        }
        stackView.addArrangedSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.height.equalTo(27)
            make.left.right.equalTo(0)
        }
        stackView.addArrangedSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.left.right.equalTo(0)
        }
        stackView.addArrangedSubview(passwordT)
        passwordT.snp.makeConstraints { make in
            make.height.equalTo(37)
            make.left.right.equalTo(0)
        }
        stackView.addArrangedSubview(wrongL)
        wrongL.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.left.right.equalTo(0)
        }
        stackView.addArrangedSubview(spaceView)
        spaceView.snp.makeConstraints { make in
            make.height.equalTo(10)
            make.left.right.equalTo(0)
        }
        stackView.addArrangedSubview(buttonView)
        buttonView.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.left.right.equalTo(0)
        }
        
        joinBtn = self.createMeetingButton(backColor: AppTheme.red, title: comfireString)
        cancelBtn = self.createMeetingButton(backColor: UIColor(hex: "#EDEDED"), title: cancelString, titleColor: .black)
        buttonView.addArrangedSubview(cancelBtn)
        buttonView.addArrangedSubview(joinBtn)
        
        joinBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        cancelBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        self.titleL.text = titleString
        joinBtn.addTarget(self, action: #selector(joinAction), for: .touchUpInside)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    }
    
    @objc func joinAction(){
        self.comfireAction?(passwordT.text ?? "")
    }
    @objc func cancelAction(){
        self.dismissAction?()
    }
    
    private func createMeetingButton(backColor: UIColor, title: String, titleColor: UIColor = .white) -> UIButton{
        let btn = UIButton(type: .custom)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(titleColor, for: .normal)
        btn.backgroundColor = backColor
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.clipsToBounds = true
        return btn
    }
    
    
}

class JoiningVC: UIView {
    
    let alertView: UIView = UIView()
    lazy var titleL: UILabel = {
        let lab = UILabel()
        lab.text = "meeting_joining_meeting".localized
        lab.textColor = .black
        lab.font = UIFont.systemRegularFont(ofSize: 12)
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    
    init(){
        super.init(frame: .zero)
        self.initialUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initialUI() {
        self.backgroundColor = UIColor.clear
        let coverBtn = UIView()
        self.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        coverBtn.addAction {
            //self.dismiss(animated: false)
        }
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.addSubview(alertView)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 10
        alertView.backgroundColor = UIColor.white
        alertView.snp.makeConstraints { (make) in
            make.height.equalTo(55)
            make.left.right.equalToSuperview().inset(20)
            make.top.equalTo(51)
        }
        let layer0 = CALayer()
        layer0.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1).cgColor
        layer0.shadowOpacity = 1
        layer0.shadowRadius = 10
        layer0.shadowOffset = CGSize(width: 0, height: 4)
        alertView.layer.addSublayer(layer0)
    
        alertView.addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(9)
        }

    }
    
    func show(){
        let window = UIApplication.shared.windows.first
        window?.addSubview(self)
        self.bindToEdges()
    }
    
    func dismiss(){
        self.removeFromSuperview()
    }
}

extension JoinMeetingViewController: MeetingServiceListener {
    func onMeetingStatusChanged(_ event: NEMeetingEvent) {
        if event.status == 0 || event.status == 5 { //主动离开 或者 主持人关闭会议
            self.timer?.stopTimer()
            self.timeView?.removeFromSuperview()
            print("===event.status = \(event.status), event.arg = \(event.arg)")
            
        }
    }
    
//    func onInjectedMenuItemClick(_ clickInfo: NEMenuClickInfo, meetingInfo: NEMeetingInfo, stateController: @escaping NEMenuStateController) {
//        if clickInfo.itemId == 1000 {
//            //邀请好友
//            if let vc = UIApplication.topViewController() {
//                let invite = MeetingInviteViewController(meetingNum: self.meetingNum)
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
