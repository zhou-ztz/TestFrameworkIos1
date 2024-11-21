// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import UIKit
import SwiftEntryKit
import SwiftUI

import KMPlaceholderTextView
import IQKeyboardManagerSwift
import NIMSDK

class YPTransactionViewController: TSViewController, btnTapDelegate, selectionInputDelegate {
    
    enum TransactionType {
        case personal, group, yippsTransfer
    }
    
    lazy var allStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    lazy var topView: UIView = {
        let tView = UIView()
        tView.backgroundColor = .white
        return tView
    }()
    var tipLabel = UILabel().configure {
        $0.text = "To".localized
        $0.textColor = UIColor(red: 74, green: 74, blue: 74)
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    var nameLabel = UILabel().configure {
        $0.text = "to"
        $0.textColor = UIColor(red: 18, green: 18, blue: 18)
        $0.font = UIFont.systemFont(ofSize: 16)
    }
    var headImage = AvatarView()
    
    /// 打赏类型
    //    let type: TSRewardType
    let textview: KMPlaceholderTextView = KMPlaceholderTextView(cornerRadius: 0, borderWidth: 0, borderColor: .clear)
    
    /// 选择价格视图
    lazy var choosePriceView: SelectionInputPricesView = {
        return SelectionInputPricesView(inputPrices: inputPrices, handler: { [weak self] (selectedIndex) in
            self?.btnTap(returnedInt: selectedIndex)
        })
    }()
    /// 自定义金额视图
    var customMoneyView: TSUserCustomizeTheAmountView!
    var groupInputView: InputGroupEggInfoView = InputGroupEggInfoView(frame: CGRect.zero).configure {
        $0.isRandomSwitch.isOn = true
    }
    /// 提交按钮
    var submitButtion: TSButton = TSButton(type: .custom)
    /// 用户选择打赏价格 单位是人民币分
    var inputPrice: Double? {
        didSet {
            validate()
        }
    }
    /// 打赏金额 单位人民币分
    var inputPrices: [Int] = [1, 2, 5, 10]
    /// 打赏的目标Id
    var sourceId: Int?
    var rewardSuccessAction: ((_ rewadModel: TSNewsRewardModel) -> Void)?
    
    var username: String
    var finishBlock: TransactionFinishClosure?
    var receiver: String
    var transactionType: TransactionType = .personal
    var numberOfMember: Int
    private var apiDebouncer = Debouncer(delay: 1)
    
    let quantityView = UIView().configure {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 200, green: 200, blue: 200).cgColor
        $0.isHidden = true
    }
    private lazy var quantityTextField: AuthTextfield = {
        let authField = AuthTextfield(type: .username, delegate: self)
        authField.placeholder = "enter_quantity".localized
        authField.textfield.keyboardType = .numberPad
        authField.isHidden = true
        return authField
    }()
    
    let randomView = UIView().configure {
        $0.backgroundColor = .white
        $0.isHidden = true
    }
    let randomBtn = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "cCheck"), for: .normal)
        $0.setImage(UIImage.set_image(named: "IMG_msg_box_succeed"), for: .selected)
        $0.addTarget(self, action: #selector(randomBtnClick), for: .touchUpInside)
    }
    let randomLabel = UILabel().configure {
        $0.text = "text_random".localized
        $0.textColor = .black
        $0.font = UIFont.systemFont(ofSize: 14)
    }
    let wishesView = UIView().configure {
        $0.backgroundColor = .white
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(red: 200, green: 200, blue: 200).cgColor
    }
    
    public init(transactionType: TransactionType, fromUser: String, toUser:String, numberOfMember:Int, completion: TransactionFinishClosure?) {
        self.username = fromUser
        self.receiver = toUser
        self.numberOfMember = numberOfMember
        self.transactionType = transactionType
        
        self.finishBlock = completion
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Wallet.reloadBalance, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.setRightButton(title: "reset".localized, img: nil)
        self.setRightButtonTextColor(color: TSColor.main.theme)
        self.rightButton?.frame = CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MaxWidth, height: 44)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        self.setRightCustomViewWidth(Max: false)
        
        if ((self.navigationController?.viewControllers.count) ?? 0) <= 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage.set_image(named: "IMG_topbar_close")!, action: { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            })
        }
        
        groupInputView.changedHandler = { [weak self] in
            self?.rightButton?.isEnabled = true
            self?.validate()
        }
        
        textview.delegate = self
        self.textview.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBalance), name: NSNotification.Name.Wallet.reloadBalance, object: nil)
        
        setUI()
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK: set ui
    func setUI() {
        self.view.backgroundColor = .white
        self.title = "title_send_egg".localized
        
        var btnName: Array<String> = []
        for amount in inputPrices {
            btnName.append("\(amount)")
        }
        self.view.addSubview(allStackView)
        allStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }
        let spaceView = UIView().configure { $0.backgroundColor = UIColor(red: 243, green: 243, blue: 243) }
        allStackView.addArrangedSubview(topView)
        allStackView.addArrangedSubview(spaceView)
        allStackView.addArrangedSubview(choosePriceView)
        
        spaceView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(4)
        }
        
        topView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(80)
        }
        topView.addSubview(tipLabel)
        topView.addSubview(headImage)
        topView.addSubview(nameLabel)
        nameLabel.text = self.receiver
        headImage.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(32)
        }
        //headImage.roundCorner(16)
        
        if transactionType == .group {
            nameLabel.text = NIMSDK.shared().teamManager.team(byId: self.receiver)?.teamName
            if let team: NIMTeam = NIMSDK.shared().teamManager.team(byId: self.receiver) {
                let avatarURL = team.thumbAvatarUrl
                let avatarInfo = AvatarInfo()
                avatarInfo.avatarURL = avatarURL
                avatarInfo.avatarPlaceholderType = .group
                headImage.avatarInfo = avatarInfo
            }
        } else {
            self.getAvatarIcon(userId: self.receiver)
            // MARK: REMARK NAME
            //LocalRemarkName.getRemarkName(userId: nil, username: self.receiver, originalName: nil, label: nameLabel)
        }
        tipLabel.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.top.equalTo(8)
            make.height.equalTo(16)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.left.equalTo(headImage.snp.right).offset(8)
            make.top.equalTo(32)
            make.height.equalTo(32)
            make.right.equalTo(-10)
        }
        
        choosePriceView.prepareButtons()
        choosePriceView.showRemainingYipps { [weak self] in
            DispatchQueue.main.async {
                self?.showTopUp()
            }
        }
        choosePriceView.inputDelegate = self
        choosePriceView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(160.5)
        }
        let spaceView1 = UIView().configure { $0.backgroundColor = .white }
        allStackView.addArrangedSubview(spaceView1)
        spaceView1.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(20)
        }
        allStackView.addArrangedSubview(quantityTextField)
        allStackView.addArrangedSubview(randomView)
        allStackView.addArrangedSubview(wishesView)
        //quantityView.addSubview(quantityTextField)
        //        quantityView.snp.makeConstraints { (make) in
        //            make.left.equalTo(24)
        //            make.right.equalTo(-24)
        //            make.height.equalTo(50)
        //        }
        //        quantityView.roundCorner(4)
        quantityTextField.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(50)
        }
        
        quantityTextField.textfield.add(event: .editingChanged) {  [weak self] in
            self?.validate()
        }
        //随机金额
        randomView.snp.makeConstraints { (make) in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(53)
        }
        randomView.addSubview(randomBtn)
        randomView.addSubview(randomLabel)
        randomBtn.snp.makeConstraints { make in
            make.top.equalTo(9)
            make.left.equalToSuperview().inset(5)
            make.height.width.equalTo(18)
        }
        randomBtn.isSelected = true
        //        randomBtn.roundCorner(9)
        randomLabel.snp.makeConstraints { make in
            make.top.equalTo(9)
            make.left.equalTo(randomBtn.snp.right).offset(8)
            make.height.equalTo(18)
        }
        wishesView.snp.makeConstraints { (make) in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(50)
        }
        wishesView.roundCorner(4)
        if transactionType == .group {
            quantityTextField.isHidden = false
            randomView.isHidden = false
        }
        
        
        wishesView.addSubview(textview)
        textview.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalTo(-10)
        }
        
        textview.placeholder = "placeholder_send_egg".localized
        
        setSubmitBnt(bntName: "confirm".localized, distance: 24)
        
        self.inputPrice = 0
    }
    
    private func getAvatarIcon(userId: String)  {
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [userId]) { (results, msg, status) in
            if let model = results?.first {
                self.headImage.avatarInfo = model.avatarInfo()
                
                self.nameLabel.text = model.remarkName?.count == 0 ? model.name ?? "" : model.remarkName ?? ""
            } else {
                
            }
        }
    }
    
    private func showTopUp() {
      //  self.navigationController?.pushViewController(WalletViewController(), animated: true)
        
        //        let vc = TopUpViewController(shouldPop: true)
        //        vc.onSuccessTopUp = { [weak self] in
        //            self?.choosePriceView.refreshRemainingYipps()
        //        }
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc public func updateBalance() {
        self.choosePriceView.refreshRemainingYipps()
    }
    
    private func validate() {
        var enableFlag: Bool = false
        if case TransactionType.group = transactionType {
            if let text = quantityTextField.textfield.text, let inputPrice = inputPrice, text.toInt() > 0 && text.count > 0 && inputPrice > 0 {
                enableFlag = true
            } else {
                enableFlag = false
            }
        } else {
            if let inputPrice = inputPrice {
                if inputPrice > 0 {
                    if var user = CurrentUserSessionInfo {
                        if inputPrice <= user.yippsTotal {
                            enableFlag = true
                        }
                    }
                }
            }
        }
        
        //self.rightButton?.isEnabled = enableFlag      // 注：应该使用下面方法，该方案无效
        self.rightButtonEnable(enable: enableFlag)
        self.submitButtion.isEnabled = enableFlag
        self.submitButtion.setTitleColor(enableFlag ? AppTheme.white : AppTheme.white, for: enableFlag ? .normal : .disabled)
        self.submitButtion.backgroundColor = enableFlag ? TSColor.main.theme : TSColor.button.disabled
    }
    
    func setSubmitBnt(bntName: String, distance: CGFloat) {
        submitButtion.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        submitButtion.setTitle(bntName, for: .normal)
        submitButtion.setTitleColor(AppTheme.white, for: .normal)
        submitButtion.backgroundColor = TSColor.button.disabled
        submitButtion.clipsToBounds = true
        submitButtion.layer.cornerRadius = 6
        submitButtion.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        self.view.addSubview(submitButtion)
        
        submitButtion.snp.makeConstraints { (make) in
            make.top.equalTo(allStackView.snp.bottom).offset(distance)
            make.left.equalTo(24)
            make.height.equalTo(50)
            make.right.equalTo(-24)
        }
        submitButtion.isEnabled = false
    }
    
    @objc func randomBtnClick(){
        randomBtn.isSelected = !randomBtn.isSelected
    }
    
    // MARK: delegate
    func btnTap(returnedInt: Int?) {
        guard let returnedInt = returnedInt else {
            inputPrice = nil
            return
        }
        
        if returnedInt < 0 {
            inputPrice = Double(choosePriceView.moneyTextfiled.text?.replacingOccurrences(of: ",", with: "") ?? "0")
            validate()
        } else {
            choosePriceView.moneyTextfiled.resignFirstResponder()
            let userInputMoney = inputPrices[returnedInt]
            inputPrice = Double(userInputMoney)
            choosePriceView.moneyTextfiled.text = String(format: "%.2f", inputPrice ?? 0)
        }
    }
    
    func userInput(input: String?) {
        guard let input = input, let number = Double(input) else {
            if choosePriceView.selectedInputIndex == nil {
                inputPrice = nil
            }
            return
        }
        choosePriceView.unSelectAll()
        //        inputPrice = TSWalletConfigModel.convertToFen(number)
        inputPrice = number
    }
    
    /// rightButton点击方法（重置页面）
    override func rightButtonClicked() {
        customMoneyView.userInputMoney.resignFirstResponder()
        customMoneyView.userInputMoney.text = nil
        choosePriceView.unSelectAll()  // 会在其代理里回调btnTap，所以无需再单独设置inputPrice
        groupInputView.reset()
        inputPrice = nil
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func submitAction() {
        view.endEditing(true)
        if TSAppConfig.share.localInfo.shouldShowTransferAlert {
            FeedIMSDKManager.shared.delegate?.didShowPin(type: .egg, completion: {[weak self] pin in
                DispatchQueue.main.async {
                    self?.makeSendRequest(with: pin)
                }
            }, cancel: {
                
            }, needDisplayError: true)
//            showPin(type: .egg, { [weak self] pin in
//
//            }, cancel: nil)
            
        } else {
           // self.makeSendRequest(with: "")
        }
    }
    
    private func sendRequest(with pin: String, sendType: SendEggRequest.SendType) {
//        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "sending_egg".localized)
//        loadingAlert.show()
//        self.view.isUserInteractionEnabled = false
//        
//        let message = textview.text
//        let request: SendEggRequest = SendEggRequest(amount: inputPrice ?? 0.0, message: message, pin: pin, type: sendType)
//        
//        apiDebouncer.handler = {
//            request.execute(onSuccess: { [weak self] response in
//                defer {
//                    DispatchQueue.main.async {
//                        loadingAlert.dismiss()
//                        TSUtil.dismissPin()
//                        self?.view.isUserInteractionEnabled = true
//                    }
//                }
//                
//                guard let self = self, let response = response else { return }
//                self.showSuccess(message: "send_egg_success".localized)
//                
//                if var user = CurrentUserSessionInfo {
//                    user.yippsTotal -= self.inputPrice.orZero
//                    user.save()
//                }
//                
//                if self.finishBlock != nil {
//                    self.finishBlock?(response.redpacketId, nil, message ?? "viewholder_egg_break".localized)
//                    self.finishBlock = nil
//                    self.dismiss(animated: true) { [weak self] in
//                        
//                    }
//                }
//                
//            }) { [weak self] error in
//                defer {
//                    DispatchQueue.main.async {
//                        loadingAlert.dismiss()
//                        self?.view.isUserInteractionEnabled = true
//                    }
//                }
//                self?.responseErrorHandling(error: error, onShowTopUp: {
//                    self?.showTopUp()
//                })
//            }
    //    }
        
       // apiDebouncer.execute()
    }
    
    private func transferRequest(with password: String, receiver: String) {
//        let request = YippsTransferRequestType(amount: inputPrice ?? 0.0, message: textview.text, pin: password, username: receiver)
//        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "sending_egg".localized)
//        loadingAlert.show()
//        self.view.isUserInteractionEnabled = false
//        
//        apiDebouncer.handler = { [weak self] in
//            guard let self = self else { return }
//            request.execute(
//                onSuccess: { [weak self] response in
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
//                    })
//                })
//        }
//        
//        apiDebouncer.execute()
    }
    
    func makeSendRequest(with password: String) {
//        switch transactionType {
//        case .personal : sendRequest(with: password, sendType: .personal(receiver: self.receiver))
//            
//        case .group :
//            let quantity = quantityTextField.textfield.text!.toInt()
//            let isRandom = randomBtn.isSelected
//            sendRequest(with: password, sendType: .group(groupId: self.receiver, isRandom: isRandom, quantity: quantity))
//            
//        case .yippsTransfer: transferRequest(with: password, receiver: self.receiver)
//        }
    }
}

extension YPTransactionViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        IQKeyboardManager.shared.shouldResignOnTouchOutside = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 50
        let currentString: NSString = textView.text as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: text) as NSString
        return newString.length <= maxLength
    }
}

extension YPTransactionViewController: AuthTextfieldDelegate{
    func textDidEndEditing(_ text: String, type: AuthFieldType, view: AuthTextfield) {
        
    }
    
    func textDidChanged(_ text: String, type: AuthFieldType, view: AuthTextfield) {
        
    }
    
    func countryCodeDidTapped(view: AuthTextfield) {
        
    }
    
    func textFieldHandler(_ selectedPrice: Int, type: AuthFieldType, view: AuthTextfield) {}
}


