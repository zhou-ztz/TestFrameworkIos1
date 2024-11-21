//
//  ChatWhiteboardViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/11/18.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
//import NIMPrivate
import SVProgressHUD

class ChatWhiteboardViewController: TSViewController {
    
//    var myUid: String = ""
//    private var user: String!
//    private var chatroom: NIMChatroom!
//    private var session: NIMSession!
//    private var name: String!
//    private var managerUid: String!
//    var isManager: Bool! = false
//    var isJoin: Bool = false
//    var myDrawColorRGB: Int?
//    var colors: [Any]
//    
//    var whiteboardSegment: UISegmentedControl!
//    var whiteboardSelectedBorder = UIView()
//    var chatSelectedBorder = UIView()
//    var segmentSelectedView = UIView()
//    var whiteboardButtonView = UIView()
//    var segmentControlView = UIView()
//    var whiteContentView = UIView()
//    var clearButton = UIButton()
//    var undoButton = UIButton()
//    var whiteboardDrawView = UIView()
//    lazy var memberCollectionView: UICollectionView = {
//        let collectionLayout = UICollectionViewFlowLayout.init()
//        collectionLayout.scrollDirection = .horizontal
//        let rect = CGRect(x: 0, y: 0, width: ScreenWidth , height: 70 )
//        collectionLayout.itemSize = CGSize(width: 50, height: 50)
//        let col = UICollectionView(frame: rect, collectionViewLayout: collectionLayout)
//        col.delegate = self
//        col.dataSource = self
//        col.backgroundColor = UIColor(red: 247, green: 247, blue: 247)
//        col.showsHorizontalScrollIndicator = false
//        col.register(UINib(nibName: WhiteBoardCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: WhiteBoardCell.cellIdentifier)
//        return col
//    }()
//    lazy var inviteMemberButton : UIButton = {
//        let btn = UIButton(frame: CGRect(x: ScreenWidth - 65, y: 10, width: 50, height: 50))
//        btn.addTarget(self, action: #selector(inviteMembers), for: .touchUpInside)
//        btn.setImage(UIImage.set_image(named: "icon_invite_whiteboard"), for: .normal)
//        return btn
//    }()
//    var badgeView = UIView()
//    
//    var closeWhiteboard : UIButton!
//    var muteWhiteboard : UIButton!
//    var lines: NTESWhiteboardLines!
//    var cmdHander: NTESWhiteboardCmdHandler!
//    var drawView: NTESWhiteboardDrawView!
//    var colorSelectView: NTESColorSelectView!
//    var colorSelectButton: UIButton = {
//        let button = UIButton()
//        button.frame =  CGRect(x: 0, y: 0, width: 28, height: 28)
//        button.layer.cornerRadius = 28 / 2
//        button.layer.borderWidth = 4
//        button.layer.borderColor = UIColor.white.cgColor
//        button.addTarget(self, action: #selector(onColorSelectPressed(_:)), for: .touchUpInside)
//        return button
//    }()
//    var laserView = UIView()
//    //var chatroomViewController: NTESChatroomViewController?
//    var chatroomViewController: IMChatroomViewController?
//    var avatarImageView: NIMAvatarImageView!
//    
//    var keyboardIsShown: Bool = false
//    var isRemainStdNav: Bool = false
//    var tableView: UITableView!
//    var whiteboardMembers = [String]()
//    var notificaionSender: ChatCustomSysNotificationSender!
//    var popOutTimer : TimerHolder!
//    var picker: UIViewController!
//    
//    func colorFromRGB(rgbValue: Int?) -> UIColor{
//      
//        return UIColor(red: CGFloat(Double(((rgbValue! & 0xFF0000) >> 16)) / 255.0), green: CGFloat(Double(((rgbValue! & 0xFF00) >> 8)) / 255.0), blue: CGFloat(Double((rgbValue! & 0xFF)) / 255.0), alpha: 1)
//    }
//
//    @objc func setMeeting() {
//   //     let myRole = MeetingRolesManager.shared.myRole()
////        NIMAVChatSDK.shared().netCallManager.setMute(!myRole!.audioOn)
////      
////        let myUid = myRole?.uid
////        MeetingRolesManager.shared.updateMeetingUser(user: myUid!, isJoined: true)
//   
//    }
//    
//    @objc func sendData(notification: Notification){
////        let dict: NSDictionary = notification.userInfo! as NSDictionary
////        let user = dict["user"] as! String
////        let cmd = dict["SendBuffer"] as! String
////        let data = cmd.data(using: .utf8)
////        if user.count > 0 {
////            MeetingRTSManager.shared.sendRTSData(data: data!, toUser: user)
////        }else{
////            MeetingRTSManager.shared.sendRTSData(data: data!, toUser: nil)
////        }
//        
//    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(whiteboardResponded(_:)), name: NSNotification.Name(rawValue: "NTESWhiteboardResponded"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(setMeeting), name: NSNotification.Name(rawValue: "setMeeting"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(sendData(notification:)), name: NSNotification.Name(rawValue: "MeetingRTSManager"), object: nil)
//       
//
//        NIMSDK.shared().chatroomManager.add(self)
//        NIMSDK.shared().loginManager.add(self)
//      //  MeetingRolesManager.shared.delegate = self
////        MeetingRTSManager.shared.delegate = self
//       
//       // MeetingNetCallManager.shared.joinMeeting(name: name ?? "", delegate: self)
//
////        NTESMeetingNetCallManager.sharedInstance().joinMeeting(name ?? "", delegate: nil)
//
////        if let role = MeetingRolesManager.shared.myRole() {
////            whiteboardMembers.append(role.uid!)
////        }
//        self.view.addSubview(memberCollectionView)
//        self.view.addSubview(inviteMemberButton)
//        inviteMemberButton.isHidden = !(isManager && self.session.sessionType == .team)
//        memberCollectionView.width = (isManager && self.session.sessionType == .team) ? ScreenWidth : ScreenWidth - 70
//
//       
////        if (isManager) {
////            let _ = MeetingRTSManager.shared.reserveConference(name: name)
////            if (self.session.sessionType == .P2P) {
////                popOutTimer.startTimer(seconds: 45, delegate: self, repeats: false)
////            }
////        }
////        else {
////            let _ = MeetingRTSManager.shared.joinConference(name: name)
////
////        }
//        self.colorSelectButton.setBackgroundColor(colorFromRGB(rgbValue: myDrawColorRGB), for: .normal)
//        self.setUpNav()
//        self.setUpSegmentControl()
//        self.setupWhiteboardView()
//        self.setUpWhiteboardButton()
//        self.setupChatroomViewController()
//        
//    }
//    
//    init(room: NIMChatroom, session: NIMSession){
//        
//        self.chatroom = room
//        self.session = session
//        self.name = room.roomId ?? ""
//        self.managerUid = room.creator!
//        self.colors = [0x000000, 0xd1021c, 0xfddc01, 0x7dd21f, 0x228bf7, 0x9b0df5]
//        super.init(nibName: nil, bundle: nil)
//        cmdHander = NTESWhiteboardCmdHandler(delegate: self)
////        MeetingRTSManager.shared.dataHandler = cmdHander
//       
////        isManager = MeetingRolesManager.shared.myRole()!.isManager
////        if  isManager {
////            myDrawColorRGB = colors[0] as? Int
////        }else{
////            myDrawColorRGB = colors[4] as? Int
////        }
////        lines = NTESWhiteboardLines()
////        myUid = NIMSDK.shared().loginManager.currentAccount()
////        notificaionSender  = ChatCustomSysNotificationSender()
////        popOutTimer = TimerHolder()
//        
//        
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        NIMSDK.shared().chatroomManager.exitChatroom(chatroom.roomId!, completion: nil)
//        NIMSDK.shared().chatroomManager.remove(self)
//        UIApplication.shared.isIdleTimerDisabled = false
////        NTESMeetingNetCallManager.sharedInstance().leaveMeeting()
////        MeetingRTSManager.shared.leaveCurrentConference()
//    }
//    
//    override func viewDidLayoutSubviews()
//    {
//        super.viewDidLayoutSubviews()
//        
//        let spacing = 15.0
//
//        self.colorSelectButton.left = CGFloat(spacing)
//        self.colorSelectButton.bottom = self.whiteboardButtonView.height - 10
//        
//        self.colorSelectView.width = 34
//        self.colorSelectView.height = self.colorSelectView.width * CGFloat(colors.count)
//        self.colorSelectView.centerX = self.colorSelectButton.centerX
//        self.colorSelectView.bottom = self.whiteboardButtonView.top - 3.5
//        //小屏适配
//        if (self.colorSelectView.height > self.view.height - self.whiteboardButtonView.height) {
//            self.colorSelectView.height = self.view.height - self.whiteboardButtonView.height
//            self.colorSelectView.bottom = self.whiteboardButtonView.top
//        }
//        
//        self.chatroomViewController!.view.frame = self.whiteContentView.frame
//       // drawView.frame = whiteboardDrawView.frame
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//    }
//   
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        self.navigationController!.isNavigationBarHidden = false
//        self.navigationController!.navigationBar.alpha = 1
//        
//        NIMSDK.shared().chatroomManager.exitChatroom(chatroom.roomId!, completion: nil)
//        NIMSDK.shared().chatroomManager.remove(self)
//        UIApplication.shared.isIdleTimerDisabled = false
////        NTESMeetingNetCallManager.sharedInstance().leaveMeeting()
////        MeetingRTSManager.shared.leaveCurrentConference()
//    }
// 
//    func setupBadgeView() {
//        self.badgeView.backgroundColor = AppTheme.red
//        self.badgeView.layer.cornerRadius = 10 / 2
//        badgeView.isHidden = true
//    }
//    
//    func setUpNav() {
//        
////        muteWhiteboard = UIButton(type: .system)
////        muteWhiteboard.frame = CGRect(x: 200, y: 200, width: 40, height: 40)
////        let audioIsOn = MeetingRolesManager.shared.myRole()!.audioOn
////        let audioImage = audioIsOn ? "icon_mute_whiteboard" : "icon_unmute_whiteboard"
////        muteWhiteboard.setImage(UIImage.set_image(named: audioImage), for: .normal)
////        muteWhiteboard.addTarget(self, action: #selector(onSelfAudioPressed), for: .touchUpInside)
////    
////        muteWhiteboard.tintColor = AppTheme.red
////        let muteWhiteboardBtnItem = UIBarButtonItem(customView: muteWhiteboard)
////        
////        closeWhiteboard = UIButton()
////        closeWhiteboard.frame = CGRect(x: 200, y: 300, width: 40, height: 40)
////        closeWhiteboard.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
////        closeWhiteboard.addTarget(self, action: #selector(onBack), for: .touchUpInside)
////        
////        let closeWhiteboardBtnItem = UIBarButtonItem(customView: closeWhiteboard)
////       
////        self.title = "input_panel_whiteboard".localized
////        self.navigationItem.rightBarButtonItem = muteWhiteboardBtnItem
////        self.navigationItem.leftBarButtonItem = closeWhiteboardBtnItem
//        
//    }
//    
//    func setUpSegmentControl() {
//        whiteboardSegment = UISegmentedControl(items: ["input_panel_whiteboard".localized, "chat_tab_chat".localized])
//        whiteboardSegment.frame = CGRect(x: 0, y: 70, width: ScreenWidth, height: 50)
//        whiteboardSelectedBorder.backgroundColor = AppTheme.red
//        chatSelectedBorder.backgroundColor = AppTheme.red
//        chatSelectedBorder.isHidden = true
//       
//        self.view.addSubview(whiteboardSegment)
//        whiteboardSegment.addTarget(self, action: #selector(didTapChange(_:)), for: .valueChanged)
//        whiteboardSegment.tintColor = AppTheme.white
//        whiteboardSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.lightGray], for: .normal)
//        whiteboardSegment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
//        whiteboardSegment.selectedSegmentIndex = 0
//
//        segmentControlView.layer.masksToBounds = false
//        segmentControlView.layer.shadowColor = UIColor.black.cgColor
//        segmentControlView.layer.shadowOffset = CGSize(width: 0, height: 2)
//        segmentControlView.layer.shadowOpacity = 0.5
//        segmentControlView.layer.shadowRadius = 4
//        
//        self.view.addSubview(badgeView)
//        self.badgeView.snp_makeConstraints { make in
//            make.centerY.equalTo(whiteboardSegment.snp_centerY)
//            make.right.equalTo(-(self.view.width / 4 - 30))
//            make.width.height.equalTo(10)
//        }
//        setupBadgeView()
//        
//    }
//
//    func setupWhiteboardView() {
//        self.whiteContentView.frame = CGRect(x: 0, y: 120, width: ScreenWidth, height: ScreenHeight - TSNavigationBarHeight - 120)
//        self.view.addSubview(self.whiteContentView)
//        self.whiteboardDrawView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: self.whiteContentView.height - 50 - TSBottomSafeAreaHeight)
//        
//        self.drawView = NTESWhiteboardDrawView()
//        self.drawView.frame = self.whiteboardDrawView.bounds
//        drawView.backgroundColor = UIColor.white
//        drawView.dataSource = lines
//        
//        laserView.width = 7
//        laserView.height = 7
//        laserView.backgroundColor = .red
//        laserView.layer.cornerRadius = 3.5
//        laserView.layer.masksToBounds = true
//        
//        colorSelectView = NTESColorSelectView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), colors: colors, delegate: self)
//        
//        self.whiteContentView.addSubview(self.drawView)
//        self.drawView.addSubview(self.laserView)
//        self.whiteContentView.addSubview(self.colorSelectView)
//        colorSelectView.isHidden = true
//        self.laserView.isHidden = true
//        
//        whiteboardButtonView.layer.borderWidth = 0.5
//        whiteboardButtonView.layer.borderColor = UIColor.lightGray.cgColor
//        whiteboardButtonView.addSubview(self.colorSelectButton)
//        self.view.bringSubviewToFront(self.whiteContentView)
//        self.whiteContentView.addSubview(whiteboardButtonView)
//        self.whiteContentView.bringSubviewToFront(self.whiteboardButtonView)
//        whiteboardButtonView.snp.makeConstraints { (make) in
//            make.left.right.equalTo(0)
//            make.height.equalTo(50)
//            make.bottom.equalTo(-TSBottomSafeAreaHeight)
//        }
//
//    }
//    
//    func setUpWhiteboardButton(){
//        whiteboardButtonView.layer.borderWidth = 1
//        whiteboardButtonView.layer.borderColor = UIColor.lightGray.cgColor
//        whiteboardButtonView.addSubview(clearButton)
//        whiteboardButtonView.addSubview(undoButton)
//        undoButton.snp.makeConstraints { (make) in
//            make.top.equalTo(9)
//            make.left.equalTo(66)
//            make.height.width.equalTo(32)
//        }
//        clearButton.snp.makeConstraints { (make) in
//            make.top.equalTo(9)
//            make.left.equalTo(122)
//            make.height.width.equalTo(32)
//        }
//        undoButton.setImage(UIImage.set_image(named: "icon_undo_whiteboard"), for: .normal)
//        clearButton.setImage(UIImage.set_image(named:"icon_clear_whiteboard"), for: .normal)
//        clearButton.addTarget(self, action: #selector(onClearAllPressed(_:)), for: .touchUpInside)
//        undoButton.addTarget(self, action: #selector(onCancelLinePressed(_:)), for: .touchUpInside)
//      
//        self.colorSelectView.width = 34
//        self.colorSelectView.height = self.colorSelectView.width * CGFloat(colors.count)
//        self.colorSelectView.centerX = self.colorSelectButton.centerX
//        self.colorSelectView.bottom = self.whiteboardButtonView.top - 3.5
//        //小屏适配
//        if (self.colorSelectView.height > self.view.height - self.whiteboardButtonView.height) {
//            self.colorSelectView.height = self.view.height - self.whiteboardButtonView.height
//            self.colorSelectView.bottom = self.whiteboardButtonView.top
//        }
//    }
//    
//    func setupChatroomViewController()
//    {
//
//        self.chatroomViewController = IMChatroomViewController(session: session, chatRoom: chatroom)
//        self.addChild(self.chatroomViewController!)
//        self.chatroomViewController!.view.frame = self.whiteContentView.frame
//        self.view.addSubview(chatroomViewController!.view)
//        self.chatroomViewController!.view.clipsToBounds = true
//        self.chatroomViewController!.didMove(toParent: self) 
//       // self.chatroomViewController!.delegate = self
//        self.chatroomViewController!.badgeDelegate = self
//        
//        whiteboardSelectedBorder.isHidden = false
//        chatSelectedBorder.isHidden = true
//        whiteContentView.isHidden = false
//        chatroomViewController!.view.isHidden = true
//        chatroomViewController!.beginAppearanceTransition(false, animated: true)
//        DispatchQueue.main.async {
//            self.chatroomViewController!.endAppearanceTransition()
//        }
//
//    }
//    
//    func hideChatroomViewController() {
//        chatroomViewController!.willMove(toParent: nil)
//        chatroomViewController!.view.removeFromSuperview()
//        chatroomViewController!.removeFromParent()
//      
//    }
//    
//    func requestCloseChatRoom() {
//        SVProgressHUD.show()
//        YippiAPI.togaShared.closeWhiteboardChatroom(roomId: name) { (response, error) in
//            DispatchQueue.main.async {
//                SVProgressHUD.dismiss()
//                self.dismissWhiteboard()
//            }
//        }
//
//    }
//    
//    func requestChatRoomInfo()
//    {
//        guard let roomID = chatroom.roomId else {
//            return
//        }
//        NIMSDK.shared().chatroomManager.fetchChatroomInfo(roomID) { [weak self] (error, chatroom) in
//            if error != nil {
//                //self?.view.makeToast("fetch_chatroom_info_fail".localized, duration: 2, position: CSToastPositionCenter)
//            }
//        }
//    }
//    
//    
//    func dismissWhiteboard()
//    {
//        if (isManager) {
//            self.navigationController?.popViewController(animated: true)
//        } else {
//            self.navigationController?.dismiss(animated: true, completion: nil)
//        }
//    }
//    
//    // MARK: - actions
//    @objc func onClearAllPressed(_ sender: UIButton)
//    {
////        lines.clearUser(myUid)
////        cmdHander.sendPureCmd(.clearLines, to: nil)
//        
//    }
//
//    @objc func onCancelLinePressed(_ sender: UIButton)
//    {
////        lines.cancelLastLine(myUid)
////        cmdHander.sendPureCmd(.cancelLine, to: nil)
//    }
//    
//    @objc func onSelfAudioPressed(){
//        
////        let audioIsOn = MeetingRolesManager.shared.myRole()?.audioOn
////        MeetingRolesManager.shared.setMyAudio(on: !audioIsOn!)
////       
////        let audioImage = !audioIsOn! ? "icon_mute_whiteboard" : "icon_unmute_whiteboard"
////        muteWhiteboard.setImage(UIImage.set_image(named: audioImage), for: .normal)
//        
//    }
//    
//    @objc func onBack(){
//        
//        let alert = TSAlertController(title: "text_quit_whiteboard_sharing".localized, message: "text_quit_whiteboard_msg".localized, style: .alert, animateView: false)
//        let action = TSAlertAction(title: "quit".localized, style: TSAlertActionStyle.default) { [weak self] (action) in
//            guard let self = self else {return}
//            if self.isManager {
//                self.requestCloseChatRoom()
//                
//            } else {
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
//                    self.dismissWhiteboard()
//                }
//                
//                
//            }
//        }
//        let actionCancel = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.default) { [weak self] (action) in
//            
//        }
//        self.presentPopup(alert: alert, actions: [action, actionCancel])
//        
//        
//    }
//    
//    @objc func didTapChange(_ segment: UISegmentedControl){
//        
//        if whiteboardSegment.selectedSegmentIndex == 0 {
//            whiteboardSelectedBorder.isHidden = false
//            chatSelectedBorder.isHidden = true
//            whiteContentView.isHidden = false
//            chatroomViewController!.view.isHidden = true
////            chatroomViewController!.beginAppearanceTransition(false, animated: true)
////            DispatchQueue.main.async {
////                self.chatroomViewController!.endAppearanceTransition()
////            }
//            
//            
//        } else if(whiteboardSegment.selectedSegmentIndex == 1) {
//            self.badgeView.isHidden = true
//            whiteboardSelectedBorder.isHidden = true
//            chatSelectedBorder.isHidden = false
//            whiteContentView.isHidden = true
//            chatroomViewController!.view.isHidden = false
//            chatroomViewController!.beginAppearanceTransition(true, animated: true)
//            DispatchQueue.main.async {
//                self.chatroomViewController!.endAppearanceTransition()
//            }
//        }
//        
//    }
//    
//    @objc func inviteMembers(){
//        if self.checkCondition() {
//            
//            NIMSDK.shared().teamManager.fetchTeamMembers(self.session.sessionId) { [weak self] (error, members) in
//                guard let teamMembers = members else {
//                    return
//                }
//                var ids = [String]()
//                for member in teamMembers {
//                    if !(self?.whiteboardMembers.contains(member.userId!))! {
//                        ids.append(member.userId!)
//                    }
//                }
//                let config = ContactsPickerConfig(title: "select_contacts".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: false, enableRecent: false, enableRobot: false, maximumSelectCount: 9, excludeIds: nil, members: ids, enableButtons: false, allowSearchForOtherPeople: true)
//                
//                self?.picker = ContactsPickerViewController(configuration: config, finishClosure: { (contacts) in
//                    self?.picker.dismiss(animated: true, completion: nil)
//                    var selectedIds = [String]()
//                    for data in contacts {
//                        selectedIds.append(data.userName)
//                    }
//                    guard let session = self?.session , let roomID = self?.name else {
//                        return
//                    }
//                    self?.notificaionSender.sendWhiteboardRequest(session: session, roomID: roomID, invitedContacts: selectedIds)
//                   
//                    
//                })
//                
//                let nav = UINavigationController(rootViewController: (self?.picker)!)
//                
//                DispatchQueue.main.async {
//                    self?.present(nav, animated: true, completion: nil)
//                }
//  
//            }
//
//        }
//    }
//    
//    @objc func onColorSelectPressed(_ sender: UIButton){
//        self.colorSelectView.isHidden = !self.colorSelectView.isHidden
//    }
//    
//    //MARK: - condition checking
//    func checkCondition() -> Bool
//    {
//        var result = true
//        
//        if !NTESDevice.current().canConnectInternet() {
//            result = false
//            self.view.makeToast("network_is_not_available".localized, duration: 2, position: CSToastPositionCenter)
//        }
//        
//        let currentUserID = NIMSDK.shared().loginManager.currentAccount()
//        if managerUid != currentUserID  {
//            self.view.makeToast("You can not add people.".localized, duration: 2, position: CSToastPositionCenter)
//            result = false
//        }
//        
//        if self.whiteboardMembers.count > 4  {
//            self.view.makeToast("text_whiteboard_exceed_limit_user".localized, duration: 2, position: CSToastPositionCenter)
//            result = false
//        }
//        
//        return result
//    }
//
//    
//    // MARK: - Whiteboard custom notification
//    @objc func whiteboardResponded(_ sender: NSNotification)
//    {
//        let dict = sender.object as! [String: Any]
//        let roomID =  dict["roomID"]
//        let content = dict["content"] as! String
//        let fromAccount = dict["fromAccount"] as! String
//
//        if (String(describing: roomID) != name) {
//            return
//        }
//        
//        var msg = ""
//        if (content == "INVITE" ) {
//        }
//        else if (content == "REJECT") {
//            msg = "text_rejected_whiteboard_presentation".localized + fromAccount
//        }
//        else if (content == "BUSY") {
//            msg = "whiteboard_opponent_busy".localized + fromAccount
//        }
//        self.view.makeToast(msg, duration: 2, position: CSToastPositionCenter)
//       
//    }
//    
//    // MARK:  - UIResponder
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.colorSelectView.isHidden = true
//        for touch:AnyObject in touches {
//            let t: UITouch = touch as! UITouch
//            let p = t.location(in: drawView)
//            self.onPointCollected(p: p, type: .start)
//        }
//    }
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch:AnyObject in touches {
//            let t: UITouch = touch as! UITouch
//            let p = t.location(in: drawView)
//            self.onPointCollected(p: p, type: .move)
//        }
//        
//    }
//  
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch:AnyObject in touches {
//            let t: UITouch = touch as! UITouch
//            let p = t.location(in: drawView)
//            self.onPointCollected(p: p, type: .end)
//        }
//    }
//   
//    func onPointCollected(p: CGPoint, type: NTESWhiteboardPointType){
////        if !(MeetingRolesManager.shared.myRole()?.whiteboardOn)! {
////            return
////        }
////        
////        if !isJoin {
////            return
////        }
////        
////        let point = NTESWhiteboardPoint()
////        point.type = type
////        point.xScale = Float(p.x / drawView.frame.size.width)
////        point.yScale = Float(p.y / drawView.frame.size.height)
////        point.colorRGB = Int32(myDrawColorRGB!)
////        cmdHander.sendMyPoint(point)
////        lines.add(point, uid: myUid)
//      
//    }
//   
//    func checkPermission()
//    {
//        self.colorSelectButton.setBackgroundColor(colorFromRGB(rgbValue: myDrawColorRGB), for: .normal)
//        self.colorSelectButton.isEnabled = true
//        self.undoButton.isEnabled = true
//        self.clearButton.isEnabled = true
//    }
//    
//    func onReceiveMessage(){
//        self.badgeView.isHidden = self.whiteboardSegment.selectedSegmentIndex == 1
//    }
//
//}
////MARK: - NTESWhiteboardCmdHandlerDelegate
////extension ChatWhiteboardViewController: NTESWhiteboardCmdHandlerDelegate{
////    func onReceive(_ point: NTESWhiteboardPoint!, from sender: String!) {
////        lines.add(point, uid: sender)
////    }
////    
////    func onReceive(_ type: NTESWhiteBoardCmdType, from sender: String!) {
////        if (type == .cancelLine) {
////            lines.cancelLastLine(sender)
////        }else if (type == .clearLines) {
////            lines.clearUser(sender)
////            cmdHander.sendPureCmd(.clearLinesAck, to: nil)
////        }else if (type == .clearLinesAck) {
////            lines.clearUser(myUid)
////        }else if (type == .syncPrepare) {
////            lines.clear()
////            cmdHander.sendPureCmd(.syncPrepareAck, to: sender)
////        }
////    }
////    
////    func onReceiveSyncRequest(from sender: String!) {
////        cmdHander.sync(lines.allLines(), toUser: sender)
////    }
////    
////    func onReceiveSyncPoints(_ points: NSMutableArray!, owner: String!) {
////        lines.clearUser(owner)
////        for point in points {
////            lines.add(point as! NTESWhiteboardPoint, uid: owner)
////        }
////    }
////    
////    func onReceiveLaserPoint(_ point: NTESWhiteboardPoint!, from sender: String!) {
////        self.laserView.isHidden = false
////        let p = CGPoint(x: CGFloat(point.xScale) * self.drawView.frame.size.width, y: CGFloat(point.yScale) * self.drawView.frame.size.height)
////        self.laserView.center = p
////    }
////    
////    func onReceiveHiddenLaserfrom(_ sender: String!) {
////        self.laserView.isHidden = true
////    }
////    
////
////}
//
////MARK: - NIMChatroomManagerDelegate
//extension ChatWhiteboardViewController: NIMChatroomManagerDelegate {
//    func chatroomBeKicked(_ result: NIMChatroomBeKickedResult) {
//        if result.roomId == self.chatroom.roomId {
//            var toast: String = ""
//            if !isManager {
//                toast = "text_whiteboard_presentation_ended".localized
//                self.view.makeToast(toast, duration: 2, position: CSToastPositionCenter)
//                self.dismissWhiteboard()
//            }
//            
//        }
//    }
//    
//    func onLogin(_ step: NIMLoginStep) {
//        if step == .loginOK {
////            if NTESMeetingNetCallManager.sharedInstance().isInMeeting {
////                //self.view.makeToast("whiteboard_reconnect_success".localized)
////                NTESMeetingNetCallManager.sharedInstance().joinMeeting(name ?? "", delegate: nil)
////            }else{
////               let _ = MeetingRTSManager.shared.joinConference(name: name)
////            }
//        }
//    }
//
//    func chatroom(_ roomId: String, connectionStateChanged state: NIMChatroomConnectionState) {
//        if state == .enterOK {
//            self.requestChatRoomInfo()
//        }
//    }
//
//  
//}
//
//// MARK: - MeetingRTSManagerDelegate
//extension ChatWhiteboardViewController: MeetingRTSManagerDelegate {
//    func onLeft(name: String, error: Error?) {
//        self.view.makeToast("target_has_end_session".localized)
//        isJoin = false
////        MeetingRTSManager.shared.joinConference(name: name)
//        self.checkPermission()
//    }
//    
//    func onUserJoined(uid: String, conference name: String) {
//        popOutTimer.stopTimer()
//        self.whiteboardMembers.append(uid)
//        self.memberCollectionView.reloadData()
//  
//    }
//    
//    func onUserLeft(uid: String, conference name: String) {
//        
//        if let index = self.whiteboardMembers.firstIndex(where: { ($0 == uid)
//        }) {
//            self.whiteboardMembers.remove(at: index)
//        }
//        
//        self.memberCollectionView.reloadData()
//    }
//    
//    func onReserve(name: String, result: Error?) {
////        if result == nil {
////            let _ = MeetingRTSManager.shared.joinConference(name: name)
////        }else{
////            self.view.makeToast("reserve_whiteboard_error".localized)
////        }
//    }
//    
//    func onJoin(name: String, result: Error?) {
//        if result == nil {
//            isJoin = true
//            self.checkPermission()
//            cmdHander.sendPureCmd(.syncPrepare, to: nil)
//            cmdHander.sync(lines.allLines(), toUser: nil)
//        }
//    }
//    
//}
//
//extension ChatWhiteboardViewController: MeetingRolesManagerDelegate {
//    func meetingRolesUpdate(){
//        
//    }
//    func meetingMemberRaiseHand(){
//        
//    }
//    func meetingActorBeenEnabled(){
//        
//    }
//    func meetingActorBeenDisabled(){
//        
//    }
//    func meetingActorsNumberExceedMax(){
//     //   self.view.makeToast("text_whiteboard_exceed_limit_user".localized, duration: 1, position: CSToastPositionCenter)
//       
//    }
//    func meetingVolumesUpdate(){
//        
//    }
//    func chatroomMembersUpdated(members: [NIMChatroomNotificationMember]?, entered: Bool?){
//        
//    }
//    func meetingRolesShowFullScreen(notifyExt: String?){
//        
//    }
//}
//
////extension ChatWhiteboardViewController: NTESColorSelectViewDelegate {
////    func onColorSelected(_ rgbColor: Int32) {
////        self.colorSelectView.isHidden = true
////        myDrawColorRGB = Int(rgbColor)
////        self.colorSelectButton.setBackgroundColor(colorFromRGB(rgbValue: myDrawColorRGB), for: .normal)
////    }
////   
////    
////}
//
//extension ChatWhiteboardViewController: TimerHolderDelegate {
//    func onTimerFired(holder: TimerHolder) {
//        self.requestCloseChatRoom()
//    }
//    
//}
//
////MARK: - MeetingNetCallManagerDelegate
//extension ChatWhiteboardViewController: MeetingNetCallManagerDelegate {
//
////    func onJoinMeetingFailed(name: String, error: Error?) {
////        self.view.window?.makeToast("chatroom_status_exception".localized, duration: 2, position: CSToastPositionCenter)
////        if let role = MeetingRolesManager.shared.myRole() {
////            if role.isManager {
////                self.requestCloseChatRoom()
////            }
////        }
////        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
////            self.dismissWhiteboard()
////        }
//
//    }
//
//    func onMeetingContectStatus(connected: Bool) {
////        if !connected {
////            self.view.window?.makeToast("whiteboard_weak_connection".localized, duration: 2, position: CSToastPositionCenter)
////
////        }
//    }
//
//
//}
//
//extension ChatWhiteboardViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.whiteboardMembers.count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView .dequeueReusableCell(withReuseIdentifier: WhiteBoardCell.cellIdentifier, for: indexPath) as! WhiteBoardCell
//        let member = self.whiteboardMembers[indexPath.row]
//        
//        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: member)
//        cell.headImage.sd_setImage(with: URL(string: avatarInfo.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"), options: [], progress: nil, completed: nil)
//        return cell
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return  UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
//    }
//    
//    //    MARK: - 行最小间距
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 15
//    }
//    
//    //    MARK: - 列最小间距
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 15
//    }
}
