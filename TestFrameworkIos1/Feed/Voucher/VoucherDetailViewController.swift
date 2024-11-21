//
//  VoucherDetailViewController.swift
//  RewardsLink
//
//  Created by Eric Low on 21/05/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit


class VoucherDetailViewController: TSViewController {
    @IBOutlet weak var tableView: TSTableView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var voucherBtn: UIButton!
    @IBOutlet weak var redeemView: UIView!
    @IBOutlet weak var redeemStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var redeemStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var redeemImageView: UIView!
    @IBOutlet weak var redeemImage: UIImageView!
    @IBOutlet weak var redeemBtnLabel: UILabel!
    @IBOutlet weak var bottomViewH: NSLayoutConstraint!
    
    var voucherId: Int = 0
    var instructionArr: [ExpandableContentSection] = []
    var voucherDetails: VoucherDetailsResponse?
    var blurUIView : UIView!
    var isOpenPlayer: Bool = false
    var firstLoad: Bool = true
    var voucherButtonType: VoucherButtonType = .getVoucher
    
    var voucherHeader = VoucherInfoHeader()
    var myVoucher: MyVoucherModel?
    var transactionFee: String = ""
    var type: String = ""
    var selectedPackage : VoucherPackage? = nil
    var voucherController = GetVoucherBottomView()
    var isMiniVideo: Bool = false
    var isHidePurchaseButton: Bool = false
    var serviceTransId: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBlurView()
        setUpTableView()
        setupNavigationRightButton()
        
        bottomView.layer.shadowColor = UIColor.lightGray.cgColor
        bottomView.layer.shadowOffset = CGSize(width: 0.0, height : -3.0)
        bottomView.layer.shadowOpacity = 0.2
        bottomView.layer.shadowRadius = 3
        
        voucherBtn.tintColor = AppTheme.red
        
        redeemView.addTap(action: { _ in
            self.presentCancelPopup {
                //update redeem button
                if let myVoucherId = self.myVoucher?.myVoucherId {
                    self.markAsRedeemVoucher(voucherId: myVoucherId)
                }
            }
        })
        
        switch voucherButtonType {
        case .redeem, .isExpiring:
            redeemView.layer.borderWidth = 1
            redeemView.layer.borderColor = UIColor(hex: 0xE5E6EB).cgColor
            redeemImageView.isHidden = true
            redeemBtnLabel.text = "rw_text_mark_as_redeemed".localized
            voucherBtn.setTitle("rw_redeem_voucher".localized, for: .normal)
            break
        case .expired:
            voucherBtn.setTitle("rw_expired".localized, for: .normal)
            voucherBtn.isUserInteractionEnabled = false
            voucherBtn.titleLabel?.textColor = UIColor(hex: 0x808080)
            voucherBtn.tintColor = UIColor(hex: 0xD1D1D1)
            redeemView.isHidden = true
            break
        case .isRedeemed:
            redeemView.backgroundColor = UIColor(hex: 0xD1D1D1)
            redeemView.isUserInteractionEnabled = false
            redeemImageView.isHidden = false
            redeemBtnLabel.text = "rw_text_redeemed".localized
            redeemBtnLabel.textColor = UIColor(hex: 0x808080)
            redeemStackViewTrailingConstraint.constant = 30
            redeemStackViewLeadingConstraint.constant = 30
            voucherBtn.setTitle("rw_text_view_voucher".localized, for: .normal)
        default:
            voucherBtn.setTitle("rw_get_voucher".localized, for: .normal)
            redeemView.isHidden = true
            break
        }
        
        EventTrackingManager.instance.trackEvent(itemId: voucherId.stringValue ?? "", itemType: ItemType.voucherDetail.rawValue, behaviorType: BehaviorType.expose, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDetail.rawValue)
        
        viewStayEvent()
        
        getVoucherDetails()
        voucherButtonStatus(isHidePurchaseButton)
        
        if voucherButtonType == .redeem && myVoucher == nil && serviceTransId != nil {
            getPaymentHistory(id: serviceTransId)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setClearNavBar(shadowColor: .clear)
    
        if !firstLoad {
            voucherHeader.resumeVideo()
            tableView.setContentOffset(.zero, animated: true)
        }
        
        updateNavigationBar(contentOffset: tableView.contentOffset.y)
        
        isOpenPlayer = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: self.voucherHeader.player.currentItem)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewStayEvent()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isOpenPlayer {
            setNavigationBarBackgroundColor(color: .white, isTranslucent: false)
        }
        NotificationCenter.default.removeObserver(self)
        self.voucherHeader.pauseVideo()
        stopStayEvent()
    }
    
    override func viewStayEvent() {
        eventStartTime = self.getCurrentTime()
        stayTimer?.invalidate()
        stayTimer = Timer.scheduledTimer(timeInterval: Utils.getStayEventTimerValue(), target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func stopStayEvent() {
        stayTimer?.invalidate()
        let stay = getCurrentTime() - eventStartTime
        if Double(stay) >= Utils.getStayEventTimerValue() {
            printIfDebug("\(className(self))'s timer stopped voucher Id: \(voucherId.stringValue), seconds: \(stay)")
            EventTrackingManager.instance.trackEvent(itemId: voucherId.stringValue, itemType: ItemType.voucherDetail.rawValue, behaviorType: BehaviorType.stay, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherDetail.rawValue, behaviorValue: stay.stringValue)
            eventStartTime = 0
        }
    }
    
    @objc func updateTimer(timer: Timer) {
        stopStayEvent()
    }
    
    @objc func playerItemDidReachEnd() {
        self.voucherHeader.resumeVideo(isBackToStart: true)
    }
    
    @objc func appDidEnterBackground() {
        self.voucherHeader.pauseVideo()
    }
    
    @objc func appWillEnterForeground() {
        if !blurUIView.isHidden {
            self.voucherHeader.resumeVideo()
        }
    }
    
    func setupNavigationRightButton() {
        var barButton = UIBarButtonItem()
        let backButtonView = UIView()
        backButtonView.snp.makeConstraints {
            $0.width.height.equalTo(30)
        }
        
        let imageView = UIImageView(image: UIImage.set_image(named: "ic_rl_voucher_share"))
        
        backButtonView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        
        backButtonView.backgroundColor = .white

        backButtonView.layer.masksToBounds = true
        backButtonView.clipsToBounds = true
        backButtonView.layer.cornerRadius = 15
        
        barButton = UIBarButtonItem(customView: backButtonView)
        backButtonView.addTap(action: { [weak self] (_) in
            guard let self = self else { return }
            self.navigationController?.presentPopVC(target: "", type: .share, delegate: self)
        })
        
        barButton.tintColor = .black
        
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func setupBlurView() {
        blurUIView = UIView()
        blurUIView.backgroundColor = .black.withAlphaComponent(0.6)
        blurUIView.frame = view.bounds
        blurUIView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurUIView.isHidden = true
        view.addSubview(blurUIView)
        
        blurUIView.addAction(action: { [weak self] in
            guard let self = self else { return }
            if !blurUIView.isHidden {
                self.voucherController.dismiss(animated: true, completion: {
                    //self.view.isUserInteractionEnabled = true
                    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.navigationItem.rightBarButtonItem?.isEnabled = true
                    self.blurUIView.isHidden = true
                    self.selectedPackage = nil
                    self.voucherHeader.resumeVideo()
                })
            }
        })
    }
    
    func setUpTableView() {
        tableView.tableFooterView = UIView()
        tableView.register(ExpandableTableViewCell.nib(), forCellReuseIdentifier: ExpandableTableViewCell.cellIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.mj_header = nil
        tableView.mj_footer = nil
    }
    
    func voucherButtonStatus(_ isHidden: Bool) {
        bottomView.isHidden = isHidden
        bottomViewH.constant = isHidden ? 0 : 90
    }
    
    func getVoucherDetails() {
        let request = VoucherDetailsRequest(voucherId: self.voucherId.stringValue)
        request.execute(
            onSuccess: { [weak self] (response) in                
                guard let self = self , let items = response else {
                    self?.removePlaceholderView()
                    self?.show(placeholder: .network)
                    return
                }
                DispatchQueue.main.async {
                    self.removePlaceholderView()
                    self.voucherDetails = items
                    self.transactionFee = items.transactionFee ?? ""
                    self.type = self.voucherDetails?.type ?? ""
                    self.setExpandableData(items)
                    self.tableView.reloadData(completion: {
                        self.firstLoad = false
                        self.tableView.layoutTableHeaderView()
                    })
                }
            }) { [weak self] (error) in
                printIfDebug(error)
                guard let self = self else { return }
                self.removePlaceholderView()
                self.show(placeholder: .network)
            }
    }
    
    private func getPaymentHistory(id: Int) {
        let request = PandaHistoriesVoucherRequest(serviceTransId: id)
        request.execute(
            onSuccess: { [weak self] (response) in
                guard let self = self , let items = response else { return }
                DispatchQueue.main.async {
                    if let myVoucher = items.first {
                        self.myVoucher = myVoucher
                    }
                }
            }) { [weak self] (error) in
                guard let self = self else { return }
                self.tableView.tableFooterView = nil
            }
    }
    
    private func markAsRedeemVoucher(voucherId: Int) {
        if !(TSReachability.share.isReachable()) {
            self.showError(message: "network_is_not_available".localized)
            return
        }
        let request = VoucherMarkAsRedeemRequest(id: voucherId)
        request.execute(
            onSuccess: { [weak self] (response) in
                guard let self = self , let items = response else { return }
                DispatchQueue.main.async {
                    self.redeemView.isUserInteractionEnabled = false
                    self.redeemView.backgroundColor = UIColor(hex: 0xD1D1D1)
                    self.redeemImageView.isHidden = false
                    self.redeemBtnLabel.textColor = UIColor(hex: 0x808080)
                    self.redeemBtnLabel.text = "rw_text_redeemed".localized
                    self.voucherBtn.setTitle("rw_text_view_voucher".localized, for: .normal)
                    
                    NotificationCenter.default.post(name: Notification.Name.Voucher.updateRedeemedVoucher, object: nil, userInfo: nil)
                }
            }) { [weak self] (error) in
                guard let self = self else { return }
                self.showError(message: error.localizedDescription ?? "")
            }
    }
    
    override func placeholderButtonDidTapped() {
        self.getVoucherDetails()
    }
    
    func setExpandableData(_ detail: VoucherDetailsResponse?) {
        guard let detail = detail else { return }
        
        if let redemptionOnlineInstruction = detail.redemptionOnlineInstruction, !redemptionOnlineInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.instructionArr.append(ExpandableContentSection(title: "rw_how_to_redeem_online".localized, content: redemptionOnlineInstruction))
        }
        
        if let redemptionInstoreInstruction = detail.redemptionInstoreInstruction, !redemptionInstoreInstruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.instructionArr.append( ExpandableContentSection(title: "rw_how_to_redeem_in_store".localized, content: redemptionInstoreInstruction))
        }
        
        if let cardTerms = detail.cardTerms, !cardTerms.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.instructionArr.append(ExpandableContentSection(title: "srs_utilities_tnc_web_view_title".localized, content: cardTerms))
        }
    }
    
    @IBAction func getVoucherAction(_ sender: Any) {
        if voucherButtonType == .redeem || voucherButtonType == .isRedeemed || voucherButtonType == .isExpiring {
            if let myVoucher = myVoucher {
                EventTrackingManager.instance.trackEvent(itemId: myVoucher.myVoucherId?.stringValue ?? "", itemType: ItemType.voucherRedeem.rawValue, behaviorType: BehaviorType.click, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.voucherRedeem.rawValue)
                
                let redeemVoucherController = RedeemVoucherBottomView()
                if myVoucher.type == "voucher" {
                    if let activationTokenURL = myVoucher.activationTokenURL, let url = URL(string: activationTokenURL) {
                        redeemVoucherController.activationTokenURL = myVoucher.activationTokenURL
                    } else {
                        let toastView = SharedToastView()
                        toastView.title = "rw_redeem_voucher_error_message".localized
                        self.showTopFloatingToast(with: "", background: UIColor(hex: 0xFFD5D4), customView: toastView)
                    }
                } else if myVoucher.type == "softpins" {
                    redeemVoucherController.softpins = myVoucher.softpins
                }
                
                self.navigationController?.pushViewController(redeemVoucherController, animated: true)
            }
            return
        }
        
        showVoucherBottomSheet()
    }
    
    private func presentCancelPopup(action: @escaping () -> Void) {
        let view = CancelPopView(isVoucherPop: true)
        let popup = TSAlertController(style: .popup(customview: view), hideCloseButton: true)
        
        view.alertButtonClosure = {
            action()
            popup.dismiss()
        }
        
        view.cancelButtonClosure = {
            popup.dismiss()
        }
        
        present(popup, animated: false)
    }
    
    
    private func showVoucherBottomSheet() {
        if let voucherDetails = voucherDetails, let packages = voucherDetails.packages, packages.count > 0 {
            voucherController = GetVoucherBottomView()
            voucherController.delegate = self
            voucherController.voucherDetails = voucherDetails
            voucherController.packages = packages
            voucherController.selectedPackage = selectedPackage
            
            let formNC = UINavigationController(rootViewController: voucherController)
            formNC.modalPresentationStyle = .pageSheet
            formNC.navigationBar.isHidden = true
            
            if #available(iOS 15.0, *) {
                if let sheetPresentationController = formNC.presentationController as? UISheetPresentationController {
                    sheetPresentationController.prefersGrabberVisible = false
                    sheetPresentationController.detents = [.medium(), .myLarge()]
                    sheetPresentationController.largestUndimmedDetentIdentifier = .myLarge
                    sheetPresentationController.preferredCornerRadius = 15
                }
                
                voucherHeader.pauseVideo()
                
                //view.isUserInteractionEnabled = false
                navigationController?.interactivePopGestureRecognizer?.isEnabled = false
                navigationController?.navigationBar.isUserInteractionEnabled = false
                navigationItem.leftBarButtonItem?.isEnabled = false
                navigationItem.rightBarButtonItem?.isEnabled = false
                blurUIView.isHidden = false
                present(formNC, animated: true)
            } else {
                // Fallback on earlier versions
            }
        }
    }
}

extension VoucherDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let voucherDetails = voucherDetails {
            voucherHeader.setVoucherDetail(voucherDetails)
            voucherHeader.voucherButtonType = voucherButtonType
            voucherHeader.delegate = self
        }
        
        return voucherHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension VoucherDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return instructionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTableViewCell.cellIdentifier, for: indexPath) as? ExpandableTableViewCell, let cData = instructionArr[safe: indexPath.row]  {
            cell.set(content: cData)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if var cData = instructionArr[safe: indexPath.row] {
            cData.isExpanded = !cData.isExpanded
            instructionArr[indexPath.row] = cData
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension VoucherDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateNavigationBar(contentOffset: scrollView.contentOffset.y)
    }
    
    func updateNavigationBar(contentOffset: Double) {
        let offset = contentOffset / 120
        if offset > 1 {
            setCloseButton(backImage: true, titleStr: voucherDetails?.name)
            setNavigationBarBackgroundColor(color: .white, isTranslucent: true)
        } else {
            let color = UIColor(hex: 0xFFFFFF, alpha: offset)
            setCloseButton(backImage: true, titleStr: "", backWhiteCircle: true)
            setNavigationBarBackgroundColor(color: .clear, isTranslucent: true)
        }
    }
}

@available(iOS 15.0, *)
extension UISheetPresentationController.Detent.Identifier {
    static let myMedium = UISheetPresentationController.Detent.Identifier("myMedium")
    static let myLarge = UISheetPresentationController.Detent.Identifier("myLarge")
}

@available(iOS 15.0, *)
extension UISheetPresentationController.Detent {
    class func myMedium() -> UISheetPresentationController.Detent {
        if #available(iOS 16.0, *) {
            return UISheetPresentationController.Detent.custom(identifier: .myMedium) { context in
                return ScreenHeight * 0.6
            }
        } else {
            // Fallback on earlier versions
            return .medium()
        }
    }
    
    class func myLarge() -> UISheetPresentationController.Detent {
        if #available(iOS 16.0, *) {
            return UISheetPresentationController.Detent.custom(identifier: .myLarge) { context in
                return context.maximumDetentValue - 50
            }
        } else {
            // Fallback on earlier versions
            return .large()
        }
    }
}

extension VoucherDetailViewController: GetVoucherBottomViewDelegate {
    func selectePackage(_ package: VoucherPackage?) {
        //view.isUserInteractionEnabled = true
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.navigationBar.isUserInteractionEnabled = true
        navigationItem.leftBarButtonItem?.isEnabled = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        blurUIView.isHidden = true
        
        if let package = package {
            selectedPackage = package
            voucherHeader.pauseVideo()
            
            EventTrackingManager.instance.trackEvent(itemId: voucherId.stringValue, itemType: ItemType.getVoucher.rawValue, behaviorType: BehaviorType.click, sceneId: "", moduleId: ModuleId.voucher.rawValue, pageId: PageId.getVoucher.rawValue)
            
//            let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "checkoutVoucher") as! CheckoutVoucherViewController
//            if let newStatus = PandaPurchaseType(rawValue: type) {
//                vc.type = newStatus
//            }
//            vc.package = package
//            vc.transactionFee = transactionFee
//            vc.delegate = self
//            navigationController?.pushViewController(vc, animated: true)
        } else {
            selectedPackage = nil
            voucherHeader.resumeVideo()
        }
    }
}

extension VoucherDetailViewController: VoucherInfoHeaderDelegate {
    func onTapAction(_ videoUrl: String?) {
//        if let videoUrl = videoUrl, let url = URL(string: videoUrl) {
//            isOpenPlayer = true
//            let web = TSWebViewController(url: url, type: .defaultType, title: "", needDismiss: false)
//            web.haveToken = false
//            self.navigationController?.pushViewController(web, animated: true)
//        }
    }
}

//extension VoucherDetailViewController: CheckoutVoucherDelegate {
//    func viewControllerDismiss() {
//        showVoucherBottomSheet()
//    }
//}

extension VoucherDetailViewController: CustomPopListProtocol {
    func customPopList(itemType: TSPopUpItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.handlePopUpItemAction(itemType: itemType)
        }
    }
    
    func handlePopUpItemAction(itemType: TSPopUpItem) {
        switch itemType {
        case .message:
            // 记录转发数
            if let voucherDetails = self.voucherDetails {
                let messageModel = TSmessagePopModel(voucherDetails: voucherDetails)
                let contactPicker = ContactsPickerViewController(model: messageModel, configuration: ContactsPickerConfig.shareToChatConfig(), finishClosure: nil)
                let navigation = TSNavigationController(rootViewController: contactPicker).fullScreenRepresentation
                self.navigationController?.present(navigation, animated: true, completion: nil)
            }
        case .shareExternal:
            // 记录转发数
//            if let voucherDetails = self.voucherDetails {
//                let messageModel = TSmessagePopModel(voucherDetails: voucherDetails)
//                let fullUrlString = "\(TSAppConfig.share.environment.serverAddress)\(messageModel.contentType.path)/\(messageModel.feedId.stringValue)"
//                let combineText = "rl_share_voucher_desc".localized.replacingOccurrences(of: "%s", with: fullUrlString)
//                // By Kit Foong (Hide Yippi App from share)
//                let items: [Any] = [combineText, messageModel.titleSecond, ShareExtensionBlockerItem()]
//                let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
//                activityVC.popoverPresentationController?.sourceView = self.view
//                if let presentedVC = self.presentedViewController {
//                    presentedVC.dismiss(animated: false) {
//                        self.present(activityVC, animated: true, completion: nil)
//                    }
//                } else {
//                    self.present(activityVC, animated: true, completion: nil)
//                }
//            }
            break
        default:
            break
        }
    }
}

