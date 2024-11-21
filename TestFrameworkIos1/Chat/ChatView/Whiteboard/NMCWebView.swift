//
//  NMCWebView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/6.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit
import WebKit

let NMCNativeMethodMessage  = "NMCNativeMethodMessage"
let NMCMethodAction  = "action"
let NMCMethodParam  = "param"

let NMCMethodParamCode = "code"
let NMCMethodParamMsg = "msg"
let NMCMethodParamEventName = "eventName"

//登录白板webView
let NMCMethodActionWebLogin = "jsJoinWB"
//登出白板webView
let NMCMethodActionWebLogout = "jsLeaveWB"
//发送鉴权信息
let NMCMethodActionSendAuth = "jsSendAuth"
//发送防盗链信息
let NMCMethodActionSendAntiLeechInfo = "jsSendAntiLeechInfo"

//设置JS调用命令
let NMCMethodActionJSDirectCall = "jsDirectCall"
//绘制相关命令
let NMCMethodTargetDrawPlugin = "drawPlugin"
let NMCMethodTargetActionEnableDraw = "enableDraw"

//页面加载完成
let NMCMethodActionWebPageLoaded = "webPageLoaded"

//创建房间成功
let NMCMethodActionWebCreateWBSucceed = "webCreateWBSucceed"
//创建房间失败
let NMCMethodActionWebCreateWBFailed = "webCreateWBFailed"
//加入房间成功
let NMCMethodActionWebJoinWBSucceed = "webJoinWBSucceed"
//加入房间失败
let NMCMethodActionWebJoinWBFailed = "webJoinWBFailed"

//一般是由于Native调用了jsLeaveWB，webView随之退出IM及白板信令，然后发送此消息给客户端
let NMCMethodActionWebLeaveWB = "webLeaveWB"
//WebView中发生了网络异常
let NMCMethodActionWebError = "webError"
//WebView抛出Js错误。客户端可以根据此消息调试
let NMCMethodActionWebJSError = "webJsError"

//web需要鉴权信息
let NMCMethodActionWebGetAuth = "webGetAuth"
//web需要防盗链信息
let NMCMethodActionWebGetAntiLeechInfo = "webGetAntiLeechInfo"

class NMCWebView: WKWebView {

    init(frame: CGRect, scriptMessageHandler: WKScriptMessageHandler?) {
        
        let config = WKWebViewConfiguration()
        
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        } else {
            config.requiresUserActionForMediaPlayback = false
            config.mediaPlaybackRequiresUserAction = false
        }
        super.init(frame: frame, configuration: config)
        configureWithScriptMessageHandler(scriptMessageHandler)
    }
   
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: NMCNativeMethodMessage)
        configuration.userContentController.removeAllUserScripts()
        stopLoading()
        super.uiDelegate = nil
        super.navigationDelegate = nil
    }
    
    func configureWithScriptMessageHandler(_ scriptMessageHandler: WKScriptMessageHandler?) {
        // 注入 JS
        if let scriptPath = Bundle.main.path(forResource: "NMCJSBridge", ofType: "js"),
           let scriptString = try? String(contentsOfFile: scriptPath, encoding: .utf8) {
            let userScript = WKUserScript(source: scriptString, injectionTime: .atDocumentStart, forMainFrameOnly: false)
            configuration.userContentController.addUserScript(userScript)
        }
        
        // 指定 message handler
        if let handler = scriptMessageHandler {
            configuration.userContentController.add(handler, name: NMCNativeMethodMessage)
        }
    }

}
