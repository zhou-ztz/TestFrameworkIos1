// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import Toast
import SVProgressHUD
//import NIMPrivate

@objc public class ChatDetailViewController: UIViewController {

    @IBOutlet weak var sessionCardTable: UITableView!
    private let sessionHeaderIdentifier = "sessionHeaderIdentifier"
    private let sessionCardCellIdentifier = "sessionCardCell"
    var sessionId: String
    var session: NIMSession
    var contactPicker: UIViewController!
    var clearMessageCall: (() -> ())?
    @objc public init(sessionId: String) {
        self.sessionId = sessionId
        self.session = NIMSession(self.sessionId, type: .P2P)
        super.init(nibName: "ChatDetailViewController", bundle: Bundle(for: type(of: self)))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = NSLocalizedString("title_personal_chat_info", comment:"")

        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: session.sessionId)
        if let username = avatarInfo.nickname {
            self.navigationItem.title = username
        }

        self.sessionCardTable.delegate = self
        self.sessionCardTable.dataSource = self
        self.sessionCardTable.register(UINib(nibName: "ChatDetailTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: sessionCardCellIdentifier)
        self.sessionCardTable.register(UINib(nibName: "ChatDetailHeaderView", bundle: Bundle(for: type(of: self))), forHeaderFooterViewReuseIdentifier: sessionHeaderIdentifier)
        self.sessionCardTable.tableFooterView = UIView()
        self.sessionCardTable.backgroundColor = AppTheme.headerGrey
        self.sessionCardTable.separatorInset = .zero;
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRemarkName), name: Notification.Name(rawValue: "RefreshRemarkName"), object: nil)

    }

    func needNotify(sessionId: String) -> Bool {
        return NIMSDK.shared().userManager.notify(forNewMsg: sessionId)
    }

    func isTop(session: NIMSession) -> Bool {
//        let recent: NIMRecentSession? = NIMSDK.shared().conversationManager.recentSession(by: session)
        return false
    }
    
    @objc func refreshRemarkName () {
        sessionCardTable.reloadData()
    }

    @objc func onActionNeedNotifyValueChange(_ sender: UISwitch) {
        SVProgressHUD.show(withStatus: NSLocalizedString("loading", comment: ""))
        NIMSDK.shared().userManager.updateNotifyState(!sender.isOn, forUser: self.sessionId) { [weak self](error) in
            guard let strongself = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if(error != nil) {
                    strongself.view.makeToast(NSLocalizedString("operation_failed", comment: ""), duration: 2, position: CSToastPositionCenter)
                    strongself.sessionCardTable.reloadData()
                }
            }
        }
    }

    @objc func onActionNeedTopValueChange(_ sender: UISwitch) {
//        let recent: NIMRecentSession? = NIMSDK.shared().conversationManager.recentSession(by: self.session)
//        if(sender.isOn) {
//            if(recent == nil) {
//                NIMSDK.shared().conversationManager.addEmptyRecentSession(by: self.session)
//            }
//            NTESSessionUtil.addRecentSessionMark(self.session, type: .top)
//        } else {
//            if(recent != nil) {
//                NTESSessionUtil.removeRecentSessionMark(self.session, type: .top)
//            }
//        }
    }

    func onActionClearMessage() {
        let removeRecentSession: Bool = UserDefaults.standard.bool(forKey: "enabled_remove_recent_session")
        let removeTable: Bool = UserDefaults.standard.bool(forKey: "enabled_drop_msg_table")
        
//        let deleteOption = NIMDeleteMessagesOption()
//                deleteOption.removeSession = removeRecentSession
//                deleteOption.removeTable = removeTable
//        DispatchQueue.main.async {
//            NIMSDK.shared().conversationManager.deleteAllmessages(in: self.session, option: deleteOption)
//            self.clearMessageCall?()
//        }
        let deleteOption = NIMSessionDeleteAllRemoteMessagesOptions()
        deleteOption.removeOtherClients = false
        NIMSDK.shared().conversationManager.deleteAllRemoteMessages(in: self.session, options: deleteOption) { error in
            DispatchQueue.main.async {
                self.clearMessageCall?()
            }
        }
    }

    @objc func onAvatarClick(_ sender: UIImageView) {
        DependencyContainer.shared.resolveUtilityFactory().getUserID(username: sessionId) { (uid) in
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: uid, username: self.sessionId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//            let vc = DependencyContainer.shared.resolveViewControllerFactory().makeUserHomepageViewController(userId: uid, userName: self.sessionId)
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    @objc func onInviteTap() {
        presentMemberSelector { [weak self] (members) in
            guard let strongself = self else { return }
            let uid = NIMSDK.shared().loginManager.currentAccount()
            let uids = [uid, strongself.sessionId] + members.compactMap { $0.userName }

            let createGroupController = DependencyContainer.shared.resolveViewControllerFactory().makeCreateGroupViewController(member: uids, completion: { (teamId) in
                strongself.navigationController?.popViewController(animated: false)
                let session = NIMSession(teamId as String, type: .team)
                let vc = IMChatViewController(session: session, unread: 0)
                let teamObject = NIMSDK.shared().teamManager.team(byId: teamId as String)
                do {
                    let message = IMSessionMsgConverter.shared.msgWithTip(tip: String(format: "%@ %@", (teamObject?.teamName ?? "new_group".localized),"created".localized))
                    
                    try NIMSDK.shared().chatManager.send(message!, to: session)
                    
                } catch {
                    assert(false, "Send group created message failed!")
                }
                strongself.navigationController?.pushViewController(vc, animated: true)
            })
            strongself.navigationController?.pushViewController(createGroupController, animated: true)
        }
    }

    func presentMemberSelector(block: @escaping (([ContactData]) -> Void)) {
        let config = ContactsPickerConfig.selectFriendBasicConfig([sessionId])
        
        let contactsPickerVC = ContactsPickerViewController(configuration: config, finishClosure: block)
        contactsPickerVC.isP2PInvite = true
        
        //contactPicker = DependencyContainer.shared.resolveViewControllerFactory().makeContactPicker(configuration: config, completion: block)
        
        self.navigationController?.pushViewController(contactsPickerVC, animated: true)
    }

}

extension ChatDetailViewController: UITableViewDelegate, UITableViewDataSource {

    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 0
        case 1:
            return 2
        case 2:
            return 3
        case 3:
            return 1
        default:
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sessionCardCellIdentifier, for: indexPath) as! ChatDetailTableViewCell
        let isTop = self.isTop(session: self.session)
        let needNotify = self.needNotify(sessionId: self.session.sessionId)
        let section = indexPath.section
        let row = indexPath.row
       
        switch section {
        case 0:
            break
        case 1:
            if row == 0 {
                cell.configure(title: NSLocalizedString("photo_video_files", comment: ""))
                cell.accessoryType = .disclosureIndicator
                cell.switcher.makeHidden()
            } else {
                cell.configure(title: NSLocalizedString("chatinfo_search_message", comment: ""))
                cell.accessoryType = .disclosureIndicator
                cell.switcher.makeHidden()
            }
            cell.cellTitle.textColor = .black
            break
        case 2:
             if(row == 0) {
                 cell.configure(title: NSLocalizedString("chat_wallpaper", comment: ""))
                 cell.accessoryType = .none
                 cell.switcher.makeHidden()
             } else if(row == 1) {
                cell.configure(title: NSLocalizedString("chatinfo_mute_notification", comment: ""))
                cell.selectionStyle = .none
                if(!needNotify) {
                    cell.switcher.setOn(true, animated: false)
                } else {
                    cell.switcher.setOn(false, animated: false)
                }
                cell.switcher.addTarget(self, action: #selector(onActionNeedNotifyValueChange(_:)), for: .valueChanged)
            } else if(row == 2) {
                cell.configure(title: NSLocalizedString("chatinfo_set_chat_on_top", comment: ""))
                if(isTop) {
                    cell.switcher.setOn(true, animated: false)
                } else {
                    cell.switcher.setOn(false, animated: false)
                }
                cell.switcher.addTarget(self, action: #selector(onActionNeedTopValueChange(_:)), for: .valueChanged)
            }
            cell.cellTitle.textColor = .black
            break
        case 3:
            cell.configure(title: NSLocalizedString("chatinfo_clear_chat", comment: ""))
            cell.accessoryType = .none
            cell.switcher.makeHidden()
            cell.cellTitle.textColor = .red
            break
        default:
            break
        }
    
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        let section = indexPath.section
//        let row = indexPath.row
//        
//        switch section {
//        case 0:
//            break
//        case 1:
//            if row == 0 {
//                let viewController = DependencyContainer.shared.resolveViewControllerFactory().makeChatMediaViewController(sessionId: self.sessionId, type: 0)
//                self.navigationController?.pushViewController(viewController, animated: true)
//
//            } else {
//                
//                let vc = IMSessionLocalHistoryViewController(session: self.session)
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            break
//        case 2:
//            if(row == 0) {
//                let vc: IMChatWallpaperViewController = IMChatWallpaperViewController()
//                self.navigationController?.pushViewController(vc, animated: true)
//             }
//            break
//        case 3:
//            let alert = UIAlertController(title: NSLocalizedString("confirm_delete_record", comment: ""), message: nil, preferredStyle: .alert)
//            let confirm = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .destructive) { [weak self] _ in
//                guard let strongself = self else { return }
//                strongself.onActionClearMessage()
//            }
//            let cancel = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: nil)
//            alert.addAction(confirm)
//            alert.addAction(cancel)
//            self.present(alert, animated: true, completion: nil)
//            break
//        default:
//            break
//        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(section == 0) {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: sessionHeaderIdentifier) as! ChatDetailHeaderView

            header.configure(session: self.session)
            let tap = UITapGestureRecognizer(target: self, action: #selector(onAvatarClick(_:)))
            header.avatar.addGestureRecognizer(tap)
            header.inviteHandler = {
                self.onInviteTap()
            }
            return header
        }
        return nil
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0) {
            return 100
        }

        return 25
    }
}
