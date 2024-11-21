//
//  MeetNewUserChatViewController.swift
//  Yippi
//
//  Created by Tinnolab on 19/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//
import UIKit
import SnapKit

import Combine

class MeetNewUserChatViewController: ChatViewController {
    
//    private var cancellables = Set<AnyCancellable>()
//    private var chatroom: NIMChatroom
//    private var targetUser: ChatroomMemberItem
//
//    private var targetUserInfo = AvatarInfo()
//    
//    lazy var tipView: UIView = {
//        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 36)))
//        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
//        view.roundCorner(10)
//        return view
//    }()
//        
//    lazy var tipLabel: UILabel = {
//        let infoLbl = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 14)))
//        infoLbl.font = UIFont.systemFont(ofSize: 14.0)
//        infoLbl.textColor = UIColor(white: 1.0, alpha: 0.85)
//        infoLbl.text = "meet_user_request_accept_tip".localized
//        infoLbl.textAlignment = .center
//        infoLbl.numberOfLines = 1
//        return infoLbl
//    }()
//        
//    init(chatroom: NIMChatroom, targetUser: ChatroomMemberItem) {
//        self.chatroom = chatroom
//        self.targetUser = targetUser
//        super.init(session: NIMSession(chatroom.roomId.orEmpty, type: .chatroom), unread: 0)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.title = targetUser.nick
//        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"), style: .plain, target: self, action: #selector(backItemClick))
//        
//        bottomInfoView.backgroundColor = UIColor(red: 249, green: 249, blue: 249)
//        infoLabel.text = "meet_user_cant_message_tip".localized
//        infoLabel.font = UIFont.systemFont(ofSize: 12)
//        infoLabel.textColor = AppTheme.brownGrey
//        
//        targetUserInfo.avatarPlaceholderType = .unknown
//        targetUserInfo.avatarURL = targetUser.avatarUrl
//        targetUserInfo.verifiedIcon = targetUser.certUrl.orEmpty
//        targetUserInfo.verifiedType = "badge"
//        
//        loadData()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        NIMSDK.shared().chatManager.add(self)
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NIMSDK.shared().chatManager.remove(self)
//    }
//    
//    @objc private func backItemClick() {
//        self.exitChatroom()
//        
//        if self.chatroom.creator == CurrentUserSessionInfo?.username {
//            self.closeChatroom()
//                .receive(on: DispatchQueue.main)
//                .sink(receiveCompletion: { _ in
//                    self.navigationController?.popViewController(animated: true)
//                }, receiveValue: { response in
//                    self.navigationController?.popViewController(animated: true)
//                }).store(in: &cancellables)
//        }
//    }
//    
//    private func exitChatroom() {
//        NIMSDK.shared().chatroomManager.exitChatroom(chatroom.roomId.orEmpty, completion: nil)
//    }
//    
//    private func closeChatroom() -> Future<Bool?, Error> {
//        let networkManager = ChatroomNetworkManager()
//        
//        return Future() { [weak self] promise in
//            guard let self = self else { return }
//            networkManager.closeRooom(roomId: self.chatroom.roomId.orEmpty, operatorName: NIMSDK.shared().loginManager.currentAccount())
//                .sink(receiveCompletion: { completion in
//                    switch completion {
//                    case .failure(let error):
//                        promise(.failure(error))
//                    case .finished: break
//                    }
//                    
//                }, receiveValue: { response in
//                    promise(.success(true))
//                }).store(in: &self.cancellables)
//        }
//        
//    }
//    
//    override func setupUI() {
//        
//        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        
//        tableview.backgroundColor = UIColor(red: 243, green: 244, blue: 245)
//        
//        let stackView = UIStackView().configure { (stack) in
//            stack.axis = .vertical
//            stack.spacing = 0
//            stack.distribution = .fill
//            stack.alignment = .fill
//        }
//        bottomInfoView.addSubview(infoLabel)
//        stackView.addArrangedSubview(tableview)
//        stackView.addArrangedSubview(bottomInfoView)
//        stackView.addArrangedSubview(chatInputView)
//        self.view.addSubview(stackView)
//        stackView.snp.makeConstraints {(make) in
//            make.bottom.equalTo(self.view)
//            make.top.left.right.equalTo(self.view)
//        }
//        infoLabel.snp.makeConstraints { make in
//            make.left.right.equalToSuperview().inset(38)
//            make.top.bottom.equalToSuperview().inset(12)
//        }
//        chatInputView.snp.makeConstraints { make in
//            make.bottom.equalTo(self.view).inset(TSBottomSafeAreaHeight)
//            make.height.equalTo(52)
//        }
//        
//        self.view.addSubview(tipView)
//        tipView.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().inset(72 + TSBottomSafeAreaHeight)
//            make.centerX.equalToSuperview()
//        }
//        tipView.addSubview(tipLabel)
//        tipLabel.snp.makeConstraints { make in
//            make.top.bottom.equalToSuperview().inset(8)
//            make.left.right.equalToSuperview().inset(14)
//        }
//        tipView.isHidden = true
//        bottomInfoView.isHidden = true
//        self.setUpInputView()
//    }
//    
//    private func showTip() {
//        tipView.isHidden = false
//        self.perform(#selector(hideTip), afterDelay: 3)
//    }
//    
//    @objc private func hideTip() {
//        tipView.isHidden = true
//    }
//    
//    func requestUserProfile(with username: String) {
//        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [username], complete: { [weak self] (userModel, _, _) in
//            guard let userInfo = userModel?.first else { return }
//            DispatchQueue.main.async {
//                let vc = HomePageViewController(userId: userInfo.userIdentity)
//                self?.navigationController?.pushViewController(vc, animated: true)
//            }
//        })
//    }
//    
//    override func makeDataSource() -> ChatDataSource {
//        return ChatDataSource(tableView: tableview) { tableView, indexPath, _ in
//            let message = MeetNewUserChatManager.shared.messageList[indexPath.row]
//
//            switch message.type {
//            case .tip:
//                let cell = tableView.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
//                cell.tipLabel.text = message.infoString!
//                return cell
//            case .outgoing, .incoming:
//                let cell = tableView.dequeueReusableCell(withIdentifier: BaseMessageCell.cellIdentifier) as! BaseMessageCell
//                let content = MeetNewUserTextMessageContentView(messageModel: message)
//                cell.dataUpdate(contentView:content, messageModel: message)
//                cell.showUserProfile = { [weak self] username in
//                    guard let username = username else { return }
//                    self?.requestUserProfile(with: username)
//                }
//                cell.resendMessage = { [weak self] message in
//                    if let messageModel = message.nimMessageModel {
//                        self?.retryMessage(messageModel)
//                    }
//                }
//                return cell
//            case .headerTip:
//                let cell = tableView.dequeueReusableCell(withIdentifier: MeetNewUserInfoTipsCell.cellIdentifier) as! MeetNewUserInfoTipsCell
//                cell.updateData(userId: self.targetUser.id, userInfo: self.targetUserInfo)
//                cell.showUserProfile = { [weak self] username in
//                    guard let username = username else { return }
//                    self?.requestUserProfile(with: username)
//                }
//                return cell
//            case .time:
//                return UITableViewCell()
//            }
//        }
//    }
//    
//    private func loadData() {
//        var snapshot = dataSource.snapshot()
//        snapshot.appendSections([0])
//        dataSource.defaultRowAnimation = .top
//        dataSource.apply(snapshot, animatingDifferences: false) {
//            self.scrollToBottom()
//        }
//    }
//}
//    
//extension MeetNewUserChatViewController {
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 40 {
//            isAutoScrollEnabled = true
//        } else {
//            isAutoScrollEnabled = false
//        }
//    }
//}
//
//extension MeetNewUserChatViewController {
//    
//    /// 传送普通信息
//    func sendMessage(text: String) {
//        let avatarUrl = (CurrentUserSessionInfo?.avatarUrl).orEmpty
//        
//        do {
//            if let message = IMSessionMsgConverter.msg(withText: text) {
//                message.remoteExt = ["avatar":avatarUrl, "badge_url": (CurrentUserSessionInfo?.verificationIcon).orEmpty, "nickname": (CurrentUserSessionInfo?.name).orEmpty]
//                try NIMSDK.shared().chatManager.send(message, to: self.session)
//            }
//        }
//        catch {
//            LogManager.Log(error.localizedDescription, loggingType: .exception)
//        }
//    }
//    
//    func retryMessage(_ message: NIMMessage) {
//        if (message.isReceivedMsg) {
//            do {
//                try NIMSDK.shared().chatManager.fetchMessageAttachment(message)
//            } catch {
//                LogManager.Log(error.localizedDescription, loggingType: .exception)
//            }
//        } else {
//            do {
//                try NIMSDK.shared().chatManager.resend(message)
//            } catch {
//                LogManager.Log(error.localizedDescription, loggingType: .exception)
//            }
//        }
//    }
//    
//    override func onSendText(_ text: String?, atUsers: [Any]?) -> Void {
//        guard let content = text else { return }
//        self.sendMessage(text: content)
//    }
//}
//
//extension MeetNewUserChatViewController: NIMChatManagerDelegate {
//    func willSend(_ message: NIMMessage) {
//        guard message.session?.sessionId == chatroom.roomId && message.session?.sessionType == .chatroom else {
//            return
//        }
//        let data = MessageData(message)
//        add([data])
//        scrollToBottom()
//    }
//    
//    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
//        guard message.session?.sessionId == chatroom.roomId && message.session?.sessionType == .chatroom else {
//            return
//        }
//        self.update(message)
//    }
//
//    func onRecvMessages(_ messages: [NIMMessage]) {
//        
//        messages.forEach { message in
//            guard message.session?.sessionId == chatroom.roomId && message.session?.sessionType == .chatroom else {
//                return
//            }
//            
//            switch message.messageType {
//            case .notification:
//                if let object: NIMNotificationObject = message.messageObject as? NIMNotificationObject,
//                    let content: NIMChatroomNotificationContent = object.content as? NIMChatroomNotificationContent,
//                    let _ = content.source?.userId {
//                    
//                    switch content.eventType {
//                    case NIMChatroomEventType.enter:
//                        showTip()
//                        break
//                    case .exit:
//
//                        if let json = content.notifyExt,
//                        let ext = RoomExtModel.decode(jsonData: json) {
//                            print(ext.nickname.orEmpty)
//                        }
//                        
//                        if let nickname = content.source?.nick {
//                            self.add([MessageData(type: .tip, infoString: String(format: "meet_user_left".localized, nickname))])
//                        }
//
//                        bottomInfoView.isHidden = false
//                        chatInputView.isHidden = true
//                        sessionInputView.endEditing(true)
//                        break
//                    default:  break
//                    }
//                }
//                break
//            case .custom: break
//            default:
//                add([MessageData(message)])
//                break
//            }
//        }
//    }
}
