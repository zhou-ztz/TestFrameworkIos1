//
//  NMCWhiteBoardViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/6.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import WebKit

class NMCWhiteBoardViewController: UIViewController, NMCWhiteboardManagerDelegate, NMCWhiteboardManagerWKDelegate {
    
    var whiteBoardParam: NMCWhiteBoardParam
    
    lazy var webView: WKWebView = {
        let web = NMCWhiteBoardManager.shared.createWebViewWithFrame(frame: .zero)
        web.layer.borderWidth = 1
        web.layer.borderColor = UIColor.lightGray.cgColor
        return web
    }()
    
    init(whiteBoardParam: NMCWhiteBoardParam) {
        self.whiteBoardParam = whiteBoardParam
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.isIdleTimerDisabled = true
        self.view.backgroundColor = UIColor.white
        self.title = "input_panel_whiteboard".localized
        
        let closeWhiteboard = UIButton()
        closeWhiteboard.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        closeWhiteboard.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
        closeWhiteboard.addTarget(self, action: #selector(onBack), for: .touchUpInside)
        
        let closeWhiteboardBtnItem = UIBarButtonItem(customView: closeWhiteboard)
        self.navigationItem.leftBarButtonItem = closeWhiteboardBtnItem
        
        if #available(iOS 11.0, *) {
            
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.addSubview(webView)
        webView.bindToEdges()
      
        webView.load(URLRequest(url: URL(string: whiteBoardParam.webViewUrl)!))

        NMCWhiteBoardManager.shared.configureDelegate(delegate: self)
        NMCWhiteBoardManager.shared.confiureWKDelegate(wkDelegate: self)
    }
    
    @objc func onBack(){
        
        let alert = TSAlertController(title: "text_quit_whiteboard_sharing".localized, message: "text_quit_whiteboard_msg".localized, style: .alert, animateView: false)
        let action = TSAlertAction(title: "quit".localized, style: TSAlertActionStyle.default) { [weak self] (action) in
            guard let self = self else {return}
            self.leaveRoom()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                self.dismiss(animated: true)
            }
        }
        let actionCancel = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.default) { [weak self] (action) in
            
        }
        self.presentPopup(alert: alert, actions: [action, actionCancel])

    }
    
    func generateWebLoginParam(withParam param: NMCWhiteBoardParam) -> NMCWebLoginParam {
        let loginParam = NMCWebLoginParam()
        loginParam.channelName = param.channelName
        loginParam.appKey = param.appKey
        loginParam.uid = param.uid
        loginParam.record = true
        loginParam.debug = true
        
        return loginParam
    }
    
    func handleResult(_ result: String?) {
        leaveRoom()
        if let result = result, !result.isEmpty {
            self.showError(message: result)
            print("result = \(result)")
        }
    }
    
    func leaveRoom() {
        NMCWhiteBoardManager.shared.callWebLogout()
        webView.stopLoading()
        clearWebViewCache()
    }
    
    func clearWebViewCache() {
        if let systemVersion = Int(UIDevice.current.systemVersion), systemVersion >= 9 {
            let types: Set<String> = [WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache]
            let websiteDataTypes = NSSet(array: Array(types))
            let dateFrom = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: dateFrom) {}
        } else {
            if let libraryPath = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                let cookiesFolderPath = (libraryPath as NSString).appendingPathComponent("Cookies")
                NSLog("%@", cookiesFolderPath)
                do {
                    try FileManager.default.removeItem(atPath: cookiesFolderPath)
                } catch {
                    // Handle error
                }
            }
        }
    }
    
    // MARK: NMCWhiteboardManagerWKDelegate
    func onDecidePolicyForNavigationAction(_ navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func onDecidePolicyForNavigationResponse(_ navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    // MARK: NMCWhiteboardManagerDelegate
    func onWebPageLoaded() {
        let loginParam = self.generateWebLoginParam(withParam: whiteBoardParam)
        NMCWhiteBoardManager.shared.callWebLogin(with: loginParam)
    }
    
    func onWebCreateWBSucceed() {
        NSLog("[demo] ===> onWebCreateWBSucceed")
    }
    
    func onWebJoinWBSucceed() {
        NSLog("[demo] ===> onWebJoinWBSucceed")
        NMCWhiteBoardManager.shared.callWebEnableDraw(true)
    }
    
    func onWebJoinWBFailed(_ code: Int, error: String) {
        handleResult(error)
    }
    
    func onWebCreateWBFailed(_ code: Int, error: String) {
        handleResult(error)
    }
    
    func onWebLeaveWB() {
        webView.stopLoading()
        clearWebViewCache()

    }
    
    func onWebError(_ code: Int, error: String) {
        handleResult(error)
    }
    
    func onWebJsError(_ error: String) {
      //  handleResult(error)
    }
    
    func onWebGetAuth() {
        NMCWhiteBoardManager.shared.callWebSendAuth(with: whiteBoardParam.appKey, channelName: whiteBoardParam.channelName, userId: whiteBoardParam.uid) { error in
            if let error = error {
                self.showError(message: error.localizedDescription)
            }
        }
    }
    
    func onWebGetAntiLeechInfo(withParams params: [String : Any]) {
        let prop = params["prop"] as? NSDictionary
        let bucketName = prop?["bucket"] as? String
        let objectKey = prop?["object"] as? String
        let seqId = params["seqId"] as? Int
        let url = params["url"] as? String
        let currentTime = Date().timeIntervalSince1970
        let timeStamp = String(format: "%llu", UInt64(currentTime))
        NMCWhiteBoardManager.shared.callWebSendAntiLeechInfo(with: whiteBoardParam.appKey, bucketName: bucketName ?? "", objectKey: objectKey ?? "", url: url ?? "", seqId: seqId ?? 0, timeStamp: timeStamp)
    }
    

}
