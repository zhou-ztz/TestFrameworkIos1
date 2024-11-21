//
//  TSWebViewController.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/6.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  网页浏览器

import UIKit
import WebKit
import Alamofire
import SwiftyJSON

public typealias WebViewBackClosure = () -> Void

private struct TSWebViewControllerUX {
    static let timeoutInterval = 10
}

enum WebViewType {
    case pinInfo
    case aboutVerification
    case publicFigure
    case deactivateAccount
    case tnc
    case privatePolicy
    case earnYipps
    case srsUtilitiesTnc
    case walletHistoryFaq
    case communityGuidelines
    case referral
    case liveRanking
    
    var urlString : String {
        switch self {
        case .pinInfo:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_security_pin_info_url_cn".localized : "rw_security_pin_info_url".localized
        case .aboutVerification:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_text_about_verification_cn".localized : "rw_text_about_verification".localized
        case .publicFigure:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_settings_public_figure_form_url_cn".localized : "rw_settings_public_figure_form_url".localized
        case .deactivateAccount:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_setting_deactivate_account_link_cn".localized : "rw_setting_deactivate_account_link".localized
        case .tnc:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_setting_term_link_china".localized : "rw_setting_term_link".localized
        case .privatePolicy:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_setting_privacy_policy_link_china".localized : "rw_setting_privacy_policy_link".localized
        case .earnYipps:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_yipps_wanted_how_to_get_web_link_cn".localized : "rw_yipps_wanted_how_to_get_web_link".localized
        case .srsUtilitiesTnc:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_srs_utilities_tnc_cn".localized : "rw_srs_utilities_tnc".localized
        case .walletHistoryFaq:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_wallet_history_faq_link_cn".localized : "rw_wallet_history_faq_link".localized
        case .communityGuidelines:
            return "rw_community_guidelines".localized
        case .referral:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_re_learn_more_web_link_cn".localized : "rw_re_learn_more_web_link".localized
        case .liveRanking:
            return LocationManager.shared.isChina() || LocalizationManager.isUsingChinese() ? "rw_livestarranking_faq_link_cn".localized : "rw_livestarranking_faq_link".localized
        }
    }
}

class TSWebViewController: TSViewController, WKNavigationDelegate, WKUIDelegate, WKHTTPCookieStoreObserver {
    
    /// 网页地址
    var url: URL? = nil
    /// 网页视图
    var webView = WKWebView()
    /// 返回按钮
    let buttonForBack = TSButton(type: .custom)
    /// 关闭按钮
    let buttonForClose = TSButton(type: .custom)
    /// 进度条
    public let progressView = UIProgressView(progressViewStyle: .bar)
    /// 是否开启请求网页时,携带口令在请求头中
    var haveToken: Bool = true
    
    var type: WebEntryType = .defaultType
    let gamebar = UIView()
    
    private var webpageTitle: String? = nil
    private var entranceOrientation:  UIInterfaceOrientationMask = .portrait
    
    var openedFile: Bool = false
    var openedFileUrl: URL? = nil
    var paymentData: SRSV2PurchaseRequest? = nil
    var reloadlyData: ReloadlyV3PurchaseRequest? = nil
    var pandaData: PandaPurchaseRequest? = nil
    var isReloadly: Bool? = false
    var isSRSResponseURL: Bool = false
    var isReloadlyResponseURL: Bool = false
    var isResponseURL: Bool = false
    var paymentSRSResponseURL: String = ""
    var paymentReloadlyResponseURL: String = ""
    var paymentResponseURL: String = ""
    var scashData: CreatePaymentRequest? = nil
    var scashResponseURL: String = ""
    var isSCashResponseURL: Bool = false
    var transactionId: String = ""
    var completion: WebViewBackClosure?
    var redirectURL: String? = ""
    var isMPMerchant: Bool? = false
    var isVoucher: Bool? = false
    var needDismiss: Bool = true
    var isSoftpin: Bool? = false
    var isScashPayment: Bool? = false
    var isShopeePayment: Bool? = false
    var needHideDialog: Bool = false
    
    private let destination: DownloadRequest.DownloadFileDestination = { _, response in
        let pathComponent = response.suggestedFilename.orEmpty
        var documentsURL : URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL : URL = documentsURL.appendingPathComponent(pathComponent)
        return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
    }
    
    // MARK: - Lifecycle
    /// 自定义初始化方法
    ///
    /// - Parameter url: 链接
    init(url: URL, type: WebEntryType, title: String? = nil, orientation: UIInterfaceOrientationMask = .portrait, paymentData: SRSV2PurchaseRequest? = nil, reloadlyData: ReloadlyV3PurchaseRequest? = nil, scashData: CreatePaymentRequest? = nil, pandaData: PandaPurchaseRequest? = nil, isReloadly: Bool? = nil, redirectURL: String? = nil, isMPMerchant: Bool? = nil, isVoucher: Bool? = nil, completion: WebViewBackClosure? = nil, needDismiss: Bool = true, isSoftpin: Bool? = nil, isScashPayment: Bool? = nil, isShopeePayment: Bool? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.url = url
        self.type = type
        self.modalPresentationStyle = .fullScreen
        self.entranceOrientation = orientation
        self.paymentData = paymentData
        self.reloadlyData = reloadlyData
        self.scashData = scashData
        self.pandaData = pandaData
        self.isReloadly = isReloadly
        if let token = RequestNetworkData.share.authorization, url.absoluteString.contains("__token__") {
            var tokenUrl = url.absoluteString
            tokenUrl.replaceAll(matching: "__token__", with: token)
            self.url = URL(string: tokenUrl)!
        }
        self.redirectURL = redirectURL
        self.isMPMerchant = isMPMerchant
        self.isVoucher = isVoucher
        self.isSoftpin = isSoftpin
        self.webpageTitle = title
        self.completion = completion
        self.needDismiss = needDismiss
        self.isScashPayment = isScashPayment
        self.isShopeePayment = isShopeePayment
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        self.webView = WKWebView(frame: .zero, configuration: configuration)
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.title))
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
        progressView.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        WKWebsiteDataStore.default().httpCookieStore.add(self)
        
        paymentSRSResponseURL = "\(TSAppConfig.share.rootServerAddress)wallet/guest/aeropay/srs-web-response"
        paymentReloadlyResponseURL = "\(TSAppConfig.share.rootServerAddress)wallet/guest/aeropay/basic-web-response"
        paymentResponseURL = "\(TSAppConfig.share.rootServerAddress)wallet/partner/srs/aeropay/response"
        scashResponseURL = "\(TSAppConfig.share.environment.scashCallBackURL)/payment/response"
        // for testing purpose
        //"https://preprod-rewardslink-payment-gateway.getyippi.cn/payment/simulator-response"
        if isShopeePayment ?? false {
            NotificationCenter.default.addObserver(self, selector: #selector(self.shopeeNotification(notification:)), name: Notification.Name.SCash.rlpgCallBack, object: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 添加观察者观察 webView 加载进度
        //        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        //        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.title), options: .new, context: nil)
        openedFile = false
        openedFileUrl = nil
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 移除观察者
        // 隐藏进度条
        progressView.isHidden = true
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.SCash.rlpgCallBack, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { (_) in
            UIView.setAnimationsEnabled(true)
        }
        UIView.setAnimationsEnabled(false)
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    func cookiesDidChange(in cookieStore: WKHTTPCookieStore) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            cookies.forEach({ [weak self] (cookie) in
            })
        }
    }
    
    func setupCloseButton() {
        let backView = UIView(frame: CGRect(x: -10, y: 0, width: 25, height: 25))
        
        buttonForClose.setImage(UIImage.set_image(named: "IMG_topbar_close"), for: .normal)
        buttonForClose.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
        buttonForClose.addTarget(self, action: #selector(closeButtonTaped), for: .touchUpInside)
        backView.addSubview(buttonForClose)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backView)
    }
    
    // MARK: - Custom user interface
    /// 视图相关
    func setUI() {
        self.setCloseButton(backImage: true, titleStr: self.webpageTitle, completion: {
            self.backButtonTaped()
        }, needPop: false)
        
        // progress view
        progressView.tintColor = TSColor.main.theme
        
        self.view.addSubview(webView)
        
        switch type {
        case .game:
            self.view.addSubview(progressView)
            self.view.addSubview(gamebar)
            // game bar
            gamebar.backgroundColor = UIColor.black
            gamebar.snp.makeConstraints {
                if #available(iOS 11.0, *) {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                } else {
                    $0.top.equalTo(self.navigationController?.navigationBar.frame.height ?? 0.0)
                }
                $0.left.right.equalToSuperview()
                $0.height.equalTo(40)
            }
            
            //close view for game bar
            let back = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
            let buttonClose = TSButton(type: .custom)
            buttonClose.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
            buttonClose.addTarget(self, action: #selector(closeButtonTaped), for: .touchUpInside)
            buttonClose.setImage(UIImage.set_image(named: "ic_close_shadow"), for: .normal)
            back.addSubview(buttonClose)
            gamebar.addSubview(back)
            
            progressView.snp.makeConstraints {
                $0.top.equalTo(gamebar.snp.bottom)
                $0.right.left.equalToSuperview()
                $0.height.equalTo(progressView.frame.height)
            }
            webView.snp.makeConstraints {
                $0.top.equalTo(progressView.snp.bottom)
                $0.left.right.bottom.equalToSuperview()
            }
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            webView.scrollView.isScrollEnabled = false
            
        case .defaultType, .eshop, .vendor, .togago, .query, .aeropay, .scash, .panda:
            self.view.addSubview(progressView)
            setupCloseButton()
            progressView.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.height.equalTo(2.5)
                
            }
            
            webView.snp.makeConstraints {
                if #available(iOS 11.0, *) {
                    $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                } else {
                    $0.top.equalTo(self.navigationController?.navigationBar.frame.height ?? 0.0)
                }
                $0.left.right.bottom.equalToSuperview()
            }
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            buttonForBack.tintColor = nil
            webView.scrollView.isScrollEnabled = true
        }
        
        // webview
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.isMultipleTouchEnabled = true
#if compiler(>=5.8) && os(iOS) && DEBUG
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
#endif
        
        if url!.isFileURL {
            webView.loadFileURL(url!, allowingReadAccessTo: url!)
        } else {
            var request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(TSWebViewControllerUX.timeoutInterval))
            
            switch type {
            case .query(let bearer):
                var components = URLComponents(string: (url?.absoluteString).orEmpty)
                
                components?.queryItems = [URLQueryItem(name: "language", value: LocalizationManager.getCurrentLanguage())]
                if bearer.isEmpty == false {
                    components?.queryItems?.append(URLQueryItem(name: "token", value: bearer))
                }
                
                components?.queryItems?.append(URLQueryItem(name: "platform", value: "ios"))
                
                request.url = components?.url
                
            case .vendor(let bearer):
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                if let authorization = TSCurrentUserInfo.share.accountToken?.token, haveToken == true {
                    request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
                }
                
            case .defaultType, .eshop, .game:
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                if let authorization = TSCurrentUserInfo.share.accountToken?.token, haveToken == true {
                    request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
                }
                
            case .togago(let bearer):
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
                
            case .aeropay(let bearer):
                
                var components = URLComponents(string: (url?.absoluteString).orEmpty)
                
                if isReloadly ?? false {
                    components?.queryItems = [URLQueryItem(name: "country_code", value: reloadlyData?.countryISO ?? "")]
                    components?.queryItems?.append(URLQueryItem(name: "phone", value: reloadlyData?.phoneNo ?? ""))
                    components?.queryItems?.append(URLQueryItem(name: "pin", value: reloadlyData?.pin ?? ""))
                    components?.queryItems?.append(URLQueryItem(name: "amount", value: reloadlyData?.amount ?? ""))
                    components?.queryItems?.append(URLQueryItem(name: "provider_id", value: reloadlyData?.providerID ?? ""))
                } else {
                    components?.queryItems = [URLQueryItem(name: "account_no", value: paymentData?.accountNo ?? "")]
                    components?.queryItems?.append(URLQueryItem(name: "product_id", value: paymentData?.productId ?? ""))
                    components?.queryItems?.append(URLQueryItem(name: "pin", value: paymentData?.pin ?? ""))
                    components?.queryItems?.append(URLQueryItem(name: "mobile_number", value: paymentData?.mobileNo ?? ""))
                }
                
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
                
                request.url = components?.url
                request.httpMethod = "post"
                
            case .scash(let bearer):
                var components = URLComponents(string: (url?.absoluteString).orEmpty)
                
                components?.queryItems = [URLQueryItem(name: "pay_channel_id", value: scashData?.paymentChannelId ?? "")]
                components?.queryItems?.append(URLQueryItem(name: "pay_type", value: scashData?.paymentType ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "amount", value: String(scashData?.amount ?? 0.00)))
                components?.queryItems?.append(URLQueryItem(name: "pin", value: scashData?.pin ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "branch_hash_id", value: scashData?.branchHashId ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "remark", value: scashData?.remark ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "is_offset", value: scashData?.isOffset ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "offset_rate", value: String(scashData?.offsetRate ?? 0)))
                components?.queryItems?.append(URLQueryItem(name: "provider_order_no", value: scashData?.provideroOrderNo ?? ""))
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
                request.url = components?.url
                request.httpMethod = "post"
                
            case .panda(let bearer):
                var components = URLComponents(string: (url?.absoluteString).orEmpty)
                
                components?.queryItems = [URLQueryItem(name: "account_no", value: pandaData?.accountNo ?? "")]
                components?.queryItems?.append(URLQueryItem(name: "product_id", value: pandaData?.productId ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "pay_channel_id", value: pandaData?.payChannelId ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "pay_type", value: pandaData?.payType ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "pin", value: pandaData?.pin ?? ""))
                components?.queryItems?.append(URLQueryItem(name: "offset_rate", value: String(pandaData?.offsetRate ?? 0)))
                components?.queryItems?.append(URLQueryItem(name: "remark", value: pandaData?.remark ?? ""))
//                
//                if pandaType == .utilities {
//                    components?.queryItems?.append(URLQueryItem(name: "bill_reference", value: pandaData?.billReference ?? ""))
//                    components?.queryItems?.append(URLQueryItem(name: "amount", value: String(pandaData?.amount ?? 0)))
//                    components?.queryItems?.append(URLQueryItem(name: "account_type", value: pandaData?.accountType ?? ""))
//                } else if pandaType == .softpins || pandaType == .voucher {
//                    components?.queryItems?.append(URLQueryItem(name: "quantity", value: String(pandaData?.quantity ?? 0)))
//                }
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                request.addValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
                request.url = components?.url
                request.httpMethod = "post"
            }
            
            let cookies = HTTPCookieStorage.shared.cookies
            let values = HTTPCookie.requestHeaderFields(with: cookies!)
            request.allHTTPHeaderFields = values
            request.httpShouldHandleCookies = true
            
            webView.load(request)
        }
    }
    
    func bridgeDecoder(data: Any) -> JSON {
        guard let json = JSON(rawValue: data) else { return JSON.null }
        
        return json
    }
    
    private func downloadFile(for fileUrl: URL) {
        openedFile = true
        
        if let filepath = fileUrl.lastPathComponent.checkFileIsExist() {
            let filepathUrl = URL(fileURLWithPath: filepath)
            openedFileUrl = filepathUrl
            self.webView.loadFileURL(filepathUrl, allowingReadAccessTo: filepathUrl)
        } else {
            DispatchQueue.main.async {
                Alamofire.download(fileUrl, method: .get, parameters: nil, encoding: JSONEncoding.default, to: self.destination)
                    .validate { (request, response, temporaryURL, destinationURL) in
                        DispatchQueue.main.async {
                            guard let url = destinationURL else { return }
                            if let filepath = url.lastPathComponent.checkFileIsExist() {
                                let filepathUrl = URL(fileURLWithPath: filepath)
                                self.openedFileUrl = filepathUrl
                                self.webView.loadFileURL(filepathUrl, allowingReadAccessTo: filepathUrl)
                            }
                        }
                        return .success
                    }
            }
        }
        
    }
    
    // MARK: - Button click
    /// 点击了返回按钮
    @objc func backButtonTaped() {
        if isSRSResponseURL || isReloadlyResponseURL {
            TSRootViewController.share.presentServiceListVC()
            return
        }
        
        if isScashPayment ?? false {
            if !needHideDialog {
                presentCancelPopup {
                    if self.navigationController?.popViewController(animated: true) == nil && self.needDismiss {
                        self.dismiss(animated: true) {
                            self.completion?()
                        }
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            scashResponseURL = ""
            return
        }
        
        if webView.canGoBack {
            webView.goBack()
        } else {
            closeButtonTaped()
        }
    }
    
    /// 点击了关闭按钮
    @objc func closeButtonTaped() {
        if isSRSResponseURL || isReloadlyResponseURL {
            TSRootViewController.share.presentServiceListVC()
            return
        }
        if isSCashResponseURL {
            TSRootViewController.share.presentSCashPaymentDetail(transactionId: transactionId, redirectURL: redirectURL ?? "", isMPMerchant: isMPMerchant ?? false, isVoucher: isVoucher ?? false, isSoftpin: isSoftpin ?? false )
            return
        }
        
        if isScashPayment ?? false {
            if !needHideDialog {
                presentCancelPopup {
                    if self.navigationController?.popViewController(animated: true) == nil && self.needDismiss {
                        self.dismiss(animated: true) {
                            self.completion?()
                        }
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
            scashResponseURL = ""
            return
        }
        
        let popVC = navigationController?.popViewController(animated: true)
        if popVC == nil && needDismiss {
            dismiss(animated: true, completion: {
                self.completion?()
            })
        }
    }
    
    private func presentCancelPopup(action: @escaping () -> Void) {
        let view = CancelPopView(isVoucherPop: false)
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
    
    override func placeholderButtonDidTapped() {
        updateWebView()
    }
    
    // MARK: - Private
    /// 刷新网页
    func updateWebView() {
        if url!.isFileURL {
            webView.loadFileURL(url!, allowingReadAccessTo: url!)
        } else {
            var request = URLRequest(url: url!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(TSWebViewControllerUX.timeoutInterval))
            
            if case let type = WebEntryType.defaultType {
                request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
                if let authorization = TSCurrentUserInfo.share.accountToken?.token, haveToken == true {
                    request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
                }
            }
            
            webView.load(request)
        }
    }
    
    // MARK: - Delegate
    // MARK: WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // 这里为了让用户感觉到进度，设置了一个假进度
        progressView.progress = 0.2
        progressView.isHidden = false
        // 隐藏占位图
        self.removePlaceholderView()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 更新网页标题
        if let title = webView.title, title.count > 0, self.webpageTitle != nil {
            self.setCloseButton(backImage: true, titleStr: webView.title, completion: {
                self.backButtonTaped()
            }, needPop: false)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webview did fail load with error: \(error)")
        // 显示占位图，再次点击可重新刷新
        manageFailedNavigation(webView, didFail: navigation, withError: error)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.lastPathComponent.contains(".pdf") {
            if !openedFile {
                decisionHandler(.cancel)
                self.downloadFile(for: url)
                return
            }
        }
        
        if navigationAction.navigationType == WKNavigationType.linkActivated {
            webView.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        print("web url \(navigationAction.request.url)")
        
        if let url = navigationAction.request.url {
            if url.absoluteString == paymentSRSResponseURL  {
                //self.isSRSResponseURL = true
                //TSRootViewController.share.presentServiceListVC()
            }
            if url.absoluteString == paymentReloadlyResponseURL {
                //self.isReloadlyResponseURL = true
                //TSRootViewController.share.presentServiceListVC()
            }
            if url.absoluteString.contains(paymentResponseURL) {
                self.isResponseURL = true
            }
            if url.absoluteString.hasSuffix("#closeWebview") {
                closeButtonTaped()
                
            }
            if url.absoluteString.contains(scashResponseURL) {
                NotificationCenter.default.post(name: NSNotification.Name.Wallet.reloadBalance, object: nil)
                self.isSCashResponseURL = true
                transactionId = url.valueOf("orderNo") ?? ""
                closeButtonTaped()
            }
            
            if url.valueOf("YPRoute") != nil {
                TSUtil.pushURLDetail(url: url, currentVC: self)
            }
            
            if url.scheme != "https" && url.scheme != "http" {
                decisionHandler(.cancel)
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return
            }
            
            if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = urlComponents.queryItems, isScashPayment ?? false {
                
                // Find the `responseCode` parameter
                if let responseCodeItem = queryItems.first(where: { $0.name == "responseCode" }) {
                    let responseCode = responseCodeItem.value
                    // Response code 202 indicates that the account is frozen; Response code 203 indicates for invalid pin.
                    if responseCode == "202" || responseCode == "203" {
                        needHideDialog = true
                    } else {
                        print("Received response code: \(responseCode ?? "Not found")")
                    }
                }
            }
            
//            webView.loadDiskCookies(for: url.host ?? "") {
//                decisionHandler(.allow)
//            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Swift.Void) {
        
//        defer {
//            if let response = navigationResponse.response as? HTTPURLResponse, let url = navigationResponse.response.url {
//                
//                webView.writeDiskCookies(for: url.host!) {
//                    decisionHandler(.allow)
//                }
//            } else {
//                decisionHandler(.cancel)
//            }
//        }
//        
//        if let statusCode = (navigationResponse.response as? HTTPURLResponse)?.statusCode, statusCode == 404 {
//            
//            guard let currentUrl = webView.url?.absoluteString, currentUrl.contains(Constants.swiftCodeInfoLink), let url = URL(string: Constants.swiftCodeInfoLink) else {
//                return
//            }
//            var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: TimeInterval(TSWebViewControllerUX.timeoutInterval))
//            request.setValue(LocalizationManager.getCurrentLanguage(), forHTTPHeaderField: "Accept-Language")
//            
//            if case let type = WebEntryType.defaultType {
//                if let authorization = TSCurrentUserInfo.share.accountToken?.token, haveToken == true {
//                    request.addValue("Bearer \(authorization)", forHTTPHeaderField: "Authorization")
//                }
//            }
//            webView.load(request)
//        } else {
//            if openedFileUrl == webView.url {
//                openedFile = false
//                openedFileUrl = nil
//            }
//        }
    }
    
    func manageFailedNavigation(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if error.localizedDescription == "Redirection to URL with a scheme that is not HTTP(S)" {
            let nsError = error as NSError
            if let failedURL = nsError.userInfo["NSErrorFailingURLKey"] as? URL {
                if UIApplication.shared.canOpenURL(failedURL) {
                    UIApplication.shared.open(failedURL, options: [:], completionHandler: nil)
                }
            }
        } else {
            if (webView.url?.absoluteString.contains("alipays://") != nil) {
                return
            }
            
            let nsError = error as NSError
            
            if nsError.domain == NSURLErrorDomain {
                switch nsError.code {
                case NSURLErrorNotConnectedToInternet:
                    self.show(placeholder: .network)
                case NSURLErrorUnsupportedURL, NSURLErrorCannotFindHost, NSURLErrorCannotConnectToHost:
                    self.show(placeholder: .websiteError)
                default:
                    self.show(placeholder: .websiteError)
                }
            } else {
                self.show(placeholder: .websiteError)
            }
        }
    }
    
    // MARK: - WebView UI Delegate
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
            completionHandler()
        }))
        
        if let presentedViewController = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentedViewController.present(alertController, animated: true, completion: nil)
            return
        }
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: { (action) in
            completionHandler(false)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .actionSheet)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Observer
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let _ = object as? WKWebView else { return }
        guard let keyPath = keyPath else { return }
        guard let change = change else { return }
        
        if keyPath == "estimatedProgress" {
            switch Float(self.webView.estimatedProgress) {
            case 1.0: // 隐藏进度条
                UIView.animate(withDuration: 0.1, animations: {
                    self.progressView.alpha = 0
                    self.progressView.isHidden = true
                }, completion: nil)
            default:  // 显示进度条
                self.progressView.alpha = 1
            }
            progressView.setProgress(Float(self.webView.estimatedProgress), animated: true)
        } else if keyPath == "title" {
            self.setCloseButton(backImage: true, titleStr: webView.title, completion: {
                self.backButtonTaped()
            }, needPop: false)
        }
    }
    
    override var shouldAutorotate: Bool {
        switch type {
        case .defaultType:
            switch entranceOrientation {
            case .landscape, .landscapeLeft, .landscapeRight: return true
            default: return false
            }
        default:
            return true
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        switch type {
        case .defaultType:
            switch entranceOrientation {
            case .portrait: return .portrait
            default: return .allButUpsideDown
            }
        default:
            return .allButUpsideDown
        }
    }
    
    public enum WebEntryType {
        case game
        case defaultType
        case eshop
        case query(bearer: String)
        case vendor(bearer: String)
        case togago(bearer: String)
        case aeropay(bearer: String)
        case scash(bearer: String)
        case panda(bearer: String)
        
        var value: String {
            switch self {
            case .game: return "0"
            case .defaultType: return "1"
            case .eshop: return "2"
            case .eshop: return "3"
            case .query(let bearer): return bearer
            case .vendor(let bearer): return bearer
            case .togago(let bearer): return bearer
            case .aeropay(let bearer): return bearer
            case .scash(let bearer): return bearer
            case .panda(let bearer): return bearer
            }
        }
    }
    
    @objc func shopeeNotification(notification: Notification) {
        transactionId = notification.object as! String
        isSCashResponseURL = true
        TSRootViewController.share.presentSCashPaymentDetail(transactionId: transactionId)
    }
    
}

extension URL {
    func valueOf(_ queryParameterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParameterName })?.value
    }
}

