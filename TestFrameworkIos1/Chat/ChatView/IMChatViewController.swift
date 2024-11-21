//
//  IMChatViewController.swift
//  Yippi
//
//  Created by Tinnolab on 28/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import InputBarAccessoryView

import TZImagePickerController
import AVKit
import MobileCoreServices
import SVProgressHUD
import Toast
import Alamofire
import Photos
import IQKeyboardManagerSwift
import NEMeetingKit
import Combine
import NIMSDK
import iOSPhotoEditor
//import NIMPrivate


enum InputStauts: Int {
    case norma = 0
    case text
    case more
    case sticker
    case picture
    case file
    case local
}

class KeyInputView: UIView {
    override var canBecomeFirstResponder: Bool { return true }
    override var canResignFirstResponder: Bool { return true }
}

extension KeyInputView: UIKeyInput {
    var hasText: Bool { return false }
    func insertText(_ text: String) {}
    func deleteBackward() {}
}

let NIMInputAtStartChar = "@"
let NIMInputAtEndChar   = "\u{2004}"

class IMChatViewController: ChatViewController {
    
    private var userInfo: UserInfoModel? = nil
    
    let sessionConfig: IMChatViewConfig = IMChatViewConfig()
    private var firstScrollEnabled = false
    var firstScrollNo = true
    private var cachedContentHeight: CGFloat!
    var isSecretMessage = false
    var secretDuration: Int!
    var messageLimit: Int!
    var messageSearch = false
    let inputBar: CustomInputBar = CustomInputBar()
    private var keyboardManager = KeyboardManager()
    private var keyboardHeight:CGFloat = 0
    private var stickerContainerView: InputEmoticonContainerView?
    private var moreContainerView: InputMoreContainerView?
    private var localContainerView: InputLocalContainer?
    private var fileContainerView: InputFileContainer?
    private var pictrueContainerView: InputPictrueContainer?
    private var onClickedSticker = false
    private var onClickedContact = false
    private var onClickedEgg = false
    private var isRedPacket = false
    private var selectedMsgId: [String] = []
    private var isLeavedGroupUser = false {
        didSet {
            if isLeavedGroupUser {
                guard leaveGroupBottomView.superview == nil else {
                    return
                }
                self.view.addSubview(self.leaveGroupBottomView)
                leaveGroupBottomView.snp.makeConstraints {
                    $0.leading.bottom.trailing.equalToSuperview()
                }
            } else {
                leaveGroupBottomView.removeFromSuperview()
            }
        }
    }
    
    private var mentionsUsernames = [AutocompleteCompletion]()
    var teamMembers = [String]()
//    private var mediaFetcher = NIMKitMediaFetcher()
    private var messageForMenu: MessageData!
    
    private var eggAttachment: IMEggAttachment?
    private var isEggAttachmentOutgoing: Bool?
    //记录当前录制的语音
    private var saveAudioMessage: NIMMessage?
    //记录当前录制的语音文件地址
    private var saveAudioFilePath: String?
    //保存识别结果
    private var receiveResult = ""
    var whiteboardInvitedMembers = [String]()
    var notificaionSender = ChatCustomSysNotificationSender()
    var dependVC : UIViewController!
    var currentSingleSnapView: UIView!
    //input stauts
    var inputStauts: InputStauts = InputStauts(rawValue: 1)!
    var containerHeight: CGFloat = 0.0
    
    var disableCommandTyping: Bool = false //是否显示正在打字
    var titleTimer: TimerHolder?
    var searchMessageId: String = "" // 信息搜索ID
    var isScrollToBottom: Bool = true
    var isUnreadMessage: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    var interactionController: UIDocumentInteractionController!
    var isDownLoading: Bool! = false
    //是否私密会议
    var isPrivate: Bool = false
    
    lazy var shareButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "msg_select_forward"), for: .normal)
        button.addTarget(self, action: #selector(forwardMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var deleteButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "msg_select_delete"), for: .normal)
        button.addTarget(self, action: #selector(deleteMessages), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var selectedItem: UIButton = {
        let button = UIButton()
        button.setTitle("msg_number_of_selected".localized, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //button.tintColor = UIColor.black
        return button
    }()
    
    lazy var selectActionToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.tintColor = AppTheme.white
        toolbar.isTranslucent = false
        toolbar.isHidden = true
        return toolbar
    }()
    
    lazy var stackView = {
        UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 0
            stack.distribution = .fill
            stack.alignment = .fill
        }
    }()
    
    lazy var enterTeamCardBtn: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(enterTeamCard), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var enterInfoBtn: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "more")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(enterPersonInfoCard), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var videoCallBtn: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var teamMeetingBtn: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_call_plus")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var voiceCallBtn: UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        button.setImage(UIImage.set_image(named: "voiceCallTop")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.setImage(UIImage.set_image(named: "voiceCallTop")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        button.tintColor = UIColor(hex: 0x808080)
        button.addTarget(self, action: #selector(callActionSheet), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()
    
    lazy var cancelSelectionBtn: UIBarButtonItem = {
        let button = UIBarButtonItem(title: "cancel".localized, style: .done, target: self, action: #selector(cancelSelectMessage))
        button.tintColor = AppTheme.black
        return button
    }()
    
    lazy var headerAvatarView: AvatarView = {
        let view = AvatarView(type: .width26(showBorderLine: false))
        return view
    }()
    
    lazy var headerTitle: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.black
        label.font = UIFont.systemFont(ofSize: FontSize.chatroomMsgFontSize)
        label.numberOfLines = 1
        return label
    }()
    
    lazy var isTypingLabel: UILabel = {
        let label = UILabel()
        label.text = "text_typing_chat".localized
        label.textColor = AppTheme.black
        label.font = UIFont.systemFont(ofSize: 10)
        label.numberOfLines = 1
        label.isHidden = true
        return label
    }()
    
    lazy var headerTitleView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var scrollToBottomBtn: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "icon_scroll_to_bottom")
        image.isHidden = true
        return image
    }()
    
    lazy var scrollToUnreadView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: 50)))
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var unreadMsgLabel: UILabel = {
        let label = UILabel()
        label.text = "  " + String(self.unreadCount) + " " + "chatroom_unread_message".localized + "   "
        label.textColor = AppTheme.black
        label.font = UIFont.systemFont(ofSize: FontSize.defaultLocationDefaultFontSize)
        label.numberOfLines = 1
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var unreadMsgArrow: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "icon_scroll_to_bottom")
        image.isUserInteractionEnabled = false
        image.isHidden = true
        return image
    }()
    
    /// The object that manages autocomplete
    open lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.inputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        return manager
    }()
    
    lazy var eggOverlayView: RedPacketView = {
        let view = RedPacketView(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width, height: self.view.bounds.height)))
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.5)
        return view
    }()
    
    lazy var replyView: MessageReplyView = {
        let view = MessageReplyView()
        view.backgroundColor = AppTheme.inputContainerGrey
        view.closeBtn?.addTarget(self, action: #selector(stopReplyingMessage), for: .touchUpInside)
        view.isHidden = true
        return view
    }()
    
    lazy var nonfriendBottomView = NonFriendBottomView()
    lazy var leaveGroupBottomView = LeaveGroupBottomView()
    
    private var eggOverlayTapGesture : UITapGestureRecognizer!
    private var openEggTapGesture : UITapGestureRecognizer!
    
    var pauseTime: TimeInterval = 0.0
    var playTime: TimeInterval = 0.0
    var pendingAudioMessages: [NIMMessage]? = nil
    var myView: KeyInputView! { return KeyInputView() }
    
    var currentSelectedLangCode: SupportedLanguage?
    //置顶view
    var pinnedView: IMPinnedView?
    //被置顶的列表
    var pinnedList: [PinnedMessageModel] = []
    //当前的Pinned msg
    private var currentPinned: PinnedMessageModel?
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    //IM会议
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
    var meetingNum: String = ""
    var timer: TimerHolder?
    
    var roomUuid: Int = 0
    var timeView: UIView?
    var timeLabel:  UILabel?
    
    var pinnedAlert: TSAlertController?
    //白板房间id
    var whiteboardRoomId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // By Kit Foong (Used global variable to control message limit when got searchId)
        if self.searchMessageId.count > 0 {
            messageLimit = self.sessionConfig.messageSearchLimit() + self.unreadCount
        } else {
            messageLimit = self.sessionConfig.messageLimit() + self.unreadCount
        }
        if self.session.sessionType == .P2P {
            //同步云端好友信息到本地
            NIMSDK.shared().userManager.fetchUserInfos([self.session.sessionId])
        }
        NIMSDK.shared().chatManager.add(self)
        
        self.initSecretTimerImage()
//        self.mediaFetcher.limit = 9
//        let imageType = kUTTypeImage as String
//        let videoType = kUTTypeMovie as String
//        self.mediaFetcher.mediaTypes = [imageType, videoType]
        getTeamMembers()
        setupUI()
        self.titleViewSetup()
        loadMessages()
        if self.session.sessionType == .P2P && !NIMSDK.shared().userManager.isUser(inBlackList: self.session.sessionId) {
            titleTimer = TimerHolder()
            //NIMSDK.shared().systemNotificationManager.add(self)
        }
//        NIMSDK.shared().systemNotificationManager.add(self)
//        //删除最近会话列表中有人@你的标记
//        NTESSessionUtil.removeRecentSessionMark(self.session, type: .at)
//        NotificationCenter.default.addObserver(self, selector: #selector(updateFollowStatus(notice:)), name: NSNotification.Name(rawValue: "newChangeFollowStatus"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(whiteboardInvite(notice:)), name: NSNotification.Name(rawValue: "NTESWhiteboardInvite"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserInfo(_:)), name: Notification.Name.Chatroom.updateProfile, object: nil)
//        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBadge"), object: nil, userInfo: nil)
    }
    
    deinit {
        NIMSDK.shared().systemNotificationManager.remove(self)
        NIMSDK.shared().chatManager.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().conversationManager.add(self)
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
        self.setChatWallpaper()
        if NIMSDK.shared().teamManager.isMyTeam(self.session.sessionId) == false && self.session.sessionType == .team {
            self.isLeavedGroupUser = true
            self.inputBar.isHidden = true
        } else {
            self.isLeavedGroupUser = false
        }
        
        UserDefaults.enableFetchIMMessage = true
        
        if isRedPacket {
            isRedPacket = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.scrollToBottom()
            }
        }
        
        //会议
        if let service = NEMeetingKit.getInstance().getMeetingService() {
            service.add(self)
        } else {
            NIMSDKManager.shared.meetingKitConfig {
                NEMeetingKit.getInstance().getMeetingService()?.add(self)
            }
        }
        loadMessagePins()
        setupNav()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // By Kit Foong (Moved into loadMessage function)
        //        if self.searchMessageId.count > 0 && messageSearch == false {
        //            self.loadParticularMessage(messageId: searchMessageId, shouldScrollTo: true)
        //        }
    }
    
    @objc func appDidBecomeActive() {
        if let nimMessages = NIMSDK.shared().conversationManager.messages(in: self.session, message: nil, limit: messageLimit), nimMessages.count > 0 {
            self.readAllMessages(messages: nimMessages)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //关闭voiceToText
        PopupWindowManager.shared.changeKeyWindow(rootViewController: nil, height: keyboardHeight)
        IMAudioCenter.shared.currentMessage = nil
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        //NIMSDK.shared().chatManager.remove(self)
        NIMSDK.shared().mediaManager.remove(self)
        NIMSDK.shared().conversationManager.remove(self)
    
        NEMeetingKit.getInstance().getMeetingService()?.remove(self)
        self.inputStauts = .text
        //        inputBar.inputTextView.endEditing(true)
        //        view.endEditing(true)
        //        stickerContainerView?.isHidden = true
        //        moreContainerView?.isHidden = true
        //        localContainerView?.isHidden = true
        //        fileContainerView?.isHidden = true
        //        pictrueContainerView?.isHidden = true
        isScrollToBottom = false
        hideKeyboard()
        UserDefaults.enableFetchIMMessage = false
    }
    
    override func setupUI() {
        self.view = KeyInputView(frame: UIScreen.main.bounds)
        
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        bottomInfoView.addSubview(infoLabel)
        //stackView.addArrangedSubview(scrollToUnreadView)
        stackView.addArrangedSubview(tableview)
        self.view.addSubview(stackView)
        self.view.addSubview(scrollToUnreadView)
        stackView.snp.makeConstraints {(make) in
            make.bottom.equalTo(self.view)
            make.top.left.right.equalTo(self.view)
        }
        scrollToUnreadView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        scrollToUnreadView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        var outerView = UIView()
        outerView.backgroundColor = .clear
        
        eggOverlayTapGesture = UITapGestureRecognizer(target: self, action: #selector(closeEggView))
        eggOverlayView.addGestureRecognizer(eggOverlayTapGesture)
        
        openEggTapGesture = UITapGestureRecognizer(target: self, action: #selector(checkOpenEggStatus))
        eggOverlayView.openEggView.addGestureRecognizer(openEggTapGesture)
        
        self.inputViewSetup()
        //self.setChatWallpaper()
        self.scrollToBottomBtnSetup()
        self.unreadMsgViewSetup()
        self.view.addSubview(selectActionToolbar)
        selectActionToolbar.snp.makeConstraints { make in
            if TSUserInterfacePrinciples.share.hasNotch() {
                make.height.equalTo(64)
            }else{
                make.height.equalTo(50)
            }
            
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        self.view.addSubview(replyView)
        replyView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalToSuperview()
            make.bottom.equalTo(self.inputBar.snp.top)
        }
        
        self.view.addSubview(nonfriendBottomView)
        nonfriendBottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        nonfriendBottomView.makeHidden()
        nonfriendBottomView.messageRequestLabel.addAction { [weak self] in
            guard let self = self else { return }
            let vc = MsgRequestChatViewController()
            vc.userInfo = self.userInfo
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        self.view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
    }
    
    func getTeamMembers() {
        if self.session.sessionType == .P2P { return }
        
        NIMSDK.shared().teamManager.fetchTeamMembers(fromServer: self.session.sessionId) { [weak self] (error, members) in
            guard let self = self, let members = members, error == nil else { return }
            
            var memberIds = members.filter({ $0.userId != NIMSDK.shared().loginManager.currentAccount() }).map { $0.userId ?? "" }
            self.teamMembers = memberIds
        }
    }
    
    func getSpeechRecognizerAuthorizationStatus() {
        SpeechVoiceDetectManager.shared.getAuthorization { status in
            
        }
    }
    
    func setChatWallpaper() {
        let image = sessionConfig.sessionBackgroundImage()
        //tableview.backgroundColor = AppTheme.inputContainerGrey
        tableview.backgroundColor = AppTheme.white
        
        if image != nil {
            let cellBackgroundView = UIImageView(image: image)
            cellBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            cellBackgroundView.clipsToBounds = true
            cellBackgroundView.contentMode = .scaleAspectFill
            cellBackgroundView.frame = tableview.bounds
            
            tableview.backgroundView = cellBackgroundView
        } else {
            tableview.backgroundView = nil
        }
    }
    
    private func inputViewSetup () {
        inputBar.inputTextView.keyboardType = .default
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.delegate = self
        inputBar.inputDelegate = self
        inputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        inputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        inputBar.moreBtn.makeVisible()
        
        autocompleteManager.register(prefix: "@", with: [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: AppTheme.primaryColor, .backgroundColor: UIColor.clear])
        autocompleteManager.maxSpaceCountDuringCompletion = 10
        
        inputBar.inputPlugins = [autocompleteManager]
        view.addSubview(inputBar)
        
        // keyboardManager.bind(inputAccessoryView: inputBar)
        // Binding to the tableView will enabled interactive dismissal
        //keyboardManager.bind(to: stackView)
        self.inputBar.snp.makeConstraints({ make in
            make.left.right.bottom.equalTo(0)
        })
        
        self.view.layoutIfNeeded()
        
        let barHeight = self.inputBar.bounds.height
        var bottomHeight = self.bottomInfoView.height
        if !self.isSecretMessage {
            bottomHeight = 0
        }
        
        self.tableview.contentInset.bottom = barHeight + bottomHeight
        self.tableview.scrollIndicatorInsets.bottom = barHeight + bottomHeight
        
        self.view.addSubview(bottomInfoView)
        
        bottomInfoView.snp.makeConstraints {
            $0.bottom.equalTo(inputBar.snp.top)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
    
    override func hideKeyboard() {
        self.view.removeGestureRecognizer(hideKeyboardGesture)
        inputBar.inputTextView.resignFirstResponder()
        self.view.endEditing(true)
        //self.inputBar.hideBtn.isSelected = false
        self.inputStauts = .text
        
        self.inputBar.snp_remakeConstraints { make in
            make.left.right.equalTo(0)
            make.bottom.equalTo(0)
        }
        
        if isScrollToBottom {
            self.hiddenInput(isScrollToBottom: true)
        } else {
            isScrollToBottom = true
            self.hiddenInput(isScrollToBottom: false)
        }
    }
    
    func hiddenInput(isScrollToBottom: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            self.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            self.localContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            self.fileContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            self.pictrueContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            
            let barHeight = (self.inputBar.bounds.height ?? 0) > 98.5 ? 98.5 : (self.inputBar.bounds.height ?? 0)
            var bottomInfoHeight = self.bottomInfoView.height ?? 0
            if !self.isSecretMessage {
                bottomInfoHeight = 0
            }
            self.tableview.contentInset.bottom = barHeight  + bottomInfoHeight
            self.tableview.scrollIndicatorInsets.bottom = barHeight + bottomInfoHeight
            if isScrollToBottom{
                self.scrollToBottom()
            }
        } completion: { _ in
            self.stickerContainerView?.isHidden = true
            self.moreContainerView?.isHidden = true
            self.localContainerView?.isHidden = true
            self.fileContainerView?.isHidden = true
            self.pictrueContainerView?.isHidden = true
        }
    }
    
    override func keyboardWillShow(notification: Notification) {
        if self.inputBar.recordPhase == .converted {
            return
        }
        self.inputBar.ResetStickerImage()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            if self.inputStauts == .text || self.inputStauts == .more || self.inputStauts == .sticker || self.inputStauts == .local || self.inputStauts == .file || self.inputStauts == .picture {
                handleKeyboardLogic()
            }
            onClickedContact = false
        }
        
        animateWithKeyboard(notification: notification) { [weak self] (keyboardFrame) in
            guard let self = self else { return }
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.localContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.fileContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.pictrueContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            
            self.inputBar.snp_remakeConstraints { make in
                make.left.right.equalTo(0)
                make.bottom.equalTo(-keyboardFrame.height)
            }
            let barHeight = self.inputBar.bounds.height > 98.5 ? 98.5 : self.inputBar.bounds.height
            var bottomInfoHeight = self.bottomInfoView.height
            if !self.isSecretMessage {
                bottomInfoHeight = 0
            }
            self.tableview.contentInset.bottom = barHeight + keyboardFrame.height + bottomInfoHeight - TSBottomSafeAreaHeight
            self.tableview.scrollIndicatorInsets.bottom = barHeight + keyboardFrame.height + bottomInfoHeight - TSBottomSafeAreaHeight
            self.scrollToBottom()
            self.view.layoutIfNeeded()
        }
        
        self.view.addGestureRecognizer(hideKeyboardGesture)
        
        if !self.isScrolledToBottom() {
            self.scrollToBottom()
        }
    }
    
    override func keyboardWillHide(notification: Notification) {
        //self.view.removeGestureRecognizer(hideKeyboardGesture)
        // self.inputStauts = .text
        animateWithKeyboard(notification: notification) {[weak self] (keyboardFrame) in
            //            self?.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            //            self?.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            //            self?.localContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            //            self?.fileContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            //            self?.pictrueContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            
            //            let barHeight = self?.inputBar.bounds.height ?? 0
            //            var bottomInfoHeight = self?.bottomInfoView.height ?? 0
            //            if !self!.isSecretMessage {
            //                bottomInfoHeight = 0
            //            }
            //            self?.tableview.contentInset.bottom = barHeight  + bottomInfoHeight
            //            self?.tableview.scrollIndicatorInsets.bottom = barHeight + bottomInfoHeight
            //            self?.scrollToBottom()
        }
    }
    
    @objc func keyboardWillChangeFrame(notification: Notification) {
        animateWithKeyboard(notification: notification) { [weak self] (keyboardFrame) in
            //            self?.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            //            self?.moreContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            //            self?.localContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            //            self?.fileContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            //            self?.pictrueContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
        }
    }
    
    func showEmoticonContainer() {
        if self.inputStauts == .sticker {
            self.inputStauts = .text
            self.inputBar.inputTextView.becomeFirstResponder()
            self.inputBar.ResetStickerImage()
        } else {
            self.view.resignFirstResponder()
            self.inputBar.inputTextView.resignFirstResponder()
            self.stickerContainerView?.refreshStickerKeyboard()
            self.inputStauts = .sticker
            //self.stickerContainerView?.isHidden = true
            if keyboardHeight > 0 {
                self.handleKeyboardLogic()
            }
            self.inputBar.changeStickerImageToKeyboard()
        }
        //inputBar.hideBtn.isSelected = false
    }
    
    func showmMoreContainer() {
        if self.inputStauts == .more {
            self.inputStauts = .text
            self.inputBar.inputTextView.becomeFirstResponder()
            //inputBar.hideBtn.isSelected = false
        } else {
            self.view.resignFirstResponder()
            self.inputBar.inputTextView.resignFirstResponder()
            self.inputStauts = .more
            if keyboardHeight > 0 {
                self.handleKeyboardLogic()
            }
            
            //inputBar.hideBtn.isSelected = true
        }
    }
    
    func showmFileContainer() {
        sendFile()
        //        if self.inputStauts == .file {
        //            self.inputStauts = .text
        //            self.inputBar.inputTextView.becomeFirstResponder()
        //        } else {
        //            self.view.resignFirstResponder()
        //            self.inputBar.inputTextView.resignFirstResponder()
        //            self.view.endEditing(true)
        //            self.inputStauts = .file
        //            if keyboardHeight > 0 {
        //                self.handleKeyboardLogic()
        //            }
        //        }
        //inputBar.hideBtn.isSelected = false
    }
    
    func showLocalContainer() {
        if self.inputStauts == .local {
            self.inputStauts = .text
            self.inputBar.inputTextView.becomeFirstResponder()
        } else {
            self.view.resignFirstResponder()
            self.inputBar.inputTextView.resignFirstResponder()
            self.inputStauts = .local
            if keyboardHeight > 0 {
                self.handleKeyboardLogic()
            }
        }
        //inputBar.hideBtn.isSelected = false
    }
    
    func showPictrueContainer() {
        if self.inputStauts == .picture {
            self.inputStauts = .text
            
            self.inputBar.inputTextView.becomeFirstResponder()
        } else {
            self.view.resignFirstResponder()
            self.inputBar.inputTextView.resignFirstResponder()
            self.inputStauts = .picture
            if keyboardHeight > 0 {
                self.handleKeyboardLogic()
            }
        }
        // inputBar.hideBtn.isSelected = false
    }
    
    func hideAudioRecording () {
        if inputBar.inputTextView.text.isEmpty {
            inputBar.hideHoldToTalk()
        }
    }
    
    func openCamera() {
        DispatchQueue.main.async {
            let mediaVC = TSIMMediaRecordController()
            mediaVC.allowPickingVideo = true
            mediaVC.enableMultiplePhoto = true
            mediaVC.allowEdit = true
            
            mediaVC.onSelectMiniVideo = { [weak self] (path) in
                guard let self = self else { return }
                let message = self.messageManager.videoMessage(with: path)
                let pathURL = URL(fileURLWithPath: path)
                
                DependencyContainer.shared.resolveViewControllerFactory().makeTSAlertController(url: pathURL as NSURL, message: message, parentVC: self, title: "im_send_confirmation".localized, messageDisplay: String(format: "text_send_confirmation_description".localized, pathURL.lastPathComponent, self.sessionTitle()! as! CVarArg), onSend: { (msg, url) in
                    self.messageManager.sendMessage(message)
                })
            }
            
            mediaVC.onSelectPhoto = { [weak self] (assetss, image, videoPath, isGif, isSelOriImage) in
                guard let self = self else { return }
                if let path = videoPath {
                    let message = self.messageManager.videoMessage(with: path)
                    let pathURL = URL(fileURLWithPath: path)
                    DependencyContainer.shared.resolveViewControllerFactory().makeTSAlertController(url: pathURL as NSURL, message: message, parentVC: self, title: "im_send_confirmation".localized, messageDisplay: String(format: "text_send_confirmation_description".localized, pathURL.lastPathComponent, self.sessionTitle()! as! CVarArg), onSend: { (msg, url) in
                        self.messageManager.sendMessage(message)
                    })
                } else {
                    for asset in assetss {
                        let manager = PHImageManager.default()
                        let option = PHImageRequestOptions()
                        option.isSynchronous = false
                        manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
                            guard let imageData = imageData else {
                                return
                            }
                            DispatchQueue.main.async {
                                var image: UIImage!
                                if type == kUTTypeGIF as String {
                                    image = UIImage.gif(data: imageData)
                                    
                                } else {
                                    image = UIImage.init(data: imageData)
                                }
                                
                                if let message = self.messageManager.imageMessage(with: image, isFullImage: isSelOriImage) {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.07) {
                                        self.messageManager.sendMessage(message)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            let nav = TSNavigationController(rootViewController: mediaVC).fullScreenRepresentation
            self.present(nav, animated: true, completion: nil)
            nav.didMove(toParent: self)
        }
    }
    
    func handleKeyboardLogic () {
        if moreContainerView == nil {
            moreContainerView =  InputMoreContainerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.width, height: keyboardHeight))
            moreContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
            moreContainerView!.actionDelegate = self
        }
        
        if stickerContainerView == nil {
            stickerContainerView = InputEmoticonContainerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.width, height: keyboardHeight))
            stickerContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
            stickerContainerView!.delegate = self
        }
        
        if pictrueContainerView == nil {
            pictrueContainerView = InputPictrueContainer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height, width: self.view.width, height: keyboardHeight), callBackHandler: { [weak self] (isSend, isCamera, assets, isFullImage) in
                guard let self = self else { return }
                if isCamera {// 相机
                    self.cameraTapped()
                    return
                }
                
                if isSend {
                    guard let assets = assets else {
                        return
                    }
                    for asset in assets {
                        let manager = PHImageManager.default()
                        let option = PHImageRequestOptions()
                        option.isSynchronous = false
                        manager.requestImageData(for: asset, options: option) { (imageData, type, orientation, info) in
                            guard let imageData = imageData else {
                                return
                            }
                            DispatchQueue.main.async {
                                var image: UIImage!
                                if type == kUTTypeGIF as String {
                                    image = UIImage.gif(data: imageData)
                                    
                                } else {
                                    image = UIImage.init(data: imageData)
                                }
                                
                                if let message = self.messageManager.imageMessage(with: image) {
                                    self.messageManager.sendMessage(message)
                                }
                                
                            }
                        }
                    }
                } else {//相册
                    self.openMedia()
                }
            })
            pictrueContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
        }
        
        if fileContainerView == nil {
            fileContainerView = InputFileContainer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height , width: self.view.width, height: keyboardHeight), callBackHandler: { [weak self] (flag, url) in
                guard let self = self else { return }
                if flag {
                    if let url = url {
                        var alert = TSAlertController(style: .alert)
                        
                        alert = TSAlertController(title: "im_send_confirmation".localized,
                                                  message:  String(format: "text_send_confirmation_description".localized, url.lastPathComponent, self.sessionTitle()! as! CVarArg),
                                                  style: .alert, hideCloseButton: true, animateView: false)
                        
                        let dismissAction = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel) { (_) in
                            alert.dismiss()
                        }
                        let alertAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { [weak self] (_) in
                            guard let self = self else { return }
                            if let message = self.messageManager.fileMessage(with: url.path) {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.07) {
                                    self.messageManager.sendMessage(message)
                                }
                            }
                        }
                        alert.addAction(alertAction)
                        alert.addAction(dismissAction)
                        
                        self.present(alert, animated: false, completion: nil)
                    }
                } else {
                    self.sendFile()
                }
            })
            fileContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
        }
        
        if localContainerView == nil {
//            localContainerView = InputLocalContainer(frame: CGRect(x: 0, y: UIScreen.main.bounds.height , width: self.view.width , height: keyboardHeight), callBackHandler: { [weak self] (isSend, title, coordinate) in
//                guard let self = self else { return }
//                if isSend {
//                    let locationPoint = NIMKitLocationPoint(coordinate: coordinate, andTitle: title)
//                    if let locationPoint = locationPoint  {
//                        let message = self.messageManager.locationMessage(with: locationPoint)
//                        self.messageManager.sendMessage(message)
//                    }
//                } else {
//                    let vc = NIMLocationViewController()
//                    vc.delegate = self
//                    let nav = UINavigationController(rootViewController: vc)
//                    nav.modalPresentationStyle = .fullScreen
//                    self.navigationController?.present(nav, animated: true, completion: nil)
//                }
//            })
//            localContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
        }
        
        switch self.inputStauts {
        case .text:
            stickerContainerView?.isHidden = true
            moreContainerView?.isHidden = true
            pictrueContainerView?.isHidden = true
            localContainerView?.isHidden = true
            fileContainerView?.isHidden = true
            break
        case .more:
            moreContainerView?.reloadMediaItems(removeVoice: self.session.sessionType == .team)
            
            stickerContainerView?.isHidden = true
            moreContainerView?.isHidden = false
            pictrueContainerView?.isHidden = true
            localContainerView?.isHidden = true
            fileContainerView?.isHidden = true
            moreContainerView?.height = keyboardHeight
            
            if let moreView = moreContainerView {
                moreView.layer.zPosition = CGFloat(MAXFLOAT)
                UIApplication.shared.windows.first!.addSubview(moreView)
            }
            break
        case .sticker:
            stickerContainerView?.isHidden = false
            moreContainerView?.isHidden = true
            pictrueContainerView?.isHidden = true
            localContainerView?.isHidden = true
            fileContainerView?.isHidden = true
            stickerContainerView?.height = keyboardHeight
            
            if let stickerview = stickerContainerView {
                stickerview.layer.zPosition = CGFloat(MAXFLOAT)
                UIApplication.shared.windows.first!.addSubview(stickerview)
            }
            break
        case .picture:
            pictrueContainerView!.getPhotoAlbumAssets()
            
            stickerContainerView?.isHidden = true
            moreContainerView?.isHidden = true
            pictrueContainerView?.isHidden = false
            localContainerView?.isHidden = true
            fileContainerView?.isHidden = true
            pictrueContainerView?.height = keyboardHeight
            
            if let picview = pictrueContainerView {
                picview.layer.zPosition = CGFloat(MAXFLOAT)
                UIApplication.shared.windows.first!.addSubview(picview)
            }
            break
        case .file:
            stickerContainerView?.isHidden = true
            moreContainerView?.isHidden = true
            fileContainerView?.isHidden = false
            pictrueContainerView?.isHidden = true
            localContainerView?.isHidden = true
            fileContainerView?.height = keyboardHeight
            
            if let flieview = fileContainerView{
                flieview.layer.zPosition = CGFloat(MAXFLOAT)
                UIApplication.shared.windows.first!.addSubview(flieview)
            }
            break
        case .local:
            LocationManager.shared.setupLocationService()
            
            stickerContainerView?.isHidden = true
            moreContainerView?.isHidden = true
            fileContainerView?.isHidden = true
            pictrueContainerView?.isHidden = true
            localContainerView?.isHidden = false
            localContainerView?.height = keyboardHeight
            
            if let localview = localContainerView {
                localview.layer.zPosition = CGFloat(MAXFLOAT)
                UIApplication.shared.windows.first!.addSubview(localview)
            }
            break
        default:
            break
        }
    }
    
    func animateWithKeyboard(notification: Notification, animations: ((_ keyboardFrame: CGRect) -> Void)?) {
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve) {
            animations?(keyboardFrameValue.cgRectValue)
            self.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func setupNav() {
        //self.titleViewSetup()
        
        if self.tableview.isEditing {
            self.navigationItem.rightBarButtonItems = [cancelSelectionBtn]
        } else {
            switch self.session.sessionType {
            case .team:
                var rightBarItems = [enterTeamCardBtn]
                if NIMSDK.shared().teamManager.isMyTeam(self.session.sessionId) {
                    rightBarItems.append(teamMeetingBtn)
                }
                self.navigationItem.rightBarButtonItems = rightBarItems
                break
            case .P2P:
                if let info = self.userInfo {
                    updateNav(info)
                } else {
                    TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [self.session.sessionId], complete: { [weak self] (models, _, status) in
                        guard let self = self, let model = models?.first, status else {
                            return
                        }
                        self.userInfo = model
                        DispatchQueue.main.async {
                            self.updateNav(model)
                        }
                    })
                }
                break
            default:
                self.navigationItem.rightBarButtonItems = []
                break
            }
        }
    }
    
    func updateNav(_ model: UserInfoModel) {
        guard let relationship = model.relationshipWithCurrentUser else { return }
        self.inputBar.isHidden = false
        var showIM = false
        
        let isMeWhitelist = TSCurrentUserInfo.share.userInfo?.whiteListType?.contains("outgoing_message") ?? false
        let isUserWhitelist = model.whiteListType?.contains("incoming_call") ?? false
        
        switch relationship.status {
        case .eachOther:
            showIM = true
        case .follow, .unfollow:
            showIM = isUserWhitelist || isMeWhitelist
        case .oneself:
            return
        }

        if showIM {
            self.navigationItem.rightBarButtonItems = [self.enterInfoBtn, self.videoCallBtn]
            self.nonfriendBottomView.makeHidden()
        } else {
            self.navigationItem.rightBarButtonItems = []
            self.view.bringSubviewToFront(self.nonfriendBottomView)
            self.inputBar.isHidden = true
            self.nonfriendBottomView.makeVisible()
        }
    }
    
    func titleViewSetup() {
        var backButton = UIBarButtonItem(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"), style: .plain, target: self, action: #selector(backAction))
        
        let allunreadCount = NIMSDK.shared().conversationManager.allUnreadCount()
        var unreadCountStr = allunreadCount.stringValue
        if allunreadCount > 99 {
            unreadCountStr = "99+"
        }
        if allunreadCount > 0 {
            backButton = UIBarButtonItem(image: UIImage.set_image(named: "btn_back_normal"), style: .plain, target: self, action: #selector(backAction))
        }
        
        let type = self.session.sessionType
        switch type {
        case .team:
            headerAvatarView.avatarPlaceholderType = .unknown
            headerAvatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: self.session.sessionId, isTeam: true)
            headerAvatarView.buttonForAvatar.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.enterTeamCard()
            })
            headerTitle.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.enterTeamCard()
            })
        case .P2P:
            headerAvatarView.avatarPlaceholderType = .unknown
            headerAvatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: self.session.sessionId)
            headerAvatarView.buttonForAvatar.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.enterUserProfile()
            })
            headerTitle.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.enterUserProfile()
            })
        default:
            break
        }
        
        let title = sessionTitle()
        headerTitle.text = title
        nonfriendBottomView.setName(title.orEmpty)
        
        let unreadCountLabel = UILabel()
        unreadCountLabel.isHidden = (allunreadCount <= 0)
        unreadCountLabel.backgroundColor = AppTheme.secondaryColor
        unreadCountLabel.textColor = AppTheme.twilightBlue
        unreadCountLabel.font = UIFont.boldSystemFont(ofSize: 12)
        unreadCountLabel.numberOfLines = 1
        unreadCountLabel.text = unreadCountStr
        unreadCountLabel.textAlignment = .center
        unreadCountLabel.sizeToFit()
        let unreadCountView = UIView()
        unreadCountView.addSubview(unreadCountLabel)
        
        let lblHeight: CGFloat = unreadCountLabel.height + 4
        let lblWidth: CGFloat = unreadCountLabel.width + 10.0
        
        let titleStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 10
            stack.distribution = .fill
            stack.alignment = .center
        }
        let titleTypingStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 2
            stack.distribution = .fill
            stack.alignment = .center
        }
        if allunreadCount > 0 {
            titleStackView.addArrangedSubview(unreadCountView)
        }
        titleStackView.addArrangedSubview(headerAvatarView)
        titleStackView.addArrangedSubview(titleTypingStackView)
        titleTypingStackView.addArrangedSubview(headerTitle)
        titleTypingStackView.addArrangedSubview(isTypingLabel)
        headerTitleView.addSubview(titleStackView)
        
        headerAvatarView.snp.makeConstraints({make in
            make.width.height.equalTo(26)
        })
        titleStackView.snp.makeConstraints({make in
            make.edges.equalToSuperview()
        })
        unreadCountView.snp.makeConstraints({make in
            make.width.equalTo(lblWidth)
        })
        unreadCountLabel.snp.makeConstraints({make in
            make.width.equalTo(lblWidth)
            make.height.equalTo(lblHeight)
            make.centerY.equalToSuperview()
        })
        headerTitleView.snp.makeConstraints({make in
            make.height.equalTo(36)
        })
        
        unreadCountLabel.roundCorner(lblHeight/2)
        
        let customTitles = UIBarButtonItem.init(customView: headerTitleView)
        self.navigationItem.leftBarButtonItems = [backButton, customTitles]
    }
    
    func scrollToBottomBtnSetup() {
        self.view.addSubview(scrollToBottomBtn)
        self.view.bringSubviewToFront(scrollToBottomBtn)
        scrollToBottomBtn.addAction(action: {self.scrollToBottom()})
        scrollToBottomBtn.snp.makeConstraints({make in
            make.height.equalTo(40)
            make.width.equalTo(53)
            make.bottom.equalToSuperview().inset(self.inputBar.bounds.height+20 + TSBottomSafeAreaHeight)
            make.right.equalToSuperview()
        })
    }
    
    func unreadMsgViewSetup() {
        scrollToUnreadView.backgroundColor = .clear
        scrollToUnreadView.addSubview(unreadMsgLabel)
        scrollToUnreadView.addSubview(unreadMsgArrow)
        unreadMsgArrow.isHidden = true
        unreadMsgLabel.backgroundColor = .white
        unreadMsgLabel.snp.makeConstraints({make in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            //make.width.equalTo(80)
        })
        
        unreadMsgLabel.layer.cornerRadius = 15
        unreadMsgLabel.layer.masksToBounds = true
        unreadMsgArrow.snp.makeConstraints({make in
            make.width.height.equalTo(40)
            make.top.bottom.right.equalToSuperview()
        })
        
        scrollToUnreadView.addAction(action: { [weak self] in
            guard let self = self else { return }
            self.scrollToUnread()
        })
        scrollToUnreadView.isHidden = self.unreadCount <= 0
    }
    
    func sessionTitle() -> String? {
        var title = ""
//        let type = self.session.sessionType
//        switch type {
//        case .team:
//            let team = NIMSDK.shared().teamManager.team(byId: self.session.sessionId)
//            if let team1 = team?.teamName {
//                title = "\(team1)"
//            }
//        case .P2P:
//            let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: session.sessionId)
//            title = LocalRemarkName.getRemarkName(userId: session.sessionId, username: nil, originalName: avatarInfo.nickname, label: nil)
//            title = NIMKitUtil.showNick(session.sessionId, in: session)
//        default:
//            break
//        }
        return title
    }
    
    override func scrollToBottom(_ animation: Bool? = true) {
        super.scrollToBottom(animation)
        scrollToBottomBtn.setViewHidden(true)
    }
    
    override func makeDataSource() -> ChatDataSource {
        return ChatDataSource(tableView: tableview) { table, indexPath, message in
            switch message.type {
            case .time:
                let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                cell.tipLabel.text = message.messageTime?.messageTime(showDetail: true)
                return cell
            case .tip:
                let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                cell.tipLabel.text = message.infoString.orEmpty
                return cell
            case .outgoing, .incoming:
                if message.nimMessageModel?.messageType == .tip {
                    let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                    cell.tipLabel.text = message.nimMessageModel?.text ?? ""
                    return cell
                }
                
                if let messageModel = message.nimMessageModel, let object = messageModel.messageObject as? NIMCustomObject {
                    if let attachment = object.attachment as? IMReplyAttachment, attachment.image.isEmpty {
                        var messageList = NIMSDK.shared().conversationManager.messages(in: self.session, messageIds: [attachment.messageID])
                        
                        if let firstMessage = messageList?.first, let imageObject = firstMessage.messageObject as? NIMImageObject {
                            attachment.image = imageObject.url ?? ""
                        }
                    }
                }
                
                let cell = table.dequeueReusableCell(withIdentifier: BaseMessageCell.cellIdentifier) as! BaseMessageCell
                var contentView = self.messageManager.contentView(message)
                cell.dataUpdate(contentView:contentView, messageModel: message)
                cell.delegate = self
                cell.resendMessage = { [weak self] message in
                    guard let self = self else { return }
                    self.handleRetryMessage(message: message)
                }
                
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    func checkCondition() -> Bool {
        var result = true
        
        if (!NetworkReachabilityManager()!.isReachable) {
            showError(message: "network_is_not_available".localized)
            result = false
        }
        
        let currentUid = NIMSDK.shared().loginManager.currentAccount()
        if (self.session.sessionId == currentUid) {
            showError(message: "no_self_chat".localized)
            result = false
        }
        
        ///multiple video chat 发起
        if (self.session.sessionType == .team) {
            let team = NIMSDK.shared().teamManager.team(byId: self.session.sessionId)
            guard let memberNumber = team?.memberNumber else { return result}
            if (memberNumber < 2) {
                showError(message: "at_least_2".localized)
                result = false
            }
        }
        return result
    }
    
    func createWhiteboardChatroom(numbers: [String]) {
        DependencyContainer.shared.resolveUtilityFactory().stopVideoPlayer()
        whiteboardInvitedMembers = numbers
        YippiAPI.togaShared.createWhiteboardChatroom(roomName: "whiteboard".localized) { [weak self] (response, error) in
            guard let self = self else { return }
            if let error = error {
                DispatchQueue.main.async {
                    self.showError(message: error.localizedDescription)
                }
                return
            }
            if let result = response {
                let roomId = String(result.data.chatroom.roomid)
                self.reserveNetCallMeeting(roomId: roomId, newCreate: true)
            }
        }
    }
    
    func reserveNetCallMeeting(roomId: String, newCreate: Bool) {
//        let meeting = NIMNetCallMeeting()
//        meeting.name = roomId
//        meeting.type = .video
//        meeting.actor = true
//        meeting.ext = "test extend meeting messge".localized
//        meeting.option = self.fillNetCallOption()
//        DispatchQueue.main.async {
//            SVProgressHUD.show()
//            NIMAVChatSDK.shared().netCallManager.reserve(meeting) { [weak self] (callMeeting, error) in
//                guard let self = self else { return }
//                SVProgressHUD.dismiss()
//                if (error != nil) {
//                    self.showError(message: "reserve_meeting_fail".localized)
//                    return
//                }
//                self.enterChatRoom(roomId: roomId, newCreate: newCreate)
//            }
//        }
    }
    
    func enterChatRoom(roomId: String, newCreate: Bool) {
//        DependencyContainer.shared.resolveUtilityFactory().stopVideoPlayer()
//        let request = NIMChatroomEnterRequest()
//        request.roomId = roomId
//        SVProgressHUD.show()
//        NIMSDK.shared().chatroomManager.enterChatroom(request) { [weak  self] (error, chatRoom, me) in
//            guard let self = self else { return }
//            SVProgressHUD.dismiss()
//            if (error != nil) {
//                self.showError(message: "enter_whiteboard_fail".localized)
//            } else {
//                if (newCreate) {
//                    guard let chatRoom = chatRoom else { return }
//                    self.notificaionSender.sendWhiteboardRequest(session: self.session , roomID: roomId, invitedContacts: self.whiteboardInvitedMembers ?? [])
//                    
//                    MeetingManager.shared.cacheMyInfo(info: me!, roomId: request.roomId)
//                    MeetingRolesManager.shared.startNewMeeting(me: me!, chatroom: chatRoom, newCreated: newCreate)
//                    
//                    let vc = ChatWhiteboardViewController(room: chatRoom, session: session)
//                    
//                    DispatchQueue.main.async {
//                        if let vc1 = self.dependVC {
//                            vc1.dismiss(animated: true, completion: {
//                                self.navigationController?.pushViewController(vc, animated: true)
//                            })
//                        } else {
//                            self.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }
//                }
//            }
//        }
    }
    
//    func fillNetCallOption() -> NIMNetCallOption {
//        let option: NIMNetCallOption = NIMNetCallOption()
//        option.autoRotateRemoteVideo = NTESBundleSetting.sharedConfig().videochatAutoRotateRemoteVideo()
//        
//        let serverRecord: NIMNetCallServerRecord = NIMNetCallServerRecord()
//        serverRecord.enableServerAudioRecording  = NTESBundleSetting.sharedConfig().serverRecordAudio()
//        serverRecord.enableServerVideoRecording  = NTESBundleSetting.sharedConfig().serverRecordVideo()
//        serverRecord.enableServerHostRecording   = NTESBundleSetting.sharedConfig().serverRecordHost()
//        serverRecord.serverRecordingMode         = NIMNetCallServerRecordMode(rawValue: NIMNetCallServerRecordMode.RawValue(NTESBundleSetting.sharedConfig().serverRecordMode()))!
//        option.serverRecord = serverRecord
//        
//        let socks5Info: NIMNetCallSocksParam =  NIMNetCallSocksParam()
//        socks5Info.useSocks5Proxy    = NTESBundleSetting.sharedConfig().useSocks()
//        socks5Info.socks5Addr        = NTESBundleSetting.sharedConfig().socks5Addr()
//        socks5Info.socks5Username    = NTESBundleSetting.sharedConfig().socksUsername()
//        socks5Info.socks5Password    = NTESBundleSetting.sharedConfig().socksPassword()
//        socks5Info.socks5Type        = NIMSocksType(rawValue: NIMSocksType.RawValue(NTESBundleSetting.sharedConfig().socks5Type()) ?? 0)!
//        option.socks5Info            = socks5Info
//        
//        option.preferredVideoEncoder = NTESBundleSetting.sharedConfig().perferredVideoEncoder()
//        option.preferredVideoDecoder = NTESBundleSetting.sharedConfig().perferredVideoDecoder()
//        option.videoMaxEncodeBitrate = UInt(NTESBundleSetting.sharedConfig().videoMaxEncodeKbps() * 1000)
//        option.autoDeactivateAudioSession = NTESBundleSetting.sharedConfig().autoDeactivateAudioSession()
//        option.audioDenoise = NTESBundleSetting.sharedConfig().audioDenoise()
//        option.voiceDetect = NTESBundleSetting.sharedConfig().voiceDetect()
//        option.preferHDAudio = NTESBundleSetting.sharedConfig().preferHDAudio()
//        option.scene = NTESBundleSetting.sharedConfig().scene()
//        
//        return option
//    }
    
    func sendFile() {
        self.hideKeyboard()
        SendFileManager.instance.presentView(owner: self)
        
        SendFileManager.instance.completion = { [weak self] urls in
            guard let self = self else { return }
            for url in urls {
                var alert = TSAlertController(style: .alert)
                
                alert = TSAlertController(title: "im_send_confirmation".localized,
                                          message:  String(format: "text_send_confirmation_description".localized, url.lastPathComponent, self.sessionTitle()! as! CVarArg),
                                          style: .alert, hideCloseButton: true, animateView: false, allowBackgroundDismiss: false)
                
                let dismissAction = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel) { (_) in
                    alert.dismiss()
                }
                let alertAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { [weak self] (_) in
                    guard let self = self else { return }
                    if let message = self.messageManager.fileMessage(with: url.path) {
                        self.messageManager.sendMessage(message)
                    }
                }
                alert.addAction(alertAction)
                
                alert.addAction(dismissAction)
                
                self.present(alert, animated: false, completion: nil)
            }
        }
    }
    
    func loadParticularMessage(messageId: String , shouldScrollTo: Bool) {
        guard let model = dataSource.snapshot().itemIdentifiers.first(where: { $0.nimMessageModel?.messageId == messageId }), let indexPath = dataSource.indexPath(for: model) else {
            return
        }
        self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
        self.perform(#selector(cellAnimation(indexpath:)), with: indexPath, afterDelay: 0.3)
    }
    
    func openMedia () {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
        
//        self.mediaFetcher.fetchPhoto() { [weak self] (images, path, type) in
//            guard let self = self else { return }
//            switch type {
//            case .image:
//                if let path = path {
//                    if path.contains("HEIC") {
//                        let image = UIImage(contentsOfFile: path)
//                        if let message = self.messageManager.imageMessage(with: image, imagePath: nil) {
//                            self.messageManager.sendMessage(message)
//                        }
//                    } else {
//                        if let message = self.messageManager.imageMessage(with: nil, imagePath: path) {
//                            self.messageManager.sendMessage(message)
//                        }
//                    }
//                    return
//                }
//                
//                if let images = images as? [UIImage] {
//                    for image in images {
//                        if let message = self.messageManager.imageMessage(with: image) {
//                            self.messageManager.sendMessage(message)
//                        }
//                    }
//                }
//                break
//            case .video:
//                guard let path = path else { return }
//                let pathURL = URL(fileURLWithPath: path)
//                let message = self.messageManager.videoMessage(with: path)
//                
//                DependencyContainer.shared.resolveViewControllerFactory().makeTSAlertController(url: pathURL as NSURL, message: message, parentVC: self, title: "im_send_confirmation".localized, messageDisplay: String(format: "text_send_confirmation_description".localized, pathURL.lastPathComponent, self.sessionTitle()! as! CVarArg), onSend: { (msg, url) in
//                    self.messageManager.sendMessage(message)
//                })
//                
//                break
//            default:
//                break
//            }
//        }
    }
    
    @objc func updateFollowStatus(notice: NSNotification) {
        guard let userid: String = (notice.userInfo?["userid"] ?? "-1") as? String, let statusFollow: FollowStatus = (notice.userInfo?["follow"]) as? FollowStatus else { return }
        
        guard self.userInfo?.userIdentity == userid.toInt() else { return }
        self.userInfo?.follower = statusFollow == .follow
        self.setupNav()
    }
    
    //接收到白板的消息
    @objc func whiteboardInvite(notice: NSNotification) {
        self.hideKeyboard()
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard tableview.isEditing else {
            return
        }
        guard let messageModel = self.dataSource.itemIdentifier(for: indexPath), let message = messageModel.nimMessageModel else {
            return
        }
        
        if !SessionUtil().canMessageBeForwarded(message) {
            shareButton.isEnabled = false
        }
        //            if !SessionUtil().canMessageBeRevoked(message) {
        //                deleteButton.isEnabled = false
        //            }
        selectedMsgId.append(message.messageId)
        self.updateSelectedItem()
        
        if (tableView.indexPathsForSelectedRows?.count ?? 0) > 30 {
            DispatchQueue.main.async(execute: { [self] in
                var alert = UIAlertController()
                alert = UIAlertController(title: nil, message: "choice_overrun".localized, preferredStyle: .alert)
                let ok = UIAlertAction(title: "confirm".localized, style: .cancel, handler: { [self] action in
                    DispatchQueue.main.async(execute: { [self] in
                        let selectedMessageIndex = tableView.indexPathsForSelectedRows
                        if let lastIndex = selectedMessageIndex?.last {
                            self.updateTableViewSelection(by: lastIndex, select: false)
                        }
                    })
                })
                alert.addAction(ok)
                self.present(alert, animated: true)
            })
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableview.isEditing else {
            return
        }
        guard let messageModel = dataSource.itemIdentifier(for: indexPath), let message = messageModel.nimMessageModel else {
            return
        }
        
        self.updateShareButton()
        self.updateRevokeButton()
        
        selectedMsgId.removeAll { $0 == message.messageId }
        self.updateSelectedItem()
    }
}

extension IMChatViewController {
    @objc func forwardMessages() {
        EventTrackingManager.instance.track(event: .forwardClicked)
        guard let selectedRows = tableview.indexPathsForSelectedRows, selectedRows.count > 0 else {
            let alertController = UIAlertController(title: "warning".localized, message: "text_please_select_one_item".localized, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            return
        }
        
        let configuration = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "confirm".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: Constants.maximumSendContactCount, excludeIds: [self.session.sessionId], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = ContactsPickerViewController(configuration: configuration, finishClosure: { [weak self] (contacts) in
            guard let self = self else { return }
            var count = 0
            
            for contact in contacts {
                let group = DispatchGroup()
                group.enter() // pair 1 enter
                let session = NIMSession(contact.userName, type: contact.isTeam ? NIMSessionType.team : NIMSessionType.P2P)
                
                group.leave()
                self.forward(selectedRows, to: session, isTeam: contact.isTeam)
                group.notify(queue: .global(), execute: {
                    count += 1
                })
            }
            self.selectedMsgId.removeAll()
        })
        let nav = UINavigationController(rootViewController: picker)
        self.present(nav.fullScreenRepresentation, animated: true)
    }
    
    private func forward(_ indexPaths:[IndexPath], to session: NIMSession, isTeam team: Bool) {
        indexPaths.forEach { path in
            if let message = dataSource.itemIdentifier(for: path) {
                if message.messageList.count >= 4 {
                    // Multiple Stack Image
                    for var item in message.messageList {
                        if let messageModel = item.nimMessageModel {
                            var forwardMessage = self.messageManager.updateApnsPayloadBySessonId(messageModel, session.sessionId, team)
                            
                            do {
                                try NIMSDK.shared().chatManager.forwardMessage(forwardMessage, to: session)
                            } catch {
                            }
                        }
                    }
                } else {
                    if let messageModel = message.nimMessageModel {
                        var forwardMessage = self.messageManager.updateApnsPayloadBySessonId(messageModel, session.sessionId, team)
                        
                        if messageModel.messageType == .robot {
                            forwardMessage = self.messageManager.textMessage(with: forwardMessage.text ?? "")
                            do {
                                try NIMSDK.shared().chatManager.send(forwardMessage, to: session)
                            } catch {
                            }
                        } else {
                            do {
                                try NIMSDK.shared().chatManager.forwardMessage(forwardMessage, to: session)
                            } catch {
                            }
                        }
                    }
                }
            }
        }
        
        self.showSelectActionToolbar(false, isDelete: false)
    }
    
    private func forward(_ message: NIMMessage, to session: NIMSession) {
        var forwardMessage = self.messageManager.updateApnsPayload(message)
        if message.messageType == NIMMessageType.robot {
            forwardMessage = self.messageManager.textMessage(with: forwardMessage.text ?? "")
            do {
                try NIMSDK.shared().chatManager.send(forwardMessage, to: session)
            } catch {
            }
        } else {
            do {
                try NIMSDK.shared().chatManager.forwardMessage(forwardMessage, to: session)
            } catch {
            }
        }
        
        self.showSelectActionToolbar(false, isDelete: false)
    }
    
    @objc func deleteMessages() {
        EventTrackingManager.instance.track(event: .deleteMultiForSelfClicked)
        guard let selectedRows = tableview.indexPathsForSelectedRows, selectedRows.count > 0 else {
            let alertController = UIAlertController(title: "warning".localized, message: "text_please_select_one_item".localized, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true)
            return
        }
        
        let sortedRows = selectedRows.sorted(by: { $0.row > $1.row })
        var canDeleteForEveryone = true
        
        sortedRows.forEach { path in
            let model = dataSource.itemIdentifier(for: path)
            if let message = model?.nimMessageModel, !SessionUtil().canMessageBeRevoked(message) || !showRevokeButton(message) {
                canDeleteForEveryone = false
            }
        }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        
        let deleteForEveryone = UIAlertAction(title: "longclick_msg_revoke_message".localized, style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            for path in sortedRows {
                if let model = self.dataSource.itemIdentifier(for: path) {
                    self.revokeSelectedMessage(model)
                }
            }
            self.selectedMsgId.removeAll()
            self.showSelectActionToolbar(false, isDelete: false)
        })
        
        let deleteForMe = UIAlertAction(title: "longclick_msg_delete_for_me".localized, style: .default, handler: { [weak self] action in
            guard let self = self else { return }
            for path in sortedRows {
                if let model = self.dataSource.itemIdentifier(for: path) {
                    self.deleteMessage(model)
                }
            }
            self.selectedMsgId.removeAll()
            self.showSelectActionToolbar(false, isDelete: false)
        })
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteForMe)
        
        if canDeleteForEveryone {
            alertController.addAction(deleteForEveryone)
        }
        
        self.present(alertController, animated: true)
    }
    
    private func revokeSelectedMessage(_ data: MessageData) {
        guard let message = data.nimMessageModel else {
            return
        }
        EventTrackingManager.instance.track(event: .deleteForEveryoneClicked)
        message.apnsContent = nil
        message.apnsPayload = nil
        if data.messageList.count >= 4 {
            var errorCount = 0
            
            for var item in data.messageList {
                if let messageModel = item.nimMessageModel {
                    messageModel.apnsContent = nil
                    messageModel.apnsPayload = nil
                    
                    NIMSDK.shared().chatManager.revokeMessage(messageModel, completion: { [weak self] error in
                        guard let self = self else { return }
                        if error != nil {
                            errorCount += 1
                        } else {
                            DispatchQueue.main.async {
                                self.remove(item)
                            }
                        }
                    })
                }
            }
            
            DispatchQueue.main.async {
                if errorCount > 0 {
                    self.view.makeToast("revoke_try_again".localized, duration: 2.0, position: CSToastPositionCenter)
                } else {
                    self.view.makeToast("message_delete_success".localized, duration: 2.0, position: CSToastPositionCenter)
                }
            }
        } else {
            NIMSDK.shared().chatManager.revokeMessage(message, completion: { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if error != nil {
                        if (error! as NSError).code == 508 {
                            let alertController = UIAlertController(title: nil, message: "revoke_failed".localized, preferredStyle: .alert)
                            let cancelAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil)
                            alertController.addAction(cancelAction)
                            self.present(alertController, animated: true)
                        } else {
                            self.view.makeToast("revoke_try_again".localized, duration: 2.0, position: CSToastPositionCenter)
                        }
                    } else {
                        self.remove(data)
                        DispatchQueue.main.async {
                            self.view.makeToast("message_delete_success".localized, duration: 2.0, position: CSToastPositionCenter)
                        }
                    }
                }
            })
        }
    }
    
    private func deleteMessage(_ message: MessageData) {
        EventTrackingManager.instance.track(event: .deleteForSelfClicked)
        if message.messageList.count >= 4 {
            for var item in message.messageList {
                if let model = item.nimMessageModel {
                    NIMSDK.shared().conversationManager.deleteMessage(fromServer: model, ext: nil) { error in
                        if let error = error {
                            
                        }else {
                            DispatchQueue.main.async {
                                self.remove(item)
                            }
                        }
                    }
                }
            }
        } else {
            if let model = message.nimMessageModel {
                NIMSDK.shared().conversationManager.deleteMessage(fromServer: model, ext: nil) { error in
                    if let error = error {
                        printIfDebug("error = \(error)")
                    } else {
                        DispatchQueue.main.async {
                            self.remove(message)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.view.makeToast("message_delete_success".localized, duration: 2.0, position: CSToastPositionCenter)
        }
    }
    
    private func UIInsertTranslateMessage(_ message: MessageData, translateMessage: MessageData) {
        insert(message: translateMessage, after: message)
    }
    
    @objc func enterUserProfile() {
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: self.userInfo?.userIdentity ?? -1, username: self.session.sessionId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//        let vc = HomePageViewController(userId: self.userInfo?.userIdentity ?? -1, username: self.session.sessionId)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func enterTeamCard() {
        guard let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: self.session.sessionId), let teamId = team.teamId else { return }
        let vc = GroupChatDetailViewController(teamId: teamId)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.clearGroupMessageCall = { [weak self] in
            guard let self = self else { return }
            self.removeAll()
            self.show(placeholder: .imEmpty)
            self.inputViewSetup()
        }
    }
    
    @objc func enterPersonInfoCard() {
        let vc = ChatDetailViewController(sessionId: self.session.sessionId)
        self.navigationController?.pushViewController(vc, animated: true)
        vc.clearMessageCall = { [weak self] in
            guard let self = self else { return }
            self.removeAll()
            self.show(placeholder: .imEmpty)
            self.inputViewSetup()
        }
    }
    
    @objc func videoCall() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let vc = VideoCallController(callee: self.session.sessionId)
                vc.callInfo.callType = .video
                let transition = CATransition()
                transition.duration = 0.25
                transition.timingFunction = CAMediaTimingFunction(name: .default)
                transition.type = .push
                transition.subtype = .fromTop
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        })
    }
    
    @objc func teamMeeting() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        
        let team =  NIMSDK.shared().teamManager.team(byId: self.session.sessionId)
        let currentUserID = NIMSDK.shared().loginManager.currentAccount()
        
        if !self.checkCondition() {
            return
        }
        
        NIMSDK.shared().teamManager.fetchTeamMembers(self.session.sessionId) { [weak self] (error, teams) in
            guard let self = self else { return }
            var memberIds = [String]()
            if  let teams = teams {
                for team in teams{
                    if team.userId != currentUserID {
                        memberIds.append(team.userId!)
                    }
                }
            }
            
            let config = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "confirm".localized, allowMultiSelect: true, enableTeam: false, enableRecent: false, enableRobot: false, maximumSelectCount: 8, members: memberIds, enableButtons: false, allowSearchForOtherPeople: true)
            
            self.dependVC = ContactsPickerViewController(configuration: config, finishClosure: { [weak self] (contacts) in
                guard let self = self, let contacts = contacts as? [ContactData]  else {return}
                var members : [String] = [currentUserID]
                members.append(contentsOf: contacts.map({ $0.userName }))
                let info = IMTeamMeetingCallerInfo()
                info.members = members
                info.teamId = team?.teamId ?? ""
                TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
                    DispatchQueue.main.async {
                        if let vc = self.dependVC {
                            vc.dismiss(animated: true) {
                                let vc1 = IMTeamMeetingViewController(info: info, session: self.session)
                                vc1.modalPresentationStyle = .fullScreen
                                self.present(vc1, animated: true, completion: nil)
                            }
                        }
                    }
                })
            }, isTeamMeeting: true)
            
            DispatchQueue.main.async {
                let nav = TSNavigationController(rootViewController: (self.dependVC)!)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    @objc func voiceCall() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let vc = VideoCallController(callee: self.session.sessionId)
                vc.callInfo.callType = .audio
                let transition = CATransition()
                transition.duration = 0.25
                transition.timingFunction = CAMediaTimingFunction(name: .default)
                transition.type = .push
                transition.subtype = .fromTop
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.isNavigationBarHidden = true
                self.navigationController?.pushViewController(vc, animated: false)
            }
        })
    }
    
    @objc func cancelSelectMessage() {
        self.showSelectActionToolbar(false, isDelete: false)
    }
    
    @objc func backAction() {
        if let nav = self.navigationController {
            var isPop = false
            for vc in nav.viewControllers {
                if vc.isKind(of: NewMessageViewController.self) {
                    isPop = true
                    self.navigationController?.popToViewController(vc, animated: true)
                }
            }
            
            if !isPop {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @objc func stopReplyingMessage() {
        replyView.isHidden = true
    }
    
    @objc func callActionSheet() {
        self.hideKeyboard()
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let voiceImage = UIImage.set_image(named: "voiceCallTop")
        let videoImage = UIImage.set_image(named: "videoCallTop")
        let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: nil)
        videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
        
        switch self.session.sessionType {
        case .team:
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.teamMeeting()
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            actionSheet.addAction(videoCall)
            break
        case .P2P:
            let voiceCall = UIAlertAction(title: "msg_type_voice_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.voiceCall()
            })
            voiceCall.setValue(voiceImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            
            let videoImage = UIImage.set_image(named: "videoCallTop")
            let videoCall = UIAlertAction(title: "msg_type_video_call".localized, style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                self.videoCall()
            })
            videoCall.setValue(videoImage?.withRenderingMode(.alwaysOriginal), forKey: "image")
            
            actionSheet.addAction(voiceCall)
            actionSheet.addAction(videoCall)
            break
        default:
            break
        }
        
        actionSheet.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    @objc func reloadUserInfo(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let users = userInfo["nim_user"] as? [NIMUser] else {
            return
        }
        
        if self.session.sessionType == .P2P {
            // Assuming sessionId is of type String and NIMUser has a userId property of type String
            if users.contains(where: { $0.userId == self.session.sessionId }) {
                self.tableview.reloadData()
            }
        } else {
            for item in teamMembers {
                // Assuming item is of type String and matches NIMUser's userId property
                if users.contains(where: { $0.userId == item }) {
                    self.tableview.reloadData()
                    break
                }
            }
        }
    }
}

extension IMChatViewController: NIMChatManagerDelegate {
    func willSend(_ message: NIMMessage) {
        if message.session != session { return }
        let data = MessageData(message)
        add([data])
        if isRedPacket == false {
            scrollToBottom()
        }
    }
    
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        self.update(message, animation: false)
        self.removePlaceholderView()
        /// self.messageManager.lastMessage == nil, 有发送新消息 需要记录
        if self.messageManager.lastMessage == nil {
            self.messageManager.lastMessage = message
        }
    }
    
    func send(_ message: NIMMessage, progress: Float) {
    }
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        if messages.first?.session != session { return }
        onReceiveMessage(messages)
        if isAutoScrollEnabled {
            scrollToBottom()
        }
        if isUnreadMessage {
            isUnreadMessage = false
            scrollToBottomBtn.setViewHidden(false)
        }
        self.removePlaceholderView()
        /// self.messageManager.lastMessage == nil, 有发送新消息 需要记录
        if self.messageManager.lastMessage == nil {
            self.messageManager.lastMessage = messages.first
        }

    }
    
    func onRecvRevokeMessageNotification(_ notification: NIMRevokeMessageNotification) {
        guard let message = notification.message else {
            return
        }
        if message.session != session { return }
        if let data = get(message) {
            deleteMessage(data)
        }
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
        self.update(message)
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        self.update(message)
    }
    
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        let receiptArray = receipts.filter({$0.session == session})
        if !receiptArray.isEmpty {
            self.tableview.reloadData()
        }
        //check receipt
    }
    
    func initSecretTimerImage() {
        self.turnOffSecretMessage()
        
        let secretMessageDuration = ChatManager.loadDurationForSecretMessage(sessionId: self.session.sessionId)
        if (secretMessageDuration == nil || secretMessageDuration!.duration == 0) {
            self.messageManager.updateIsSecretMessage(false, duration: 0)
            isSecretMessage = false
        } else {
            secretDuration = secretMessageDuration?.duration
            self.messageManager.updateIsSecretMessage(false, duration: secretMessageDuration!.duration)
            self.showSecretMessageWarning(secretMessageDuration!.duration)
            isSecretMessage = true
        }
        //self.inputBar.secretTimerBtn.isSelected = isSecretMessage
        //[self updateTimerImagge:_isSecretMessage];
    }
    
    private func turnOffSecretMessage () {
        //inputBar.secretTimerBtn.isSelected = false
        bottomInfoView.isHidden = true
        self.isSecretMessage = false
        let barHeight = self.inputBar.bounds.height
        var bottomInfoHeight = self.bottomInfoView.height
        if !self.isSecretMessage {
            bottomInfoHeight = 0
        }
        self.tableview.contentInset.bottom = barHeight + bottomInfoHeight + keyboardHeight
        self.tableview.scrollIndicatorInsets.bottom = barHeight + bottomInfoHeight + keyboardHeight
        self.messageManager.updateIsSecretMessage(false, duration: 0)
        let secretDuration = secretMessageDuration(sessionId: self.session.sessionId, duration: 0)
        ChatManager.setDurationForSecretMessage(sessionId: self.session.sessionId, duration: secretDuration)
    }
    
    private func showSecretMessageWarning (_ duration: Int) {
        self.isSecretMessage = true
        bottomInfoView.isHidden = false
        infoLabel.text = String(format: "secret_chat_input_bar_info".localized, String(duration/1000))
        //inputBar.secretTimerBtn.isSelected = true
        
        let barHeight = self.inputBar.bounds.height
        let bottomInfoHeight = self.bottomInfoView.height
        
        self.tableview.contentInset.bottom = barHeight  + bottomInfoHeight + keyboardHeight
        self.tableview.scrollIndicatorInsets.bottom = barHeight + bottomInfoHeight + keyboardHeight
        
        self.messageManager.updateIsSecretMessage(true, duration: duration)
        let secretDuration = secretMessageDuration(sessionId: self.session.sessionId, duration: duration)
        ChatManager.setDurationForSecretMessage(sessionId: self.session.sessionId, duration: secretDuration)
    }
    
    func hideSecretWarningByFriendStatus(status: Bool) {
        if isSecretMessage == true {
            self.bottomInfoView.isHidden = status
        } else {
            self.bottomInfoView.isHidden = true
        }
    }
    
    func startSecretMessage() {
        let alert = UIAlertController(title: "secret_chat_pop_up_title".localized, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        
        let offAction = UIAlertAction(title: "secret_chat_off".localized, style: .default) { (action) in
            self.turnOffSecretMessage()
            self.dismiss(animated: true, completion: nil)
        }
        
        let action5 = UIAlertAction(title: "5", style: .default) { (action) in
            self.showSecretMessageWarning(5000)
            self.dismiss(animated: true, completion: nil)
        }
        let action10 = UIAlertAction(title: "10", style: .default) { (action) in
            self.showSecretMessageWarning(10000)
            self.dismiss(animated: true, completion: nil)
        }
        
        let action30 = UIAlertAction(title: "30", style: .default) { (action) in
            self.showSecretMessageWarning(30000)
            self.dismiss(animated: true, completion: nil)
        }
        
        let action60 = UIAlertAction(title: "60", style: .default) { (action) in
            self.showSecretMessageWarning(60000)
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancel = UIAlertAction(title: "cancel".localized, style: .cancel) { (action) in
        }
        
        alert.addAction(offAction)
        alert.addAction(action5)
        alert.addAction(action10)
        alert.addAction(action30)
        alert.addAction(action60)
        alert.addAction(cancel)
        
        self.present(alert, animated: true)
    }
}

extension IMChatViewController: NIMConversationManagerDelegate {
    
}

extension IMChatViewController: NIMMediaManagerDelegate {
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        if filePath == nil || error != nil {
            inputBar.recording = false
            //            onRecordFailed(error)
        }
    }
    
    func recordAudio(_ filePath: String?, didCompletedWithError error: Error?) {
        if error == nil {
            if recordFileCanBeSend(filePath: filePath) {
                guard let filepath = filePath else { return }
                let message = self.messageManager.audioMessage(with: filepath)
                if inputBar.recordPhase == .converted || inputBar.recordPhase == .converting || inputBar.recordPhase == .converterror{
                    self.saveAudioMessage = message
                    self.saveAudioFilePath = filepath
                    return
                }
                let volumeLevels = self.getVolumeLevels()
                guard let audioObject = message.messageObject as? NIMAudioObject else { return }
                message.messageObject = audioObject
                message.remoteExt = ["voice":volumeLevels]
                self.messageManager.sendMessage(message)
            } else {
                //                showRecordFileNotSendReason()
            }
        } else {
            //            onRecordFailed(error)
        }
        inputBar.recording = false
    }
    
    func recordAudioDidCancelled() {
        inputBar.recording = false
    }
    
    func recordAudioProgress(_ currentTime: TimeInterval) {
        inputBar.updateAudioRecordTime(time: currentTime)
    }
    
    func recordAudioInterruptionBegin() {
        NIMSDK.shared().mediaManager.cancelRecord()
    }
    
    func recordFileCanBeSend(filePath: String?) -> Bool {
        let anURL = URL(fileURLWithPath: filePath ?? "")
        let urlAsset = AVURLAsset(url: anURL, options: nil)
        let time = urlAsset.duration
        let mediaLength = CGFloat(CMTimeGetSeconds(time))
        return mediaLength > 1
    }
    
    func stopPlayAudio(_ filePath: String, didCompletedWithError error: Error?) {
        if let error = error {
            
        } else {
            self.playNextAudio()
        }
    }
    
    func playNextAudio() {
        guard let pendingAudioMessage = pendingAudioMessages else {
            return
        }
        
        if let message = pendingAudioMessage.last {
            pendingAudioMessages?.removeLast()
            DispatchQueue.main.async {
                IMAudioCenter.shared.play(for: message)
            }
        }
    }
    
    //获取处理后的语音分贝数据
    func getVolumeLevels() -> String {
        var saveLevels = self.inputBar.audioRecordIndicator.recordStateView.saveLevels
        let filterArrays = saveLevels.filterDuplicates({$0})
        var resultArrays = [CGFloat]()
        var audioSecond = filterArrays.count / 10
        switch audioSecond {
        case 5..<10:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 2 == 0 }.map { CGFloat($0.element) }
        case 10..<25:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 4 == 0 }.map { CGFloat($0.element) }
        case 25..<40:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 6 == 0 }.map { CGFloat($0.element) }
        default:
            resultArrays = filterArrays.enumerated().filter { $0.offset % 1 == 0 }.map { CGFloat($0.element) }
            break
        }
        // 转换为Android需要的格式
        let targetArray = (0..<27).map { index -> Int in
            if index < resultArrays.count {
                var value = Int(resultArrays[index] * 100)
                return min(value, 55)
            } else {
                return 5
            }
        }
        let dblist = VoiceDBBean(dbList: targetArray)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let jsonData = try? encoder.encode(dblist),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return ""
    }
}

//MARK: - Cell actions
extension IMChatViewController: MessageCellDelegate {
    func itemsActionArray(_ message: MessageData, isPinned: Bool = false) -> [IMActionItem] {
        var items: [IMActionItem] = []
        let isLeavedGroupUser = false
        
        if SessionUtil().canMessagePinned(message.nimMessageModel!) && self.session.sessionType == .team{
            if !isPinned {
                items.append(.pinned)
            } else {
                items.append(.unPinned)
            }
            
        }
        
        if SessionUtil().canMessageBeCopy(message.nimMessageModel!) {
            items.append(.copy)
        }
        
        if SessionUtil().canMessageBeForwarded(message.nimMessageModel!) && isLeavedGroupUser == false {
            if message.messageList.count == 0 {
                items.append(.forward)
            } else {
                items.append(.forwardAll)
            }
        }
        
        if SessionUtil().canMessageBeReplied(message.nimMessageModel!) && isLeavedGroupUser == false && message.messageList.count == 0 {
            if let messageModel = message.nimMessageModel, messageModel.deliveryState == NIMMessageDeliveryState.deliveried {
                items.append(.reply)
            }
        }
        
        if SessionUtil().canMessageBeCancelled(message.nimMessageModel!) && message.nimMessageModel!.messageType != NIMMessageType.text {
            items.append(.cancelUpload)
        }
        
        
        
        if SessionUtil().canMessageCollection(message.nimMessageModel!) && message.messageList.count == 0 {
            items.append(.collection)
        }
        
        if let data = get(message.nimMessageModel!), SessionUtil().canMessageBeTranslated(data) {
            items.append(.translate)
        }
        
        if message.nimMessageModel!.messageType == NIMMessageType.audio {
            items.append(.voiceToText)
        }
        if SessionUtil().canStickerCollectionBeOpened(message.nimMessageModel!) {
            items.append(.stickerCollection)
        }
        
        if SessionUtil().canMessageBeRevoked(message.nimMessageModel!) && showRevokeButton(message.nimMessageModel!) && isLeavedGroupUser == false {
            if message.nimMessageModel!.messageType == NIMMessageType.text {
                items.append(.edit)
            }
        }
        
        
        if SessionUtil().canMessageBeDeleted(message.nimMessageModel!) {
            if message.messageList.count == 0 {
                items.append(.delete)
            } else {
                items.append(.deleteAll)
            }
        }
        
        return items
    }
    
    func longPressMessageCell(_ cell: BaseMessageCell, message: MessageData) {
        isScrollToBottom = false
        self.hideKeyboard()
        if isLeavedGroupUser {
            return
        }
        //是否已经被pinned
        messagePinned(for: message.nimMessageModel!) { flag in
            DispatchQueue.main.async {
                let items = self.itemsActionArray(message, isPinned: flag)
                if (items.count > 0 && self.becomeFirstResponder() && !self.tableview.isEditing) {
                    var groupItems: [GroupIMActionItem] = []
                    var totalRow = Int(ceil(Double(items.count) / Double(4)))
                    
                    for (index, item) in items.enumerated() {
                        if groupItems.isEmpty {
                            groupItems.append(GroupIMActionItem(sectionId: 0, items: [item]))
                            
                            var i = index + 1
                            repeat {
                                if items.indices.contains(i) {
                                    let nextItem = items[i]
                                    
                                    if let firstGroup = groupItems.first {
                                        if firstGroup.items.count < 4 {
                                            firstGroup.items.append(nextItem)
                                        } else {
                                            break
                                        }
                                    } else {
                                        break
                                    }
                                }
                                
                                i += 1
                            } while items.indices.contains(i)
                        } else {
                            if groupItems.contains(where: { $0.items.contains(where: { $0 == item })}) == false {
                                groupItems.append(GroupIMActionItem(sectionId: groupItems.count, items: [item]))
                                
                                var i = index + 1
                                repeat {
                                    if items.indices.contains(i) {
                                        let nextItem = items[i]
                                        
                                        if groupItems.last!.items.count < 4 {
                                            groupItems.last!.items.append(nextItem)
                                        } else {
                                            break
                                        }
                                    }
                                    
                                    i += 1
                                } while items.indices.contains(i)
                            } else {
                                continue
                            }
                        }
                    }
                    
                    if let indexPath = self.dataSource.indexPath(for: message) {
                        let rectOfCellInTableView = self.tableview.rectForRow(at: indexPath)
                        let rectOfCellInSuperview = self.tableview.convert(rectOfCellInTableView, to: self.tableview.superview)
                        
                        let preference = ToolChoosePreferences()
                        preference.drawing.bubble.color = UIColor(red: 38, green: 50, blue: 56)
                        preference.drawing.message.color = .white
                        preference.drawing.background.color = .clear
                        preference.drawing.bubble.cornerRadius = 10
                        
                        let barHeight = self.inputBar.bounds.height
                        var bottomHeight = self.bottomInfoView.height
                        
                        self.tableview.contentInset.bottom = barHeight + bottomHeight
                        
                        if rectOfCellInSuperview.y > ((ScreenHeight - TSNavigationBarHeight) / 2 - self.inputBar.height - 25) {
                            cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: message.type == .incoming ? .bottomLeft : .bottomRight, preferences: preference, delegate: self)
                        } else {
                            if (cell.frame.y + cell.height + barHeight + bottomHeight) > self.tableview.contentSize.height {
                                self.tableview.contentInset.bottom = (barHeight + bottomHeight) * 2.5
                                
                                UIView.animate(withDuration: 0.2) {
                                    self.tableview.scrollRectToVisible(CGRect(x: 0, y: cell.frame.y + (cell.frame.height / 2), width: cell.frame.width, height: cell.frame.height), animated: false)
                                } completion: { _ in
                                    cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: message.type == .incoming ? .topLeft : .topRight, preferences: preference, delegate: self, dismissCompletion: {
                                        UIView.animate(withDuration: 0.2) {
                                            self.tableview.contentInset.bottom = barHeight + bottomHeight
                                        }
                                    })
                                }
                            } else if rectOfCellInTableView.height > (ScreenHeight - self.inputBar.height) {
                                UIView.animate(withDuration: 0.2) {
                                    self.tableview.scrollRectToVisible(CGRect(x: 0, y: cell.frame.y + (cell.frame.height / 2), width: cell.frame.width, height: cell.frame.height), animated: false)
                                } completion: { _ in
                                    cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: message.type == .incoming ? .topLeft : .topRight, preferences: preference, delegate: self)
                                }
                            } else if rectOfCellInSuperview.y > 200 && (self.tableview.height - rectOfCellInSuperview.y - rectOfCellInTableView.height ) < 180 {
                                cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: message.type == .incoming ? .bottomLeft : .bottomRight, preferences: preference, delegate: self)
                            } else  {
                                cell.showIMToolChoose(identifier: "", data: groupItems, arrowPosition: message.type == .incoming ? .topLeft : .topRight, preferences: preference, delegate: self)
                            }
                        }
                        
                        //            let view = IMActionListView(actions: items)
                        //            view.delegate = self
                        self.messageForMenu = message
                    }
                }
            }
        }
    }
    
    func validateUrlString(urlString: String) {
        guard let url = TSUtil.matchUrlInString(urlString: urlString) else { return }
        if url.absoluteString.contains("/mini-program/") {
            let arr = url.absoluteString.components(separatedBy: "/mini-program/")
            if let lastStr = arr.last, let appId = lastStr.components(separatedBy: "/").first {
                var items = lastStr.components(separatedBy: "/")
                if let index = items.firstIndex(where: { $0 == appId }) {
                    items.remove(at: index)
                }
                if items.count == 0 {
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: nil)
                //    miniProgramExecutor.startApplet(type: .normal(appId: appId), parentVC: self)
                } else {
                    let path = items.joined(separator: "/").removingPercentEncoding
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: path)
//                    miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: self)
                }
            }
        } else {
            self.showShareContent(url)
        }
    }
    
    func tappedAvatar(_ userId: String) {
        self.isScrollToBottom = false
        if !self.tableview.isEditing {
           // var vc: UIViewController!
            if NIMSDK.shared().robotManager.isValidRobot(userId) {
                // vc = [[NTESRobotCardViewController alloc] initWithUserId:userId];
            } else {
                let isTeam = session.sessionType != .P2P
                FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: userId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: isTeam)
//                vc = DependencyContainer.shared.resolveViewControllerFactory().makeUserHomepageViewControllerFromChatroom(userId: 0, userName: userId, isTeam: isTeam)
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func findRemainAudioMessages(message: NIMMessage) -> [NIMMessage]? {
        if message.isPlayed || message.from == NIMSDK.shared().loginManager.currentAccount() {
            //如果这条音频消息被播放过了 或者这条消息是属于自己的消息，则不进行轮播
            return nil
        }
        
        return dataSource.snapshot().itemIdentifiers.filter {
            guard let model = $0.nimMessageModel else {
                return false
            }
            return model.from != NIMSDK.shared().loginManager.currentAccount() && model.isPlayed == false && model.messageType == .audio
        }.compactMap { $0.nimMessageModel }
    }
    
    func longPressAvatar(_ cell: BaseMessageCell, message: MessageData) {
        if self.session.sessionType != .team { return }
        guard let nimMessage = message.nimMessageModel, let userId = nimMessage.from else { return }
        if userId == NIMSDKManager.shared.getCurrentLoginUserName() { return }
        let nickName = NIMSDKManager.shared.getDisplayName(from: nimMessage)
        
        self.inputBar.inputTextView.insertText("@")
        self.mentionsUsernames.append(AutocompleteCompletion(text: nickName, context: ["username": userId]))
        
        guard let session = self.autocompleteManager.currentSession else { return }
        session.completion = self.mentionsUsernames.last
        self.autocompleteManager.autocomplete(with: session)
        
        self.autocompleteManager.unregisterCurrentSession()
        
        self.stickerContainerView?.isHidden = true
        self.moreContainerView?.isHidden = true
        self.onClickedContact = true
        self.inputStauts = .text
        self.inputBar.inputTextView.becomeFirstResponder()
    }
    
    func tappedContactCard(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMContactCardAttachment
        let memberId = attachment.memberId
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: true)
//        let vc = HomePageViewController(userId: 0, username: memberId, isTeam: true)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tappedStickerCard(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMStickerCardAttachment
        let bundleId = attachment.bundleID
        
        let vc = StickerDetailViewController(bundleId: bundleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tappedSocialPost(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel, let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMSocialPostAttachment else { return }
        
        self.validateUrlString(urlString: attachment.postUrl)
    }
    
    func tappedImage(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel else { return }
        
        let option = NIMMessageSearchOption()
        option.limit = 0
        option.messageTypes = [NSNumber(value: NIMMessageType.image.rawValue), NSNumber(value: NIMMessageType.video.rawValue)]
        
        NIMSDK.shared().conversationManager.searchMessages(self.session, option: option, result: { [weak self] error, messages in
            guard let self = self, let messages = messages else { return }
            
            var mediaArray: [MediaPreviewObject] = []
            var focusObject: MediaPreviewObject = MediaPreviewObject()
            for previewMessage in messages {
                switch previewMessage.messageType {
                case .image:
                    let previewMedia = self.previewImageMedia(by: previewMessage.messageObject as! NIMImageObject)
                    if previewMessage.messageId == message.messageId {
                        focusObject = previewMedia
                    }
                    mediaArray.append(previewMedia)
                    break
                case .video:
                    let previewMedia = self.previewVideoMedia(by: previewMessage.messageObject as! NIMVideoObject)
                    if previewMessage.messageId == message.messageId {
                        focusObject = previewMedia
                    }
                    mediaArray.append(previewMedia)
                default:
                    break
                }
            }
            
            DispatchQueue.main.async {
                let vc = MediaGalleryPageViewController(objects: mediaArray, focusObject: focusObject, session: self.session, showMore: true)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
    }
    
    func tappedVideo(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMVideoObject
        
        guard let url = object.url else { return }
        let vc = NIMChatroomplayerViewController(url: url)
        vc.modalPresentationStyle = .fullScreen
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func tappedLocation(_ cell: BaseMessageCell, message: MessageData) {
//        self.isScrollToBottom = false
//        guard let message = message.nimMessageModel, let object = message.messageObject as? NIMLocationObject else { return }
//        
//        let locationPoint: NIMKitLocationPoint = NIMKitLocationPoint.init(locationObject: object)
//        guard let vc = NIMLocationViewController.init(locationPoint: locationPoint) else { return }
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tappedEgg(_ cell: BaseMessageCell, message: MessageData) {
        //self.inputBar.hideBtn.isSelected = false
        self.inputStauts = .text
        self.stickerContainerView?.isHidden = true
        self.moreContainerView?.isHidden = true
        self.localContainerView?.isHidden = true
        self.fileContainerView?.isHidden = true
        self.pictrueContainerView?.isHidden = true
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as? IMEggAttachment
        self.eggAttachment = attachment
        self.isEggAttachmentOutgoing = message.isOutgoingMsg
        
        if (message.isOutgoingMsg) {
            self.checkOpenEggStatus()
        } else {
            self.eggOverlayView.updateInfo(avatarInfo: cell.avatarHeaderView.avatarInfo, name: message.nickName, message: attachment?.message ?? "", uids: attachment?.uids, completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.renderEggView()
                }
            })
        }
    }
    
    func tappedRetryTextTranslate(_ cell: BaseMessageCell, message: MessageData) {
        guard let translatedMsg = message.nimMessageModel, let object = translatedMsg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMTextTranslateAttachment, let oriMsg = getMessageData(for: attachment.oriMessageId) else { return }
        
        self.textTranslate(withText: attachment.originalText, oriMessage: oriMsg, translateMessage: message)
    }
    
    func tappedFile(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel,
              let object = message.messageObject as? NIMFileObject,
              let path = object.path else { return }
        
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            // By Kit Foong (Check the file is web or file url)
            if url.isFileURL {
                if FileManager.default.fileExists(atPath: path) {
                    self.openWithDocumentInterator(object: object)
                } else {
                    if isDownLoading {
                        if let msg = object.message {
                            NIMSDK.shared().chatManager.cancelFetchingMessageAttachment(msg)
                        }
                        //progress.isHidden = true
                        //progress.progress = 0
                        //doneBtn.setTitle("viewholder_download_document".localized, for: .normal)
                        isDownLoading = false
                    } else {
                        self.downLoadFile(object: object)
                    }
                }
                
                //                let vc: IMFilePreViewController = IMFilePreViewController(object: object)
                //                vc.refreshTable = {
                //                    self.tableview.reloadData()
                //                }
                //                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = TSWebViewController(url: url, type: .defaultType, title: object.displayName)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let vc: IMFilePreViewController = IMFilePreViewController(object: object)
            vc.refreshTable = {
                self.tableview.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tappedWhiteboard(_ cell: BaseMessageCell, message: MessageData) {
        guard let msg = message.nimMessageModel, let object = msg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMWhiteboardAttachment else { return }
        let param = NMCWhiteBoardParam()
        param.uid = UInt(TSCurrentUserInfo.share.userInfo?.userIdentity ?? 1)
        param.appKey = Constants.NIMKey
        param.channelName = attachment.channel
        param.webViewUrl = FeedIMSDKManager.shared.param.apiBaseURL + kwebViewUrl
        DispatchQueue.main.async {
            let vc = NMCWhiteBoardViewController(whiteBoardParam: param)
            self.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true)
        }
    }
    
    func tappedUnknown() {
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
            TSRootViewController.share.checkAppVersion(lastCheckModel: lastCheckModel, forceShowAlert: true)
        }
    }
    
    func tappedVoucher(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let message = message.nimMessageModel, let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMVoucherAttachment else { return }
        
        self.validateUrlString(urlString: attachment.postUrl)
    }
    
    func tappedMeeting(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let replyMsg = message.nimMessageModel, let object = replyMsg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMMeetingRoomAttachment else { return }
        
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "tips".localized, message: "meeting_join_confirmation".localized, preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "cancel".localized, style: .cancel)
                let comfirm = UIAlertAction(title: "confirm".localized,style: .default) {_ in
                    self.meetingNum = attachment.meetingNum
                    self.joinMeetingApi(meetingNum: attachment.meetingNum, password: attachment.meetingPassword)
                }
                alert.addAction(cancel)
                alert.addAction(comfirm)
                self.present(alert, animated: true)
            }
        })
    }
    
    //MARK: 会议
    //meetingkit 登录
    func meetingkitLogin(username: String, password: String, meetingId: String, meetingPW: String) {
        NEMeetingKit.getInstance().login(username, token: password) { code, msg, result in
            if code == 0 {
                printIfDebug("NEMeetingKit登录成功")
                self.joinInMeeting(meetingNum: meetingId, password: meetingPW)
            } else {
                self.showError(message: msg ?? "")
            }
        }
    }
    
    func quertMeetingKitAccountInfo(meetingId: String, password: String){
        let userUuid: String? = UserDefaults.standard.string(forKey: "MeetingKit-userUuid")
        let token: String? = UserDefaults.standard.string(forKey: "MeetingKit-userToken")
        self.meetingkitLogin(username: userUuid ?? "", password: token ?? "",meetingId: meetingId, meetingPW: password)
    }
    
    ///加入会议
    func joinInMeeting(meetingNum: String, password: String){
        let params = NEJoinMeetingParams() //会议参数
        params.meetingNum = meetingNum
        params.displayName = NIMSDK.shared().loginManager.currentAccount()
        params.password = password
        //会议选项，可自定义会中的 UI 显示、菜单、行为等
        let options = NEJoinMeetingOptions()
        options.noVideo = false //入会时关闭视频，默认为 YES
        options.noAudio = false //入会时关闭音频，默认为 YES
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
        //在MoreMenus里面添加自定义菜单
        if isPrivate {
            SessionUtil().configMoreMenus(options: options)
        }
        let meetingServce = NEMeetingKit.getInstance().getMeetingService()
        meetingServce?.joinMeeting(params, opts: options, callback: { resultCode, resultMsg, result in
            if resultCode == 0 {
                printIfDebug("会议加入成功")
                if self.meetingLevel == 0 {
                    self.startTimerHolder()
                }
            } else {
                self.showError(message: resultMsg ?? "")
            }
        })
    }
    
    //后端接口加入会议- 会议记录
    func joinMeetingApi(meetingNum: String, password: String){
        JoinMeetingRequest.init(params: ["meetingNum" : meetingNum]).execute {[weak self] model in
            guard let self = self else { return }
            self.meetingLevel = model?.data.meetingLevel ?? 0
            self.meetingTimeLimit = model?.data.meetingTimeLimit ?? 0
            self.meetingNumlimit = model?.data.meetingMemberLimit ?? 0
            self.startTime = (model?.data.meetingInfo?.startTime ?? "").toInt()
            DispatchQueue.main.async {
                self.isPrivate = (model?.data.meetingInfo?.isPrivate ?? 0) == 1 ? true : false
                self.quertMeetingKitAccountInfo(meetingId: meetingNum, password: password)
            }
        } onError: { error in
            switch error {
            case .error(let msg, code: let errorCode):
                switch errorCode {
                case .meetingEndOrInexistence:
                    self.showError(message: "meeting_ended".localized)
                case .meetingNumberLimit:
                    self.showError(message: "meeeting_max_user_limit_reached".localized)
                default:
                    self.showError(message: error.localizedDescription)
                    break
                }
            case .carriesMessage(let msg,let code, _):
                self.showError(message: msg.localized)
                
            default:
                self.showError(message: error.localizedDescription)
                break
            }
        }
    }
    
    func startTimerHolder() {
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
    
    func showTimeView() {
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
    
    func tappedReplyMessage(_ cell: BaseMessageCell, message: MessageData) {
        guard let replyMsg = message.nimMessageModel, let object = replyMsg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMReplyAttachment else { return }
        
        guard let data = dataSource.snapshot().itemIdentifiers.filter { $0.nimMessageModel?.messageId == attachment.messageID }.first, let indexPath = dataSource.indexPath(for: data) else {
            return
        }
        self.scrollToMessage(by: indexPath, animation: true)
    }
    
    func onRemoveSecretMessage(message: MessageData) {
        guard let msg = message.nimMessageModel else {
            return
        }
        remove(message)
        NIMSDK.shared().conversationManager.delete(msg)
    }
    
    func tappedSnapMessage(_ cell: BaseMessageCell, message: MessageData, baseView: UIView, isEnd: Bool){
        guard let snapMsg = message.nimMessageModel, let object = snapMsg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMSnapchatAttachment else {
            return
        }
        
        if (attachment.isFired) {
            return
        }
        
        if isEnd {
            if let snapView = self.currentSingleSnapView {
                snapView.dismissPresentedView(animated: true) { [weak self] in
                    guard let self = self else { return }
                    attachment.isFired  = true
                    guard let msg = object.message else {
                        return
                    }
                    NIMSDK.shared().conversationManager.delete(msg)
                    self.remove(message)
                    /*
                     if BundleSetting.sharedConfig().autoRemoveSnapMessage() {
                     NIMSDK.shared().conversationManager.delete(msg)
                     self.UIDeleteMessage(msg)
                     }else{
                     NIMSDK.shared().conversationManager.update(msg, for: msg.session!, completion: nil)
                     self.UIDeleteMessage(msg)
                     }
                     */
                    
                    do {
                        if FileManager.default.fileExists(atPath: attachment.filePath) {
                            try FileManager.default.removeItem(atPath: attachment.filePath)
                        }
                    } catch {
                        
                    }
                    
                    self.currentSingleSnapView = nil
                }
            }
        } else {
            //let point = baseView.convert(CGPoint(x: 0, y: 0), toViewOrWindow: UIApplication.shared.windows.last!)
            self.currentSingleSnapView = IMSingleSnapView(frame: UIScreen.main.bounds, object: object, baseView: baseView)
        }
    }
    
    func tappedMiniProgramMessage(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let object = message.nimMessageModel?.messageObject as? NIMCustomObject, let attactment = object.attachment as? IMMiniProgramAttachment else {
            return
        }
        FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: attactment.appId, path: attactment.path)

//        DependencyContainer.shared.resolveUtilityFactory().openMiniProgram(appId: attactment.appId, path: attactment.path, parentVC: self) { (status, error) in
//            if status {
//                 DependencyContainer.shared.resolveUtilityFactory().registerMiniProgramExt()
//            }
//        }
    }
    
    func tappedStickerRPSMessage(_ cell: BaseMessageCell, message: MessageData) {
        self.isScrollToBottom = false
        guard let object = message.nimMessageModel?.messageObject as? NIMCustomObject, let attactment = object.attachment as? IMStickerAttachment else {
            return
        }
        //自定义贴图
        if attactment.chartletCatalog == "-1" {
            let vc = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerDialogView(imageUrl: attactment.chartletId, customStickerId: attactment.stickerId) { [weak self] (index) in
                guard let self = self else { return }
                if index == 1 { //保存
                    //需要弹出贴图弹窗
                    DispatchQueue.main.async {
                        self.emojiContainerTapped()
                    }
                } else if (index == 3) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        let vc1 = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerMaxNumDialogView(imageUrl: attactment.chartletId, customStickerId: attactment.stickerId) { (index1) in
                            if index1 == 2 {
                                let stickerVc = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerViewController(stickerId: "")
                                self.navigationController?.pushViewController(stickerVc, animated: true)
                            }
                        }
                        self.present(vc1, animated: true, completion: nil)
                    }
                }
            }
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func tappedAnnouncementMessage(_ cell: BaseMessageCell, url: String?) {
        self.isScrollToBottom = false
        guard let link = url else {
            return
        }
        
        if link == ""  {
            self.view.makeToast("error_message_open_attachment".localized, duration: 3, position: CSToastPositionCenter)
            return
        }
        
        if let urlLink = URL(string: link){
            DependencyContainer.shared.resolveUtilityFactory().handleWeb(url: urlLink, currentVC: self)
        }
    }
    
    func handleRetryMessage(message: MessageData) {
        if let yidunAntiSpamRes = message.nimMessageModel?.yidunAntiSpamRes, yidunAntiSpamRes.isEmpty == false {
            SessionUtil().showYiDunAlertMessage(jsonString: yidunAntiSpamRes)
        } else if let localExt = message.nimMessageModel?.localExt, let yidunAntiSpamRes = localExt["yidunAntiSpamRes"] as? String, yidunAntiSpamRes.isEmpty == false {
            SessionUtil().showYiDunAlertMessage(jsonString: yidunAntiSpamRes)
        } else {
            if message.messageList.count >= 4 {
                // Multi Stack Image
                for var item in message.messageList {
                    self.retryMessage(message: item)
                }
            } else {
                self.retryMessage(message: message)
            }
        }
    }
    
    func retryMessage(message: MessageData) {
        if let messageModel = message.nimMessageModel {
            if (messageModel.isReceivedMsg) {
                do {
                    try NIMSDK.shared().chatManager.fetchMessageAttachment(messageModel)
                } catch {
                    LogManager.Log(error.localizedDescription, loggingType: .exception)
                }
            } else {
                do {
                    self.remove(message)
                    try NIMSDK.shared().chatManager.resend(messageModel)
                } catch {
                    LogManager.Log(error.localizedDescription, loggingType: .exception)
                }
            }
        }
    }
    
    func tappedVoiceMessage(_ cell: BaseMessageCell, message: MessageData, contentView: VoiceMessageContentView) {
        guard let nimMessage = message.nimMessageModel, let audioObject = nimMessage.messageObject as? NIMAudioObject else { return }
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        let milliseconds = Double(audioObject.duration)
        let seconds = milliseconds / 1000.0
        
        if !NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.switch(NIMAudioOutputDevice.speaker)
            pendingAudioMessages = findRemainAudioMessages(message: nimMessage)
            if message.audioIsPaused ?? false {
                if let indexPath = self.dataSource.indexPath(for: message), let data = self.dataSource.itemIdentifier(for: indexPath) {
                    data.audioTimeSeek = seconds
                    data.audioTimeSeek = (message.audioTimeSeek ?? 0.0) - (message.audioLeftDuration ?? 0.0)
                    self.update(message)
                    IMAudioCenter.shared.resume(for: data)
                }
            }
            playTime = Date.timeIntervalSinceReferenceDate
        } else {
            pauseTime = Date.timeIntervalSinceReferenceDate
            message.audioTimeDifferent = pauseTime - playTime
            pendingAudioMessages = nil
            NIMSDK.shared().mediaManager.stopPlay()
            message.audioLeftDuration = (message.audioLeftDuration ?? 0.0) - (message.audioTimeDifferent ?? 0.0)
            message.audioIsPaused = true
        }
    }
    
    func tappedTextUrl(_ url: String?) {
        if let urlString = url, let textUrl = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(textUrl) {
                UIApplication.shared.open(textUrl)
            }
        }
    }
    
    func selectionLanguageTapped(_ cell: BaseMessageCell, message: MessageData) {
        guard let nimMessage = message.nimMessageModel, let audioObject = nimMessage.messageObject as? NIMAudioObject else { return }
        
        var audioPath = audioObject.path ?? ""
        let fileUrl = URL(fileURLWithPath: audioPath)
        
        let voiceToTextVC = VoiceToTextIMViewController(fileUrl: fileUrl, selectedLanguage: currentSelectedLangCode, isLanguageSelection: true)
        voiceToTextVC.onLanguageChanged = { [weak self] model in
            guard let self = self else { return }
            self.currentSelectedLangCode = model
        }
        self.present(voiceToTextVC, animated: true)
    }
    
    //MARK: 打开其他应用
    func openWithDocumentInterator(object: NIMFileObject) {
        let url = URL(fileURLWithPath: object.path ?? "")
        self.interactionController = UIDocumentInteractionController(url: url)
        self.interactionController.delegate = self
        self.interactionController.name = object.displayName ?? ""
        self.interactionController.presentPreview(animated: true)
    }
    
    //MARK: 文件下载
    func downLoadFile(object: NIMFileObject) {
        if let msg = object.message {
            do {
                try NIMSDK.shared().chatManager.fetchMessageAttachment(msg)
            } catch {
                printIfDebug("error = \(error.localizedDescription)")
            }
        }
    }
}

extension IMChatViewController: IMToolChooseDelegate {
    func didSelectedItem(model: IMActionItem) {
        switch model {
        case .stickerCollection:
            self.stickerCollectionIM()
            break
        case .cancelUpload:
            self.cancelUploadIM()
            break
        case .reply:
            self.replyTextIM()
            break
        case .copy:
            self.copyTextIM()
            break
        case .copyImage:
            self.copyImageIM()
            break
        case .forward:
            self.forwardTextIM()
            break
        case .edit:
            self.revokeTextIM()
            break
        case .delete:
            self.deleteTextIM()
            break
        case .translate:
            self.translateTextIM()
            break
        case .voiceToText:
            self.voiceToTextIM()
            break
        case .collection:
            self.messageCollectionIM()
            break
        case .save:
            self.saveMsgCollectionIM()
            break
        case .forwardAll:
            self.forwardAllImageIM()
            break
        case .deleteAll:
            self.deleteAllImageIM()
            break
        case .pinned:
            self.pinnedMessage()
        case .unPinned:
            if let message = messageForMenu.nimMessageModel, let model = pinnedList.filter({ pinnedModel in
                pinnedModel.im_msg_id == message.messageId
            }).first {
                self.unPinnedMessage(model: model)
            }
            
        default:
            break
        }
    }
}

extension IMChatViewController {
    @objc func closeEggView() {
        eggOverlayView.removeFromSuperview()
        self.eggAttachment = nil
    }
    
    @objc func checkOpenEggStatus() {
        self.isScrollToBottom = false
        eggOverlayView.removeFromSuperview()
        
        guard let attachment = self.eggAttachment, let eggId = Int(attachment.eggId) else { return }
        self.hideKeyboard()
        SVProgressHUD.show()
        self.view.isUserInteractionEnabled = false
        let isGroup = self.session.sessionType == .P2P ? false : true
        YippiAPI.togaShared.sessionOpenEgg(eggId: eggId, isGroup: isGroup) { [weak self] (eggResponse, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                if error == nil {
//                    let vc = UIStoryboard(name: "Egg", bundle: Bundle.main).instantiateViewController(withIdentifier: "egg_detail") as! EggDetailViewController
//                    vc.info = eggResponse
//                    vc.isSender = self.isEggAttachmentOutgoing ?? true
//                    vc.isGroup = isGroup
//                    let nav = TSNavigationController(rootViewController: vc, availableOrientations: [.portrait]).fullScreenRepresentation
//                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
//                        self.present(nav, animated: true, completion: {  [weak self] in
//                            guard let self = self else { return }
//                            self.closeEggView()
//                        })
//                    }
                } else {
                    self.closeEggView()
                    self.view.makeToast(error?.localizedDescription, duration: 2.0, position: CSToastPositionCenter)
                }
                
                self.view.isUserInteractionEnabled = true
            }
        }
        //        if self.session.sessionType == .P2P {
        //            YippiAPI.shared.sessionOpenPersonalEgg(eggId: eggId, completion: {eggResponseModel, error in
        //                DispatchQueue.main.async {
        //                    SVProgressHUD.dismiss()
        //                    if error == nil {
        //                        let vc = UIStoryboard(name: "Egg", bundle: Bundle.main).instantiateViewController(withIdentifier: "egg_detail") as! EggDetailViewController
        //                        //MARK: eggResponseModel  error
        //                        //vc.info = eggResponseModel
        //                        vc.isSender = self.isEggAttachmentOutgoing ?? true
        //                        let nav = UINavigationController(rootViewController: vc)
        //                        nav.modalPresentationStyle = .fullScreen
        //                        self.navigationController?.present(nav, animated: true, completion: nil)
        //                    } else {
        //                        self.closeEggView()
        //                        self.view.makeToast(error?.localizedDescription, duration: 2.0, position: CSToastPositionCenter)
        //                    }
        //
        //                    self.view.isUserInteractionEnabled = true
        //                }
        //            })
        //        } else {
        //            YippiAPI.shared.sessionOpenGroupEgg(eggId: eggId, groupId: self.session.sessionId, completion: {eggResponseModel, error in
        //                DispatchQueue.main.async {
        //                    SVProgressHUD.dismiss()
        //                    if error == nil {
        //                        let vc = UIStoryboard(name: "Egg", bundle: Bundle.main).instantiateViewController(withIdentifier: "egg_detail") as! EggDetailViewController
        //                        //MARK: eggResponseModel  error
        //                        //vc.info = eggResponseModel
        //                        vc.isSender = self.isEggAttachmentOutgoing ?? true
        //                        let nav = UINavigationController(rootViewController: vc)
        //                        nav.modalPresentationStyle = .fullScreen
        //                        self.navigationController?.present(nav, animated: true, completion: nil)
        //                    } else {
        //                        self.closeEggView()
        //                        self.view.makeToast(error?.localizedDescription, duration: 2.0, position: CSToastPositionCenter)
        //                    }
        //
        //                    self.view.isUserInteractionEnabled = true
        //                }
        //            })
        //        }
    }
    
    private func renderEggView() {
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = .fade
        eggOverlayView.layer.add(transition, forKey: nil)
        eggOverlayView.frame = UIScreen.main.bounds
        let count = UIApplication.shared.windows.count
        UIApplication.shared.windows[count - 1].addSubview(eggOverlayView)
        UIApplication.shared.windows[count - 1].bringSubviewToFront(eggOverlayView)
    }
    
    private func previewVideoMedia(by videoObject: NIMVideoObject) -> MediaPreviewObject {
        let previewObject = MediaPreviewObject()
        previewObject.objectId  = videoObject.message?.messageId
        previewObject.thumbPath = videoObject.coverPath
        previewObject.thumbUrl  = videoObject.coverUrl
        previewObject.path      = videoObject.path
        previewObject.url       = videoObject.url
        previewObject.type      = MediaPreviewType.video
        previewObject.timestamp = TimeInterval(videoObject.message?.timestamp ?? 0)
        previewObject.displayName = videoObject.displayName
        previewObject.duration  = TimeInterval(videoObject.duration)
        previewObject.imageSize = videoObject.coverSize
        previewObject.imageSize = videoObject.coverSize
        return previewObject
    }
    
    private func previewImageMedia(by imageObject: NIMImageObject) -> MediaPreviewObject {
        let previewObject = MediaPreviewObject()
        previewObject.objectId = imageObject.message?.messageId
        previewObject.thumbPath = imageObject.thumbPath
        previewObject.thumbUrl  = imageObject.thumbUrl
        previewObject.path      = imageObject.path
        previewObject.url       = imageObject.url
        previewObject.type      = MediaPreviewType.image
        previewObject.timestamp = TimeInterval(imageObject.message?.timestamp ?? 0)
        previewObject.displayName = imageObject.displayName
        previewObject.imageSize = imageObject.size
        return previewObject
    }
    
    private func showShareContent(_ url: URL) {
        if url.host?.lowercased().contains("yippi") ?? false {
            if url.pathComponents.containsIgnoringCase("feeds") {
                if let detailIDString = url.pathComponents.last, let detailID = Int(detailIDString) {
                    self.navigateLive(feedId: detailID, isDeepLink: true)
                }
            }else {
                FeedIMSDKManager.shared.delegate?.didShowDeeplink(urlString: url.absoluteString)
               // self.deeplink(urlString: url.absoluteString)
            }
//            let itemID = Int(url.lastPathComponent) ?? 0
//            if url.absoluteString.contains("users") {
//                let vc = HomePageViewController(userId: itemID, username: "")
//                //TSHomepageVC(itemID, userName: "")
//                self.navigationController?.pushViewController(vc, animated: true)
//            } else if url.absoluteString.contains("feeds") {
//                SVProgressHUD.show()
//                DependencyContainer.shared.resolveUtilityFactory().navigateToLive(feedId: itemID, viewController: self) { [weak self] suceess in
//                    SVProgressHUD.dismiss()
//                    if !suceess {
//                        DispatchQueue.main.async {
//                            //self.liveEndAlert()
//                            //Change alert dialog to empty screen
//                            let vc = NoContentController()
//                            self?.navigationController?.pushViewController(vc, animated: true)
//                        }
//                    }
//                }
//            } else if url.absoluteString.contains("voucher") {
//                let vc = VoucherDetailViewController()
//                vc.voucherId = itemID
//                self.navigationController?.pushViewController(vc, animated: true)
//            } else {
//                if UIApplication.shared.canOpenURL(url) {
//                    UIApplication.shared.open(url)
//                }
//            }
        } else {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func liveEndAlert() {
        let alertController = UIAlertController(title: nil, message: "text_livestream_ended".localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true)
    }
    
    private func showRevokeButton(_ message: NIMMessage) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let result = currentTime - message.timestamp
        
        if ((message.timestamp > 0) && result >= 120) == true {
            return false
        }
        return true
    }
    
    private func showRevokeEditButton(_ message: NIMMessage) -> Bool {
        if message.timestamp > 0 {
            let currentTime = Date().timeIntervalSince1970
            let result = currentTime - (message.timestamp )
            if result >= 60 {
                return false
            }
        }
        return true
    }
    
    private func showTextTranslateButton(_ message: NIMMessage) -> Bool {
        guard let model = get(message) else { return false }
        if model.isTranslated != nil || message.isOutgoingMsg == true {
            return false
        }
        return SessionUtil().canMessageBeTranslated(model)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y == -(self.setTopContentInset()) {
            //firstScrollNo = false
            if self.messageManager.isNeedFetchMessageForService {
                fetchMessageForService()
            } else {
                fetchHistory()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 40 {
            isAutoScrollEnabled = true
        } else {
            isAutoScrollEnabled = false
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging == true && !isAutoScrollEnabled {
            scrollToBottomBtn.setViewHidden(self.isScrolledToBottom())
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrollToBottom = false
        hideKeyboard()
        isAutoScrollEnabled = false
    }
    
    func isScrolledToBottom() -> Bool {
        return tableview.contentOffset.y >= (tableview.contentSize.height - tableview.bounds.size.height)
    }
    
    private func scrollToUnread() {
        guard let indexPath = unreadMessageIndexPath() else {
            return
        }
        self.scrollToMessage(by: indexPath, animation: true)
        self.scrollToUnreadView.isHidden = true
        self.isAutoScrollEnabled = false
        self.isUnreadMessage = true
    }
    
    private func scrollToMessage(by indexpath: IndexPath, animation: Bool) {
        self.tableview.scrollToRow(at: indexpath, at: .top, animated: false)
        
        if animation {
            self.perform(#selector(cellAnimation(indexpath:)), with: indexpath, afterDelay: 0.3)
        }
    }
    
    @objc func cellAnimation(indexpath: IndexPath) {
        guard let cell = self.tableview.cellForRow(at: indexpath) as? BaseMessageCell, let bubble = cell.bubbleContentView else { return }
        let layer = CALayer()
        layer.frame = bubble.bounds
        bubble.layer.addSublayer(layer)
        let colorsAnimation = CAKeyframeAnimation(keyPath: "backgroundColor")
        colorsAnimation.values = [UIColor(red: 0.81, green: 0.81, blue: 0.81, alpha: 1.0).cgColor].compactMap { $0 }
        colorsAnimation.fillMode = .forwards
        colorsAnimation.duration = 1.0
        colorsAnimation.autoreverses = true
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.toValue = NSNumber(value: 0)
        fade.duration = 1.0
        let pulse = CABasicAnimation(keyPath: "transform.scale")
        pulse.toValue = NSNumber(value: 2)
        
        let group = CAAnimationGroup()
        group.duration = 1.0
        group.animations = [colorsAnimation, fade]
        layer.add(group, forKey: nil)
    }
}

extension IMChatViewController: CustomInputBarDelegate {
    func moreTapped() {
        if let view = view as? KeyInputView {
            view.becomeFirstResponder()
            showmMoreContainer()
            hideAudioRecording()
        }
    }
    
    func imageTapped() {
        self.hideKeyboard()
        self.hideAudioRecording()
        
        TSUtil.checkAuthorizeEnableByType(type: .album, completionHandler: { status in
            if status == .firstDenied {
                return
            }
            
            if status == .denied {
                let vc = IMPermissionViewController(permissionType: .album)
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            self.openMedia()
        })
    }
    
    func cameraTapped() {
        self.hideKeyboard()
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        
        TSUtil.checkAuthorizeEnableByType(type: .camera, completionHandler: { status in
            if status == .firstDenied {
                return
            }
            
            if status == .denied {
                let vc = IMPermissionViewController(permissionType: .camera)
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
            self.openCamera()
        })
    }
    
    func attachmentTapped() {
        if let view = view as? KeyInputView {
            view.becomeFirstResponder()
            showmFileContainer()
            hideAudioRecording()
        }
    }
    
    func eggTapped() {
        self.hideKeyboard()
        self.stickerContainerView?.isHidden = true
        self.moreContainerView?.isHidden = true
        self.onClickedEgg = true
        
        var isP2P: Bool? = nil
        var noOfMember: Int? = nil
        var tid: String? = nil
        
        switch self.session.sessionType {
        case .P2P:
            noOfMember = 0
            isP2P = true
            break
        case .team:
            tid = self.session.sessionId
            let team = NIMSDK.shared().teamManager.team(byId: self.session.sessionId)
            noOfMember = team?.memberNumber ?? 0
            isP2P = false
            break
        default:
            break
        }
        
        if let isP2P = isP2P, let numberOfMember = noOfMember {
            let vc = RedPacketViewController(transactionType: isP2P ? .personal : .group,
                                             fromUser: NIMSDK.shared().loginManager.currentAccount(),
                                             toUser: self.session.sessionId,
                                             numberOfMember: numberOfMember,
                                             teamId: tid,
                                             completion: { [weak self] rid, uid, message in
                guard let self = self else { return }
                self.onClickedEgg = false
                self.isRedPacket = true
                if let message = self.messageManager.eggMessage(with: rid, tid: tid, uid: uid, messageStr: message) {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                        self.messageManager.sendMessage(message)
                    }
                }
            })
            //            let nav = UINavigationController(rootViewController: vc)
            //            self.navigationController?.present(nav.fullScreenRepresentation, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func videoCallTapped() {
        self.hideKeyboard()
        if self.session.sessionType == .P2P {
            self.videoCall()
        } else if self.session.sessionType == .team {
            self.teamMeeting()
        }
    }
    
    func voiceCallTapped() {
        self.hideKeyboard()
        self.voiceCall()
    }
    
    func onContactTapped() {
        self.hideKeyboard()
        
        let vc = ShareContactsViewController(cancelType: .allwayNoShow)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
        vc.compleleHandle = { [weak self] (contacts) in
            guard let self = self else { return }
            for contactData in contacts {
                let message = self.messageManager.contactCardMessage(with: contactData.userName)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                    self.messageManager.sendMessage(message)
                }
            }
        }
    }
    
    // MARK: - 白板
    func onWhiteboardTapped() {
        self.hideKeyboard()
        let currentUid = NIMSDK.shared().loginManager.currentAccount()
        
        if (self.checkCondition() == false ) {return}
        let timeStamp = Date().timeIntervalSince1970
        TSIMNetworkManager.createWhiteboard(roomName: currentUid + timeStamp.toString()) {[weak self] model, error in
            guard let self = self else {return}
            if let error = error {
                self.showError(message: error.localizedDescription)
            } else {
                self.whiteboardRoomId = model?.data?.cid ?? 0
                let param = NMCWhiteBoardParam()
                param.uid = UInt(TSCurrentUserInfo.share.userInfo?.userIdentity ?? 1)
                param.appKey = Constants.NIMKey
                param.channelName = self.whiteboardRoomId.stringValue
                param.webViewUrl = FeedIMSDKManager.shared.param.apiBaseURL + kwebViewUrl

                DispatchQueue.main.async {
                    let vc = NMCWhiteBoardViewController(whiteBoardParam: param)
                    self.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true)
                }
                self.sendWhiteboardMessage(channel: self.whiteboardRoomId.stringValue)  
            }
        }
    }
    
    func onLocationTapped() {
        if let view = view as? KeyInputView {
            view.becomeFirstResponder()
            self.hideAudioRecording()
            TSUtil.checkAuthorizeEnableByType(type: .location, completionHandler: { status in
                if status == .firstDenied {
                    return
                }
                if status == .denied {
                    let vc = IMPermissionViewController(permissionType: .location)
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                }
                DispatchQueue.main.async {
                    self.showLocalContainer()
                }
            })
        }
    }
    
    func sendWhiteboardMessage(channel: String) {
        let attachment = IMWhiteboardAttachment()
        attachment.channel = channel
        attachment.creator = NIMSDK.shared().loginManager.currentAccount()
        let message = NIMMessage()
        let customObject = NIMCustomObject()
        customObject.attachment = attachment
        message.messageObject = customObject
        message.apnsContent = "recent_msg_desc_whiteboard".localized
        do {
            try NIMSDK.shared().chatManager.send(message, to: self.session)
        } catch {
            
        }
    }
    
    func onVoiceToTextTapped() {
        self.hideKeyboard()
        let vc = SpeechTyperViewController()
        let tDelegate = TransitioningDelegate(height: keyboardHeight)
        vc.collapseFrameHeight = keyboardHeight
        vc.transitionDelegate = tDelegate
        vc.transitioningDelegate = tDelegate
        vc.modalPresentationStyle = .custom
        
        PopupWindowManager.shared.changeKeyWindow(rootViewController: vc, height: keyboardHeight)
        vc.closure = { [weak self] (text) in
            guard let self = self, let text = text else { return }
            let message = self.messageManager.textMessage(with: text)
            self.messageManager.sendMessage(message)
        }
    }
    
    func onRPSTapped() {
        let message = self.messageManager.rpsMessage()
        self.messageManager.sendMessage(message)
    }
    
    //收藏的消息
    func oncollectionMessageTapped() {
        self.isScrollToBottom = false
        self.hideKeyboard()
        let vc = MsgCollectionViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func onSecretMessageTapped() {
        self.hideKeyboard()
        startSecretMessage()
    }
    
    func emojiContainerTapped() {
        if let view = view as? KeyInputView {
            view.becomeFirstResponder()
            showEmoticonContainer()
            hideAudioRecording()
        }
    }
    
    // MARK: Audio
    func onStartRecording() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
        if NIMSDK.shared().mediaManager.isPlaying() {
            NIMSDK.shared().mediaManager.stopPlay()
        }
        inputBar.recognizedText = ""
        inputBar.recording = true
        let type = self.sessionConfig.recordType()
        let duration = self.sessionConfig.recordMaxDuration()
        
        NIMSDK.shared().mediaManager.add(self)
        NIMSDK.shared().mediaManager.record(type, duration: 65)
        //保存识别结果
        SpeechVoiceDetectManager.shared.state = .recording
        SpeechVoiceDetectManager.shared.onReceiveValue = { [weak self] (receiveValue, isFinal) in
            guard let self = self else { return }
            printIfDebug("receiveValue \(receiveValue)")
            //判断识别结果是否为空
            guard let receiveValue = receiveValue, receiveValue.count > 0 else {
                //判断之前识别到了结果，但是最终为nil 取用之前的结果显示
                if self.receiveResult.count > 0 {
                    self.inputBar.recordPhase = .converted
                    self.inputBar.recognizedText = self.receiveResult
                } else if self.inputBar.audioRecordIndicator.moreButton.isHidden == false && isFinal {
                    //判断是否是二次识别，需要更改状态为识别错误
                    self.inputBar.recordPhase = .converterror
                }
                return
            }
            
            self.receiveResult = receiveValue
            // 在识别错误的前提下，识别到了文字，将状态改回识别成功状态
            if self.receiveResult.count > 0 && self.inputBar.audioRecordIndicator.convertErrorView.isHidden == false {
                self.inputBar.recordPhase = .converted
            }
            //识别结果赋值给TextView
            self.inputBar.recognizedText = self.receiveResult
        }
        
        SpeechVoiceDetectManager.shared.onRequestAuthorizationStateChanged = { [weak self] (state,errorMsg) in
            guard let self = self else { return }
            if state != .authorized {
                //声音授权出现问题
                self.inputBar.audioRecordIndicator.authErrorMsg = errorMsg
                self.showTopFloatingToast(with: errorMsg ?? "", desc: "")
            }
        }
        
        var dotCount = 1 // 初始点数为 3
        SpeechVoiceDetectManager.shared.onDurationChanged = { [weak self] (duration) in
            guard let self = self else { return }
            if dotCount == 1 {
                dotCount = 2
            } else if dotCount == 2 {
                dotCount = 3
            } else if dotCount == 3 {
                dotCount = 1
            }
            let dots = String(repeating: "·", count: dotCount)
            
            self.inputBar.audioRecordIndicator.countDownNumber = duration
            self.inputBar.audioRecordIndicator.recognizedTextView.text = "\(self.inputBar.recognizedText)\(dots)"
        }
        
        SpeechVoiceDetectManager.shared.onRecordEnd = { [weak self] in
            guard let self = self else { return }
            self.onRecordEnd()
        }
    }
    
    func onStopRecording() {
        NIMSDK.shared().mediaManager.stopRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.inputBar.audioRecordIndicator.countDownNumber = 60
        self.recognizedText = ""
    }
    
    func onRecordEnd() {
        let isConvert = (self.inputBar.recordPhase == .converting || self.inputBar.recordPhase == .converted)
        if isConvert && self.inputBar.recognizedText.isEmpty {
            //没有识别到任何文字
            self.inputBar.recordPhase = .converterror
        } else {
            self.inputBar.recordPhase = isConvert == true ? .converted : .end
        }
    }
    
    func onCancelRecording() {
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.inputBar.audioRecordIndicator.countDownNumber = 60
        self.inputBar.audioRecordIndicator.recognizedTextView.text = ""
        self.recognizedText = ""
    }
    
    func onConverting() {
        SpeechVoiceDetectManager.shared.stopRecording()
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    func onConvertError() {
        SpeechVoiceDetectManager.shared.stopRecording()
        self.inputBar.audioRecordIndicator.countDownNumber = 60
        NIMSDK.shared().mediaManager.stopRecord()
    }
    
    //取消发送
    func cancelButtonTapped() {
        self.view.resignFirstResponder()
        self.handleKeyboardLogic()
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.recognizedText = ""
        inputBar.recording = false
    }
    
    //发送原语音
    func sendVoiceButtonTapped() {
        self.view.resignFirstResponder()
        self.handleKeyboardLogic()
        if let message = self.saveAudioMessage, let audioObject = message.messageObject as? NIMAudioObject {
            let volumeLevels = self.getVolumeLevels()
            guard let audioObject = message.messageObject as? NIMAudioObject else { return }
            message.messageObject = audioObject
            message.remoteExt = ["voice":volumeLevels]
            self.messageManager.sendMessage(message)
            
            inputBar.recording = false
        }
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
    }
    
    //发送语音文字
    func sendVoiceMsgTextButtonTapped() {
        self.view.resignFirstResponder()
        self.handleKeyboardLogic()
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        var recognizedText = self.inputBar.audioRecordIndicator.recognizedTextView.text ?? ""
        if recognizedText != "" {
            let message = self.messageManager.textMessage(with: recognizedText)
            self.messageManager.sendMessage(message)
        }
        self.recognizedText = ""
        inputBar.recording = false
    }
    
    //弹出更多语言页面
    func moreLanguageButtonTapped() {
        let vc = IMAudioLanguageViewController()
        vc.onLanguageCodeDidSelect =  { [weak self] (langCode) in
            guard let self = self else { return }
            self.inputBar.recordPhase = .converted
            self.receiveResult = ""
            SpeechVoiceDetectManager.shared.convertToTextWithAudioFile(filePath: self.saveAudioFilePath ?? "", langCode: langCode)
        }
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        self.present(vc, animated: true, completion: nil)
    }
    
    func pasteImage(image: UIImage) {
        let editor = AppUtil().createPhotoEditor(for: image)
        editor?.photoEditorDelegate = self
        self.present(editor!.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func onPasteMentioned(usernames: [String], _ message: String) {
        self.inputBar.inputTextView.insertText(message)
        
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: usernames) { [weak self] models, _, _  in
            guard let self = self, let models = models else { return }
            self.mentionsUsernames.append(contentsOf: models.compactMap { AutocompleteCompletion(text: $0.displayName, context: ["username": $0.username]) })
            DispatchQueue.main.async {
                guard let session = self.autocompleteManager.currentSession else { return }
                session.completion = self.mentionsUsernames.last
                self.autocompleteManager.autocomplete(with: session)
                
                self.autocompleteManager.unregisterCurrentSession()
            }
        }
    }
}

extension IMChatViewController: TZImagePickerControllerDelegate {
//    func showYippiCamera(cameraModes: [CameraMode] = [.photo, .video]) {
//        let vc = YippiCameraViewController.launch { [weak self] (videoAsset, imageAsset, videoPath, images, _) in
//            guard let self = self else { return }
//            if let path = videoPath {
//                let message = self.messageManager.videoMessage(with: path)
//                self.messageManager.sendMessage(message)
//            } else if let images = images {
//                for img in images {
//                    if let message = self.messageManager.imageMessage(with: img) {
//                        self.messageManager.sendMessage(message)
//                    }
//                }
//            }
//        }
//        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//        present(nav, animated: true)
//    }
}

//extension IMChatViewController: NIMLocationViewControllerDelegate {
//    func onSendLocation(_ locationPoint: NIMKitLocationPoint) {
//        let message = self.messageManager.locationMessage(with: locationPoint)
//        self.messageManager.sendMessage(message)
//    }
//}

extension IMChatViewController: InputEmoticonProtocol {
    func didPressSend(_ sender: Any?) {
        
    }
    
    func didPressAdd(_ sender: Any?) {
        //        self.inputBar.inputTextView.resignFirstResponder()
        //        self.view.endEditing(true)
        //        stickerContainerView?.isHidden = true
        hideKeyboard()
        let vc = StickerMainViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        guard let stickerUrl = emoticonID, let bundleId = emotCatalogID, let stickerId = stickerId else { return }
        let message = self.messageManager.stickerMessage(with: bundleId, stickerUrl: stickerUrl, stickerId: stickerId)
        self.messageManager.sendMessage(message)
    }
    
    func sendEmoji(_ emojiTag: String?) {
        guard let emojiTag = emojiTag else { return }
        self.inputBar.inputTextView.insertText(emojiTag)
    }
    
    func didPressMySticker(_ sender: Any?) {
        //        self.inputBar.inputTextView.resignFirstResponder()
        //        self.view.endEditing(true)
        //        stickerContainerView?.isHidden = true
        hideKeyboard()
        let vc = MyStickersViewController()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didPressCustomerSticker() {
        //        self.inputBar.inputTextView.resignFirstResponder()
        //        self.view.endEditing(true)
        //        stickerContainerView?.isHidden = true
        hideKeyboard()
        let vc = CustomerStickerViewController(sticker: "")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: Autocompletion
extension IMChatViewController : AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    func autocompleteManager(_ manager: AutocompleteManager, shouldBecomeVisible: Bool) {
        
    }
    
    // MARK: - AutocompleteManagerDataSource
    func autocompleteManager(_ manager: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
        if prefix == "@" {
            return mentionsUsernames
        }
        
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
    
    func autocompleteManagerShouldChangeInCharacter(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) {
        if text == "@" {
            NIMSDK.shared().teamManager.fetchTeamMembers(fromServer: self.session.sessionId) { [weak self] (error, members) in
                guard let self = self else { return }
                guard error == nil else { return }
                
                if let members = members {
                    var teamMembers = [String]()
                    teamMembers = members.filter({ $0.userId != NIMSDK.shared().loginManager.currentAccount() }).map({ $0.userId ?? "" })
                    
                    let contactsPickerVC = ContactsPickerViewController(configuration: ContactsPickerConfig.mentionConfig(teamMembers), finishClosure: nil)
                    contactsPickerVC.modalPresentationStyle = .fullScreen
                    
                    contactsPickerVC.cancelClosure = { [weak self] in
                        guard let self = self else { return }
                        self.inputBar.inputTextView.deleteBackward()
                        self.onClickedContact = true
                    }
                    
                    contactsPickerVC.finishClosure = { [weak self] contacts in
                        guard let self = self else { return }
                        self.mentionsUsernames.append(contentsOf: contacts.filter { String($0.userName) != NIMSDK.shared().loginManager.currentAccount() }.map { user in
                            return AutocompleteCompletion(text: String(user.displayname),
                                                          context: ["username": user.userName])
                        })
                        
                        for (index, user) in contacts.enumerated() {
                            guard let session = self.autocompleteManager.currentSession else { return }
                            session.completion = AutocompleteCompletion(text: String(user.displayname),
                                                                        context: ["username": user.userName])
                            self.autocompleteManager.autocomplete(with: session)
                            if index != contacts.count - 1 {
                                self.inputBar.inputTextView.insertText(" @")
                            }
                        }
                        
                        self.autocompleteManager.unregisterCurrentSession()
                        
                        self.stickerContainerView?.isHidden = true
                        self.moreContainerView?.isHidden = true
                        self.onClickedContact = true
                        
                        self.inputBar.inputTextView.becomeFirstResponder()
                    }
                    
                    //                    self.inputBar.inputTextView.resignFirstResponder()
                    //                    self.view.endEditing(true)
                    self.hideKeyboard()
                    let nav = TSNavigationController(rootViewController: contactsPickerVC)
                    nav.modalPresentationStyle = .overFullScreen
                    
                    self.present(nav, animated: true, completion: nil)
                }
            }
        }
    }
}

extension IMChatViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if inputBar.inputTextView.text.isEmpty {
            self.inputBar.checkAudioPermission { [weak self] success in
                guard let self = self else { return }
                if success {
                    self.getSpeechRecognizerAuthorizationStatus()
                    if self.inputBar.recordButton.isHidden == true {
                        self.inputBar.configureHoldToTalk()
                        self.hideKeyboard()
                    } else {
                        self.inputBar.hideHoldToTalk()
                    }
                }
            }
        } else {
            if text.isValidURL() {
                guard let contentUrl = TSUtil.matchUrlInString(urlString: text) else { return }
                let message = self.messageManager.socialPostMessage(link: text, contentUrl: contentUrl.absoluteString)
                self.messageManager.sendMessage(message)
                inputBar.inputTextView.text = String()
                return
            }
            
            let mentionUsernames = mentionsUsernames.compactMap { $0.context?["username"] as? String }
            inputBar.inputTextView.text = String()
            
            if self.replyView.isHidden {
                let message = self.messageManager.textMessage(with: text)
                self.messageManager.sendMessage(message, mentionUsernames)
            } else {
                if let repliedMsg = messageForMenu.nimMessageModel {
                    replyView.isHidden = true
                    let message = self.replyMessage(with: repliedMsg, replyView: replyView, text: text)
                    self.messageManager.sendMessage(message, mentionUsernames)
                }
            }
            self.mentionsUsernames.removeAll()
        }
    }
    
    func inputBarTextViewDidBeginEditing(_ inputBar: InputBarAccessoryView) {
        self.stickerContainerView?.isHidden = true
        self.moreContainerView?.isHidden = true
        // self.inputStauts = InputStauts(rawValue: 1)!
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        notificaionSender.sendTypingState(session: self.session)
    }
}

extension IMChatViewController {
    func stickerCollectionIM() {
        EventTrackingManager.instance.track(event: .collectionClicked)
        showStickerCollection()
    }
    
    func cancelUploadIM() {}
    
    func replyTextIM() {
        guard let message = messageForMenu.nimMessageModel else { return }
        self.replyView.isHidden = false
        self.replyView.configure(message)
    }
    
    func copyTextIM() {
        EventTrackingManager.instance.track(event: .copyMessageClicked)
        guard let message = messageForMenu.nimMessageModel else { return }
        let pasteboard = UIPasteboard.general
        if let object = message.messageObject as? NIMCustomObject {
            if let attachment = object.attachment as? IMReplyAttachment {
                pasteboard.string = attachment.content
            } else if let attachment = object.attachment as? IMSocialPostAttachment {
                pasteboard.string = attachment.postUrl
            } else if let attachment = object.attachment as? IMMeetingRoomAttachment {
                pasteboard.string = attachment.meetingNum
            }
        } else {
            guard let messageText = message.text else { return }
            let ext = message.remoteExt
            let usernames = ext?["usernames"] as? [String] ?? []
            if (usernames.count) > 0 {
                pasteboard.items = [["usernames": usernames.joined(separator: ","), "message": messageText]]
            } else {
                pasteboard.string = messageText
            }
        }
    }
    
    func copyImageIM() {}
    
    func forwardTextIM() {
        self.showSelectActionToolbar(true, isDelete: false)
    }
    
    private func showSelectActionToolbar(_ show: Bool, isDelete: Bool) {
        self.selectActionToolbar.setToolbarHidden(!show)
        self.inputBar.isHidden = show
        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, action: {})
        
        if show {
            guard let message = messageForMenu.nimMessageModel, let menuMessage = messageForMenu else { return }
            selectedMsgId = [message.messageId]
            self.selectedItem.bounds = CGRect(x: 0, y: 0, width: self.selectActionToolbar.bounds.width / 4, height: self.selectActionToolbar.bounds.height)
            let selectedItem1 = UIBarButtonItem(customView: self.selectedItem)
            if (isDelete) {
                self.dataSource.isForwarding = false
                self.selectActionToolbar.setItems([self.deleteButton, spacing, selectedItem1, spacing], animated: true)
            } else {
                self.dataSource.isForwarding = true
                self.selectActionToolbar.setItems([self.shareButton, spacing, selectedItem1, spacing], animated: true)
            }
            
            self.tableview.allowsMultipleSelectionDuringEditing = true
            self.tableview.setEditing(true, animated: false)
            if let msgIndexPath = getIndexPath(for: menuMessage) {
                self.updateTableViewSelection(by: msgIndexPath, select: true)
            }
            
            self.updateShareButton()
            self.updateRevokeButton()
            self.updateSelectedItem()
        } else {
            tableview.setEditing(show, animated: true)
            
            let selectedMessage = tableview.indexPathsForSelectedRows
            for path in selectedMessage ?? [] {
                tableview.deselectRow(at: path, animated: false)
            }
        }
        setupNav()
    }
    
    func updateTableViewSelection(by messageIndexPath: IndexPath, select: Bool) {
        if select {
            updateSelectedItem()
            tableview.selectRow(at: messageIndexPath, animated: true, scrollPosition: .none)
        } else {
            updateSelectedItem()
            tableview.deselectRow(at: messageIndexPath, animated: true)
        }
    }
    
    func updateSelectedItem() {
        selectedItem.setTitle(String(format: "msg_number_of_selected".localized, String(format: "%i", selectedMsgId.count)), for: .normal)
    }
    
    func updateShareButton() {
        shareButton.isEnabled = true
        let selectedMessage = tableview.indexPathsForSelectedRows
        
        selectedMessage?.forEach({ indexPath in
            let model = dataSource.itemIdentifier(for: indexPath)
            if let message = model?.nimMessageModel {
                if !SessionUtil().canMessageBeForwarded(message) {
                    shareButton.isEnabled = false
                }
            }
        })
    }
    
    func updateRevokeButton() {
        deleteButton.isEnabled = true
        //        let selectedMessage = tableview.indexPathsForSelectedRows
        //
        //        for messageIndexPath in selectedMessage ?? [] {
        //            let model = dataSource.itemIdentifier(for: messageIndexPath)
        //            if let message = model?.nimMessageModel {
        //                if !SessionUtil().canMessageBeRevoked(message) {
        //                    deleteButton.isEnabled = false
        //                    break
        //                }
        //            }
        //        }
    }
    
    func revokeTextIM() {
        guard let message = messageForMenu.nimMessageModel else { return }
        EventTrackingManager.instance.track(event: .revokeAndEditClicked)
        message.apnsContent = nil
        message.apnsPayload = nil
        NIMSDK.shared().chatManager.revokeMessage(message, completion: { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error != nil {
                    if (error! as NSError).code == 508 {
                        let alertController = UIAlertController(title: nil, message: "revoke_failed".localized, preferredStyle: .alert)
                        let cancelAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil)
                        alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                    } else {
                        self.view.makeToast("revoke_try_again".localized, duration: 2.0, position: CSToastPositionCenter)
                    }
                } else {
                    //TODO: add tip after revoke message
                    self.remove(self.messageForMenu)
                    self.inputBar.inputTextView.insertText(message.text ?? "")
                    
                    self.moreContainerView?.isHidden = true
                    self.inputBar.inputTextView.becomeFirstResponder()
                    
//                    let tip = IMSessionMsgConverter.shared.msgWithTip(tip: NTESSessionUtil.tip(onMessageRevoked: nil))
//                    guard let tips = tip else { return }
                    // By Kit Foong (duplicate add tips, conversation Manager will add tips)
                    //self.add([MessageData(tips)])
//                    tips.timestamp = message.timestamp
                    //NIMSDK.shared().conversationManager.save(tips, for: message.session!, completion: nil)
                    do{
//                        try NIMSDK.shared().chatManager.send(tips, to: message.session!)
                    }catch {
                        
                    }
                }
            }
        })
    }
    
    func deleteTextIM() {
        self.showSelectActionToolbar(true, isDelete: true)
    }
    
    func translateTextIM() {
        EventTrackingManager.instance.track(event: .translateClicked)
        if let message = self.messageForMenu.nimMessageModel {
            var messageText = message.text
            if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMReplyAttachment {
                messageText = attachment.content
            }
            
            if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMSocialPostAttachment {
                messageText = attachment.postUrl
            }
            
            if messageText == nil || messageText == "" { return }
            self.textTranslate(withText: messageText!, oriMessage: self.messageForMenu)
        }
    }
    
    private func textTranslate(withText messageText: String, oriMessage: MessageData, translateMessage: MessageData? = nil) {
        oriMessage.isTranslated = true
        update(oriMessage)
        
        ChatroomNetworkManager().translateTexts(message: messageText, onSuccess: { [weak self] message in
            guard let self = self else { return }
            if let translateMessage = translateMessage {
                let data = self.messageManager.updateTranslateMessage(for: translateMessage, with: message)
                self.update(data)
            } else {
                let data = self.messageManager.translateMessage(oriMessage, with: message)
                self.insert(message: data, after: oriMessage, completion: {
                    if let indexPath = self.dataSource.indexPath(for: data), let cell = self.tableview.cellForRow(at: indexPath) as? BaseMessageCell {
                        let barHeight = self.inputBar.bounds.height
                        var bottomHeight = self.bottomInfoView.height
                        
                        if (cell.frame.y + cell.height + barHeight + bottomHeight) > self.tableview.contentSize.height && self.isAutoScrollEnabled {
                            self.scrollToBottom()
                        }
                    }
                })
            }
        }, onFailure: { [weak self] errMsg, code in
            guard let self = self else { return }
            if let translateMessage = translateMessage {
                let data = self.messageManager.updateTranslateMessage(for: translateMessage, with: errMsg)
                self.update(data)
            } else {
                let data = self.messageManager.translateMessage(oriMessage, with: errMsg)
                self.insert(message: data, after: oriMessage, completion: {
                    if let indexPath = self.dataSource.indexPath(for: data), let cell = self.tableview.cellForRow(at: indexPath) as? BaseMessageCell {
                        let barHeight = self.inputBar.bounds.height
                        var bottomHeight = self.bottomInfoView.height
                        
                        if (cell.frame.y + cell.height + barHeight + bottomHeight) > self.tableview.contentSize.height && self.isAutoScrollEnabled {
                            self.scrollToBottom()
                        }
                    }
                })
            }
        })
    }
    
    func voiceToTextIM() {
        EventTrackingManager.instance.track(event: .voiceToTextClicked)
        if let message = self.messageForMenu.nimMessageModel {
            var audioPath = ((message.messageObject as? NIMAudioObject)?.path)!
            let fileUrl = URL(fileURLWithPath: audioPath)
            
            let voiceToTextVC = VoiceToTextIMViewController(fileUrl: fileUrl, selectedLanguage: currentSelectedLangCode, isLanguageSelection: false)
            self.present(voiceToTextVC, animated: true)
            
            //            guard let vc = NTESAudio2TextViewController(message: message) else { return }
            //            self.present(vc, animated: true)
        }
    }
    
    func messageCollectionIM() {
        if let message = self.messageForMenu.nimMessageModel {
            guard let data = self.messageManager.collectionMsgData(message) else { return }
            let type = self.messageManager.collectionMsgType(message)
            let params = NIMAddCollectParams()
            params.data = data
            params.type = type.rawValue
            params.uniqueId = message.messageId
            NIMSDK.shared().chatExtendManager.addCollect(params) { [weak self] (error, collectionInfo) in
                guard let self = self else { return }
                if let error = error {
                    self.showError(message: error.localizedDescription)
                } else {
                    //TODO:
                    if UserDefaults.isMessageFirstCollection == false {
                        UserDefaults.isMessageFirstCollection = true
                        UserDefaults.messageFirstCollectionFilterTooltipShouldHide = true
                    }
                    self.showError(message: "favourite_msg_save_success".localized)
                    printIfDebug("收藏成功")
                }
            }
        }
    }
    
    func saveMsgCollectionIM() {}
    
    func forwardAllImageIM() {
        self.showSelectActionToolbar(true, isDelete: false)
    }
    
    func deleteAllImageIM() {
        self.showSelectActionToolbar(true, isDelete: true)
    }
    
    private func replyMessage(with messageReplied: NIMMessage, replyView:MessageReplyView, text: String) -> NIMMessage {
        EventTrackingManager.instance.track(event: .replyMessageClicked)
        let attachment = IMReplyAttachment()
        attachment.message = replyView.messageLabel?.text ?? ""
        attachment.name = replyView.nicknameLabel?.text ?? ""
        attachment.username = String(replyView.username ?? "")
        
        if String(replyView.messageCustomType ?? "") == String(CustomMessageType.ContactCard.rawValue) {
            let strArr = replyView.messageLabel?.text?.components(separatedBy: ": ")
            let suffix = strArr?.last
            attachment.message = suffix ?? ""
        }
//        if replyView.nicknameLabel?.text == "you".localized {
//            let me = NIMSDK.shared().loginManager.currentAccount
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(me())
//            let nick = info.showName ?? ""
//            attachment.name = nick
//        }
        
        attachment.content = text
        attachment.messageType = String(replyView.messageType ?? "")
        attachment.messageID = String(replyView.messageID ?? "")
        attachment.messageCustomType = String(replyView.messageCustomType ?? "")
        attachment.image = ""
        attachment.videoURL = ""
        
//        if let imageObject = messageReplied.messageObject as? NIMImageObject {
//            attachment.image = imageObject.thumbUrl ?? ""
//            attachment.videoURL = ""
//        } else if let videoObject = messageReplied.messageObject as? NIMVideoObject {
//            attachment.image = String(videoObject.coverUrl ?? "")
//            attachment.videoURL = String(videoObject.coverUrl ?? "")
//        } else if let object = messageReplied.messageObject as? NIMCustomObject {
//            if let contactCard = object.attachment as? IMContactCardAttachment {
//                let info: NIMKitInfo = NIMBridgeManager.sharedInstance().getUserInfo(contactCard.memberId)
//                attachment.image = info.avatarUrlString ?? ""
//                attachment.videoURL = ""
//            } else if let charlet = object.attachment as? IMStickerAttachment {
//                attachment.image = charlet.chartletId
//                attachment.videoURL = ""
//            } else if let stickerCard = object.attachment as? IMStickerCardAttachment {
//                attachment.image = stickerCard.bundleIcon
//                attachment.message = stickerCard.bundleName
//                attachment.videoURL = ""
//            } else if let shareSocial = object.attachment as? IMSocialPostAttachment {
//                attachment.image = shareSocial.imageURL
//                attachment.message = shareSocial.title
//                attachment.videoURL = ""
//            } else if let voucher = object.attachment as? IMVoucherAttachment {
//                attachment.image = voucher.imageURL
//                attachment.message = voucher.title
//                attachment.videoURL = ""
//            } else {
//                attachment.image = ""
//                attachment.videoURL = ""
//            }
//        } else {
//            attachment.image = ""
//            attachment.videoURL = ""
//        }
//        
        let message = NIMMessage()
//        let object = NIMCustomObject()
//        object.attachment = attachment
//        message.messageObject = object
        
        return message
    }
    
    func handleStickerIM() {
        showStickerCollection()
    }
    
    private func showStickerCollection() {
        if let message = self.messageForMenu.nimMessageModel, let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMStickerAttachment {
            if attachment.chartletCatalog == "-1" {
                let vc = CustomerStickerViewController(sticker: attachment.stickerId)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = StickerDetailViewController(bundleId: attachment.chartletCatalog)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: pinned
    func pinnedMessage() {
        guard let message = messageForMenu.nimMessageModel, let data = self.messageManager.collectionMsgData(message, isType: true) else {
            return
        }

        TSIMNetworkManager.storePinnedMessage(imMsgId: message.messageId, imGroupId: self.session.sessionId, content: data, deleteFlag: true) { [weak self] resultModel, error in
            guard let self = self else { return }
            if let error = error  {
                printIfDebug("error = \(error)")
            } else {
                if let model = resultModel {
                    self.currentPinned = model
                    self.pinnedList.insert(model, at: 0)
                    DispatchQueue.main.async {
                        self.showPinnedView(pinItem: model)
                        self.cellForMessageId(messageId: model.im_msg_id, isPinned: true)
                    }
                    self.sendPinnedNotify(type: NTESPinnedStored, pinnedModel: model)
                    //删除之前的 pinned
                    for item in self.pinnedList {
                        if item.id != model.id {
                            DispatchQueue.main.async {
                                self.messageDeletePinItem(pinnedModel: item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: unpinned
    func unPinnedMessage(model: PinnedMessageModel) {
        TSIMNetworkManager.deletePinnedMessage(id: model.id) { [weak self] _, error in
            guard let self = self else { return }
            if let error = error  {
                printIfDebug("unPinnedMessageError = \(error)")
            } else {
                DispatchQueue.main.async {
                    self.messageDeletePinItem(pinnedModel: model)
                }
                self.sendPinnedNotify(type: NTESPinnedDeleted, pinnedModel: model)
            }
        }
    }
    
    //查询 pin 列表
    func loadMessagePins() {
        for item in self.pinnedList {
            DispatchQueue.main.async {
                self.messageDeletePinItem(pinnedModel: item)
            }
        }
        TSIMNetworkManager.showGroupPinnedMessage(group_id: self.session.sessionId) { [weak self] models, error in
            guard let self = self else { return }
            if let error = error  {
                printIfDebug("error = \(error)")
            } else {
                if let models = models, let model = models.first {
                    self.pinnedList = models
                    self.currentPinned = model
                    DispatchQueue.main.async {
                        self.showPinnedView(pinItem: model)
                        self.setPinnedMessageForMessageId()
                    }
                }
            }
        }
    }
    
    func showPinnedView(pinItem: PinnedMessageModel) {
        if pinnedView != nil{
            pinnedView?.setData(pinItem: pinItem)
        } else {
            pinnedView = IMPinnedView(pinItem: pinItem)
            pinnedView?.setData(pinItem: pinItem)
            stackView.insertArrangedSubview(pinnedView!, at: 0)
            pinnedView?.snp_makeConstraints { make in
                make.left.right.top.equalToSuperview()
                make.height.equalTo(50)
            }
            pinnedView?.delegate = self
            pinnedView?.addAction(action: { [weak self] in
                guard let self = self else { return }
                self.hideKeyboard()
                let popView = IMPinnedPopView(pinItem: self.pinnedView!.pinItem)
                let popup = TSAlertController(style: .popup(customview: popView), hideCloseButton: false)
                popView.delegate = self
                self.present(popup, animated: false)
                self.pinnedAlert = popup
            })
        }
    }
    
    //处理点击删除消息后，移除pinnedView
    func messageDeletePinItem(pinnedModel: PinnedMessageModel) {
        pinnedList.removeAll { item in
            item.id == pinnedModel.id
        }
        self.cellForMessageId(messageId: pinnedModel.im_msg_id, isPinned: false)
        if pinnedList.count == 0 {
            self.currentPinned = nil
            self.pinnedView?.removeFromSuperview()
            self.pinnedView = nil
        } else {
            self.currentPinned = pinnedList.first
            self.pinnedView?.setData(pinItem: currentPinned!)
        }
    }
    
    func messagePinned(for message: NIMMessage, completed: @escaping (_ flag: Bool) -> Void)  {
        for pinItem in pinnedList {
            if pinItem.im_msg_id == message.messageId {
                completed(true)
                return
            }
        }
        completed(false)
    }
    
    func cellForMessageId(messageId: String, isPinned: Bool = false) {
        if let messageData = self.getMessageData(for: messageId), let indexPath = getIndexPath(for: messageData){
            messageData.isPinned = isPinned
            var snapshot = self.dataSource.snapshot()
            snapshot.reloadItems([messageData])
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    func setPinnedMessageForMessageId() {
        var messageDatas: [MessageData] = []
        pinnedList.forEach { item in
            if let messageData = self.getMessageData(for: item.im_msg_id), let indexPath = getIndexPath(for: messageData){
                if !messageDatas.contains(where: { message in message.nimMessageModel?.messageId == item.im_msg_id }){
                    messageData.isPinned = true
                    messageDatas.append(messageData)
                }
            }
        }
        if messageDatas.count == 0 {return}
        var snapshot = self.dataSource.snapshot()
        snapshot.reloadItems(messageDatas)
        self.dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    func sendPinnedNotify(type: Int, pinnedModel: PinnedMessageModel) {
        let dict: [String : Any] = [NTESNotifyID: type, NTESCustomContent: pinnedModel.content, "pinned_id": pinnedModel.id, "im_msg_id": pinnedModel.im_msg_id]
        
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []), let json = String(data: data, encoding: .utf8) else {
            return
        }
       
        let notification = NIMCustomSystemNotification(content: json)
        
        notification.sendToOnlineUsersOnly = true
        let setting = NIMCustomSystemNotificationSetting()
        setting.apnsEnabled = false
        notification.setting = setting
        NIMSDK.shared().systemNotificationManager.sendCustomNotification(notification, to: session, completion: nil)
    }
}

extension IMChatViewController: IMPinnedViewDelegate {
    func deletePinItem(pinItem: PinnedMessageModel) {
        unPinnedMessage(model: pinItem)
    }
}

extension IMChatViewController: IMPinnedPopViewDeleagte {
    func didClickImageVideo(model: FavoriteMsgModel) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let vc = CollectionImageVideoMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickContactCard(memberId: String, popView: IMPinnedPopView) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: true)
//        let vc = HomePageViewController(userId: 0, username: memberId, isTeam: true)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickLocaltion(title: String, lat: Double, lng: Double, popView: IMPinnedPopView) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
//        let object: NIMLocationObject = NIMLocationObject.init(latitude: lat, longitude: lng, title: title)
//        let locationPoint: NIMKitLocationPoint = NIMKitLocationPoint.init(locationObject: object)
//        guard let vc = NIMLocationViewController.init(locationPoint: locationPoint) else { return }
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickFile(attachment: IMFileCollectionAttachment) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
        let name = attachment.name
        let path = "\(documentsPath)/collectionFile/\(name)"
        if FileManager.default.fileExists(atPath: path) {
            let url = URL(fileURLWithPath: path)
            self.interactionController = UIDocumentInteractionController(url: url)
            self.interactionController.delegate = self
            self.interactionController.name = name
            self.interactionController.presentPreview(animated: true)
        } else {
            let vc: CollectionFileMsgViewController = CollectionFileMsgViewController(model: attachment)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didClickAudio(model: FavoriteMsgModel) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        let vc = CollectionAudioMsgViewController(model: model)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didClickMeeting(meetingNum: String, meetingPw: String) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "tips".localized, message: "meeting_join_confirmation".localized, preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "cancel".localized, style: .cancel)
                let comfirm = UIAlertAction(title: "confirm".localized,style: .default) {_ in
                    self.meetingNum = meetingNum
                    self.joinMeetingApi(meetingNum: meetingNum, password: meetingPw)
                }
                alert.addAction(cancel)
                alert.addAction(comfirm)
                self.present(alert, animated: true)
            }
        })
    }
    
    func didClickEgg(attachment: IMEggAttachment, nickName: String, avatarInfo: AvatarInfo) {
        pinnedAlert?.dismiss()
        pinnedAlert = nil
        self.eggAttachment = attachment
        self.isEggAttachmentOutgoing = attachment.senderId == NIMSDK.shared().loginManager.currentAccount()
        
        if (self.isEggAttachmentOutgoing!) {
            self.checkOpenEggStatus()
        } else {
            self.eggOverlayView.updateInfo(avatarInfo: avatarInfo, name: nickName, message: attachment.message ?? "", uids: attachment.uids, completion: {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                    self.renderEggView()
                }
            })
        }
    }
    
    func didUpdateProfileData(_ data: String, avatar: AvatarInfo) {
        self.pinnedView?.avatarImageView.avatarInfo = avatar
        self.pinnedView?.avatarImageView.avatarPlaceholderType = .unknown
        self.pinnedView?.content.text = data
        self.pinnedView?.layoutIfNeeded()
    }
}

extension IMChatViewController: NIMSystemNotificationManagerDelegate, TimerHolderDelegate {
    func onReceive(_ notification: NIMCustomSystemNotification) {
        if !notification.sendToOnlineUsersOnly { return }
        let data = notification.content?.data(using: .utf8)
        if let data = data {
            do {
                let dic = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                guard let dict = dic else {
                    return
                }
                guard let sender = notification.sender  else {
                    return
                }
                guard let type = dict[NTESNotifyID] as? Int  else {
                    return
                }
                
                if type == NTESCommandTyping && self.session.sessionType == .P2P && sender == self.session.sessionId {
                    isTypingLabel.isHidden = false
                    self.titleTimer?.stopTimer()
                    self.titleTimer?.startTimer(seconds: 5, delegate: self, repeats: false)
                }
                if type == NTESPinnedStored && self.session.sessionType == .team {
                    loadMessagePins()
                }
                if type == NTESPinnedDeleted && self.session.sessionType == .team {
                    if let pinned_id = dict["pinned_id"] as? Int , let item = pinnedList.first(where: { e in
                        e.id == pinned_id
                    }) {
                        self.messageDeletePinItem(pinnedModel: item)
                    }
                    
                }
                if type == NTESPinnedUpdated && self.session.sessionType == .team {
                    loadMessagePins()
                }
            } catch  {
                
            }
        }
    }
    
    // MARK: - TimerHolder
    func onTimerFired(holder: TimerHolder) {
        //isTypingLabel.isHidden = true
        //headerTitle.text = sessionTitle()
        if holder == timer {
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
            } else {
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
        } else if holder == titleTimer {
            isTypingLabel.isHidden = true
        }
    }
}

extension IMChatViewController: PhotoEditorDelegate {
    func doneEditing(image: UIImage) {
        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            if let message = self.messageManager.imageMessage(with: image) {
                self.messageManager.sendMessage(message)
            }
        }
    }
    
    func canceledEditing() {
        
    }
    
    func readAllMessages(messages: [NIMMessage], completion: (() -> Void)? = nil) {
        NIMSDK.shared().conversationManager.markAllMessagesRead(in: self.session)
        var count = 0
        if (self.session.sessionType != .P2P) {
            for var item in messages {
                if !item.isOutgoingMsg {
                    let setting = NIMMessageSetting()
                    setting.teamReceiptEnabled = true
                    item.setting = setting
                    let returnReceipt = NIMMessageReceipt(message: item)
                    NIMSDK.shared().chatManager.sendTeamMessageReceipts([returnReceipt])
                }
                
                count += 1
                
                if count == messages.count {
                    completion?()
                }
            }
        } else {
            var reversedMessages = messages.reversed()
            DispatchQueue.global().async {
                let semahore = DispatchSemaphore(value: 0)
                for var item in reversedMessages {
                    if !item.isOutgoingMsg {
                        let returnReceipt = NIMMessageReceipt(message: item)
                        NIMSDK.shared().chatManager.send(returnReceipt, completion: { error in
                            semahore.signal()
                        })
                        semahore.wait()
                    }
                    
                    count += 1
                    
                    if count == messages.count {
                        completion?()
                    }
                }
            }
        }
    }
}

extension IMChatViewController {
    func getMessageSecondsTimeInterval(_ startInterval: TimeInterval, _ endInterval: TimeInterval) -> Int {
        let startIntervalDate = Date(timeIntervalSince1970: startInterval)
        let endIntervalDate = Date(timeIntervalSince1970: endInterval)
        
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([ .second])
        let datecomponents = calendar.dateComponents(unitFlags, from: startIntervalDate, to: endIntervalDate)
        let seconds = datecomponents.second ?? 0
        
        return seconds
    }
    
    func loadMessages() {
        var snapshot = self.dataSource.snapshot()
        snapshot.appendSections([0])
        if let nimMessages = NIMSDK.shared().conversationManager.messages(in: self.session, message: nil, limit: messageLimit), nimMessages.count > 0 {
            self.messageManager.lastMessage = nimMessages.first
            self.messageManager.isNeedFetchMessageForService = nimMessages.count < self.sessionConfig.messageLimit()
            self.readAllMessages(messages: nimMessages, completion: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let datas = nimMessages.compactMap { MessageData($0) }
                    let newDatas = self.processTimeData(datas)
                    snapshot.appendItems(newDatas, toSection: 0)
                    self.removePlaceholderView()
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.nimMessageModel?.messageType == .image {
                            var i = index + 1
                            repeat {
                                if snapshot.itemIdentifiers.indices.contains(i) {
                                    let nextMessage = snapshot.itemIdentifiers[i]
                                    
                                    if nextMessage.nimMessageModel?.messageType == .image && self.getMessageSecondsTimeInterval(message.messageTime!, nextMessage.messageTime!) < 5 {
                                        if message.messageList.contains(message) == false {
                                            message.messageList.append(message)
                                        }
                                        
                                        message.messageList.append(nextMessage)
                                    } else {
                                        break
                                    }
                                }
                                
                                i += 1
                            } while snapshot.itemIdentifiers.indices.contains(i)
                        }
                    }
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.messageList.count >= 4 {
                            var temp: [MessageData] = []
                            
                            for var sub in message.messageList {
                                if sub != message {
                                    temp.append(sub)
                                }
                            }
                            snapshot.deleteItems(temp)
                        } else {
                            message.messageList.removeAll()
                        }
                    }
                    
                    self.dataSource.defaultRowAnimation = .none
                    self.dataSource.apply(snapshot, animatingDifferences: false) {
                        //            DispatchQueue.main.async {
                        //                self.setTopContentInset()
                        //                self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                        //                self.perform(#selector(self.cellAnimation(indexpath:)), with: indexPath, afterDelay: 0.3)
                        //            }
                    }
                    
                    // By Kit Foong (If found search meassage will redirect to the messahe, else will keep get message)
                    if self.searchMessageId.count > 0 && self.messageSearch == false {
                        guard let model = self.dataSource.snapshot().itemIdentifiers.first(where: { $0.nimMessageModel?.messageId == self.searchMessageId }), let indexPath = self.dataSource.indexPath(for: model) else {
                            self.messageLimit = self.sessionConfig.messageSearchLimit() + self.unreadCount
                            self.loadMessages()
                            return
                        }
                        
                        self.messageSearch = true
                        
                        DispatchQueue.main.async {
                            self.setTopContentInset()
                            self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                            self.perform(#selector(self.cellAnimation(indexpath:)), with: indexPath, afterDelay: 0.3)
                        }
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.setTopContentInset()
                        self.scrollToBottom(false)
                    }
                }
            })
        } else {
            self.show(placeholder: .imEmpty)
            self.view.bringSubviewToFront(inputBar)
            self.dataSource.apply(snapshot, animatingDifferences: false)
            self.messageManager.isNeedFetchMessageForService = true
            self.fetchMessageForService()
        }
    }
    
    func fetchHistory() {
        loadingIndicator.startAnimating()
        
        DispatchQueue.global(qos: .background).async {
            if let nimMessages = NIMSDK.shared().conversationManager.messages(in: self.session, message: self.messageManager.lastMessage, limit: self.sessionConfig.messageLimit()), nimMessages.count > 0 {
                self.messageManager.lastMessage = nimMessages.first
                self.messageManager.isNeedFetchMessageForService = nimMessages.count < self.sessionConfig.messageLimit()
                
                self.readAllMessages(messages: nimMessages, completion: { [weak self] in
                    guard let self = self else { return }
                    
                    var currentMessage: MessageData?
                    
                    let datas = nimMessages.compactMap { MessageData($0) }
                    let newDatas = self.processTimeData(datas)
                    var snapshot = self.dataSource.snapshot()
                    if let firstItem = snapshot.itemIdentifiers.first {
                        currentMessage = firstItem
                        snapshot.insertItems(newDatas, beforeItem: firstItem)
                    } else {
                        snapshot.appendItems(newDatas, toSection: 0)
                    }
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.nimMessageModel?.messageType == .image {
                            var i = index + 1
                            repeat {
                                if snapshot.itemIdentifiers.indices.contains(i) {
                                    let nextMessage = snapshot.itemIdentifiers[i]
                                    
                                    if nextMessage.nimMessageModel?.messageType == .image && self.getMessageSecondsTimeInterval(message.messageTime!, nextMessage.messageTime!) < 5 {
                                        if message.messageList.contains(message) == false {
                                            message.messageList.append(message)
                                        }
                                        
                                        message.messageList.append(nextMessage)
                                    } else {
                                        break
                                    }
                                }
                                
                                i += 1
                            } while snapshot.itemIdentifiers.indices.contains(i)
                        }
                    }
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.messageList.count >= 4 {
                            var temp: [MessageData] = []
                            
                            for var sub in message.messageList {
                                if sub != message {
                                    temp.append(sub)
                                }
                            }
                            snapshot.deleteItems(temp)
                        } else {
                            message.messageList.removeAll()
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.removePlaceholderView()
                        self.dataSource.defaultRowAnimation = .top
                        self.dataSource.apply(snapshot, animatingDifferences: false) {
                            if let current = currentMessage, let indexPath = self.getIndexPath(for: current) {
                                self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                            //self.firstScrollNo = true
                            self.loadingIndicator.stopAnimating()
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
                self.messageManager.isNeedFetchMessageForService = true
            }
        }
    }
    
    /// 服务器拉取消息
    func fetchMessageForService() {
        let serverOption = NIMHistoryMessageSearchOption()

        serverOption.startTime = 0
        serverOption.endTime = self.messageManager.lastMessage?.timestamp ?? 0
        serverOption.currentMessage = self.messageManager.lastMessage
        serverOption.limit = UInt(self.sessionConfig.messageLimit())
        serverOption.order = .desc
        serverOption.sync = true
        
        NIMSDK.shared().conversationManager.fetchMessageHistory(session, option: serverOption, result: {[weak self] error, nimMessages in
            guard let self = self else { return }
            if let nimMessages: [NIMMessage] = nimMessages?.reversed(), nimMessages.count > 0 {
                self.messageManager.lastMessage = nimMessages.first
                
                self.readAllMessages(messages: nimMessages, completion: { [weak self] in
                    guard let self = self else { return }
                    
                    var currentMessage: MessageData?
                    
                    let datas = nimMessages.compactMap { MessageData($0) }
                    let newDatas = self.processTimeData(datas)
                    var snapshot = self.dataSource.snapshot()
                    if let firstItem = snapshot.itemIdentifiers.first {
                        currentMessage = firstItem
                        snapshot.insertItems(newDatas, beforeItem: firstItem)
                    } else {
                        snapshot.appendItems(newDatas, toSection: 0)
                    }
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.nimMessageModel?.messageType == .image {
                            var i = index + 1
                            repeat {
                                if snapshot.itemIdentifiers.indices.contains(i) {
                                    let nextMessage = snapshot.itemIdentifiers[i]
                                    
                                    if nextMessage.nimMessageModel?.messageType == .image && self.getMessageSecondsTimeInterval(message.messageTime!, nextMessage.messageTime!) < 5 {
                                        if message.messageList.contains(message) == false {
                                            message.messageList.append(message)
                                        }
                                        
                                        message.messageList.append(nextMessage)
                                    } else {
                                        break
                                    }
                                }
                                
                                i += 1
                            } while snapshot.itemIdentifiers.indices.contains(i)
                        }
                    }
                    
                    for (index, message) in snapshot.itemIdentifiers.enumerated() {
                        if message.messageList.count >= 4 {
                            var temp: [MessageData] = []
                            
                            for var sub in message.messageList {
                                if sub != message {
                                    temp.append(sub)
                                }
                            }
                            snapshot.deleteItems(temp)
                        } else {
                            message.messageList.removeAll()
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.removePlaceholderView()
                        self.dataSource.defaultRowAnimation = .top
                        self.dataSource.apply(snapshot, animatingDifferences: false) {
                            if let current = currentMessage, let indexPath = self.getIndexPath(for: current) {
                                self.tableview.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                            //self.firstScrollNo = true
                            self.loadingIndicator.stopAnimating()
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.loadingIndicator.stopAnimating()
                }
            }
            
        })
    }
}

extension IMChatViewController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
    func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        controller.dismissPreview(animated: true)
    }
}

extension IMChatViewController: MeetingServiceListener {
    func onMeetingStatusChanged(_ event: NEMeetingEvent) {
        printIfDebug("event.status = \(event.status)");
        
        if event.status == 0 || event.status == 5 { //主动离开 或者 主持人关闭会议
            self.timer?.stopTimer()
            self.timeView?.removeFromSuperview()
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
