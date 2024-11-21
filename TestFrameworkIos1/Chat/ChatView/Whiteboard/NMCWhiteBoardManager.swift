//
//  NMCWhiteBoardManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/6.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import WebKit
import CommonCrypto

let kAppKey = "<#请填写AppKey#>"
let kServerDomain = "<#请填写服务器域名#>"
let kPresetId = "<#请填写转码模板id#>"
let kwebViewUrl = "webview/webview.html"

class NMCWhiteBoardManager: NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler {
    
    static let shared = NMCWhiteBoardManager()

    var webView: NMCWebView!

    weak var  wkDelegate: NMCWhiteboardManagerWKDelegate?
    
    func configureDelegate(delegate: NMCWhiteboardManagerDelegate) {
        NMCMessageDispatcher.shared.delegate = delegate
    }

    func confiureWKDelegate(wkDelegate: NMCWhiteboardManagerWKDelegate) {
        self.wkDelegate = wkDelegate
    }

    func createWebViewWithFrame(frame: CGRect) -> WKWebView {
        let webView = NMCWebView(frame: frame, scriptMessageHandler: self)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.backgroundColor = .white
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        if #available(iOS 12.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        }
        
        self.webView = webView
        
        return self.webView
    }
    
    func callWebLogin(with param: NMCWebLoginParam) {
        var loginParam = [String: Any]()
        
        loginParam["channelName"] = param.channelName
        loginParam["appKey"] = param.appKey
        loginParam["uid"] = param.uid
        loginParam["record"] = param.record
        loginParam["debug"] = param.debug
        loginParam["platform"] = "ios"
        loginParam["toolbar"] = [String: Any]()
        //简体中文
        if "zh-Hans" == LocalizationManager.getCurrentLanguage() {
            loginParam["lang"] = "zh"
        } else {
            loginParam["lang"] = "en"
        }
        var appConfig = [String: Any]()
        appConfig["nosAntiLeech"] = true
        if kPresetId != "<#请填写转码模板id#>" {
            appConfig["presetId"] = Int(kPresetId)
        }
        
        let drawPluginParams = ["appConfig": appConfig]
        loginParam["drawPluginParams"] = drawPluginParams
        
        NMCMessageDispatcher.shared.nativeCallWeb(with: webView, action: NMCMethodActionWebLogin, param: loginParam)
    }
    
    func callWebLogout() {
        NMCMessageDispatcher.shared.nativeCallWeb(with: webView, action: NMCMethodActionWebLogout, param: [:])
    }

    func callWebEnableDraw(_ enable: Bool) {
        let targetParam: [String: Any] = ["target": NMCMethodTargetDrawPlugin, "action": NMCMethodTargetActionEnableDraw, "params": [enable]]
        NMCMessageDispatcher.shared.nativeCallWeb(with: webView, action: NMCMethodActionJSDirectCall, param: targetParam)
    }
    
    func callWebSendAuth(with appKey: String, channelName: String, userId: UInt, complete: @escaping (Error?) -> Void) {
        TSIMNetworkManager.getwhiteboardAuth {resultModel, error in
        
            if let model = resultModel {
                var params = [String: Any]()
                params["code"] = 200
                params["nonce"] = model.nonce
                params["curTime"] = model.curTime
                params["checksum"] = model.checksum
                
                NMCMessageDispatcher.shared.nativeCallWeb(with: self.webView, action: NMCMethodActionSendAuth, param: params)
            }
            complete(error)
        }
    }

    func callWebSendAntiLeechInfo(with appKey: String, bucketName: String, objectKey: String, url: String, seqId: Int, timeStamp: String) {
//        let requester = NMCWhiteBoardRequester()
//        requester.requestAntiLeechInfo(withAppKey: appKey, bucketName: bucketName, objectKey: objectKey, timeStamp: timeStamp) { error, info in
//            var params = [String: Any]()
//            
//            params["code"] = info.code
//            if info.code == 200 {
//                params["seqId"] = seqId
//                let targetUrl = "\(url)?wsSecret=\(info.secret)&wsTime=\(timeStamp)"
//                params["url"] = targetUrl
//            }
//            
//            NMCMessageDispatcher.shared.nativeCallWeb(with: self.webView, action: NMCMethodActionSendAntiLeechInfo, param: params)
//        }
    }
    
    // MARK: - Private

    func getTopViewController() -> UIViewController? {
        var next = webView.superview
        while let currentView = next {
            if let nextResponder = currentView.next as? UIViewController {
                return nextResponder
            }
            next = currentView.superview
        }
        
        return nil
    }

    func generateSha1HexString(withInputString inputString: String) -> String {
        guard let stringData = inputString.data(using: .utf8) else {
            return ""
        }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        stringData.withUnsafeBytes { bytes in
            CC_SHA1(bytes.baseAddress, CC_LONG(stringData.count), &digest)
        }
        
        var outputString = ""
        for byte in digest {
            outputString += String(format: "%02x", byte)
        }
        
        return outputString
    }

    // MARK: - WKUIDelegate

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        NSLog("[WKUIDelegate] createWebViewWithConfiguration")
        return webView
    }

    func webViewDidClose(_ webView: WKWebView) {
        NSLog("[WKUIDelegate] webViewDidClose")
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedBy frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        NSLog("[WKUIDelegate] runJavaScriptAlertPanelWithMessage")
        
        if let vc = getTopViewController(), vc.isViewLoaded,  webView.superview != nil {
            let alert = UIAlertController(title: nil, message: message ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                completionHandler()
            })
            vc.present(alert, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedBy frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        NSLog("[WKUIDelegate] runJavaScriptConfirmPanelWithMessage")
        
        if let vc = getTopViewController(), vc.isViewLoaded, webView.superview != nil {
            let alert = UIAlertController(title: nil, message: message ?? "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                completionHandler(true)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                completionHandler(false)
            })
            vc.present(alert, animated: true, completion: nil)
        } else {
            completionHandler(false)
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedBy frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        NSLog("[WKUIDelegate] runJavaScriptTextInputPanelWithPrompt")
        
        if let vc = getTopViewController(), vc.isViewLoaded,  webView.superview != nil {
            let alert = UIAlertController(title: nil, message: prompt ?? "", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.textColor = .black
                textField.placeholder = defaultText ?? ""
            }
            alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
                completionHandler(alert.textFields?.last?.text)
            })
            alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
                completionHandler(nil)
            })
            vc.present(alert, animated: true, completion: nil)
        } else {
            completionHandler(nil)
        }
    }
    
    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if wkDelegate != nil {
            self.wkDelegate?.onDecidePolicyForNavigationAction(navigationAction, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        let response = navigationResponse.response
        NSLog("[WKNavigationDelegate] decidePolicyForNavigationResponse response = %@", response)
        
        if wkDelegate != nil  {
            wkDelegate?.onDecidePolicyForNavigationResponse(navigationResponse, decisionHandler: decisionHandler)
        } else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        NSLog("[WKNavigationDelegate] didReceiveAuthenticationChallenge")
        
        // Ignore untrusted HTTPS certificates
        // If not configured, uploading images will fail
        let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, credential)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        NSLog("[WKNavigationDelegate] didStartProvisionalNavigation")
    }

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        NSLog("[WKNavigationDelegate] didReceiveServerRedirectForProvisionalNavigation")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        NSLog("[WKNavigationDelegate] didFailProvisionalNavigation error = %@", error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        NSLog("[WKNavigationDelegate] didCommitNavigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        NSLog("[WKNavigationDelegate] didFinishNavigation")
        
        // Prevent the system's default menu from appearing after long-pressing the webView
        webView.evaluateJavaScript("document.documentElement.style.webkitTouchCallout='none';", completionHandler: nil)
        webView.evaluateJavaScript("document.documentElement.style.webkitUserSelect='none';", completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("WKNavigationDelegate didFailNavigation error = %@", error.localizedDescription)
    }

    @available(iOS 9.0, *)
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        NSLog("[WKNavigationDelegate] webViewWebContentProcessDidTerminate")
        
        webView.reload()
    }
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let params = message.body as? [String: Any], let action = params[NMCMethodAction] as? String, let param = params[NMCMethodParam] as? [String: Any], let webView = message.webView else { return }

        NMCMessageDispatcher.shared.webCallNative(with: webView, action: action, param: param)
    }
    
    
}
