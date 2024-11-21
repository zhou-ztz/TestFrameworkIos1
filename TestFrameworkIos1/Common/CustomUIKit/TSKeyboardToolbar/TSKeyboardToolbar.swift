//
//  KeyboardToolbar.swift
//  KeyboardToolbar
//
//  Created by LeonFa on 2017/2/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 键盘输入工具栏
// 使用详情见文档

import UIKit
import SnapKit
import KMPlaceholderTextView
//import NIMPrivate

protocol TSKeyboardToolbarDelegate: NSObjectProtocol {
    /// 回传字符串和响应对象
    ///
    /// - Parameter message: 回传的String
    func keyboardToolbarSendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: CommentContentType)

    /// 回传键盘工具栏的Frame
    ///
    /// - Parameter frame: 坐标和尺寸
    func keyboardToolbarFrame(frame: CGRect, type: keyboardRectChangeType)

    /// 键盘准备收起
    func keyboardWillHide()
    
    /// 关闭整个键盘
    func keyboardToolbarDidDismiss()
}

extension TSKeyboardToolbarDelegate {
    func keyboardToolbarDidDismiss() {}
}

enum keyboardRectChangeType {
    /// 弹出键盘
    case popUp

    /// 打字
    case typing

    /// 收起键盘
    case willHide
}

enum CommentContentType: String {
    case sticker = "sticker"
    case text = "text"
}

class TSKeyboardToolbar: UIView, TSTextToolBarViewDelegate {
    /// 是否正则At跳转
    var isAtActionPush: Bool = false
    var isAtColorBlack: Bool = false
    private let emojiHeight: CGFloat = Constants.emojiContainerHeight + TSBottomSafeAreaHeight
    // 工具栏初始高度
    private let toolBarHeight: CGFloat = Constants.textToolbarHeight + Constants.emojiContainerHeight + TSBottomSafeAreaHeight + Constants.voucherHeight
    // 键盘通知单例
    private let keyboard = Typist.shared
    // 键盘工具栏单例
    static let share = TSKeyboardToolbar()
    
    var theme: Theme = .white {
        didSet {
            textToolBarView?.theme = theme
        }
    }
    // 工具栏内部布局视图
    private var textToolBarView: TSTextToolBarView? = nil
    // 是否需要回调
    private var isBlock = true
    // 背景遮罩层
    lazy private var bgView: UIView = {
        let view = UIView()
        self.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        var frame = UIScreen.main.bounds
        frame.size.height += 64.0
        view.frame = frame
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapBG))
        view.addGestureRecognizer(tap)
        return view
    }()
    

    // 改变后需要增加的高度
    private var changeHeight: CGFloat = 0.0
    // 记录Y坐标位置
    private var originY: CGFloat = 0.0
    // 代理
    weak var keyboardToolbarDelegate: TSKeyboardToolbarDelegate?
    // 键盘的高度
    private var currentToolBarHeight: CGFloat = 0
        
    // MARK: - 初始化键盘
    public func configureKeyboard () {
        let keyboardToolbar = TSKeyboardToolbar.share
        keyboardToolbar.bounds = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: toolBarHeight)
        if textToolBarView == nil {
            textToolBarView = TSTextToolBarView(frame: keyboardToolbar.bounds, superViewSourceHeight: toolBarHeight)
            textToolBarView?.toolBarViewDelegate = self
            guard let textToolBarView = textToolBarView else {
                assert(false, "\(TSTextToolBarView.self)初始化失败")
                return
            }

            textToolBarView.changeHeightClosure = {[weak self] value in
                if let weak = self {
                    weak.changeHeight = value - weak.toolBarHeight >= 0 ? 0 : value - weak.toolBarHeight
                    keyboardToolbar.frame = CGRect(x: 0, y: weak.originY - weak.changeHeight , width: textToolBarView.frame.size.width, height: value)
                    if weak.currentToolBarHeight != value {
                        if weak.isBlock {
                            weak.keyboardToolbarDelegate?.keyboardToolbarFrame(frame: keyboardToolbar.frame, type: .typing)
                            weak.currentToolBarHeight = value
                        }
                    }
                }
            }

            keyboardToolbar.addSubview(textToolBarView)
            textToolBarView.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
        setKeyboardFun()
    }

    // MARK: - 获取相应的输入框
    ///
    /// - Parameter inputbox: 接收TextView或者TextField
    public func keyboardGetInputbox<T>(inputbox: T, maximumWordLimit: Int, placeholderText: String?) {
        textToolBarView?.setSendViewParameter(placeholderText:  placeholderText ?? " ", inputbox: inputbox as AnyObject, maximumWordLimit: maximumWordLimit)
    }

    // MARK: - BecomeFirstResponder
    /// 响应弹出键盘
    public func keyboardBecomeFirstResponder() {
        if self.isBlock == false {
            // 使用的页面没有开启,手动开启并输出日志提醒开发人员进行修复。
            self.keyboardstartNotice()
           /*
             """
             \n\n\n请注意!!!!!\n
             当前列表使用了TSKeyboardToolbar,但是没有开启监听!
             请在viewWillAppear中设置
             TSKeyboardToolbar.share.keyboardstartNotice()
             并在viewWillDisappear中注销
             TSKeyboardToolbar.share.keyboarddisappear()
             TSKeyboardToolbar.share.keyboardStopNotice()
             \n\n\n
             """
            */
        }
        textToolBarView?.messageInputView.sendTextView.becomeFirstResponder()
        textToolBarView?.refreshEmoticons()
        let window = UIApplication.shared.keyWindow
        window?.addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.2) {
            self.bgView.backgroundColor = TSColor.normal.transparentBackground
        }
        window?.addSubview(self)
        //处理每次弹出键盘出，上方闪动出现贴纸视图
        self.isHidden = true
        
    }

    // MARK: - 切换视图或者需要收起键盘的时候使用的方法
    public  func keyboarddisappear() {
        textToolBarView?.messageInputView.sendTextView.resignFirstResponder()
    }

    // MARK: - 停止通知
    public func keyboardStopNotice() {
        if TSKeyboardToolbar.share.isAtActionPush {
            return
        }
        let keyboardToolbar = TSKeyboardToolbar.share
        textToolBarView?.messageInputView.sendTextView.text = ""
        /// 这里是为重置键盘的高度
        self.isBlock = false
        textToolBarView?.textViewDidChange((textToolBarView?.messageInputView.sendTextView)!)
        keyboardToolbar.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
        })
        keyboard.stop()
        //theme = .white
    }

    // MARK: - 开启通知
    public func keyboardstartNotice() {
        self.isBlock = true
        setKeyboardFun()
        if self.isAtActionPush {
            self.keyboardBecomeFirstResponder()
            if (self.textToolBarView != nil) {
                if (!self.textToolBarView!.messageInputView.sendTextView.text.contains("@")) {
                    self.textToolBarView!.messageInputView.sendTextView.text = "\(self.textToolBarView!.messageInputView.sendTextView.text ?? "")@"
                }
            }
        } else {
            self.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.size.height)
        }
        self.isAtActionPush = false
    }

    // MARK: - 设置占位符
    /// 传入占位字符串方法(此方法在点击按钮弹出时使用，textView, 和TextField有单独的占位符参数)
    ///
    /// - Parameter placeholderText: 占位字符串内容
    public func keyboardSetPlaceholderText(placeholderText: String) {
        textToolBarView?.messageInputView.sendTextView.placeholder = placeholderText
    }

    // MARK: - 设置最大字数显示
    /// 设置最大字数显示(此方法在点击按钮弹出时使用，textView, 和TextField有单独的最大字数参数)
    ///
    /// - Parameter limit: 最大字数限制
    public func keyboardSetMaximumWordLimit(limit: Int) {
        textToolBarView?.maximumWordLimit = limit
    }

    // MARK: - 窃取textView或TextField文本相应
    /// 获取textView和TextField的方法
    ///
    /// - Parameters:
    ///   - message: 输入的文本信息
    ///   - inputBox: 把当前的textView或TextField传进去
    public func sendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: String) {        
        self.keyboardToolbarDelegate?.keyboardToolbarSendTextMessage(message: message, bundleId: bundleId, inputBox: inputBox, contentType: CommentContentType(rawValue: contentType) ?? .text)
    }
    
    public func isEmojiSelected() -> Bool {
        return textToolBarView?.messageInputView.smileButton.isSelected ?? false
    }

    public func emojiButtonClick() {
        self.isHidden = false
        textToolBarView?.messageInputView.smileButton.isSelected = true
        textToolBarView?.messageInputView.sendTextView.resignFirstResponder()
    }
    
    //外部页面点击表情时，弹出表情页
    public func showEmojiView() {
        self.isHidden = false
        let window = UIApplication.shared.keyWindow
        window?.addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        UIView.animate(withDuration: 0.2) {
            self.bgView.backgroundColor = TSColor.normal.transparentBackground
        }
        window?.addSubview(self)
        textToolBarView?.messageInputView.smileButton.isSelected = true
        originY = toolBarHeight
        
        self.updateKeyboardFrameWithNoKeyBoard(to: UIScreen.main.bounds.size)
        
    }

    public var dismissToolbarOnSend: Bool = true {
        didSet {
            self.textToolBarView?.removeToolbarOnSendMessage = self.dismissToolbarOnSend
        }
    }
    
    func removeToolBar() {
        self.textToolBarView?.emoticonView.isHidden = true
        self.keyboardToolbarDelegate?.keyboardToolbarDidDismiss()
        
        TSKeyboardToolbar.share.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
        })
        
        self.isAtColorBlack = false
    }

    func emojiClick(emoji: String) {
        originY = UIScreen.main.bounds.size.height - (self.textToolBarView?.height)! + changeHeight
        self.textToolBarView?.messageInputView.sendTextView.insertText(emoji)
        self.textToolBarView?.messageInputView.sendTextView.scrollRangeToVisible((self.textToolBarView?.messageInputView.sendTextView.selectedRange)!)
    }

    func addStickerClick() {
        if let rootViewController = UIApplication.topViewController() {
            let vc = StickerMainViewController()
            let nav = PortraitNavigationController(rootViewController: vc)
            nav.onPopViewController = { [weak self] in
                self?.keyboardToolbarDelegate?.keyboardToolbarDidDismiss()
            }
            rootViewController.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    func onClickMyStickers() {
        if let rootViewController = UIApplication.topViewController() {
            let vc = MyStickersViewController()
            let nav = PortraitNavigationController(rootViewController: vc)
            nav.onPopViewController = { [weak self] in
                self?.keyboardToolbarDelegate?.keyboardToolbarDidDismiss()
            }
            rootViewController.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    func onClickCustimerStickers() {
        if let rootViewController = UIApplication.topViewController() {
            let vc = CustomerStickerViewController(sticker: "")
            let nav = PortraitNavigationController(rootViewController: vc)
            nav.onPopViewController = { [weak self] in
                self?.keyboardToolbarDelegate?.keyboardToolbarDidDismiss()
            }
            rootViewController.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    func onVoucherClick(_ voucherId: Int) {
        if let rootViewController = UIApplication.topViewController() {
            let vc = VoucherDetailViewController()
            vc.voucherId = voucherId
            let nav = PortraitNavigationController(rootViewController: vc)
            nav.onPopViewController = { [weak self] in
                self?.keyboardToolbarDelegate?.keyboardToolbarDidDismiss()
            }
            rootViewController.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    public func setStickerNightMode(isNight: Bool){
        textToolBarView?.setEmotionNightMode(isNight: isNight)
    }

    func onTagUser(textView: UITextView) {
        TSKeyboardToolbar.share.removeFromSuperview()
        UIView.animate(withDuration: 0.2, animations: {
            self.bgView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.0)
        }, completion: { (_) in
            self.bgView.removeFromSuperview()
        })
        keyboard.stop()
//        if let rootViewController = UIApplication.topViewController() {
//            let atselectedListVC = TSAtPeopleAndMechantListVC()
//            atselectedListVC.selectedBlock = { [weak self] (userInfo, userInfoModelType) in
//                guard let self = self else { return }
//                if let userInfo = userInfo {
//                    /// 先移除光标所在前一个at
//                    self.insertTagTextIntoContent(userId: userInfo.userIdentity, userName: userInfo.name)
//                    return
//                }
//                self.textToolBarView?.messageInputView.sendTextView = TSCommonTool.atMeTextViewEdit(self.textToolBarView?.messageInputView.sendTextView) as! KMPlaceholderTextView
//            }
//            let nav = TSNavigationController(rootViewController: atselectedListVC)
//            rootViewController.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//        }
    }
    
    func insertTagTextIntoContent(userId: Int? = nil, userName: String) {
//        self.textToolBarView?.messageInputView.sendTextView = TSCommonTool.atMeTextViewEdit(self.textToolBarView?.messageInputView.sendTextView) as! KMPlaceholderTextView
//        guard var textView = self.textToolBarView?.messageInputView.sendTextView else { return }
//
//        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
//        let newMutableString = textView.attributedText.mutableCopy() as! NSMutableAttributedString
//        newMutableString.append(temp)
//        
//        textView.attributedText = newMutableString
//        textView.delegate?.textViewDidChange!(textView)
//        textView.becomeFirstResponder()
    }
    
    func updateKeyboardFrameWithNoKeyBoard(to screenSize: CGSize) {
        guard let mWindow = UIApplication.shared.keyWindow else {
            assert(false, "\(TSTextToolBarView.self)没有获取到window")
            return
        }
        self.isHidden = false
        TSKeyboardToolbar.share.snp.removeConstraints()
        if TSKeyboardToolbar.share.superview != nil {
            TSKeyboardToolbar.share.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.left.right.equalToSuperview()
                $0.height.equalTo(toolBarHeight + changeHeight)
            }
        } else {
            TSKeyboardToolbar.share.frame = CGRect(x: 0, y: screenSize.height - (toolBarHeight + changeHeight), width: screenSize.width, height: toolBarHeight + changeHeight)
        }
        textToolBarView?.refreshEmoticons()
    }
    
    // MARK: - Private
    private func changeUI(keyboard: Typist.KeyboardOptions, event: Typist.KeyboardEvent) {
        let window = UIApplication.shared.keyWindow
        guard let mWindow = window else {
            assert(false, "\(TSTextToolBarView.self)没有获取到window")
            return
        }

        let keyboardToolbar = TSKeyboardToolbar.share
        self.isHidden = false
        switch event {
        case .willShow:
            textToolBarView?.messageInputView.smileButton.isSelected = false
            setKeyboardToolbarOrigin(keyboard: keyboard, keyboardToolbar: keyboardToolbar, mWindow: mWindow, show: true)
            currentToolBarHeight = keyboardToolbar.bounds.size.height
            self.keyboardToolbarDelegate?.keyboardToolbarFrame(frame: self.frame, type: .popUp)
        case .didShow:
            break
        case .willHide:
            self.keyboardToolbarDelegate?.keyboardWillHide()
            setKeyboardToolbarOrigin(keyboard: keyboard, keyboardToolbar: keyboardToolbar, mWindow: mWindow, show: false)
        case .didHide:
            break
        default:
            break
        }
    }

    private func setKeyboardFun () {
        keyboard.on(event: .willChangeFrame) { (options) in }
            .on(event: .willShow) { (options) in
                self.isHidden = false
                self.changeUI(keyboard: options, event: .willShow)
            }.on(event: .didShow) { (options) in
                self.changeUI(keyboard: options, event: .didShow)
            }.on(event: .willHide) { (options) in
                self.changeUI(keyboard: options, event: .willHide)
            }.on(event: .didHide) { (options) in
                self.changeUI(keyboard: options, event: .didHide)
            }.start()
    }

    @objc private func tapBG() {
//        keyboarddisappear()
        removeToolBar()
    }

    private func setKeyboardToolbarOrigin(keyboard: Typist.KeyboardOptions, keyboardToolbar: TSKeyboardToolbar, mWindow: UIWindow, show: Bool) {
        if show {
            originY = keyboard.endFrame.origin.y - toolBarHeight + emojiHeight
            keyboardToolbar.snp.removeConstraints()
            if keyboardToolbar.superview != nil {
                keyboardToolbar.snp.makeConstraints {
                    $0.top.equalToSuperview().offset(keyboard.endFrame.origin.y - (toolBarHeight + changeHeight - emojiHeight))
                    $0.left.right.equalToSuperview()
                    $0.height.equalTo(toolBarHeight + changeHeight)
                }
            } else {
                keyboardToolbar.frame = CGRect(x: 0, y: keyboard.endFrame.origin.y - (toolBarHeight + changeHeight - emojiHeight), width: mWindow.bounds.size.width, height: toolBarHeight + changeHeight)
            }
        } else {
            originY = keyboard.endFrame.origin.y - toolBarHeight + emojiHeight
            
            if textToolBarView?.messageInputView.smileButton.isSelected == true {
                self.updateKeyboardFrameWithNoKeyBoard(to: UIScreen.main.bounds.size)
            } else {
                keyboardToolbar.snp.removeConstraints()
                if keyboardToolbar.superview != nil {
                    keyboardToolbar.snp.makeConstraints {
                        $0.top.equalToSuperview().offset(keyboard.endFrame.origin.y - (toolBarHeight + changeHeight - emojiHeight))
                        $0.left.right.equalToSuperview()
                        $0.height.equalTo(toolBarHeight + changeHeight)
                    }
                } else {
                    keyboardToolbar.frame = CGRect(x: 0, y: UIScreen.main.bounds.size.height - (toolBarHeight + changeHeight), width: mWindow.bounds.size.width, height: toolBarHeight + changeHeight)
                }
            }
        }
        textToolBarView?.snp.removeConstraints()
        textToolBarView?.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    public func getCurrentText() -> String {
        return self.textToolBarView?.messageInputView.sendTextView.text ?? ""
    }
    
    public func clearCurrentTextOnSend() {
        self.textToolBarView?.messageInputView.sendTextView.text = nil
        guard let textview = self.textToolBarView?.messageInputView.sendTextView else { return }
        self.textToolBarView?.textViewDidChange(textview)
    }
    
    public func inputText(input:String) {
        self.textToolBarView?.messageInputView.sendTextView.text = input
    }
    
    public func setTagVoucher(_ tagVoucher: TagVoucherModel) {
        textToolBarView?.updateVoucherTag(tagVoucher)
    }
}

