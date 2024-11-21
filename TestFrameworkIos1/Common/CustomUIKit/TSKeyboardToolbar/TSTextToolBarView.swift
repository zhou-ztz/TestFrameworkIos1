//
//  TSTextToolBarView.swift
//  KeyboardToolbar
//
//  Created by LeonFa on 2017/2/15.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 键盘工具栏布局视图

import UIKit
import SnapKit
import KMPlaceholderTextView

@objc protocol TSTextToolBarViewDelegate: NSObjectProtocol {
    func sendTextMessage(message: String, bundleId: String?, inputBox: AnyObject?, contentType: String)
    func removeToolBar()
    func emojiClick(emoji: String)
    func addStickerClick()
    func onClickMyStickers()
    func onClickCustimerStickers()
    func onTagUser(textView: UITextView)
    func onVoucherClick(_ voucherId: Int)
    @objc optional func changeFrame(currentHeight: CGFloat)
}

class TSTextToolBarView: UIView, UITextViewDelegate, TSSystemEmojiSelectorViewDelegate {
    
    typealias ChangeHeightClosure = (CGFloat) -> Void
    
    private var emojiViewHeight: CGFloat = Constants.emojiContainerHeight //145
    private var voucherHeight: CGFloat = Constants.voucherHeight //44
    
    var scrollMaxHeight: CGFloat = 120 + Constants.emojiContainerHeight + Constants.voucherHeight + TSBottomSafeAreaHeight
    
    // 显示字数下边距
    private let showTextNumberButtommargin: CGFloat = 10.0
    // 最大字数限制
    public var maximumWordLimit: Int = 255
    // 在多少字数后显示字数提示(不要低于50)
    public var maximumWord: Int {
        return maximumWordLimit - 55
    }
    // 获取当前的高度以便改变父类高度
    public var changeHeightClosure: ChangeHeightClosure? = nil
    // 父类的初始高度
    public var superViewSourceHeight: CGFloat = 0
    
    /// 选择Emoji的视图
    //var emoticonView: NTESInputEmoticonContainerView!
    var emoticonView: InputEmoticonContainerView!
    
    var removeToolbarOnSendMessage: Bool = true
    
    weak var toolBarViewDelegate: TSTextToolBarViewDelegate?
    
    var theme: Theme = .white {
        didSet {
            switch theme {
            case .white:
                backgroundColor = .white
            case .dark:
                backgroundColor = .black
            }
            
            messageInputView.theme = theme
        }
    }
    
    let messageInputView = MessageInputView()
    let voucherBottomView = VoucherBottomView()
    var voucherId: Int = 0
    
    // MARK -  Lifecycle
    ///
    /// - Parameter frame: 尺寸
    /// - Parameter initType: true TSKeyboardToolbar 创建而来 false TSMusicCommentToolView 创建而来(本项目有两个地方用到此类)
    init(frame: CGRect, superViewSourceHeight: CGFloat) {
        
        super.init(frame: frame)
        self.superViewSourceHeight = superViewSourceHeight
        backgroundColor = .white
        setUI()
    }
    
    private func setUI() {
        
        /// 限制输入文本框字数
        NotificationCenter.default.addObserver(self, selector:  #selector(self.textViewDidChanged(notification:)), name: UITextView.textDidChangeNotification, object: nil)
        
        emoticonView = InputEmoticonContainerView(frame: CGRect(x: 0, y: 54, width: ScreenWidth, height: 0))
        emoticonView!.layer.zPosition = CGFloat(MAXFLOAT)
        emoticonView!.delegate = self
        
        addSubview(voucherBottomView)
        addSubview(messageInputView)
        addSubview(emoticonView)
        
        emoticonView.isHidden = true
        voucherBottomView.isHidden = true
        voucherBottomView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        voucherBottomView.voucherOnTapped = {
            self.toolBarViewDelegate?.onVoucherClick(self.voucherId)
        }
        
        messageInputView.snp.makeConstraints {
            $0.top.equalTo(voucherBottomView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        emoticonView.snp.makeConstraints { (make) in
            make.top.equalTo(messageInputView.snp.bottom)
            make.left.right.equalToSuperview()
            
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottomMargin)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        
        messageInputView.sendButton.addTarget(self, action: #selector(sendText(_:)), for: .touchUpInside)
        messageInputView.smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControl.Event.touchUpInside)
        messageInputView.sendTextView.delegate = self
    }
    
    public func updateVoucherTag(_ tagVoucher: TagVoucherModel) {
        let hasVoucher = (tagVoucher.taggedVoucherId ?? 0) > 0
        voucherBottomView.isHidden = !hasVoucher
        voucherBottomView.voucherLabel.text = tagVoucher.taggedVoucherTitle ?? ""
        self.voucherId = hasVoucher ? tagVoucher.taggedVoucherId : 0
        self.setAllComponenSize(textView: messageInputView.sendTextView)
        voucherBottomView.snp.updateConstraints {
            $0.height.equalTo(hasVoucher ? 44 : 0)
        }
    }
    
    public func setEmotionNightMode(isNight: Bool) {
        emoticonView.setEmotionNightMode(isNight: isNight)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //根据输入内容处理sendButton是否可点击
        let number = "^\\s*|\\s*$"
        let numberPre = NSPredicate(format: "SELF MATCHES %@", number)
        if numberPre.evaluate(with: messageInputView.sendTextView.text) {
            messageInputView.sendButton.isEnabled = false
        } else {
            messageInputView.sendButton.isEnabled = true
        }
        // 免得搞忘，，这步是设置如果在粘贴的情况下超过字数如何处理
        if textView.text.count > maximumWordLimit {
            let str = textView.text
            if let str = str {
                let aaa = String(str[..<str.index(str.startIndex, offsetBy: maximumWordLimit)])
                textView.text = aaa
                textView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 300, height: 300), animated: true)
                setAllComponenSize(textView: textView)
                return
            }
        }
        self.setAllComponenSize(textView: textView)
        /// 匹配at人的情况
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            HTMLManager.shared.formatTextViewAttributeText(textView)
            return
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        /// 整体不可编辑
        // 联想文字则不修改
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
    }
    func setAllComponenSize(textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(MAXFLOAT)))
        let baseHeight = 13 + newSize.height + emojiViewHeight
        let currentComponentHeight = voucherId > 0 ? baseHeight + voucherHeight : baseHeight
        
        if textView.text.count >= maximumWord {
            self.messageInputView.showTextNumber.isHidden = false
            messageInputView.showTextNumber.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(messageInputView.sendButton.snp.top).offset(-showTextNumberButtommargin)
                make.centerX.equalTo(messageInputView.sendButton.snp.centerX)
            })
            
            UIView.animate(withDuration: 0.2, animations: {
                self.messageInputView.showTextNumber.layoutIfNeeded()
                self.messageInputView.showTextNumber.alpha = 1
            })
            
            let strCount = textView.text.count > maximumWordLimit ? maximumWordLimit : textView.text.count
            messageInputView.showTextNumber.attributedText = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: "\(strCount)" as NSString, firstColor: TSColor.normal.statisticsNumberOfWords, font: UIFont.systemFont(ofSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue)), second: (secondString: "/\(maximumWordLimit)" as NSString, secondColor: TSColor.normal.blackTitle, UIFont.systemFont(ofSize: TSFont.SubInfo.statisticsNumberOfWords.rawValue)))
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.messageInputView.showTextNumber.alpha = 0.2
            }, completion: { (_) in
                self.messageInputView.showTextNumber.isHidden = true
            })
        }
        
        if currentComponentHeight >= scrollMaxHeight {
            textView.isScrollEnabled = true
            
            if let changeHeightClosure = self.changeHeightClosure {
                changeHeightClosure(scrollMaxHeight - 20)
            }
            
            self.snp.remakeConstraints { (make) in
                make.bottom.right.left.equalTo(self.superview!)
                make.height.equalTo(scrollMaxHeight - 20)
            }
            messageInputView.layoutIfNeeded()
            messageInputView.snp.remakeConstraints {
                $0.top.equalTo(voucherBottomView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(103)
            }
            
        } else {
            
            textView.isScrollEnabled = false
            
            messageInputView.snp.remakeConstraints {
                $0.top.equalTo(voucherBottomView.snp.bottom)
                $0.leading.trailing.equalToSuperview()
                $0.height.equalTo(13 + newSize.height)
            }
            messageInputView.layoutIfNeeded()
            self.snp.remakeConstraints { (make) in
                make.bottom.right.left.equalTo(self.superview!)
                make.height.equalTo(currentComponentHeight)
            }
            
            if let changeHeightClosure = self.changeHeightClosure {
                changeHeightClosure(currentComponentHeight)
            }
        }
    }
    
    func setSendViewParameter(placeholderText: String, inputbox: AnyObject?, maximumWordLimit: Int) {
        self.maximumWordLimit = maximumWordLimit
        self.messageInputView.inputBox = inputbox
        messageInputView.sendTextView.placeholder = placeholderText
        messageInputView.sendTextView.becomeFirstResponder()
        if self.messageInputView.inputBox is UITextField {
            let inputTextField = self.messageInputView.inputBox as? UITextField
            messageInputView.sendTextView.text = inputTextField?.text
        } else if self.messageInputView.inputBox is UITextView {
            let inputTextField = self.messageInputView.inputBox as? UITextView
            messageInputView.sendTextView.text = inputTextField?.text
        }
        
        self.setAllComponenSize(textView: messageInputView.sendTextView)
        
    }
    
    func refreshEmoticons() {
        emoticonView.refreshStickerKeyboard()
    }
    
    @objc private func textViewDidChanged(notification: Notification) {
        
        TSAccountRegex.checkAndUplodTextFieldText(textField: messageInputView.sendTextView, stringCountLimit: maximumWordLimit)
    }
    internal func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if text == "" {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            if isEditAt {
                HTMLManager.shared.formatTextViewAttributeText(textView)
                textView.selectedRange = atRange
                return false
            }
        } else if text == "@" {
            // 跳转到at列表
            // 手动输入的at在选择了用户的block中会先移除掉,如果跳转后不选择用户就不做处理
            //            let topMostVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
            //            if topMostVC?.isKind(of: YippiLivePlayerViewController.self) == true || topMostVC?.isKind(of: YippiLiveViewController.self) == true {
            //                    return true
            //            }
            
            toolBarViewDelegate?.onTagUser(textView: textView)
            TSKeyboardToolbar.share.isAtActionPush = true
            return true
        }
        return true
    }
    
    @objc private func sendText(_ btn: UIButton) {
        self.sendMessage()
    }
    
    private func sendMessage() {
        if self.messageInputView.inputBox is UITextField {
            let inputTextField = self.messageInputView.inputBox as? UITextField
            inputTextField?.text = messageInputView.sendTextView.text
        } else if self.messageInputView.inputBox is UITextView {
            let inputTextView = self.messageInputView.inputBox as? UITextView
            inputTextView?.text = messageInputView.sendTextView.text
        }
        
        //        messageInputView.sendTextView.text = messageInputView.sendTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //        messageInputView.sendTextView.text = messageInputView.sendTextView.text.replacingOccurrences(of: "\r", with: "")
        
        let number = "^\\s*|\\s*$"
        let numberPre = NSPredicate(format: "SELF MATCHES %@", number)
        if numberPre.evaluate(with: messageInputView.sendTextView.text) {
            return
        }
        /// 转换手动输入的at为TS+的at规则
        var pulseContent = messageInputView.sendTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if let attributedString = messageInputView.sendTextView.attributedText {
            pulseContent = HTMLManager.shared.formHtmlString(attributedString)
        }
        //        messageInputView.sendTextView.text = TSUtil.replaceEditAtString(inputStr: messageInputView.sendTextView.text)
        self.toolBarViewDelegate?.sendTextMessage(message: pulseContent, bundleId: nil, inputBox: self.messageInputView.inputBox, contentType: CommentContentType.text.rawValue)
        messageInputView.sendTextView.text = ""
        self.textViewDidChange(messageInputView.sendTextView)
        if removeToolbarOnSendMessage {
            toolBarViewDelegate?.removeToolBar()
        }
    }
    
    @objc func emojiBtnClick() {
        messageInputView.smileButton.isSelected = !messageInputView.smileButton.isSelected
        if messageInputView.smileButton.isSelected {
            messageInputView.sendTextView.resignFirstResponder()
            emoticonView.isHidden = false
        } else {
            messageInputView.sendTextView.becomeFirstResponder()
            emoticonView.isHidden = true
        }
    }
    
    func emojiViewDidSelected(emoji: String) {
        toolBarViewDelegate?.emojiClick(emoji: emoji)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func sendSticker(url: String, bundleId: String) {
        self.toolBarViewDelegate?.sendTextMessage(message: url, bundleId: bundleId, inputBox: self.messageInputView.inputBox, contentType: CommentContentType.sticker.rawValue)
        if removeToolbarOnSendMessage {
            toolBarViewDelegate?.removeToolBar()
        }
    }
}

class MessageInputView: UIView {
    
    // 传过来的文本输入框
    public var inputBox: AnyObject?
    
    // 发送按钮
    var sendButton: UIButton
    // 显示字数
    var showTextNumber: UILabel
    // 录入文本
    var sendTextView: KMPlaceholderTextView
    // 下分割线
    private var bottomLine: UIView
    // 上分割线
    private var topLine: UIView
    // 分割线
    private var borderLine: UIImageView
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    
    // 按钮圆角
    private let buttonCorner: CGFloat = 3.0
    // 按钮右边距
    private let buttonRightmargin: CGFloat = 10.0
    // 按钮下边距
    private let buttonButtommargin: CGFloat = 9.0
    // 按钮尺寸
    private let buttonSize: CGSize = CGSize(width: 30.0, height: 30.0)
    // 下分割线左边距
    private let bottomLineLeftmargin: CGFloat = 10.0 + 10 + 18
    // 下分割线右边距
    private let bottomLineRightmargin: CGFloat = 8.0
    // 下分割线的下边距
    private let bottomLineBottommargin: CGFloat = 8.0
    // 下分割线的高度
    private let bottomLineHeight: CGFloat = 0.5
    
    var theme: Theme = .white {
        didSet {
            switch theme {
            case .white:
                backgroundColor = .white
                sendTextView.textColor = TSColor.main.content
                topLine.backgroundColor = TSColor.normal.keyboardTopCutLine
                borderLine.alpha = 1.0
            case .dark:
                backgroundColor = AppTheme.materialBlack
                sendTextView.textColor = UIColor.lightText
                topLine.backgroundColor = .clear
                borderLine.alpha = 0.1
            }
        }
    }
    
    init() {
        
        sendButton = UIButton(type: .custom)
        sendTextView = KMPlaceholderTextView()
        bottomLine = UIView()
        topLine = UIView()
        borderLine = UIImageView()
        showTextNumber = UILabel()
        
        super.init(frame: .zero)
        
        theme = .white
        
        self.addSubview(topLine)
        topLine.backgroundColor = TSColor.normal.keyboardTopCutLine
        topLine.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bottomLineHeight)
        }
        
        
        // 设置文本框
        self.addSubview(borderLine)
        borderLine.image = UIImage.set_image(named: "imgInputBackground")?.resizableImage(withCapInsets: UIEdgeInsets(top: 15, left: 80, bottom: 15, right: 80), resizingMode: .stretch)
        
        /// 设置按钮
        self.addSubview(sendButton)
        sendButton.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
        
        // 设置字数文本框
        self.addSubview(showTextNumber)
        showTextNumber.alpha = 0.2
        showTextNumber.isHidden = true
        
        self.addSubview(sendTextView)
        sendTextView.placeholder = "rw_placeholder_comment".localized
        sendTextView.backgroundColor = UIColor.clear
        sendTextView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.comment.rawValue)
        sendTextView.font = UIFont.systemFont(ofSize: TSFont.ContentText.comment.rawValue)
        sendTextView.placeholderColor = TSColor.normal.disabled
        sendTextView.isScrollEnabled = false
        sendTextView.layoutManager.allowsNonContiguousLayout = false
        sendTextView.returnKeyType = .next
        
        self.addSubview(smileButton)
        smileButton.setImage(UIImage.set_image(named: "icTextSticker_blue"), for: .normal)
        smileButton.setImage(UIImage.set_image(named: "ico_comment_keyboard"), for: .selected)
        
        showTextNumber.snp.makeConstraints { (make) in
            make.bottom.equalTo(sendButton.snp.bottom)
            make.centerX.equalTo(sendButton.snp.centerX)
        }
        sendTextView.snp.makeConstraints { (make) in
            make.bottom.greaterThanOrEqualTo(borderLine.snp.bottom).offset(-3)
            make.top.greaterThanOrEqualTo(borderLine.snp.top).offset(3)
            make.leftMargin.equalTo(borderLine.snp.leftMargin).offset(3)
            make.right.equalTo(smileButton.snp.left).offset(-3)
            make.centerY.equalTo(borderLine.snp.centerY)
        }
        borderLine.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(sendButton.snp.left).offset(-buttonRightmargin)
            make.top.equalTo(topLine.snp.bottom).offset(3)
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-3)
            } else {
                make.bottom.equalToSuperview().offset(-3)
            }
        }
        smileButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(borderLine.snp.bottom).offset(-6)
            make.right.equalTo(borderLine.snp.right).offset(-10)
            make.size.equalTo(buttonSize)
        }
        sendButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(smileButton.snp.centerY)
            if #available(iOS 11, *) {
                make.right.equalTo(self.safeAreaLayoutGuide.snp.right).offset(-buttonRightmargin)
            } else {
                make.right.equalToSuperview().offset(-buttonRightmargin)
            }
            make.size.equalTo(buttonSize)
        }
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TSTextToolBarView: InputEmoticonProtocol {
    func didPressSend(_ sender: Any?) {
        self.sendMessage()
    }
    
    func didPressAdd(_ sender: Any?) {
        self.toolBarViewDelegate?.addStickerClick()
    }
    
    func selectedEmoticon(_ emoticonID: String?, catalog emotCatalogID: String?, description: String?, stickerId: String?) {
        guard let stickerUrl = emoticonID, let bundleId = emotCatalogID, let stickerId = stickerId else { return }
        self.sendSticker(url: stickerUrl, bundleId: bundleId)
    }
    
    func sendEmoji(_ emojiTag: String?) {
        guard let emojiTag = emojiTag else { return }
        self.emojiViewDidSelected(emoji: emojiTag)
    }
    
    func didPressMySticker(_ sender: Any?) {
        self.toolBarViewDelegate?.onClickMyStickers()
    }
    
    func didPressCustomerSticker() {
        self.toolBarViewDelegate?.onClickCustimerStickers()
    }
}
