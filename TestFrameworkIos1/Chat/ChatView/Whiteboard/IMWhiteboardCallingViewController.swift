//
//  IMWhiteboardCallingViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/2.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import Toast
import SVProgressHUD
import NIMSDK
//import NIMPrivate
enum WhiteboardRoleType: Int{
    case WhiteboardRoleCaller = 0
    case WhiteboardRoleCallee
}

class IMWhiteboardCallingViewController: TSViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var conectLable: UILabel!
    @IBOutlet weak var stateLable: UILabel!
    @IBOutlet weak var refuseBtn: UIButton!
    
    @IBOutlet weak var accetBtn: UIButton!
    @IBOutlet weak var titleLab: UILabel!
    
    var isManager: Bool!
    var isP2p: Bool!
    var team: NIMTeam!
    var notificationSender: ChatCustomSysNotificationSender!
    var session: NIMSession!
    var whiteboardInvitedMembers = [String]()
    var role: WhiteboardRoleType!
    var chatroomID: String = ""
    var senderAccount: String = ""
    
    
    func initWithChatroom(room: String, session: NIMSession, members: [String], isManager: Bool, isP2p: Bool, senderAccount: String) {
        notificationSender = ChatCustomSysNotificationSender()
        self.session = session
        self.chatroomID = room
        whiteboardInvitedMembers = members
        self.isManager = isManager
        self.isP2p = isP2p
        self.senderAccount = senderAccount
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //继承TSViewController后重新设置页面背景颜色
        whiteboardInvitedMembers.insert(senderAccount, at: 0)
        self.view.backgroundColor = .black
        self.conectLable.text = ""
        self.titleLab.text = "input_panel_whiteboard".localized
//        let customLayout = NTESContactViewLayout()
//        customLayout.itemSize = CGSize(width: 90, height: 90)
//        self.collectionView.collectionViewLayout = customLayout
        self.collectionView.register(WhiteBoardCallingCell.self, forCellWithReuseIdentifier: "WhiteBoardCallingCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.showCallingButtons()
        self.collectionView.backgroundColor = .clear
        var nicknames = ""
        var i = 0
        if isP2p {
            nicknames = SessionUtil.showNick(senderAccount, in: nil) ?? ""
        }else{
            for userId in whiteboardInvitedMembers {
                var nick = SessionUtil.showNick(userId, in: nil) ?? ""
                if i == self.whiteboardInvitedMembers.count - 1 {
                    nicknames = nicknames + nick
                }else {
                    nick = nick + ","
                    nicknames = nicknames + nick
                }
                i = i + 1
            }
        }
        
        self.conectLable.text = nicknames
        self.conectLable.adjustsFontSizeToFitWidth = true
        
        self.stateLable.snp.makeConstraints { (make) in
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
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
   
    func dismiss()
    {
        self.dismiss(animated: true, completion: nil)
    }

    func setupButtons()
    {
        accetBtn.isHidden = true
        refuseBtn.isHidden = true
    }
    
    func showCallingButtons() {
        accetBtn.isHidden = false
        refuseBtn.isHidden = false
        self.bgView.isHidden = false
        self.stateLable.text = "text_request_sharing_whiteboard".localized
        if !isP2p, let team = NIMSDK.shared().teamManager.team(byId: session.sessionId){
            self.stateLable.text = (team.teamName ?? "") + " " + "text_request_sharing_whiteboard".localized
        }
    }

    @IBAction func refuseAction(_ sender: UIButton) {
        self.enterChatRoom(roomId: self.chatroomID)
        
    }
    @IBAction func acceptAction(_ sender: UIButton) {
        self.notificationSender.rejectWhiteboardRequest(session: self.session)
        self.dismiss()
    }
    
    func enterChatRoom(roomId: String)
    {
        let request = NIMChatroomEnterRequest()
        request.roomId = roomId
        SVProgressHUD.show()
        
        NIMSDK.shared().chatroomManager.enterChatroom(request) { [weak self] (error, room, members) in
            SVProgressHUD.dismiss()
            if error == nil {
                guard let room = room, let members = members else {
                    return
                }
                if room.onlineUserCount >= 5 {
                    NIMSDK.shared().chatroomManager.exitChatroom(roomId) { (error) in
                        self?.view.makeToast("text_whiteboard_exceed_limit_user".localized, duration: 2, position: CSToastPositionCenter)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                            self?.dismiss()
                        }
                        
                    }
                }else{
                    guard let session = self?.session else {
                        return
                    }
                    MeetingManager.shared.cacheMyInfo(info: members, roomId: request.roomId)
                   // MeetingRolesManager.shared.startNewMeeting(me: members, chatroom: room, newCreated: false)
//                    let viewcontroller = ChatWhiteboardViewController(room: room, session: session)
//                    
//                    let presentingViewController = self?.presentingViewController
//                    
//                    let nav = UINavigationController(rootViewController: viewcontroller)
//                    nav.modalPresentationStyle = .fullScreen
//                    
//                    self?.dismiss(animated: false, completion: {
//                        presentingViewController?.present(nav, animated: true, completion: nil)
//                    })
                    
                }
            }else{
                self?.view.makeToast("text_user_whiteboard_ended".localized, duration: 2, position: CSToastPositionCenter)
            }
        }
    }
    
    //MARK: - UICollectionViewDelegate, UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.whiteboardInvitedMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhiteBoardCallingCell", for: indexPath) as! WhiteBoardCallingCell
        let member = self.whiteboardInvitedMembers[indexPath.row]
        cell.loadCallingUser(user: member, number: self.whiteboardInvitedMembers.count, index: indexPath.row)
        
        return cell
    }
    
    
    //    MARK: - 行最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    //    MARK: - 列最小间距
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = self.collectionView.width
        let invitedMembersCount = CGFloat(self.whiteboardInvitedMembers.count)

        let letfSpace = (CGFloat( width ) - (invitedMembersCount * 90.0) - (invitedMembersCount * -20.0)) / 2.0
        return  UIEdgeInsets(top: 0, left: letfSpace, bottom: 0, right: 0)
    }

    

}
