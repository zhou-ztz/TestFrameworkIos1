//
//  RedPacketViewController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 05/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import SwiftEntryKit
import SwiftUI
import KMPlaceholderTextView
import IQKeyboardManagerSwift

enum ModeType {
    case random
    case identical
    case specific
    
    var value: String {
        switch self {
        case .random:
            return "redpacket_mode_random".localized
        case .identical:
            return "redpacket_mode_identical".localized
        case .specific:
            return "redpacket_mode_specific".localized
        default:
            return ""
        }
    }
}

enum TransactionType {
    case personal, group, yippsTransfer
}
// selectionInputDelegate
class RedPacketViewController: TSViewController, btnTapDelegate{
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var redBgView: UIView!
    @IBOutlet weak var popOutLabel: UILabel!
    @IBOutlet weak var redPacketModeView: UIView!
    @IBOutlet weak var redPacketModeLabel: UILabel!
    @IBOutlet weak var downImageView: UIImageView!
    @IBOutlet weak var sendingRedLabel: UILabel!
    @IBOutlet weak var arrowView: UIView!
    @IBOutlet weak var avatarTopStackView: UIStackView!
    @IBOutlet weak var avatarStackView: UIStackView!
    @IBOutlet weak var avatarView = AvatarView()
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var yippisBalanceLabel: UILabel!
    //@IBOutlet weak var topupButton: UIButton!
    @IBOutlet weak var groupStackView: UIStackView!
    @IBOutlet weak var redPacketQuantityStackView: UIStackView!
    @IBOutlet weak var redPacketQuantiyView: AuthTextfield!
    @IBOutlet weak var totalMemberLabel: UILabel!
    @IBOutlet weak var amountView: AuthTextfield!
    @IBOutlet weak var wishView: AuthTextfield!
    @IBOutlet weak var totalAmountLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var constHeight: NSLayoutConstraint!
    
    var inputPrice: Double? {
        didSet {
            validate()
        }
    }
    /// 打赏金额 单位人民币分
    var inputPrices: [Int] = [1, 5, 10, 20]
    /// 打赏的目标Id
    var sourceId: Int?
    var rewardSuccessAction: ((_ rewadModel: TSNewsRewardModel) -> Void)?
    
    var username: String
    var finishBlock: TransactionFinishClosure?
    var receiver: String
    var modeType: ModeType = .random
    var selectedContact: ContactData? = nil
    var transactionType: TransactionType = .personal
    var numberOfMember: Int
    var teamId: String? = nil
    private var apiDebouncer = Debouncer(delay: 1)
    private var handler: ((_ selectedPrice: Int) -> ())?
    private var buttons: [TSButton] = []
    private(set) var selectedInputIndex: Int?
    private var redPacketId: Int?
    private var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputPrices = TSAppConfig.share.launchInfo?.rewardAmounts ??  [1, 5, 10, 20]
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: NSNotification.Name.Wallet.reloadBalance, object: nil)
        
        setUI()
        view.layoutIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Wallet.reloadBalance, object: nil)
    }
    
    public init(transactionType: TransactionType, fromUser: String, toUser: String, numberOfMember: Int, teamId: String? = nil, completion: TransactionFinishClosure?) {
        self.username = fromUser
        self.receiver = toUser
        self.numberOfMember = numberOfMember
        self.transactionType = transactionType
        self.finishBlock = completion
        self.teamId = teamId
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK: set ui
    func setUI() {
        self.view.backgroundColor = .white
        self.setCloseButton(backImage: true, titleStr: transactionType == .yippsTransfer ? "transfer".localized : "title_send_egg".localized, completion: {
            self.view.endEditing(true)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
                self.navigationController?.popViewController(animated: true)
            }
        })
        
        sendingRedLabel.text = transactionType == .yippsTransfer ? "txt_transferring_to".localized : "rw_sending_red_packet_to".localized
        //topupButton.setTitle("red_packet_topup".localized, for: .normal)
        
        let modeStr = "red_packet_mode".localized
        let modeRange = (modeStr as NSString).range(of: "*")
        let modeAttr = NSMutableAttributedString.init(string: modeStr)
        modeAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: modeRange)
        
        let modeTap = UITapGestureRecognizer(target: self, action: #selector(modeAction))
        redPacketModeView.addGestureRecognizer(modeTap)
        redPacketModeLabel.text = "redpacket_mode_random".localized
        
        let selectionTap = UITapGestureRecognizer(target: self, action: #selector(selectionAction))
        avatarTopStackView.addGestureRecognizer(selectionTap)
        
        let qtyStr = "red_packet_quantity".localized
        let qtyRange = (qtyStr as NSString).range(of: "*")
        let qtyAttr = NSMutableAttributedString.init(string: qtyStr)
        qtyAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: qtyRange)
        redPacketQuantiyView.placeholder = ""
        redPacketQuantiyView.needBorder = false
        redPacketQuantiyView.attributePlaceholder = qtyAttr
        redPacketQuantiyView.textfield.keyboardType = .numberPad
        redPacketQuantiyView.textfield.add(event: .editingChanged) {  [weak self] in
            self?.validate()
        }
        redPacketQuantiyView.clipsToBounds = true
        redPacketQuantiyView.layer.cornerRadius = 10
        redPacketQuantiyView.roundBorder()
        redPacketQuantiyView.textWrapper.backgroundColor = UIColor(hex: 0xF5F5F5)
        redPacketQuantiyView.wrapper.applyBorder(color: .clear, width: 0.5)
        
        let amtStr = "red_packet_total_amount".localized
        //        let amtRange = (amtStr as NSString).range(of: "*")
        //        let totalRange = (amtStr as NSString).range(of: amtStr)
        //        let amtAttr = NSMutableAttributedString.init(string: amtStr)
        //        amtAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: amtRange)
        
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedString.Key.foregroundColor : UIColor.darkGray]
        let attrs2 = [NSAttributedString.Key.font : UIFont.systemRegularFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.red]
        
        let attributedString1 = NSMutableAttributedString(string: amtStr, attributes:attrs1)
        let attributedString2 = NSMutableAttributedString(string:"*", attributes:attrs2)
        attributedString1.append(attributedString2)
        
        amountView.type = .amount
        amountView.delegate = self
        amountView.placeholder = ""
        amountView.needBorder = false
        amountView.attributePlaceholder = attributedString1
        amountView.textfield.text = "0.00"
        amountView.animateToSelected(animated: false, isFirst: true)
        amountView.textfield.keyboardType = .numberPad
        //amountView.textfield.delegate = self
        amountView.clipsToBounds = true
        amountView.layer.cornerRadius = 10
        amountView.roundBorder()
        amountView.textWrapper.backgroundColor = UIColor(hex: 0xF5F5F5)
        amountView.wrapper.applyBorder(color: .clear, width: 0.5)
        
        wishView.type = .bestWish
        wishView.placeholder = ""
        wishView.needBorder = false
        wishView.attributePlaceholder =  NSAttributedString(string: "viewholder_egg_best_wishes".localized, attributes: [
            .foregroundColor: UIColor.lightGray,
            .font: UIFont.boldSystemFont(ofSize: 15.0)
        ])
        wishView.clipsToBounds = true
        wishView.layer.cornerRadius = 10
        wishView.roundBorder()
        wishView.textWrapper.backgroundColor = UIColor(hex: 0xF5F5F5)
        wishView.wrapper.applyBorder(color: .clear, width: 0.5)
        
//        topupButton.layer.cornerRadius = 20.0
//        topupButton.backgroundColor = TSColor.main.theme
//        topupButton.setTitleColor(.white, for: .normal)
//        topupButton.addTarget(self, action: #selector(topupAction), for: .touchUpInside)
//        topupButton.isHidden = true
        
        popOutLabel.textColor = .red
        nameLabel.textColor = UIColor(red: 18, green: 18, blue: 18)
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        sendingRedLabel.font = AppTheme.Font.semibold(14)
        yippisBalanceLabel.font =  UIFont.systemFont(ofSize: 12)
        yippisBalanceLabel.textColor = UIColor(hex: 0x808080)
        totalMemberLabel.font = UIFont.systemFont(ofSize: 12)
        totalMemberLabel.textColor = UIColor(hex: 0x808080)
        totalAmountLabel.font = AppTheme.Font.bold(28)
        
        if let user = CurrentUserSessionInfo {
            yippisBalanceLabel.text = "\("rw_yipps_balance_with_colon".localized) \(user.yippsTotal.tostring(decimal: 2)) \("rewards_link_point_short".localized)"
        }
        
        self.inputPrice = 0
        //self.prepareButtons()
        setTotalAmount(inputPrice: inputPrice)
        
        self.clearTopErrorView()
        self.arrowView.isHidden = self.modeType != .specific
        
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        sendButton.setTitle("red_packet_send".localized, for: .normal)
        sendButton.setTitleColor(.white, for: .normal)
        sendButton.backgroundColor = UIColor(hex: 0xD1D1D1)
        sendButton.clipsToBounds = true
        sendButton.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        sendButton.isEnabled = false
        
        if transactionType == .group {
            groupStackView.isHidden = false
            totalMemberLabel.text = String(format: "red_packet_member_count".localized, numberOfMember)
            self.getGroupInfo(userId: self.receiver)
            if numberOfMember < 2 {
                self.showTopErrorView(errorText: "red_packet_minimum_member".localized)
                totalMemberLabel.textColor = TSColor.main.theme
                redPacketQuantiyView.wrapper.applyBorder(color: TSColor.main.theme, width: 1.0)
            }
            self.redPacketModeView.isHidden = false
            self.constHeight.constant = 938
        } else {
            self.constHeight.constant = 770
            self.groupStackView.isHidden = true
            self.getAvatarInfo(userId: self.receiver)
            self.redPacketModeView.isHidden = true
            // MARK: REMARK NAME
            //LocalRemarkName.getRemarkName(userId: nil, username: self.receiver, originalName: nil, label: nameLabel)
        }
    }
    
    func prepareButtons() {
        priceStackView.removeAllArrangedSubviews()
        buttons = []
        
        var index = 0
        self.inputPrices.forEach ({ [weak self] input in
            defer { index += 1 }
            let button = TSButton(type: .custom)
            button.tag = index
            button.setTitle("\(input)", for: .normal)
            
            button.roundCorner(15)
            //button.layer.borderWidth = 1
            
            button.addTap(action: { [weak self] (_) in
                self?.handler?(button.tag)
                self?.select(index: button.tag)
                self?.btnTap(returnedInt: button.tag)
                
            })
            
            buttons.append(button)
            priceStackView.addArrangedSubview(button)
        })
        
        unSelectAll()
    }
    
    func unSelectAll() {
        selectedInputIndex = nil
        
        buttons.forEach({ button in
            //button.layer.borderColor = TSColor.normal.imagePlaceholder.cgColor
            button.backgroundColor = UIColor(red: 249, green: 249, blue: 249)
            button.setTitleColor(UIColor(red: 184, green: 184, blue: 184), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        })
    }
    
    func select(index: Int) {
        unSelectAll()
        selectedInputIndex = index
        
        let button = buttons[index]
        button.layer.borderColor = AppTheme.sunflowerYellow.cgColor
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = TSColor.main.theme
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func submitAction() {
        view.endEditing(true)
        if TSAppConfig.share.localInfo.shouldShowTransferAlert {
            if self.modeType == .specific && (self.selectedContact == nil || self.selectedContact?.userName == nil) {
                self.showError(message: "text_please_select_user".localized)
                return
            }
            
            if let user = CurrentUserSessionInfo, (inputPrice ?? 0.0) > user.yippsTotal {
                showTopErrorView(errorText: transactionType == .yippsTransfer ? "rw_insufficient_yippi_to_transfer".localized : "rw_insufficient_yippi_to_send_red_packet".localized)
                yippisBalanceLabel.textColor = TSColor.main.theme
                amountView.wrapper.applyBorder(color: TSColor.main.theme, width: 1.0)
                return
            }
            
            yippisBalanceLabel.textColor = UIColor(hex: 0x808080)
            amountView.wrapper.applyBorder(color: .clear, width: 1.0)
            
            if transactionType == .group {
                let quantity = redPacketQuantiyView.textfield.text!.toInt()
                if quantity > (numberOfMember - 1) {
                    showTopErrorView(errorText: "redpacket_qty_exceed_max".localized.replacingFirstOccurrence(of: "%s", with: String(numberOfMember - 1)))
                    totalMemberLabel.textColor = TSColor.main.theme
                    redPacketQuantiyView.wrapper.applyBorder(color: TSColor.main.theme, width: 1.0)
                    return
                }
                clearTopErrorView()
            }
            
            totalMemberLabel.textColor = UIColor(hex: 0x808080)
            redPacketQuantiyView.wrapper.applyBorder(color: .clear, width: 1.0)
            FeedIMSDKManager.shared.delegate?.didShowPin(type: .egg, completion: {[weak self] pin in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.clearTopErrorView()
                    self.makeSendRequest(with: pin)
                }
            }, cancel: {
                self.clearTopErrorView()
            }, needDisplayError: false)
//            showPin(type: .egg, { [weak self] pin in
//                guard let self = self else { return }
//                DispatchQueue.main.async {
//                    self.clearTopErrorView()
//                    self.makeSendRequest(with: pin)
//                }
//            }, cancel: {
//                self.clearTopErrorView()
//            }, needDisplayError: false)
        } else {
            self.makeSendRequest(with: "")
        }
    }
    
    func clearTopErrorView() {
        self.topStackView.isHidden = true
        guard let infoIcon = UIImage.set_image(named: "icInfoRed") else { return }
        self.popOutLabel.setTextWithIcon(text: "", image: infoIcon, imagePosition: .front, imageSize: CGSize(width: 12, height: 12), yOffset: -2.0)
    }
    
    func showTopErrorView(errorText: String) {
        let offset = CGPoint(x: 0, y: -self.scrollView.contentInset.top)
        self.scrollView.setContentOffset(offset, animated: true)
        self.topStackView.isHidden = false
        guard let infoIcon = UIImage.set_image(named: "icInfoRed") else { return }
        self.popOutLabel.setTextWithIcon(text: errorText, image: infoIcon, imagePosition: .front, imageSize: CGSize(width: 12, height: 12), yOffset: -2.0)
    }
    
    @objc public func updateBalance() {
        if let user = CurrentUserSessionInfo {
            yippisBalanceLabel.text = "\("rw_yipps_balance_with_colon".localized) \(user.yippsTotal.tostring(decimal: 2)) \("rewards_link_point_short".localized)"
        }
    }
    
    @objc private func topupAction () {
       // self.navigationController?.pushViewController(WalletViewController(), animated: true)
    }
    
    @objc private func modeAction () {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.redPacketModeView?.resignFirstResponder()
            self.view.endEditing(true)
            
            let bottomSheet = RedPacketBottomSheetVC()
            bottomSheet.delegate = self
            bottomSheet.modalPresentationStyle = .custom
            let transitionDelegate = HalfScreenTransitionDelegate()
            transitionDelegate.heightPercentage = Device.isSmallScreenDevice() ? 0.35 : 0.3
            bottomSheet.transitioningDelegate = transitionDelegate
            self.present(bottomSheet, animated: true)
        }
    }
    
    @objc private func selectionAction () {
        if self.modeType == .specific, let teamId = self.teamId {
            let vc = RedPacketSpecificSelectionViewController(teamId: teamId, finishClosure: { [weak self] (model) in
                guard let self = self else { return }
                
                self.selectedContact = model
                self.avatarStackView.isHidden = false
                self.sendingRedLabel.textColor = TSColor.normal.blackTitle
                if let username = self.selectedContact?.userName {
                    self.getAvatarInfo(userId: username)
                }
            })
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func validate() {
        var enableFlag: Bool = false
        
        switch transactionType {
        case .group:
            switch modeType {
            case .specific:
                if let inputPrice = inputPrice, inputPrice > 0 {
                    enableFlag = true
                } else {
                    enableFlag = false
                }
            default:
                if let text = redPacketQuantiyView.textfield.text, let inputPrice = inputPrice, text.toInt() > 0 && text.count > 0 && inputPrice > 0 && numberOfMember > 1 {
                    enableFlag = true
                } else {
                    enableFlag = false
                }
            }
        default:
            if let inputPrice = inputPrice, inputPrice > 0 {
                enableFlag = true
            } else {
                enableFlag = false
            }
        }
        
        self.sendButton.isEnabled = enableFlag
        self.sendButton.setTitleColor(enableFlag ? AppTheme.white : AppTheme.white, for: enableFlag ? .normal : .disabled)
        self.sendButton.backgroundColor = enableFlag ? TSColor.main.theme : UIColor(hex: 0xD1D1D1)
    }
    
    private func getAvatarInfo(userId: String) {
        self.nameLabel.text = ""
        self.avatarView?.avatarInfo = AvatarInfo()
        
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: userId)
        self.avatarView?.avatarPlaceholderType = .unknown
        self.avatarView?.avatarInfo = avatarInfo
        
        let contactData = ContactData(userName: userId)
        
        // MARK: REMARK NAME
        if contactData.userId == -1 {
            LocalRemarkName.getRemarkName(userId: nil, username: contactData.userName, originalName: contactData.displayname, label: nameLabel)
        } else {
            LocalRemarkName.getRemarkName(userId: String(contactData.userId), username: nil, originalName: contactData.displayname, label: nameLabel)
        }
    }
    
    private func getGroupInfo(userId: String) {
        self.avatarView?.avatarInfo = AvatarInfo()
        self.nameLabel.text = ""
        
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: userId, isTeam: true)
        self.avatarView?.avatarInfo = avatarInfo
        self.nameLabel.text = avatarInfo.nickname
    }
    
    private func sendRequest(with pin: String, specificUsers: [String]? = nil, sendType: SendEggRequest.SendType) {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "sending_egg".localized)
        loadingAlert.show()
        self.view.isUserInteractionEnabled = false
        
        let message = wishView.textfield.text
        let request: SendEggRequest = SendEggRequest(amount: inputPrice ?? 0.0, message: message, pin: pin, type: sendType)
        
//        apiDebouncer.handler = {
//            request.execute(onSuccess: { [weak self] response in
//                NotificationCenter.default.post(name: NSNotification.Name.Wallet.reloadBalance, object: nil)
//                
//                defer {
//                    DispatchQueue.main.async {
//                        loadingAlert.dismiss()
//                        TSUtil.dismissPin()
//                        self?.view.isUserInteractionEnabled = true
//                    }
//                }
//                
//                guard let self = self, let response = response else { return }
//                self.showSuccess(message: "rw_send_redpacket_success".localized)
//                
//                if var user = CurrentUserSessionInfo {
//                    user.yippsTotal -= self.inputPrice.orZero
//                    user.save()
//                }
//                
//                if self.finishBlock != nil {
//                    self.finishBlock?(response.redpacketId, specificUsers, message ?? "viewholder_egg_break".localized)
//                    self.showDialog(image: UIImage.set_image(named: "successSend"), title: "txt_successful".localized, message: "txt_best_wishes_deliver_successfully".localized, dismissedButtonTitle: "txt_back_to_msg".localized, onDismissed: { [weak self] in
//                        guard let self = self else { return }
//                        self.navigationController?.popViewController(animated: true)
//                    }, onCancelled: { [weak self] in
//                        guard let self = self else { return }
//                    }, cancelButtonTitle: "txt_send_again".localized, isRedPacket: true)
//                }
//                self.clearTopErrorView()
//            }) { [weak self] error in
//                defer {
//                    DispatchQueue.main.async {
//                        loadingAlert.dismiss()
//                        self?.view.isUserInteractionEnabled = true
//                    }
//                }
//                self?.responseErrorHandling(error: error, onShowTopUp: {
//                    self?.showTopUp()
//                }, needShowToast: false, isRedPacket: true)
//                
//                if case let YPErrorType.error(message, code) = error {
//                    self?.showTopErrorView(errorText: message)
//                } else {
//                    self?.clearTopErrorView()
//                }
//            }
//        }
        
        apiDebouncer.execute()
    }
    
    private func transferRequest(with password: String, receiver: String) {
//        let request = YippsTransferRequestType(amount: inputPrice ?? 0.0, message: wishView.textfield.text, pin: password, username: receiver)
//        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "sending_egg".localized)
//        loadingAlert.show()
//        self.view.isUserInteractionEnabled = false
//        
//        apiDebouncer.handler = { [weak self] in
//            guard let self = self else { return }
//            request.execute(
//                onSuccess: { [weak self] response in
//                    NotificationCenter.default.post(name: NSNotification.Name.Wallet.reloadBalance, object: nil)
//                    
//                    defer {
//                        DispatchQueue.main.async {
//                            loadingAlert.dismiss()
//                            TSUtil.dismissPin()
//                            self?.view.isUserInteractionEnabled = true
//                        }
//                    }
//                    guard let self = self else { return }
//                    
//                    if var user = CurrentUserSessionInfo {
//                        user.yippsTotal -= self.inputPrice.orZero
//                        user.save()
//                    }
//                    
//                    self.finishBlock?(0, nil, (response?.message).orEmpty)
//                    TSUtil.dismissPin()
//                    self.finishBlock = nil
//                    let vc1 = YippsTransferSuccessViewController(data: response?.transaction)
//                    self.navigationController?.pushViewController(vc1, animated: true)
//                    
//                },
//                onError: { [weak self] error in
//                    DispatchQueue.main.async {
//                        loadingAlert.dismiss()
//                        self?.view.isUserInteractionEnabled = true
//                    }
//                    self?.responseErrorHandling(error: error, onShowTopUp: {
//                        self?.showTopUp()
//                    }, needShowToast: false)
//                    
//                    if case let YPErrorType.error(message, code) = error {
//                        self?.showTopErrorView(errorText: message)
//                    } else {
//                        self?.clearTopErrorView()
//                    }
//                })
//        }
        
        apiDebouncer.execute()
    }
    
    private func showTopUp() {
        //self.navigationController?.pushViewController(WalletViewController(), animated: true)
    }
    
    func btnTap(returnedInt: Int?) {
        guard let returnedInt = returnedInt else {
            inputPrice = nil
            return
        }
        
        if returnedInt < 0 {
            inputPrice = Double(amountView.textfield.text?.replacingOccurrences(of: ",", with: "") ?? "0")
            validate()
        } else {
            amountView.textfield.resignFirstResponder()
            let userInputMoney = inputPrices[returnedInt]
            inputPrice = Double(userInputMoney)
            amountView.textfield.text = String(format: "%.2f", inputPrice ?? 0)
            setTotalAmount(inputPrice: inputPrice)
        }
    }
    
    func userInput(input: String?) {
        if var input = input {
            if input.contains(",") {
                input = input.replacingOccurrences(of: ",", with: "")
            }
            
            guard let number = Double(input) else {
                if self.selectedInputIndex == nil {
                    inputPrice = nil
                }
                return
            }
            
            self.unSelectAll()
            inputPrice = number
            setTotalAmount(inputPrice: inputPrice)
        }
    }
    
    func setTotalAmount(inputPrice: Double? = 0.00){
        let attrs1 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 36), NSAttributedString.Key.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string: String(format: "%@", inputPrice?.tostring(decimal: 2) ?? ""), attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:" \("rewards_link_point_short".localized)", attributes:attrs2)
        
        attributedString1.append(attributedString2)
        self.totalAmountLabel.attributedText = attributedString1
    }
    
    func makeSendRequest(with password: String) {
        switch transactionType {
        case .personal : sendRequest(with: password, sendType: .personal(receiver: self.receiver))
            
        case .group :
            switch modeType {
            case .specific:
                if let username = self.selectedContact?.userName {
                    var specificUser : [String] = [username]
                    sendRequest(with: password, specificUsers: specificUser, sendType: .group(groupId: self.receiver, isRandom: false, quantity: specificUser.count, specificUser: specificUser))
                }
            default:
                let quantity = redPacketQuantiyView.textfield.text!.toInt()
                sendRequest(with: password, sendType: .group(groupId: self.receiver, isRandom: self.modeType == .random, quantity: quantity))
            }
        case .yippsTransfer: transferRequest(with: password, receiver: self.receiver)
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.portrait]
    }
}

extension RedPacketViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 50
        let currentString: NSString = textView.text as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        return newString.length <= maxLength
    }
}

extension RedPacketViewController: AuthTextfieldDelegate {
    func textDidEndEditing(_ text: String, type: AuthFieldType, view: AuthTextfield) {}
    
    func textDidChanged(_ text: String, type: AuthFieldType, view: AuthTextfield) {    }
    
    func countryCodeDidTapped(view: AuthTextfield) {}
    
    func textFieldHandler(_ selectedPrice: Int, type: AuthFieldType, view: AuthTextfield) {
        if type == .amount {
            validate()
            clearTopErrorView()
            userInput(input: view.textfield.text)
            handler?(selectedPrice)
        }
    }
}

extension RedPacketViewController: RedPacketBottomSheetDelegate {
    func sendData(type: ModeType) {
        self.clearTopErrorView()
        self.modeType = type
        self.redPacketModeLabel.text = self.modeType.value
        self.sendingRedLabel.textColor = self.modeType != .specific || self.selectedContact != nil ? TSColor.normal.blackTitle : UIColor(hex: 0x808080)
        self.arrowView.isHidden = self.modeType != .specific
        self.redPacketQuantityStackView.isHidden = self.modeType == .specific
        
        switch transactionType {
        case .personal:
            self.avatarStackView.isHidden = false
            self.getAvatarInfo(userId: self.receiver)
        case .group:
            switch modeType {
            case .specific:
                self.avatarStackView.isHidden = self.selectedContact == nil
                
                if let username = self.selectedContact?.userName {
                    self.getAvatarInfo(userId: username)
                }
            default:
                self.avatarStackView.isHidden = false
                self.getGroupInfo(userId: self.receiver)
            }
        case .yippsTransfer:
            break
        }
        
        validate()
    }
}
