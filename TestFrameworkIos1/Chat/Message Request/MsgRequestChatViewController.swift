//
//  MsgRequestChatViewController.swift
//  Yippi
//
//  Created by Tinnolab on 22/08/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit

import Reachability
import Alamofire
//import NIMPrivate
import NIMSDK
import InputBarAccessoryView
import SnapKit


class MsgRequestChatViewController: TSViewController {
    @IBOutlet weak var internetStatusVw: UIView!
    @IBOutlet weak var internetStatusLbl: UILabel!
    @IBOutlet weak var topInfoVw: UIView!
    @IBOutlet weak var topInfoLbl: UILabel!
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var detailsLbl: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    @IBOutlet weak var blockBtn: UIButton!
    
    @IBOutlet weak var chatTableView: TSTableView!
    @IBOutlet weak var bottomInfoLabel: UILabel!
    
    @IBOutlet weak var chatInputView: UIView!
    
    @IBOutlet weak var inputViewHeight: NSLayoutConstraint!
    
    let msgRequestInputConfig = MessageRequestChatConfig()
    
    private var hideKeyboardGesture: UITapGestureRecognizer!
    var userInfo: UserInfoModel?
    var messageInfo: MessageRequestModel?
    
    var toUserId: Int!
    var hadUnread: Bool = false
    
    // By Kit Foong (refresh Request Table List)
    var refreshList: (() -> Void)?
    
    private var currentInputHeight: CGFloat = 0.0
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    let inputBar: MsgRequestInputBarView = MsgRequestInputBarView()
    private var keyboardManager = KeyboardManager()
    private var keyboardHeight:CGFloat = 0
    private var stickerContainerView: InputEmoticonContainerView?
    private var moreContainerView: InputMoreContainerView?
    
    /// The object that manages autocomplete
    open lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.inputViewSetup()
        self.tableRefresh(scrollToBottom: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserver()
        helperCallback()
        defaultDataSetup()
        defaultUISetup()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        markMessageRead()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObserver()
    }
    
    private func defaultDataSetup() {
        if let messageInfo = self.messageInfo {
            if messageInfo.fromUserID == CurrentUserSessionInfo?.userIdentity {
                toUserId = messageInfo.toUserID
                userInfo = UserInfoModel.retrieveUser(userId: toUserId)
                topView.isHidden = true
            } else {
                toUserId = messageInfo.fromUserID
                userInfo = messageInfo.user
                topView.isHidden = false
            }
            hadUnread = (messageInfo.messageDetail?.isRead == 0)
            ChatMessageManager.shared.setToUserId(toUserId:toUserId, requestId: messageInfo.requestID)
            ChatMessageManager.shared.getChatHistory(id: messageInfo.messageDetail?.id)
            
        } else {
            toUserId = userInfo?.userIdentity
            topView.isHidden = true
            hadUnread = false
            ChatMessageManager.shared.setToUserId(toUserId:toUserId, requestId: nil)
            ChatMessageManager.shared.getChatHistory(id: nil)
        }
        
        ChatMessageManager.shared.delegate = self
    }
    
    private func defaultUISetup() {
        let userName = userInfo?.name ?? ""
        
        self.title = userName
        
        self.titleLbl.text = String(format: "send_request_title".localized, userName)
        self.detailsLbl.text = String(format: "send_request_detail".localized, userName)
        
        chatTableView.delegate = self
        chatTableView.dataSource = self
        LoadingView.share.delegate = self
        
        chatTableView.register(IncomingChatTableViewCell.nib(), forCellReuseIdentifier: IncomingChatTableViewCell.cellReuseIdentifier)
        chatTableView.register(OutgoingChatTableViewCell.nib(), forCellReuseIdentifier: OutgoingChatTableViewCell.cellReuseIdentifier)
        chatTableView.register(TipsTableViewCell.nib(), forCellReuseIdentifier: TipsTableViewCell.cellReuseIdentifier)
        
        chatTableView.estimatedRowHeight = 85
        
        chatTableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        chatTableView.mj_footer = nil
        
        titleLbl.font = UIFont.boldSystemFont(ofSize: YPCustomizer.FontSize.normal)
        detailsLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal)
        detailsLbl.textColor = UIColor.lightGray
        
        followBtn.setTitleColor(AppTheme.red, for: .normal)
        followBtn.set(font: UIFont.boldSystemFont(ofSize: YPCustomizer.FontSize.normal))
        followBtn.setImage(UIImage.set_image(named: "icProfileFollow")?.withRenderingMode(.alwaysTemplate), for: .normal)
        followBtn.tintColor = AppTheme.red
        
        blockBtn.set(font: UIFont.systemFont(ofSize: YPCustomizer.FontSize.normal))
        
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        internetStatusLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.small)
        internetStatusLbl.numberOfLines = 0
        internetStatusLbl.lineBreakMode = .byWordWrapping
        internetStatusLbl.textAlignment = .center
        internetStatusLbl.textColor = UIColor.white
        internetStatusLbl.text = "net_broken".localized
        internetStatusVw.backgroundColor = UIColor.red
        internetStatusVw.isHidden = self.isConnected()
        
        topInfoLbl.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.small)
        topInfoLbl.numberOfLines = 0
        topInfoLbl.lineBreakMode = .byWordWrapping
        topInfoLbl.textAlignment = .center
        topInfoLbl.textColor = UIColor.black
        topInfoLbl.text = ""
        topInfoVw.backgroundColor = UIColor.clear
        topInfoVw.isHidden = true
        
        bottomInfoLabel.font = UIFont.systemFont(ofSize: YPCustomizer.FontSize.verySmall)
        bottomInfoLabel.textColor = UIColor.red
        bottomInfoLabel.text = "be_friend_tip".localized
    }
    
    private func inputViewSetup () {
        inputBar.inputTextView.keyboardType = .default
        inputBar.delegate = self
        //inputBar.inputDelegate = self
        inputBar.inputTextView.delegate = self
        
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body),.foregroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 1),.backgroundColor: UIColor(red: 0, green: 122/255, blue: 1, alpha: 0.1)])
        autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
        
        inputBar.inputPlugins = [autocompleteManager]
        view.addSubview(inputBar)
        
        // Binding the inputBar will set the needed callback actions to position the inputBar on top of the keyboard
        keyboardManager.bind(inputAccessoryView: inputBar)
        // Binding to the tableView will enabled interactive dismissal
        keyboardManager.bind(to: chatTableView)
        
        // Add some extra handling to manage content inset
        keyboardManager.on(event: .didChangeFrame) { [weak self] (notification) in
            guard let self = self else { return }
            let barHeight = self.inputBar.bounds.height ?? 0
            self.chatTableView.contentInset.bottom = barHeight + notification.endFrame.height
            self.chatTableView.scrollIndicatorInsets.bottom = barHeight + notification.endFrame.height
        }.on(event: .didHide) { [weak self] _ in
            guard let self = self else { return }
            let barHeight = self.inputBar.bounds.height ?? 0
            self.chatTableView.contentInset.bottom = barHeight
            self.chatTableView.scrollIndicatorInsets.bottom = barHeight
        }
    }
    
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: Notification.Name.reachabilityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.menuDidHide), name: UIMenuController.didHideMenuNotification, object: nil)
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func helperCallback() {
        ChatMessageManager.shared.onMessageListRefresh = { scrollToBottom in
            self.tableRefresh(scrollToBottom: scrollToBottom, true)
        }
        
        ChatMessageManager.shared.onNoMoreMessageToRefresh = {
            DispatchQueue.main.async {
                self.chatTableView.mj_header.endRefreshing()
                
                self.topInfoLbl.textColor = UIColor.black
                self.topInfoLbl.text = "no_previous_message".localized
                self.topInfoVw.backgroundColor = UIColor.white
                self.topInfoVw.isHidden = false
                self.perform(#selector(self.hideTopInfoView), afterDelay: 2)
            }
        }
        
        ChatMessageManager.shared.onGetMessagesFailed = {
            DispatchQueue.main.async {
                self.chatTableView.mj_header.endRefreshing()
            }
        }
    }
    
    @objc private func hideTopInfoView() {
        topInfoVw.isHidden = true
    }
    
    //MARK: - menu controller
    @objc private func menuDidHide() {
        UIMenuController.shared.menuItems = nil
    }
    
    private func menusItems(message:MessageItem) -> [UIMenuItem] {
        ChatMessageManager.shared.messageForMenu = message
        
        var items: [UIMenuItem] = []
        let copyMsg = UIMenuItem(title: "longclick_msg_copy".localized, action: #selector(copyMessage))
        items.append(copyMsg)
        return items
    }
    
    @objc func copyMessage() {
        guard let message = ChatMessageManager.shared.messageForMenu else { return }
        UIPasteboard.general.string = message.content
        ChatMessageManager.shared.messageForMenu = nil
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let items: [UIMenuItem] = UIMenuController.shared.menuItems ?? []
        for item in items {
            if action == item.action {
                return true
            }
        }
        return false
    }
    
    //MARK: - keyboard
    @objc private func hideKeyboard() {
        inputBar.inputTextView.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            
            if stickerContainerView != nil {
                stickerContainerView!.frame = CGRect(x: 0, y: UIScreen.main.bounds.height-keyboardHeight, width: self.view.width, height: keyboardHeight)
                stickerContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
                let windowCount = UIApplication.shared.windows.count
                UIApplication.shared.windows[windowCount-1].addSubview(stickerContainerView!);
            }
            
            if moreContainerView != nil {
                moreContainerView = InputMoreContainerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-keyboardHeight, width: self.view.width, height: keyboardHeight))
                moreContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
                let windowCount = UIApplication.shared.windows.count
                UIApplication.shared.windows[windowCount-1].addSubview(moreContainerView!);
            }
        }
        
        animateWithKeyboard(notification: notification) { (keyboardFrame) in
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
        }
        
        self.view.addGestureRecognizer(hideKeyboardGesture)
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        self.view.removeGestureRecognizer(hideKeyboardGesture)
        
        animateWithKeyboard(notification: notification) { (keyboardFrame) in
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
        }
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        animateWithKeyboard(notification: notification) { (keyboardFrame) in
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
        }
    }
    
    private func tableRefresh(scrollToBottom: Bool, _ animate: Bool? = nil) {
        DispatchQueue.main.async {
            self.chatTableView.mj_header.endRefreshing()
            self.chatTableView.reloadData()
            if scrollToBottom {
                self.scrollToBottom(animate: animate ?? false)
            }
        }
    }
    
    private func scrollToBottom(animate: Bool) {
        let row = (self.chatTableView.numberOfRows(inSection: 0) - 1)
        
        if row > 0 {
            let indexPath:IndexPath = IndexPath(row: row, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: animate)
        }
    }
    
    //MARK: - button actions
    
    @IBAction func followButtonClicked(_ sender: UIButton) {
        self.loading()
        self.addFriend()
    }
    
    @IBAction func blockButtonClicked(_ sender: UIButton) {
        self.inputBar.resignFirstResponder()
        
        let alert = TSAlertController(title: nil, message: "add_blacklist_warning".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
        alert.addAction(TSAlertAction(title: "add_to_black_list".localized, style: TSAlertSheetActionStyle.theme, handler: { _ in
            self.blacklistUser()
        }))
        
        self.presentPopup(alert: alert)
    }
}

//MARK: - Internet
extension MsgRequestChatViewController {
    @objc private func reachabilityChanged(note: NSNotification) {
        guard let reachability = note.object as? Reachability else {
            return
        }
        
        internetStatusVw.isHidden = reachability.currentReachabilityStatus() != .ReachableViaWWAN && reachability.currentReachabilityStatus() != .ReachableViaWiFi
    }
    
    private func isConnected() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

//MARK: - Web Service
extension MsgRequestChatViewController {
    private func addFriend() {
        MessageRequestNetworkManager().addFriend(id: toUserId, complete: {
            DispatchQueue.main.async {
                self.endLoading()
                
                if let requestID = self.messageInfo?.requestID {
                    ChatMessageManager.shared.deleteChatHistory(requestId: requestID, userId: self.toUserId)
                }
                // By Kit Foong (will perform refresh function when back to previous view)
                self.navigationController?.popViewController(animated: true, completion: {
                    if let refreshList = self.refreshList {
                        refreshList()
                    }
                })
            }
        })
    }
    
    private func markMessageRead() {
        guard let messageId = messageInfo?.messageDetail?.id else { return }
        MessageRequestNetworkManager().markMessageRead(messageId: messageId, complete: {})
    }
    
    private func sendMessage(content: String) {
        if content.trimmingCharacters(in: .whitespaces).isEmpty {return}
        let id = Int.random(in: 0 ... 999999)
        ChatMessageManager.shared.addNewMessage(id: id, content: content)
        
        MessageRequestNetworkManager().sendMessage(id: toUserId, content: content, complete: { (status, model, isBlock) in
            if status {
                guard let msgModel = model else { return }
                ChatMessageManager.shared.updateMessageList(id: id, messageModel: msgModel)
            } else {
                ChatMessageManager.shared.updateFailedPendingMessage(id: id, isBlock: isBlock)
            }
            self.tableRefresh(scrollToBottom: true, true)
        })
    }
    
    private func blacklistUser() {
        MessageRequestNetworkManager().blacklistFriend(id: toUserId, complete: {(status) in
            if status {
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true, completion: {
                        // By Kit Foong (will perform refresh function when back to previous view)
                        if let refreshList = self.refreshList {
                            refreshList()
                        }
                    })
                }
            }
        })
    }
}

//MARK: - Emoticon
extension MsgRequestChatViewController {
    func showEmoticonContainer() {
        if stickerContainerView == nil {
            stickerContainerView = InputEmoticonContainerView(frame: CGRect(x: 0, y:  UIScreen.main.bounds.height-keyboardHeight, width: self.view.width, height: keyboardHeight))
            stickerContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
            stickerContainerView!.delegate = self
            let windowCount = UIApplication.shared.windows.count
            UIApplication.shared.windows[windowCount-1].addSubview(stickerContainerView!);
        } else if stickerContainerView!.isHidden || (moreContainerView?.isHidden ?? false) == false {
            self.stickerContainerView?.isHidden = false
            self.moreContainerView?.isHidden = true
            self.inputBar.inputTextView.becomeFirstResponder()
        } else {
            self.stickerContainerView?.isHidden = true
        }
    }
    
    func showmMoreContainer() {
        if moreContainerView == nil {
            moreContainerView = InputMoreContainerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-keyboardHeight, width: self.view.width, height: keyboardHeight))
            
            moreContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
            moreContainerView!.actionDelegate = self
            //moreContainerView!.config = msgRequestInputConfig
            let windowCount = UIApplication.shared.windows.count
            UIApplication.shared.windows[windowCount-1].addSubview(moreContainerView!)
        } else if moreContainerView!.isHidden || (stickerContainerView?.isHidden ?? false) == false {
            self.moreContainerView?.isHidden = false
            self.stickerContainerView?.isHidden = true
            self.inputBar.inputTextView.becomeFirstResponder()
        } else {
            self.moreContainerView?.isHidden = true
        }
    }
    
    func animateWithKeyboard(notification: Notification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        
        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!
        
        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue.cgRectValue)
            
            // Required to trigger NSLayoutConstraint changes
            // to animate
            self.view?.layoutIfNeeded()
        }
        
        // Start the animation
        animator.startAnimation()
    }
    
    // On Tap
    func onTapMediaItemRedPacket () {
        
    }
}

//MARK: - LoadingViewDelegate
extension MsgRequestChatViewController {
    /// 点击了 loading view 上的重新加载按钮
    override func reloadingButtonTaped() {
        
    }
    /// 点击了返回
    override func loadingBackButtonTaped() {
        self.dismiss(animated: true)
    }
}

//MARK: - TSTable delegate
extension MsgRequestChatViewController {
    @objc func refresh() {
        ChatMessageManager.shared.loadMoreMessage()
    }
}

extension MsgRequestChatViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatMessageManager.shared.messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = ChatMessageManager.shared.messageList[indexPath.row]
        
        switch message.type {
        case .tip, .time:
            let cell = tableView.dequeueReusableCell(withIdentifier: TipsTableViewCell.cellReuseIdentifier) as! TipsTableViewCell
            cell.titleLbl.text = message.content
            return cell
        case .outgoing:
            let cell = tableView.dequeueReusableCell(withIdentifier: OutgoingChatTableViewCell.cellReuseIdentifier) as! OutgoingChatTableViewCell
            cell.cellUpdate(messageInfo: message)
            return cell
        case .incoming:
            let cell = tableView.dequeueReusableCell(withIdentifier: IncomingChatTableViewCell.cellReuseIdentifier) as! IncomingChatTableViewCell
            cell.cellUpdate(messageInfo: message)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let outgoingCell = cell as? OutgoingChatTableViewCell {
            outgoingCell.cellSetConstraints()
        } else if let incomingCell = cell as? IncomingChatTableViewCell{
            incomingCell.cellSetConstraints()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIMenuController.shared.setMenuVisible(false, animated: true)
    }
}

extension MsgRequestChatViewController: ChatMessageManagerDelegate {
    func onResendMessageClicked(_ sender: OutgoingChatTableViewCell) {
        guard let messageInfo = sender.messageItem else {
            if let index = self.chatTableView.indexPath(for: sender) {
                self.chatTableView.reloadRow(at: index, with: .none)
            }
            return
        }
        
        MessageRequestNetworkManager().sendMessage(id: toUserId, content: messageInfo.content, complete: { (status, model, isBlock) in
            if status {
                guard let msgModel = model else { return }
                ChatMessageManager.shared.updateMessageList(id: messageInfo.id, messageModel: msgModel)
                self.tableRefresh(scrollToBottom: true)
            } else {
                ChatMessageManager.shared.updateFailedPendingMessage(id: messageInfo.id, isBlock: isBlock)
                DispatchQueue.main.async {
                    if let index = self.chatTableView.indexPath(for: sender) {
                        if (isBlock ?? false) {
                            self.tableRefresh(scrollToBottom: true)
                        } else {
                            self.chatTableView.reloadRow(at: index, with: .none)
                        }
                    }
                }
            }
        })
    }
    
    func onMessageLongPress(_ messageItem: MessageItem, on cellView: UIView) {
        let menuItems = self.menusItems(message: messageItem)
        
        if menuItems.count > 0 && self.becomeFirstResponder() {
            let menuController = UIMenuController.shared
            menuController.menuItems = menuItems
            menuController.setTargetRect(cellView.bounds, in: cellView)
            menuController.setMenuVisible(true, animated: true)
        }
    }
}

//extension MsgRequestChatViewController: NIMInputDelegate {
//    
//}

extension MsgRequestChatViewController: CustomInputBarDelegate {
    func cameraTapped () {
        return
    }
    
    func imageTapped () {
//        if let home = self.tabBarController as? TSHomeTabBarController {
//            TSUtil.checkAuthorizeStatusByType(type: .album, viewController: home, completion: {
//                DispatchQueue.main.async {
//                    //self?.showCameraVC()
//                }
//            })
//        }
    }
    
    func attachmentTapped () {
        SendFileManager.instance.presentView(owner: self)
        weak var wself = self
        SendFileManager.instance.completion = { urls in
            for url in urls {
                var alert = TSAlertController(style: .alert)
                
                alert = TSAlertController(title: "im_send_confirmation".localized,
                                          message:  String(format: "text_send_confirmation_description".localized, url.lastPathComponent ?? "", "sessionTitle"),
                                          style: .alert, hideCloseButton: true, animateView: false)
                
                let dismissAction = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel) { (_) in
                    alert.dismiss()
                }
                
                //                if let message = message as? NIMMessage {
                //                    let alertAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { (_) in
                //                        delegate.sendPhoto(message)
                //                    }
                //                    alert.addAction(alertAction)
                //                } else {
                let alertAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { (_) in
                    //wself?.sendMessage(content: [])
                }
                alert.addAction(alertAction)
                //                }
                
                alert.addAction(dismissAction)
                
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func eggTapped () {}
    
    func moreTapped () {
        self.showmMoreContainer()
    }
    
    func emojiContainerTapped () {
        showEmoticonContainer()
    }
}

extension MsgRequestChatViewController: InputEmoticonProtocol {
    func didPressSend(_ sender: Any?) {
        
    }
    
    func didPressAdd(_ sender: Any?) {
        self.view.endEditing(true)
        self.stickerContainerView?.isHidden = true
        let vc = StickerMainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        
    }
    
    func sendEmoji(_ emojiTag: String?) {
        
    }
    
    func didPressMySticker(_ sender: Any?) {
        self.view.endEditing(true)
        self.stickerContainerView?.isHidden = true
        let vc = StickerMainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressCustomerSticker() {
        
    }
}

// MARK: Autocompletion
extension MsgRequestChatViewController : AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    func autocompleteManagerShouldChangeInCharacter(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        
    }
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        
    }
    
    // MARK: - AutocompleteManagerDataSource
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        return []
    }
    
    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldRegister prefix: String, at range: NSRange) -> Bool {
        return true
    }
    
    // Optional
    func autocompleteManager(_ manager: AutocompleteManager, shouldUnregister prefix: String) -> Bool {
        return true
    }
    
    func autocompleteManager(_ manager: AutocompleteManager, shouldComplete prefix: String, with text: String) -> Bool {
        return true
    }
}

extension MsgRequestChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if inputBar.inputTextView.text.isEmpty {
            //self.inputBar.configureHoldToTalk()
        } else {
            inputBar.inputTextView.text = String()
            self.sendMessage(content: text)
        }
    }
}

extension MsgRequestChatViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let i = String.Index(utf16Offset: range.location-1, in: textView.attributedText.string)
        
        let spaceCharacter = textView.attributedText.string[i]
        if spaceCharacter == " " {
            if text == "@" {
                // For SessionViewController
                /*
                 switch session.sessionType {
                 case .team:
                 
                 default:
                 
                 }
                 
                 */
                NIMSDK.shared().teamManager.fetchTeamMembers(fromServer: /* team.teamId ?? "" */ "1579863209") { (error, members) in
                    guard error == nil else {
                        return
                    }
                    
                    if let members = members {
                        var teamMembers = [String]()
                        
                        for member in members {
                            if member.userId != NIMSDK.shared().loginManager.currentAccount() {
                                teamMembers.append(member.userId!)
                            }
                        }
                        
                        let contactsPickerVC = ContactsPickerViewController(configuration: ContactsPickerConfig.mentionConfig(teamMembers), finishClosure: nil)
                        contactsPickerVC.modalPresentationStyle = .fullScreen
                        
                        contactsPickerVC.finishClosure = { [weak self] contacts in
                            guard let self = self else { return }
                            
                            for contact in contacts {
                                // self.inputBar.inputTextView.insertText(contact.userName)
                                guard let autoCompleteSession = AutocompleteSession(prefix: "@", range: NSRange(location: 0, length: 1), filter: nil) else { return }
                                
                                let autoComplete = AutocompleteCompletion(text: contact.userName)
                                autoCompleteSession.completion = autoComplete
                                self.autocompleteManager.autocomplete(with: autoCompleteSession)
                            }
                        }
                        
                        self.present(TSNavigationController(rootViewController: contactsPickerVC), animated: true, completion: nil)
                    }
                }
            }
        }
        
        return true
    }
}
