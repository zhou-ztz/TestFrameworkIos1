//
//  NMCMessageDispatcher.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/6.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import WebKit

protocol NMCWhiteboardManagerDelegate: AnyObject {
    func onWebPageLoaded()
    
    func onWebCreateWBSucceed()
    
    func onWebJoinWBSucceed()
    
    func onWebJoinWBFailed(_ code: Int, error: String)
    
    func onWebCreateWBFailed(_ code: Int, error: String)
    
    func onWebLeaveWB()
    
    func onWebError(_ code: Int, error: String)
    
    func onWebJsError(_ error: String)
    
    func onWebGetAuth()
    
    func onWebGetAntiLeechInfo(withParams params: [String: Any])
}

protocol NMCWhiteboardManagerWKDelegate: AnyObject {
    func onDecidePolicyForNavigationAction(_ navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    
    func onDecidePolicyForNavigationResponse(_ navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void)
}

class NMCMessageDispatcher: NSObject {
    
    static let shared = NMCMessageDispatcher()
    
    weak var delegate: NMCWhiteboardManagerDelegate?
    
    func nativeCallWeb(with webView: WKWebView, action: String?, param: [AnyHashable: Any]?) {
       
        NSLog("[webview] native call web ---> action : \(action), param : \(String(describing: param))")
        
        guard let action = action, !action.isEmpty else {
            return
        }
        
        var dict: [AnyHashable: Any] = [:]
        dict[NMCMethodAction] = action
        if let param = param, !param.isEmpty {
            dict[NMCMethodParam] = param
        }
        
        if let bridgeObj = try? JSONSerialization.data(withJSONObject: dict, options: []),
           let bridgeObjString = String(data: bridgeObj, encoding: .utf8) {
            let callWebString = "window.WebJSBridge('\(bridgeObjString)')"
            
            if Thread.isMainThread {
                webView.evaluateJavaScript(callWebString) { (obj, error) in
                    if let error = error {
                        NSLog("[webview] error = \(error)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(callWebString) { (obj, error) in
                        if let error = error {
                            NSLog("[webview] error = \(error)")
                        }
                    }
                }
            }
        }
    }

    func webCallNative(with webView: WKWebView, action: String, param: [String: Any]?) {
        
        NSLog("[webview] web call native ---> action : \(action), param : \(String(describing: param))")
        
        if action == NMCMethodActionWebPageLoaded {
            delegate?.onWebPageLoaded()
        } else if action == NMCMethodActionWebCreateWBSucceed {
            delegate?.onWebCreateWBSucceed()
        } else if action == NMCMethodActionWebJoinWBSucceed {
            delegate?.onWebJoinWBSucceed()
        } else if action == NMCMethodActionWebJoinWBFailed {
            if let code = param?[NMCMethodParamCode] as? Int,
               let error = param?[NMCMethodParamMsg] as? String {
                delegate?.onWebJoinWBFailed(code, error: error)
            }
        } else if action == NMCMethodActionWebCreateWBFailed {
            if let code = param?[NMCMethodParamCode] as? Int,
               let error = param?[NMCMethodParamMsg] as? String {
                delegate?.onWebCreateWBFailed(code, error: error)
            }
        } else if action == NMCMethodActionWebLeaveWB {
            delegate?.onWebLeaveWB()
        } else if action == NMCMethodActionWebError {
            if let code = param?[NMCMethodParamCode] as? Int,
               let error = param?[NMCMethodParamMsg] as? String {
                delegate?.onWebError(code, error: error)
            }
        } else if action == NMCMethodActionWebJSError {
            if let error = param?[NMCMethodParamMsg] as? String {
                delegate?.onWebJsError(error)
            }
        } else if action == NMCMethodActionWebGetAuth {
            delegate?.onWebGetAuth()
        } else if action == NMCMethodActionWebGetAntiLeechInfo {
            if let param = param {
                delegate?.onWebGetAntiLeechInfo(withParams: param )
            }
        }
    }

}
