//
//  IMChatroomViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/17.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

import InputBarAccessoryView
import NIMSDK
import TZImagePickerController
import AVKit
import MobileCoreServices
import SVProgressHUD
import Toast
import Alamofire
import Photos
import SnapKit
//import NIMPrivate

@objc protocol MessageDelegate {
    @objc optional func onReceiveMessage()
}

class IMChatroomViewController: ChatViewController {
    
   // weak var delegate: NIMInputDelegate?
    weak var badgeDelegate: MessageDelegate?

    let sessionConfig: IMChatViewConfig = IMChatViewConfig()
    let inputBar: CustomInputBar = CustomInputBar()
    private var stickerContainerView: InputEmoticonContainerView?
    private var keyboardManager = KeyboardManager()
    private var keyboardHeight:CGFloat = 0
    private var firstScrollNo = true
    private var firstScrollEnabled = false
    private var mentionsUsernames = [AutocompleteCompletion]()
    private var messageForMenu: MessageData!
    public var teamMembers = [String]()
    var inputStauts: InputStauts = InputStauts(rawValue: 1)!
    
    lazy var stackView = {
        UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 0
            stack.distribution = .fill
            stack.alignment = .fill
        }
    }()
    lazy var replyView: MessageReplyView = {
        let view = MessageReplyView()
        view.backgroundColor = AppTheme.inputContainerGrey
        view.closeBtn?.addTarget(self, action: #selector(stopReplyingMessage), for: .touchUpInside)
        view.isHidden = true
        return view
    }()
    
    var pauseTime: TimeInterval = 0.0
    var playTime: TimeInterval = 0.0
    var pendingAudioMessages: [NIMMessage]? = nil
    //记录当前录制的语音
    private var saveAudioMessage: NIMMessage?
    //记录当前录制的语音文件地址
    private var saveAudioFilePath: String?
    //保存识别结果
    private var receiveResult = ""
    init(session: NIMSession, chatRoom: NIMChatroom) {
        super.init(session: NIMSession(chatRoom.roomId.orEmpty, type: .chatroom), unread: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setChatWallpaper()
        NIMSDK.shared().chatManager.add(self)
        NIMSDK.shared().mediaManager.add(self)
      
    }
  
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.hideKeyboard()
        NIMSDK.shared().chatManager.remove(self)
        NIMSDK.shared().mediaManager.remove(self)
        self.inputStauts = .text
        inputBar.inputTextView.endEditing(true)
        view.endEditing(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        loadData()
    }
  
    func setUI() {
        self.view = KeyInputView(frame: self.view.bounds)
        hideKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        stackView.addArrangedSubview(tableview)
        self.view.addSubview(stackView)
        stackView.snp.makeConstraints {(make) in
            make.bottom.equalTo(self.view)
            make.top.left.right.equalTo(self.view)
        }

        self.inputViewSetup()
       
        self.view.addSubview(replyView)
        replyView.snp.makeConstraints { make in
            make.height.equalTo(70)
            make.width.equalToSuperview()
            make.bottom.equalTo(self.inputBar.snp.top)
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
    private func loadData() {
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([0])
        dataSource.defaultRowAnimation = .none
        dataSource.apply(snapshot, animatingDifferences: false, completion: nil)
    }
    
    override func makeDataSource() -> ChatDataSource {
        return ChatDataSource(tableView: tableview) { table, indexPath, message in
            if let msg = message.nimMessageModel, msg.messageType == .notification {
                let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier, for: indexPath) as! TipMessageCell
                cell.tipLabel.text = ""
                if let object = msg.messageObject as? NIMNotificationObject , let content = object.content as? NIMChatroomNotificationContent {
                    cell.tipLabel.text = content.notifyExt
                    if content.eventType == .enter {
                        cell.tipLabel.text = msg.from.orEmpty + " " + "joingroup".localized
                    }
                    
                    if content.eventType == .exit {
                        cell.tipLabel.text = msg.from.orEmpty + " " + "group_leave".localized
                    }
                }
                return cell
            }
            
            switch message.type {
            case .time:
                let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                cell.tipLabel.text = message.messageTime?.messageTime(showDetail: true)
                return cell
            case .tip:
                let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                cell.tipLabel.text = message.infoString!
                return cell
            case .outgoing, .incoming:
                if message.nimMessageModel?.messageType == .tip  {
                    let cell = table.dequeueReusableCell(withIdentifier: TipMessageCell.cellIdentifier) as! TipMessageCell
                    cell.tipLabel.text = message.nimMessageModel?.text ?? ""
                    
                    return cell
                }
                let cell = table.dequeueReusableCell(withIdentifier: BaseMessageCell.cellIdentifier) as! BaseMessageCell
                let contentView = self.messageManager.contentView(message)
                cell.dataUpdate(contentView:contentView, messageModel: message)
                cell.nicknameLabel.isHidden = false
                cell.delegate = self
                cell.resendMessage = { [weak self] message in
                    guard let self = self else { return }
                    if let messageModel = message.nimMessageModel {
                        self.handleRetryMessage(message: messageModel)
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
    }
    
    private func inputViewSetup () {
        inputBar.inputTextView.keyboardType = .default
        inputBar.inputTextView.autocorrectionType = .no
        inputBar.delegate = self
        inputBar.inputDelegate = self
        //inputBar.secretTimerBtn.isHidden = true
        inputBar.bottomStackView.isHidden = true
        inputBar.leftStackView.isHidden = true
        inputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 36)
        inputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        inputBar.setLeftStackViewWidthConstant(to: 38, animated: false)
        inputBar.moreBtn.makeHidden()
        //inputBar.inputBarItems[0].setSize(CGSize(width: 0, height: 0), animated: false)
        inputBar.bottomStackView.snp.updateConstraints { make in
            make.height.equalTo(0)
        }
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
        self.hiddenInput()
    }
    
    func hiddenInput() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height)
            let barHeight = (self?.inputBar.bounds.height ?? 0) > 78.5 ? 78.5 : (self?.inputBar.bounds.height ?? 0)
            var bottomInfoHeight = self?.bottomInfoView.height ?? 0
            self?.tableview.contentInset.bottom = barHeight  + bottomInfoHeight
            self?.tableview.scrollIndicatorInsets.bottom = barHeight + bottomInfoHeight
            self?.scrollToBottom()
        }completion: { _ in
            self.stickerContainerView?.isHidden = true
        }
    }
    
    func handleKeyboardLogic () {
        if stickerContainerView == nil {
            stickerContainerView = InputEmoticonContainerView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height , width: self.view.width, height: keyboardHeight))
            stickerContainerView!.layer.zPosition = CGFloat(MAXFLOAT)
            stickerContainerView!.delegate = self
        }

        switch self.inputStauts {
        case .text:
            stickerContainerView?.isHidden = true
            
            break
        case .sticker:
            stickerContainerView?.isHidden = false
            stickerContainerView?.height = keyboardHeight
            if let stickerview = stickerContainerView{
                stickerview.layer.zPosition = CGFloat(MAXFLOAT)
                let windowCount = UIApplication.shared.windows.count
                UIApplication.shared.windows[windowCount-1].addSubview(stickerview)
                UIApplication.shared.windows[windowCount-1].bringSubviewToFront(stickerview)
            }
            
            break
        default:
            break
        }
        
    }
    override func keyboardWillShow(notification: Notification) {
        self.inputBar.ResetStickerImage()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            if self.inputStauts == .text || self.inputStauts == .more || self.inputStauts == .sticker || self.inputStauts == .local || self.inputStauts == .file || self.inputStauts == .picture {
                handleKeyboardLogic()
            }
        }
        
        animateWithKeyboard(notification: notification) { [weak self] (keyboardFrame) in
            guard let self = self else { return }
            self.stickerContainerView?.top = CGFloat(UIScreen.main.bounds.height-keyboardFrame.height)
            self.inputBar.snp_remakeConstraints { make in
                make.left.right.equalTo(0)
                make.bottom.equalTo(-keyboardFrame.height)
            }
            let barHeight = self.inputBar.bounds.height > 98.5 ? 98.5 : self.inputBar.bounds.height
            var bottomInfoHeight = self.bottomInfoView.height
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
    @objc func stopReplyingMessage() {
        replyView.isHidden = true
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
            curve: curve
        ) {
            animations?(keyboardFrameValue.cgRectValue)
            
            self.view?.layoutIfNeeded()
        }
        animator.startAnimation()
    }
    
    func showEmoticonContainer() {
        if self.inputStauts == .sticker {
            self.inputStauts = .text
            self.inputBar.inputTextView.becomeFirstResponder()
            self.inputBar.ResetStickerImage()
        }else{
            if #available(iOS 16.0, *) {
                self.view.resignFirstResponder()
            }
            self.inputBar.inputTextView.resignFirstResponder()
            self.stickerContainerView?.refreshStickerKeyboard()
            self.inputStauts = .sticker
            //self.stickerContainerView?.isHidden = true
            if keyboardHeight > 0 {
                self.handleKeyboardLogic()
            }
            self.inputBar.changeStickerImageToKeyboard()
        }
    }
    func hideAudioRecording () {
        if inputBar.inputTextView.text.isEmpty  {
            inputBar.hideHoldToTalk()
        }
    }

}
extension IMChatroomViewController: CustomInputBarDelegate {
 
    func emojiContainerTapped(){
        if let view = view as? KeyInputView {
            view.becomeFirstResponder()
            showEmoticonContainer()
            hideAudioRecording()
   
        }
    }
    
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
        SpeechVoiceDetectManager.shared.onReceiveValue = { [weak self]
            (receiveValue, isFinal) in
            guard let self = self else { return }
            print("receiveValue \(receiveValue)")
            //判断识别结果是否为空
            guard let receiveValue = receiveValue, receiveValue.count > 0 else {
                //判断之前识别到了结果，但是最终为nil 取用之前的结果显示
                if self.receiveResult.count > 0 {
                    self.inputBar.recordPhase = .converted
                    self.inputBar.recognizedText = self.receiveResult
                }else if self.inputBar.audioRecordIndicator.moreButton.isHidden == false && isFinal {
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
        SpeechVoiceDetectManager.shared.onRequestAuthorizationStateChanged = { [weak self]
            (state,errorMsg) in
            if state != .authorized {
                //声音授权出现问题
                self?.inputBar.audioRecordIndicator.authErrorMsg = errorMsg
                self?.showTopFloatingToast(with: errorMsg ?? "", desc: "")
            }
        }
        var dotCount = 1 // 初始点数为 3
        SpeechVoiceDetectManager.shared.onDurationChanged = { [weak self]
            (duration) in
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
        SpeechVoiceDetectManager.shared.onRecordEnd = { [weak self]
            in
            self?.onRecordEnd()
        }
    }
    
    func onStopRecording() {
        NIMSDK.shared().mediaManager.stopRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.inputBar.recognizedText = ""
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
        self.recognizedText = ""
        self.inputBar.recognizedText = ""
    }
    func onConverting() {
        SpeechVoiceDetectManager.shared.stopRecording()
        NIMSDK.shared().mediaManager.stopRecord()
    }
    func onConvertError() {
        SpeechVoiceDetectManager.shared.stopRecording()
        NIMSDK.shared().mediaManager.stopRecord()
    }
    //取消发送
    func cancelButtonTapped() {
        self.view.resignFirstResponder()
        self.handleKeyboardLogic()
        NIMSDK.shared().mediaManager.cancelRecord()
        SpeechVoiceDetectManager.shared.stopRecording()
        self.recognizedText = ""
        self.inputBar.recognizedText = ""
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
        self.inputBar.recognizedText = ""
        inputBar.recording = false
    }
    //弹出更多语言页面
    func moreLanguageButtonTapped() {
        let vc = IMAudioLanguageViewController()
        vc.onLanguageCodeDidSelect =  { [weak self] (langCode) in
            self?.inputBar.recordPhase = .converted
            self?.receiveResult = ""
            SpeechVoiceDetectManager.shared.convertToTextWithAudioFile(filePath: self?.saveAudioFilePath ?? "", langCode: langCode)
        }
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        self.present(vc, animated: true, completion: nil)
    }
    
    
}
extension IMChatroomViewController: NIMChatManagerDelegate {
    func willSend(_ message: NIMMessage) {
        if message.session != session { return }
        let data = MessageData(message)
        add([data])
        scrollToBottom()
    }
    
    func send(_ message: NIMMessage, didCompleteWithError error: Error?) {
        self.update(message)
    }
    
    func send(_ message: NIMMessage, progress: Float) {
//        if message.session != session { return }
//        if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMSnapchatAttachment {
//            if self.findModel(message) != nil {
//                self.updateMessage(message)
//            } else {
//                self.addMessage([message])
//            }
//        }else {
//            self.updateMessage(message)
//        }
//
        //mark read
    }
    
    func onRecvMessages(_ messages: [NIMMessage]) {
        if messages.first?.session != session { return }
        onReceiveMessage(messages)
        if isAutoScrollEnabled {
            scrollToBottom()
        }
        self.badgeDelegate?.onReceiveMessage?()
    }
    func fetchMessageAttachment(_ message: NIMMessage, progress: Float) {
        self.update(message)
    }
    
    func fetchMessageAttachment(_ message: NIMMessage, didCompleteWithError error: Error?) {
        self.update(message)
    }
    
    func onRecvMessageReceipts(_ receipts: [NIMMessageReceipt]) {
        let receiptArray = receipts.filter({$0.session == session})
        //check receipt
    }
}

extension IMChatroomViewController {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height < 40 {
            isAutoScrollEnabled = true
        } else {
            isAutoScrollEnabled = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isAutoScrollEnabled = false
    }
    
    func isScrolledToBottom() -> Bool {
        return tableview.contentOffset.y >= (tableview.contentSize.height - tableview.bounds.size.height)
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


extension IMChatroomViewController : InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if inputBar.inputTextView.text.isEmpty {
            self.inputBar.checkAudioPermission { success in
                if success {
                    if self.inputBar.recordButton.isHidden {
                        self.inputBar.configureHoldToTalk()
                        self.hideKeyboard()
                    } else {
                        self.hideAudioRecording()
                    }
                }
            }
        } else {

//            inputBar.inputTextView.text = String()
           
//            let textMessage = NIMMessage()
//            textMessage.text = text
//            do {
//                try NIMSDK.shared().chatManager.send(textMessage, to: self.session)
//            } catch {
//
//            }
                
            let mentionUsernames = mentionsUsernames.compactMap { $0.context?["username"] as? String }
            inputBar.inputTextView.text = String()
            
            if self.replyView.isHidden {
                let message = self.messageManager.textMessage(with: text)
                self.messageManager.sendMessage(message, mentionUsernames)
            } else {
                if let repliedMsg = messageForMenu.nimMessageModel {
//                    replyView.isHidden = true
//                    let message = self.replyMessage(with: repliedMsg, replyView: replyView, text: text)
//                    self.messageManager.sendMessage(message, mentionUsernames)
                }
            }
            self.mentionsUsernames.removeAll()
        }
    }
    
    func inputBarTextViewDidBeginEditing(_ inputBar: InputBarAccessoryView) {
        self.inputStauts = InputStauts(rawValue: 1)!
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
       
    }
}

extension IMChatroomViewController: NIMMediaManagerDelegate {
    func recordAudio(_ filePath: String?, didBeganWithError error: Error?) {
        if filePath == nil || error != nil {
            inputBar.recording = false
           
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

            }
        } else {
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
                let value = Int(resultArrays[index] * 100)
                return min(value, 55)
            } else {
                return 1
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

extension IMChatroomViewController: InputEmoticonProtocol {
    func didPressSend(_ sender: Any?) {
        
    }
    
    func didPressAdd(_ sender: Any?) {
        self.inputBar.inputTextView.resignFirstResponder()
        self.view.endEditing(true)
        stickerContainerView?.isHidden = true
        let vc = StickerMainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        guard let emoticonID = emoticonID, let cataLogId = emotCatalogID, let stickerId = stickerId else { return }
        let message = self.messageManager.stickerMessage(with: cataLogId, stickerUrl: emoticonID, stickerId: stickerId)
        self.messageManager.sendMessage(message)
    }
    
    func sendEmoji(_ emojiTag: String?) {
        guard let emojiTag = emojiTag else { return }
        self.inputBar.inputTextView.insertText(emojiTag)
    }
    
    func didPressMySticker(_ sender: Any?) {
        self.inputBar.inputTextView.resignFirstResponder()
        self.view.endEditing(true)
        stickerContainerView?.isHidden = true
        let vc = MyStickersViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didPressCustomerSticker() {
        self.inputBar.inputTextView.resignFirstResponder()
        self.view.endEditing(true)
        stickerContainerView?.isHidden = true
        let vc = CustomerStickerViewController(sticker: "")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
//MARK: - Cell actions
extension IMChatroomViewController: MessageCellDelegate {
    func itemsActionArray(_ message: MessageData) -> [IMActionItem] {
        var items: [IMActionItem] = []
        let isLeavedGroupUser = false
        
        if SessionUtil().canMessageBeReplied(message.nimMessageModel!) && isLeavedGroupUser == false {
            items.append(.reply)
        }
        
        if SessionUtil().canMessageBeCopy(message.nimMessageModel!) {
            items.append(.copy)
        }
        
        if let data = get(message.nimMessageModel!), SessionUtil().canMessageBeTranslated(data) {
            items.append(.translate)
        }
        
        if let data = get(message.nimMessageModel!), SessionUtil().canMessageBeVoiceToText(data) {
            items.append(.voiceToText)
        }
        
        if SessionUtil().canStickerCollectionBeOpened(message.nimMessageModel!) {
            items.append(.stickerCollection)
        }
        
        if SessionUtil().canMessageCollection(message.nimMessageModel!) {
            items.append(.collection)
        }
        
        return items
    }
    
    func handleRetryMessage(message: NIMMessage) {
        if let yidunAntiSpamRes = message.yidunAntiSpamRes, yidunAntiSpamRes.isEmpty == false {
            SessionUtil().showYiDunAlertMessage(jsonString: yidunAntiSpamRes)
        } else if let localExt = message.localExt, let yidunAntiSpamRes = localExt["yidunAntiSpamRes"] as? String, yidunAntiSpamRes.isEmpty == false {
            SessionUtil().showYiDunAlertMessage(jsonString: yidunAntiSpamRes)
        } else {
            self.retryMessage(message: message)
        }
    }
    
    func retryMessage(message: NIMMessage) {
        if (message.isReceivedMsg) {
            do {
                try NIMSDK.shared().chatManager.fetchMessageAttachment(message)
            } catch {
                LogManager.Log(error.localizedDescription, loggingType: .exception)
            }
        } else {
            do {
                try NIMSDK.shared().chatManager.resend(message)
            } catch {
                LogManager.Log(error.localizedDescription, loggingType: .exception)
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
    
    func longPressMessageCell(_ cell: BaseMessageCell, message: MessageData) {
        self.hideKeyboard()
//        let items = self.itemsActionArray(message)
//        if (items.count > 0 && self.becomeFirstResponder() && !self.tableview.isEditing) {
//            let view = IMActionListView(actions: items)
//            view.delegate = self
//            messageForMenu = message
//        }
    }
    
    func longPressAvatar(_ cell: BaseMessageCell, message: MessageData) {
        
    }
  
    func tappedAvatar(_ userId: String) {
        
    }
    
    func tappedContactCard(_ cell: BaseMessageCell, message: MessageData) {
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMContactCardAttachment
        let memberId = attachment.memberId
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: 0, username: memberId, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//        let vc = HomePageViewController(userId: 0, username: memberId)
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tappedStickerCard(_ cell: BaseMessageCell, message: MessageData) {
        guard let message = message.nimMessageModel else { return }
        let object = message.messageObject as! NIMCustomObject
        let attachment = object.attachment as! IMStickerCardAttachment
        let bundleId = attachment.bundleID
        
        let vc = StickerDetailViewController(bundleId: bundleId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tappedSocialPost(_ cell: BaseMessageCell, message: MessageData) {

    }
    
    func tappedImage(_ cell: BaseMessageCell, message: MessageData) {
      
    }
    
    func tappedVideo(_ cell: BaseMessageCell, message: MessageData) {
        
    }
    
    func tappedLocation(_ cell: BaseMessageCell, message: MessageData) {

    }
    
    func tappedEgg(_ cell: BaseMessageCell, message: MessageData) {
        
    }
    
    func tappedWhiteboard(_ cell: BaseMessageCell, message: MessageData) {
        
    }
    
    func tappedVoucher(_ cell: BaseMessageCell, message: MessageData) {
        
    }
    
    func tappedRetryTextTranslate(_ cell: BaseMessageCell, message: MessageData) {
        guard let translatedMsg = message.nimMessageModel, let object = translatedMsg.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMTextTranslateAttachment, let oriMsg = getMessageData(for: attachment.oriMessageId) else { return }
        
//        self.textTranslate(withText: attachment.originalText, oriMessage: oriMsg, translateMessage: message)
    }
    
    func tappedFile(_ cell: BaseMessageCell, message: MessageData) {
     
    }
    
    func tappedMeeting(_ cell: BaseMessageCell, message: MessageData) {
       
    }
    
    func tappedUnknown() {
        if let lastCheckModel = TSCurrentUserInfo.share.lastCheckAppVesin {
            TSRootViewController.share.checkAppVersion(lastCheckModel: lastCheckModel, forceShowAlert: true)
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
        
    }
    
    func tappedMiniProgramMessage(_ cell: BaseMessageCell, message: MessageData) {
        guard let object = message.nimMessageModel?.messageObject as? NIMCustomObject, let attactment = object.attachment as? IMMiniProgramAttachment else {
            return
        }
        DependencyContainer.shared.resolveUtilityFactory().openMiniProgram(appId: attactment.appId, path: attactment.path, parentVC: self) { (status, error) in
            if status {
                // DependencyContainer.shared.resolveUtilityFactory().registerMiniProgramExt()
            }
        }
    }
    
    func tappedStickerRPSMessage(_ cell: BaseMessageCell, message: MessageData) {
        guard let object = message.nimMessageModel?.messageObject as? NIMCustomObject, let attactment = object.attachment as? IMStickerAttachment else {
            return
        }
        //自定义贴图
        if attactment.chartletCatalog == "-1" {
            let vc = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerDialogView(imageUrl: attactment.chartletId, customStickerId: attactment.stickerId) { [weak self] (index) in
                
                if index == 1 { //保存
                    //需要弹出贴图弹窗
                    DispatchQueue.main.async {
                        self?.emojiContainerTapped()
                    }
                }else if (index == 3) {
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        let vc1 = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerMaxNumDialogView(imageUrl: attactment.chartletId, customStickerId: attactment.stickerId) { (index1) in
                            if index1 == 2 {
                                
                                let stickerVc = DependencyContainer.shared.resolveViewControllerFactory().makeCustomerStickerViewController(stickerId: "")
                                self?.navigationController?.pushViewController(stickerVc, animated: true)
                            }
                        }
                        
                        self?.present(vc1, animated: true, completion: nil)
                    }
                }
            }
            
            self.present(vc, animated: false, completion: nil)
        }
    }
    
    func tappedAnnouncementMessage(_ cell: BaseMessageCell, url: String?) {
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
        
    }
}

//extension IMChatroomViewController: ActionListDelegate {
//    func copyTextIM() {
//        guard let message = messageForMenu.nimMessageModel else { return }
//        let pasteboard = UIPasteboard.general
//        
//        if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMReplyAttachment {
//            pasteboard.string = attachment.content
//        }else {
//            guard let messageText = message.text else { return }
//            let ext = message.remoteExt
//            let usernames = ext?["usernames"] as? [String] ?? []
//            if (usernames.count) > 0 {
//                pasteboard.items = [["usernames": usernames.joined(separator: ","), "message": messageText]]
//            } else {
//                pasteboard.string = messageText
//            }
//        }
//    }
//    
//    func copyImageIM() {}
//    
//    func forwardTextIM() {
//        EventTrackingManager.instance.track(event: .forwardClicked)
//        self.showSelectActionToolbar(true, isDelete: false)
//    }
//    
//    func revokeTextIM() {
//        
//        guard let message = messageForMenu.nimMessageModel else { return }
//        EventTrackingManager.instance.track(event: .revokeAndEditClicked)
//        message.apnsContent = nil
//        message.apnsPayload = nil
//        
//        NIMSDK.shared().chatManager.revokeMessage(message, completion: { [weak self] error in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if error != nil {
//                    if (error! as NSError).code == 508 {
//                        let alertController = UIAlertController(title: nil, message: "revoke_failed".localized, preferredStyle: .alert)
//                        let cancelAction = UIAlertAction(title: "confirm".localized, style: .cancel, handler: nil)
//                        alertController.addAction(cancelAction)
//                        self.present(alertController, animated: true)
//                    } else {
//                        self.view.makeToast("revoke_try_again".localized, duration: 2.0, position: CSToastPositionCenter)
//                    }
//                } else {
//                    //TODO: add tip after revoke message
//                    self.remove(self.messageForMenu)
//                    self.inputBar.inputTextView.insertText(message.text ?? "")
//                    
//                    self.inputBar.inputTextView.becomeFirstResponder()
//                    
//                    let tip = IMSessionMsgConverter.shared.msgWithTip(tip: NTESSessionUtil.tip(onMessageRevoked: nil))
//                    guard let tips = tip else {
//                        return
//                    }
//                    // By Kit Foong (duplicate add tips, conversation Manager will add tips)
//                    //self.add([MessageData(tips)])
//                    tips.timestamp = message.timestamp
//                    //NIMSDK.shared().conversationManager.save(tips, for: message.session!, completion: nil)
//                    do{
//                        try NIMSDK.shared().chatManager.send(tips, to: message.session!)
//                    }catch {
//                        
//                    }
//                }
//            }
//        })
//    }
//    
//    func deleteTextIM() {
//        self.showSelectActionToolbar(true, isDelete: true)
//    }
//    
//    func translateTextIM() {
//        EventTrackingManager.instance.track(event: .translateClicked)
//        if let message = self.messageForMenu.nimMessageModel {
//            var messageText = message.text
//            if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMReplyAttachment {
//                messageText = attachment.content
//            }
//            
//            if messageText == nil || messageText == "" { return }
//            self.textTranslate(withText: messageText!, oriMessage: self.messageForMenu)
//        }
//    }
//    
//    private func textTranslate(withText messageText: String, oriMessage: MessageData, translateMessage: MessageData? = nil) {
//        oriMessage.isTranslated = true
//        update(oriMessage)
//        
//        ChatroomNetworkManager().translateTexts(message: messageText, onSuccess: { [weak self] message in
//            guard let self = self else { return }
//            if let translateMessage = translateMessage {
//                let data = self.messageManager.updateTranslateMessage(for: translateMessage, with: message)
//                self.update(data)
//            } else {
//                let data = self.messageManager.translateMessage(oriMessage, with: message)
//                self.insert(message: data, after: oriMessage)
//            }
//        }, onFailure: { [weak self] errMsg, code in
//            guard let self = self else { return }
//            if let translateMessage = translateMessage {
//                let data = self.messageManager.updateTranslateMessage(for: translateMessage, with: errMsg)
//                self.update(data)
//            } else {
//                let data = self.messageManager.translateMessage(oriMessage, with: errMsg)
//                self.insert(message: data, after: oriMessage)
//            }
//        })
//    }
//    
//    func replyTextIM() {
//        guard let message = messageForMenu.nimMessageModel else { return }
//        self.replyView.isHidden = false
//        self.replyView.configure(message)
//    }
//    
//    private func replyMessage(with messageReplied: NIMMessage, replyView:MessageReplyView, text: String) -> NIMMessage {
//        EventTrackingManager.instance.track(event: .replyMessageClicked)
//        let attachment = IMReplyAttachment()
//        attachment.message = replyView.messageLabel?.text ?? ""
//        attachment.name = replyView.nicknameLabel?.text ?? ""
//        attachment.username = String(replyView.username ?? "")
//        
//        if String(replyView.messageCustomType ?? "") == String(CustomMessageType.ContactCard.rawValue) {
//            let strArr = replyView.messageLabel?.text?.components(separatedBy: ": ")
//            let suffix = strArr?.last
//            attachment.message = suffix ?? ""
//        }
//        if replyView.nicknameLabel?.text == "you".localized {
//            let me = NIMSDK.shared().loginManager.currentAccount
//            let info = NIMBridgeManager.sharedInstance().getUserInfo(me())
//            let nick = info.showName ?? ""
//            attachment.name = nick
//        }
//        
//        attachment.content = text
//        attachment.messageType = String(replyView.messageType ?? "")
//        attachment.messageID = String(replyView.messageID ?? "")
//        attachment.messageCustomType = String(replyView.messageCustomType ?? "")
//        attachment.image = ""
//        attachment.videoURL = ""
//        
//        if let imageObject = messageReplied.messageObject as? NIMImageObject {
//            attachment.image = imageObject.thumbUrl ?? ""
//            attachment.videoURL = ""
//        } else if let videoObject = messageReplied.messageObject as? NIMVideoObject {
//            attachment.image = String(videoObject.coverUrl ?? "")
//            attachment.videoURL = String(videoObject.coverUrl ?? "")
//        } else if let object = messageReplied.messageObject as? NIMCustomObject {
//            
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
//            } else {
//                attachment.image = ""
//                attachment.videoURL = ""
//            }
//        } else {
//            attachment.image = ""
//            attachment.videoURL = ""
//        }
//        
//        let message = NIMMessage()
//        let object = NIMCustomObject()
//        object.attachment = attachment
//        message.messageObject = object
//        
//        return message
//    }
//    
//    func handleStickerIM() {
//        showStickerCollection()
//    }
//    
//    func cancelUploadIM() {}
//    
//    func stickerCollectionIM() {
//        showStickerCollection()
//    }
//    
//    private func showStickerCollection() {
//        EventTrackingManager.instance.track(event: .collectionClicked)
//        if let message = self.messageForMenu.nimMessageModel, let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMStickerAttachment {
//            if attachment.chartletCatalog == "-1" {
//                let vc = CustomerStickerViewController(sticker: attachment.stickerId)
//                self.navigationController?.pushViewController(vc, animated: true)
//            }else{
//                let vc = StickerDetailViewController(bundleId: attachment.chartletCatalog)
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
//            
//        }
//    }
//    
//    func voiceToTextIM() {
//        EventTrackingManager.instance.track(event: .voiceToTextClicked)
//        if let message = self.messageForMenu.nimMessageModel {
//            guard let vc = NTESAudio2TextViewController(message: message) else { return }
//            self.present(vc, animated: true)
//        }
//        
//    }
//    
//    func messageCollectionIM(){
//        if let message = self.messageForMenu.nimMessageModel {
//            guard let data = self.messageManager.collectionMsgData(message) else {
//                return
//            }
//            let type = self.messageManager.collectionMsgType(message)
//            let params = NIMAddCollectParams()
//            params.data = data
//            params.type = type.rawValue
//            params.uniqueId = message.messageId
//            NIMSDK.shared().chatExtendManager.addCollect(params) { [weak self] (error, collectionInfo) in
//                if let error = error {
//                    self?.showError(message: error.localizedDescription)
//                }else{
//                    //TODO:
//                    if UserDefaults.isMessageFirstCollection == false {
//                        UserDefaults.isMessageFirstCollection = true
//                        UserDefaults.messageFirstCollectionFilterTooltipShouldHide = true
//                    }
//                    
//                    self?.showError(message: "favourite_msg_save_success".localized)
//                    print("收藏成功")
//                }
//            }
//        }
//    }
//    
//    func saveMsgCollectionIM(){}
//    
//    private func showSelectActionToolbar(_ show: Bool, isDelete: Bool) {
////        self.selectActionToolbar.setToolbarHidden(!show)
////        self.inputBar.isHidden = show
////        let spacing = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, action: {})
////
////        if show {
////            guard let message = messageForMenu.nimMessageModel, let menuMessage = messageForMenu else { return }
////            selectedMsgId = [message.messageId]
////            self.selectedItem.bounds = CGRect(x: 0, y: 0, width: self.selectActionToolbar.bounds.width / 4, height: self.selectActionToolbar.bounds.height)
////            let selectedItem1 = UIBarButtonItem(customView: self.selectedItem)
////            if (isDelete) {
////                self.dataSource.isForwarding = false
////                self.selectActionToolbar.setItems([self.deleteButton, spacing, selectedItem1, spacing], animated: true)
////
////            } else {
////                self.dataSource.isForwarding = true
////                self.selectActionToolbar.setItems([self.shareButton, spacing, selectedItem1, spacing], animated: true)
////            }
////
////            self.tableview.allowsMultipleSelectionDuringEditing = true
////            self.tableview.setEditing(true, animated: false)
////            if let msgIndexPath = getIndexPath(for: menuMessage) {
////                self.updateTableViewSelection(by: msgIndexPath, select: true)
////            }
////
////            self.updateShareButton()
////            self.updateRevokeButton()
////            self.updateSelectedItem()
////
////        } else {
////            tableview.setEditing(show, animated: true)
////
////            let selectedMessage = tableview.indexPathsForSelectedRows
////            for path in selectedMessage ?? [] {
////                tableview.deselectRow(at: path, animated: false)
////            }
////        }
////        setupNav()
//    }
//    
//    func updateTableViewSelection(by messageIndexPath: IndexPath, select: Bool) {
//        if select {
//            updateSelectedItem()
//            tableview.selectRow(at: messageIndexPath, animated: true, scrollPosition: .none)
//        } else {
//            updateSelectedItem()
//            tableview.deselectRow(at: messageIndexPath, animated: true)
//        }
//    }
//    
//    func updateShareButton() {
////        shareButton.isEnabled = true
////        let selectedMessage = tableview.indexPathsForSelectedRows
////
////        selectedMessage?.forEach({ indexPath in
////            let model = dataSource.itemIdentifier(for: indexPath)
////            if let message = model?.nimMessageModel {
////                if !SessionUtil().canMessageBeForwarded(message) {
////                    shareButton.isEnabled = false
////                }
////            }
////        })
//    }
//    
//    func updateSelectedItem() {
////        selectedItem.setTitle(String(format: "msg_number_of_selected".localized, String(format: "%i", selectedMsgId.count)), for: .normal)
//    }
//    
//    func updateRevokeButton() {
////        deleteButton.isEnabled = true
////        //        let selectedMessage = tableview.indexPathsForSelectedRows
////        //
////        //        for messageIndexPath in selectedMessage ?? [] {
////        //            let model = dataSource.itemIdentifier(for: messageIndexPath)
////        //            if let message = model?.nimMessageModel {
////        //                if !SessionUtil().canMessageBeRevoked(message) {
////        //                    deleteButton.isEnabled = false
////        //                    break
////        //                }
////        //            }
////        //        }
//    }
//    
//    func forwardAllImageIM() {}
//    
//    func deleteAllImageIM() {}
//}
