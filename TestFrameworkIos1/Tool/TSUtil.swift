//
//  TSUtil.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/08/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  工程通用工具类

import Foundation
import UIKit
import CommonCrypto
import Contacts
import Photos
//import NIMPrivate

enum TSPermissionType {
    case album
    case camera
    case cameraAlbum
    case audio
    case videoCall
    case location
    case contacts
}

enum TSPermissionStatus {
    case notDetermined
    case limited
    case authorized
    case firstDenied
    case denied
}

class TSUtil {
    private static let shareUtil = TSUtil()
    /// 支付需要输入密码的弹窗
    //var pinVC: SecurityPinInputView?
    
    /// 输入的支付密码
    var inputCode: String?
    
    /// 状态栏高度保存
    var statusHeight: CGFloat?
    
    class func share() -> TSUtil {
        return shareUtil
    }
    
    /// URL内部跳转正则匹配
    // 动态
    let AdvertDynamicRege = TSAppConfig.share.rootServerAddress + ".*?" + "feeds/(\\d+).*"
    // 资讯
    private let AdvertInfoRege = TSAppConfig.share.rootServerAddress + ".*?" + "news/(\\d+).*"
    // 圈子
    private let AdvertCircleRege = TSAppConfig.share.rootServerAddress + ".*?" + "groups/(\\d+).*"
    // 帖子
    private let AdvertPostRege = TSAppConfig.share.rootServerAddress + ".*?" + "groups/(\\d+)/posts/(\\d+).*"
    // 问题
    private let AdvertQuestionRege = TSAppConfig.share.rootServerAddress + ".*?" + "questions/(\\d+).*"
    // 问题话题
    private let AdvertQuestionTopicRege = TSAppConfig.share.rootServerAddress + ".*?" + "question-topics/(\\d+).*"
    // 回答
    private let AdvertAnswerRege = TSAppConfig.share.rootServerAddress + ".*?" + "questions/\\d+/answers/(\\d+).*"
    // 话题(动态)
    private let AdvertTopicRege = TSAppConfig.share.rootServerAddress + ".*?" + "topic/(\\d+).*"
    
    private let AdvertUserRege = TSAppConfig.share.rootServerAddress + ".*?" + "users/(\\d+).*"
    
    // 带确定按钮的提示框
    public class func showAlert(title: String?, message: String?, showVC: UIViewController? = nil, clickAction: (() -> Void)?) -> Void {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let doneAction = UIAlertAction(title: "confirm".localized, style: UIAlertAction.Style.default) { (_) in
            clickAction?()
        }
        alertVC.addAction(doneAction)
        if nil == showVC {
            let rootVC = UIApplication.topViewController()
            rootVC?.present(alertVC, animated: true, completion: nil)
        } else {
            showVC?.present(alertVC, animated: true, completion: nil)
        }
    }
    
    //MARK - 过滤emoji
    public class func filterEmoji(str: String) -> String {
        let regex = try!NSRegularExpression(pattern: "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\\u1D000-\\u1F9DE\r\n]", options: .caseInsensitive)
        
        let modifiedString = regex.stringByReplacingMatches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSRange(location: 0, length: str.count), withTemplate: "")
        
        return modifiedString
    }
    
    //MARK: - Get user ids for remark name
    class func getUserID(remarkName: String?) -> String {
        guard let name = remarkName, let userRemarkNames = UserDefaults.standard.array(forKey: "UserRemarkName") as? [[String: String]] else {
            return ""
        }
        
        let userIds = userRemarkNames.filter {
            $0["remarkName"]!.range(of: name, options: .caseInsensitive) != nil
        }.compactMap {
            $0["userID"]
        }.joined(separator: ",")
        
        return userIds
    }
    
    class func compressImageData(imageData: Data, maxSizeKB: CGFloat) -> Data {
        var resizeRate = 0.99
        let orignalImage = UIImage(data: imageData)
        var sizeOriginKB: CGFloat = CGFloat(imageData.count) / 1_024.0
        var comImageData: Data = imageData
        var count: Int = 0
        while sizeOriginKB > maxSizeKB && resizeRate > 0.01 {
            comImageData = orignalImage!.jpegData(compressionQuality: CGFloat(resizeRate))!
            sizeOriginKB = CGFloat(comImageData.count) / 1_024.0
            resizeRate -= 0.05
            count += 1
        }
        return comImageData
    }
    
    class func heightOfAttributeString(contentWidth: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.height
    }
    
    class func heightOfLines(line: Int, font: UIFont) -> CGFloat {
        if line <= 0 {
            return 0
        }
        
        var mutStr = "*"
        for _ in 0 ..< line - 1 {
            mutStr = mutStr + "\n*"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyle.copy(), NSAttributedString.Key.strokeColor: UIColor.black]
        let tSize = mutStr.size(withAttributes: attribute)
        return tSize.height
    }
    
    /// 根据视频名称获取发布视频动态的完整路径
    class func getWholeFilePath(name: String) -> String {
        // 完整的视频路径为：沙盒/tmp/videoFeedFiles/uid
        var videoFeedPath = ""
        if let uid = CurrentUserSessionInfo?.userIdentity {
            videoFeedPath = NSHomeDirectory() + "/tmp/" + "videoFeedFiles/" + "\(uid)/" + name
        } else {
            videoFeedPath = NSHomeDirectory() + "/tmp/" + "videoFeedFiles/" + name
        }
        return videoFeedPath
    }
    
    /// 找到所以输入的at
    class func findAllInputAt(inputStr: String) -> Array<NSTextCheckingResult> {
        let regx = try? NSRegularExpression(pattern: "@[\\u4e00-\\u9fa5\\w\\-\\_]+ ", options: NSRegularExpression.Options.caseInsensitive)
        return regx!.matches(in: inputStr, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(location: 0, length: inputStr.endIndex.encodedOffset))
    }
    
    /// 找到所有TS的at
    class func findAllTSAt(inputStr: String) -> Array<NSTextCheckingResult> {
        let regx = try? NSRegularExpression(pattern: "\\u00ad(?:@[^/]+?)\\u00ad", options: NSRegularExpression.Options.caseInsensitive)
        var strLength : Int = inputStr.endIndex.encodedOffset >= inputStr.count ? inputStr.count : inputStr.endIndex.encodedOffset
        return regx!.matches(in: inputStr, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSRange(inputStr.startIndex..., in: inputStr))
    }
    
    /// 替换手动输入的at
    class func replaceEditAtString(inputStr: String) -> String {
        /// 匹配手动输入at的正则
        let inputAtRege = "(?<!\\u00ad)@[^./\\s\\u00ad@]+"
        /// TS+规则的正则
        let tsAtRege = "\\u00ad(?:@[^/]+?)\\u00ad"
        /// 替换TS+ at规则的正则
        let replaceStr = "∫∂THINKSNS∂∫"
        /// TS+ at规则的分割符号
        let spStr = String(data: ("\u{00ad}".data(using: String.Encoding.unicode))!, encoding: String.Encoding.unicode)!
        var comperFromIndex: Int = 0
        /// 把TS+定制的at内容（包含特殊字符）保存到容器
        var tsAts: [String] = []
        /// TS+定制规则的at内容替换为特殊符号后的完整字符串
        var tsAtReplaceResultStr = inputStr
        /// 依次匹配到TS+的at，把找到的内容依次保存，然后替换为特殊符号
//        while comperFromIndex < tsAtReplaceResultStr.endIndex.encodedOffset {
//            let tsAtRegx = try? NSRegularExpression(pattern: tsAtRege, options: NSRegularExpression.Options.caseInsensitive)
//            let matchs = tsAtRegx!.matches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset))
//            /// 替换为特殊字符
//            if let result = tsAtRegx?.stringByReplacingMatches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset), withTemplate: replaceStr), matchs.count > 0 {
//                tsAts.append(TSCommonTool.getStriingFrom(tsAtReplaceResultStr, rang: matchs[0].range))
//                tsAtReplaceResultStr = result
//            } else {
//                comperFromIndex = tsAtReplaceResultStr.endIndex.encodedOffset
//            }
//        }
        
        /// 找到手动输入的at并替换为TS+定制格式
        comperFromIndex = 0
        while comperFromIndex < tsAtReplaceResultStr.endIndex.encodedOffset {
            let inputAtRegx = try? NSRegularExpression(pattern: inputAtRege, options: NSRegularExpression.Options.caseInsensitive)
            let matchs = inputAtRegx!.matches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset))
            /// 如果找到了手动输入的at，并且成功截取出了指定range中的内容，并且替换为TS+指定样式
//            if matchs.count > 0, let matchStr = TSCommonTool.getStriingFrom(tsAtReplaceResultStr, rang: matchs[0].range), let result = inputAtRegx?.stringByReplacingMatches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset), withTemplate: spStr + matchStr + spStr) {
//                tsAtReplaceResultStr = result
//            } else {
//                comperFromIndex = tsAtReplaceResultStr.endIndex.encodedOffset
//            }
        }
        
        /// 还原第一步被替换掉的TS+定制格式
        comperFromIndex = 0
        var replaceIndex = 0
        while comperFromIndex < tsAtReplaceResultStr.endIndex.encodedOffset, replaceIndex < tsAts.count {
            /// 原来的at
            let orignalAtStr = tsAts[replaceIndex]
            let inputAtRegx = try? NSRegularExpression(pattern: "(\(replaceStr))", options: NSRegularExpression.Options.caseInsensitive)
            let matchs = inputAtRegx!.matches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset))
            /// 如果找到了手动输入的at，并且成功截取出了指定range中的内容，并且替换为TS+指定样式
            if matchs.count > 0, let result = inputAtRegx?.stringByReplacingMatches(in: tsAtReplaceResultStr, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: comperFromIndex, length: tsAtReplaceResultStr.endIndex.encodedOffset), withTemplate: orignalAtStr) {
                tsAtReplaceResultStr = result
                replaceIndex = replaceIndex + 1
            } else {
                comperFromIndex = tsAtReplaceResultStr.endIndex.encodedOffset
            }
        }
        return tsAtReplaceResultStr
    }
    /// 跳转到用户中心
    class func pushUserHomeName(name: String) {
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uname": name])
    }
    
    class func pushUserHomeId(uid: String) {
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": uid])
    }
    
    /// 解析TS加网络文件格式，返回请求地址
    class func praseTSNetFileUrl(netFile: TSNetFileModel?) -> String? {
        return netFile?.url
    }
    
    ///  解析TS加网络文件格式，返回请求地址
    class func praseTSNetFileUrl(netFile: EntityNetFile?) -> String? {
        return netFile?.url
    }
    
    /// 返回上一级页面
    class func popViewController(currentVC: UIViewController, animated: Bool) {
        if currentVC.presentingViewController != nil, let nav = currentVC.navigationController, nav.viewControllers.count == 1 {
            currentVC.dismiss(animated: animated, completion: nil)
        } else {
            currentVC.navigationController?.popViewController(animated: animated)
        }
    }
    
    /// URL跳转
    func getEnableAdvertModule() -> [String] {
        return [AdvertDynamicRege, AdvertInfoRege, AdvertCircleRege, AdvertPostRege, AdvertQuestionRege, AdvertQuestionTopicRege, AdvertAnswerRege, AdvertTopicRege, AdvertUserRege]
    }
    
    private func handleYippiDomainLink(url: URL, currentVC: UIViewController) -> Bool {
        guard let urlhostName = url.host, let yippiHostName = URL(string: TSAppConfig.share.rootServerAddress)?.host else {
            return false
        }
        var isURLSameAsPrefix = false
        if let shareURLPrefix = TSAppConfig.share.localInfo.shareUrlPrefix, let prefixURL = URL(string: shareURLPrefix), let prefixHostname = prefixURL.host, urlhostName.lowercased() == prefixHostname.lowercased() {
            isURLSameAsPrefix = true
        }
        guard (urlhostName.lowercased() == yippiHostName.lowercased() ||  isURLSameAsPrefix == true), url.pathComponents.count > 0 else { return false }
        if url.pathComponents.containsIgnoringCase("feeds") {
            if let detailIDString = url.pathComponents.last, let detailID = Int(detailIDString) {
                //TSRootViewController.share.presentFeedDetail(detailID, shouldCloseLive: false)
                currentVC.navigateLive(feedId: detailID, isDeepLink: true)
                return true
            }
        } else if url.pathComponents.containsIgnoringCase("users") {
            if let userIDString = url.pathComponents.last, let userID = Int(userIDString) {
                NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userID])
                return true
            }
        }
        return false
    }
    
    class func getCurrentEnvironmentConfig() -> ServerConfig {
        let item = AppEnvironment.current.bundleIdentifier
        var server = ServerConfig.production
        #if DEBUG
        let identifier = TSAppConfig.share.environment.identifier
        if identifier == "Prod" {
            server = ServerConfig.production
        } else {
            server = ServerConfig.preproduction
        }
        #else
        server = ServerConfig.production
        #endif
        return server
    }
    
    class func pushURLDetail(url: URL, currentVC: UIViewController, isFullScreen: Bool = true, appendQueryString: Bool = false, isDismiss: Bool = false) {
//        guard TSUtil().handleYippiDomainLink(url: url, currentVC: currentVC) == false else { return }
//        let webVC = TSUtil().checkYippsWantedWeb(url: url, appendQueryString: appendQueryString)
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            if appDelegate.deeplinkingHandler(url: url, currentVC: currentVC, isDismiss: isDismiss) == false {
//                if let nav = currentVC as? UINavigationController {
//                    nav.pushViewController(webVC, animated: true)
//                } else if let nav = currentVC.navigationController {
//                    nav.pushViewController(webVC, animated: true)
//                } else {
//                    if isFullScreen == false {
//                        let webVCNav = TSNavigationController(rootViewController: webVC)
//                        currentVC.present(webVCNav, animated: true, completion: nil)
//                    } else {
//                        let webVCNav = TSNavigationController(rootViewController: webVC, availableOrientations: [.allButUpsideDown])
//                        currentVC.heroPush(webVCNav)
//                    }
//                }
//            }
//        }
        
//        if url.absoluteString.contains("mini-program") {
//            let arr = url.absoluteString.components(separatedBy: "/mini-program/")
//            if let lastStr = arr.last, let appId = lastStr.components(separatedBy: "/").first {
//                var items = lastStr.components(separatedBy: "/")
//                if let index = items.firstIndex(where: { $0 == appId }) {
//                    items.remove(at: index)
//                }
//                if items.count == 0 {
//                    MiniProgramExecutor().startApplet(type: .normal(appId: appId), parentVC: currentVC)
//                } else {
//                    let path = items.joined(separator: "/").removingPercentEncoding
//                    MiniProgramExecutor().startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: currentVC)
//                }
//            }
//        } else if url.absoluteString.contains("/feeds") {
//            TSRootViewController.share.presentFeedDetail(url.lastPathComponent.toInt())
//        } else if url.absoluteString.contains("/users") {
//            TSRootViewController.share.presentUserPage(userId: url.lastPathComponent.toInt())
//        } else if url.absoluteString.contains("/discover") {
//            if isDismiss {
//                currentVC.dismiss(animated: false, completion: {
//                    if url.absoluteString.contains("/discover-live") {
//                        //直播
//                        TSRootViewController.share.presentLiveList()
//                    } else if url.absoluteString.contains("/discover-game"){
//                        //游戏
//                        TSRootViewController.share.presentLiveGame()
//                    } else if url.absoluteString.contains("/discover-trending"){
//                        //trending
//                        TSRootViewController.share.presentTrending()
//                    } else if url.absoluteString.contains("/discover-playz"){
//                        //playz
//                        TSRootViewController.share.presentPlayz()
//                    } else if url.absoluteString.contains("/discover-trt"){
//                        //trt
//                        TSRootViewController.share.presentTrt()
//                    } else if url.absoluteString.contains("/discover-event"){
//                        //event
//                        TSRootViewController.share.presentEvent()
//                    } else { //原本的跳转方式
//                        TSRootViewController.share.presentDiscover(atIndex: url.lastPathComponent.toInt())
//                    }
//                })
//            } else {
//                //直播
//                if url.absoluteString.contains("/discover-live") {
//                    //直播
//                    TSRootViewController.share.presentLiveList()
//                } else if url.absoluteString.contains("/discover-game") {
//                    //游戏
//                    TSRootViewController.share.presentLiveGame()
//                } else if url.absoluteString.contains("/discover-trending") {
//                    //trending
//                    TSRootViewController.share.presentTrending()
//                } else if url.absoluteString.contains("/discover-playz") {
//                    //playz
//                    TSRootViewController.share.presentPlayz()
//                } else if url.absoluteString.contains("/discover-trt") {
//                    //trt
//                    TSRootViewController.share.presentTrt()
//                } else if url.absoluteString.contains("/discover-event") {
//                    //event
//                    TSRootViewController.share.presentEvent()
//                } else {
//                    //原本的跳转方式
//                    TSRootViewController.share.presentDiscover(atIndex: url.lastPathComponent.toInt())
//                }
//            }
//        } else if url.absoluteString.contains("/home") {
//            TSRootViewController.share.presentFeedHome(atIndex: url.lastPathComponent.toInt())
//        } else if url.absoluteString.contains("/support-system") {
//            TSRootViewController.share.presentSubscribeVC([:])
//        } else if url.absoluteString.contains("/stickers") {
//            TSRootViewController.share.presentStickerDetail(for: url.lastPathComponent)
//        } else if url.absoluteString.contains("/refer-and-earn") {
//            TSRootViewController.share.presentReferAndEarn()
//        } else if url.absoluteString.contains("/yw-home") {
//            TSRootViewController.share.presentYipsWanted()
//        } else if url.absoluteString.contains("/wallet") {
//            if url.absoluteString.contains("/wallet-history") {
//                TSRootViewController.share.presentWalletHistory(index: url.lastPathComponent.toInt())
//                return
//            }
//            TSRootViewController.share.presentWalletMain()
//        } else if url.absoluteString.contains("/yipps-topup") {
//            TSRootViewController.share.presentYipsTopup()
//        } else if url.absoluteString.contains("/wallet-history") {
//            TSRootViewController.share.presentWalletHistory(index: url.lastPathComponent.toInt())
//        } else if url.absoluteString.contains("/mobile-topup") {
//            TSRootViewController.share.presentMobileTopup(index: url.lastPathComponent.toInt() - 1)
//        } else if url.absoluteString.contains("/utility-topup") {
//            TSRootViewController.share.presentUtilityTopup(index: url.lastPathComponent.toInt())
//        } else if url.absoluteString.contains("/sticker-shop") {
//            TSRootViewController.share.presentStickerShop()
//        } else if url.absoluteString.contains("/mp-list") {
//            TSRootViewController.share.presentMpList()
//        } else if url.absoluteString.contains("/me") {
//            if url.absoluteString.contains("/settings") {
//                TSRootViewController.share.presentSetting()
//            } else {
//                TSRootViewController.share.presentMyPage()
//            }
//        } else if url.absoluteString.contains("goama") {
//            TSRootViewController.share.presentGoama()
//        } else if url.absoluteString.contains("/globalsearch") {
//            TSRootViewController.share.presentGlobalsearch()
//        } else if url.absoluteString.contains("/qrcode") {
//            TSRootViewController.share.presentWalletQrcode()
//        } else if url.absoluteString.contains("/comments") {
//            TSRootViewController.share.presentComment()
//        } else if url.absoluteString.contains("/voucher") {
//            if url.lastPathComponent.toInt() != 0 {
//                TSRootViewController.share.presentVoucherDetails(voucherId: url.lastPathComponent.toInt())
//            } else {
//                TSRootViewController.share.presentVoucherDashboard()
//            }
//        } else {
//            if let nav = currentVC as? UINavigationController {
//                nav.pushViewController(webVC, animated: true)
//            } else if let nav = currentVC.navigationController {
//                nav.pushViewController(webVC, animated: true)
//            } else {
//                if isFullScreen == false {
//                    let webVCNav = TSNavigationController(rootViewController: webVC)
//                    currentVC.present(webVCNav, animated: true, completion: nil)
//                } else {
//                    let webVCNav = TSNavigationController(rootViewController: webVC, availableOrientations: [.allButUpsideDown])
//                    currentVC.heroPush(webVCNav)
//                }
//            }
//        }
    }
    
    private func checkYippsWantedWeb(url: URL, title: String = "", appendQueryString: Bool) -> UIViewController {
        if url.absoluteString.contains("yipps-wanted") && url.pathComponents.contains("how-to-get") {
          //  return YippsWantedQRWebViewController(url: url, frame: UIScreen.main.bounds)
        } else if url.absoluteString.contains("yipps-wanted") {
          //  return YippsWantedHomePageWebViewController(url: url, title: nil, frame: UIScreen.main.bounds)
        } else {
           // return BridgedWebController(url: url, query: appendQueryString, frame: UIScreen.main.bounds)
        }
        return UIViewController()
    }
    /// 支付密码弹窗
    //    class func showPwdVC(complete: @escaping ((String) -> Void), cancel: EmptyClosure? = nil) {
    //        let pyVC = YPTransactionVerificationAlertVC()
    //        TSUtil.share().pyVC = pyVC
    //
    //        if let rootVC = UIApplication.topViewController() {
    //            pyVC.view.frame = rootVC.view.bounds
    //            rootVC.view.addSubview(pyVC.view)
    //            rootVC.addChild(pyVC)
    //            pyVC.didMove(toParent: rootVC)
    //        }
    //
    //        pyVC.sureBtnClickBlock = { inputCodeStr in
    //            TSUtil.share().inputCode = inputCodeStr
    //            complete(inputCodeStr)
    //        }
    //        pyVC.dismissBlock = {
    //            cancel?()
    //        }
    //    }
    //    /// 移除支付密码弹窗
    //    class func dismissPwdVC() {
    //        if let payVC = TSUtil.share().pyVC {
    //            payVC.dismiss()
    //            TSUtil.share().pyVC = nil
    //        }
    //    }
    
    // MARK: - 下载视频
    func showDownloadVC(videoUrl: String) {
        let showDownloadVC = {
            let downloadVC = TSDownloadVC()
            downloadVC.downloadUrl = videoUrl
            downloadVC.view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            let nav = UINavigationController(rootViewController: downloadVC)
            nav.isNavigationBarHidden = true
            let bgView = UIView(frame: UIScreen.main.bounds)
            bgView.tag = 434_434
            bgView.isHidden = true
            bgView.backgroundColor = UIColor.white
            nav.view.addSubview(bgView)
            nav.view.sendSubviewToBack(bgView)
            downloadVC.showNav = nav
            if let keyWindow = UIApplication.shared.keyWindow, let rootViewController = keyWindow.rootViewController {
                rootViewController.view.addSubview(nav.view)
                rootViewController.addChild(nav)
                nav.didMove(toParent: keyWindow.rootViewController)
            }
            downloadVC.beginDownload()
        }
        /// 检查是否允许非Wi-Fi环境下下载
        if TSAppConfig.share.reachabilityStatus == .Cellular && TSCurrentUserInfo.share.isAgreeUserCelluarDownloadShortVideo == false {
            let alert = TSAlertController(title: "text_tips".localized, message: "warning_using_cellular_download".localized, style: .actionsheet, sheetCancelTitle: "cancel".localized)
            let action = TSAlertAction(title:"text_continue".localized, style: TSAlertSheetActionStyle.default, handler: { (_) in
                TSCurrentUserInfo.share.isAgreeUserCelluarDownloadShortVideo = true
                TSUtil.checkAuthorizeStatusByType(type: .album, isShowBottom: true, viewController: nil, completion: {
                    DispatchQueue.main.async {
                        showDownloadVC()
                    }
                })
            })
            alert.addAction(action)
            if let keyWindow = UIApplication.shared.keyWindow, let rootViewController = keyWindow.rootViewController {
                rootViewController.view.addSubview(alert.view)
                rootViewController.addChild(alert)
                alert.didMove(toParent: keyWindow.rootViewController)
            }
        } else {
            TSUtil.checkAuthorizeStatusByType(type: .album, isShowBottom: true, viewController: nil, completion: {
                DispatchQueue.main.async {
                    showDownloadVC()
                }
            })
        }
    }
    
    /// 图片压缩至指定体积,得到二进制文件
    class func compressImage(image: UIImage, dataSizeKB maxCount: Int) -> Data? {
        let maxCountBtye = maxCount * 1_024
        var compression: CGFloat = 1
        guard var imageData = image.jpegData(compressionQuality: compression) else {
            return nil
        }
        if imageData.count <= maxCountBtye {
            return imageData
        }
        // 二分法压缩6次体积,如果还达不到要求就需要修改原图分辨率
        var maxCompression: CGFloat = 1
        var minCompression: CGFloat = 0
        for _ in 0 ..< 6 {
            compression = (minCompression + maxCompression) / 2
            imageData = image.jpegData(compressionQuality: compression)!
            if CGFloat(imageData.count) < CGFloat(maxCountBtye) * 0.95 {
                minCompression = compression
            } else if imageData.count > maxCountBtye {
                maxCompression = compression
            } else {
                break
            }
        }
        if imageData.count <= maxCountBtye {
            return imageData
        }
        
        /// 质量压缩达不到要求,就通过降低分辨率调整
        var resultImage: UIImage = UIImage(data: imageData)!
        // 通过降低图片分辨率重新渲染图片降低图片体积
        var lastDataCount: Int = 0
        /// 有可能分辨率降到很低还是无法达到体积要求也结束循环
        while imageData.count > maxCountBtye, imageData.count != lastDataCount {
            lastDataCount = imageData.count
            let ratio: CGFloat = CGFloat(maxCountBtye) / CGFloat(imageData.count)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            imageData = resultImage.jpegData(compressionQuality: compression)!
        }
        return imageData
    }
    /// 获取TSFile图片宽高
    class func praseTSNetFileImageSize(netFile: TSNetFileModel?) -> CGSize {
        if let netFile = netFile {
            return CGSize(width: netFile.width, height: netFile.height)
        } else {
            return CGSize.zero
        }
    }
    
    public class func showIndicator(_ state: LoadingState, title: String? = nil) {
        let alert = TSIndicatorWindowTop(state: state, title: title)
        alert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    public class func generatePHAssetVideoCoverImage(phAsset:PHAsset, completion:@escaping (UIImage?) -> Void) {
        //Add option to allow get image store in iCloud but not local device which cause asset not accessible
        let option: PHVideoRequestOptions? = PHVideoRequestOptions()
        option?.isNetworkAccessAllowed = true
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: option, resultHandler: {  (avasset, audioMix, dict) in
            guard let avAsset = avasset else {
                completion(nil)
                return
            }
            let coverImage = generateAVAssetVideoCoverImage(avAsset: avAsset)
            completion(coverImage)
        })
    }
    
    public class func generateAVAssetVideoCoverImage(avAsset:AVAsset) -> UIImage? {
        let imgGenerator = AVAssetImageGenerator(asset: avAsset)
        imgGenerator.appliesPreferredTrackTransform = true
        imgGenerator.apertureMode = .productionAperture
        do {
            let cgImage = try imgGenerator.copyCGImage(at: .zero, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
    public class func md5(_ data: Data) -> String {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes {
            CC_MD5($0.baseAddress, UInt32(data.count), &digest)
        }
        return digest.map { String(format:"%02x", $0) }.joined()
    }
    
    class func showPin(completion: ((String) -> Void)?, cancel: EmptyClosure? = nil, needDisplayError: Bool = true) {
        guard let rootVC = UIApplication.topViewController() else {
            return
        }
//        let vc = SecurityPinInputView()
//        TSUtil.share().pinVC = vc
//        
//        vc.view.frame = rootVC.view.bounds
//        rootVC.view.addSubview(vc.view)
//        rootVC.addChild(vc)
//        vc.didMove(toParent: rootVC)
//        
//        vc.needDisplayError = needDisplayError
//        
//        vc.onCompleteCode = { pin in
//            completion?(pin)
//        }
//        
//        vc.onCancelPin = cancel
//        
//        vc.onForgotPin = {
//            let vc = SecurityPinViewController(type: .forgot)
//            if rootVC.navigationController == nil {
//                let nav = TSNavigationController(rootViewController: vc)
//                vc.setCloseButton(backImage: true)
//                rootVC.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//            } else {
//                rootVC.navigationController?.pushViewController(vc, animated: true)
//            }
//        }
    }
    
    class func dismissPin() {
//        TSUtil.share().pinVC?.dismiss()
//        TSUtil.share().pinVC = nil
    }
    
    class func showPinError(_ message: String) {
       // TSUtil.share().pinVC?.onShowError(message)
    }
    
    /// 检查App权限,提示弹窗在方法内处理
    class func showPermissionAlert(title: String = "", message: String = "", isShowBottom: Bool = false, viewController: UIViewController?) {
        if isShowBottom {
            let appName = TSAppConfig.share.localInfo.appDisplayName
            TSErrorTipActionsheetView().setWith(title: title, TitleContent: String(format: message, "\(appName)"), doneButtonTitle: ["setting_permission".localized, "cancel".localized], complete: { (_) in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            })
        } else {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
                let url = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(url!) {
                    UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                }
            }))
            alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
            
            guard let viewController = viewController else {
                return
            }
            
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    class func checkAuthorizeEnableByType (type: TSPermissionType, completionHandler:@escaping (TSPermissionStatus) -> ()) {
        var photoStatus: PHAuthorizationStatus = .notDetermined
        if #available(iOS 14, *) {
            photoStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            photoStatus = PHPhotoLibrary.authorizationStatus()
        }
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        let locationStatus = LocationManager.shared.getLocationPermissionStatus()
        let contactStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        var permissionStatus: TSPermissionStatus = .denied
        
        switch type {
        case.album:
            if photoStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (newState) in
                    if #available(iOS 14, *) {
                        if photoStatus == .authorized || photoStatus == .limited {
                            permissionStatus = TSPermissionStatus.authorized
                            completionHandler(permissionStatus)
                            return
                        }
                    } else {
                        if permissionStatus == .authorized {
                            permissionStatus = TSPermissionStatus.authorized
                            completionHandler(permissionStatus)
                            return
                        }
                    }
                })
                
                permissionStatus = TSPermissionStatus.firstDenied
                completionHandler(permissionStatus)
                return
            }
                        
            switch photoStatus {
            case .denied, .restricted:
                // 2.取消了授权
                permissionStatus = TSPermissionStatus.denied
                break
            case .notDetermined:
                permissionStatus = TSPermissionStatus.notDetermined
                break
            case .limited:
                permissionStatus = TSPermissionStatus.limited
                break
            case .authorized, .limited:
                permissionStatus = TSPermissionStatus.authorized
                break
            default: break
            }
            break
        case .camera:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    if granted {
                        permissionStatus = TSPermissionStatus.authorized
                        completionHandler(permissionStatus)
                        return
                    }
                })
                
                permissionStatus = TSPermissionStatus.firstDenied
                completionHandler(permissionStatus)
                return
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                permissionStatus = TSPermissionStatus.denied
            case .notDetermined:
                permissionStatus = TSPermissionStatus.notDetermined
                break
            case .authorized:
                permissionStatus = TSPermissionStatus.authorized
                break
            default: break
            }
            break
        case .cameraAlbum:
            break
        case .audio:
            if audioStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                    if granted {
                        permissionStatus = TSPermissionStatus.authorized
                        completionHandler(permissionStatus)
                        return
                    }
                })
                
                permissionStatus = TSPermissionStatus.firstDenied
                completionHandler(permissionStatus)
                return
            }
            
            switch audioStatus {
            case .denied, .restricted:
                // 2.取消了授权
                permissionStatus = TSPermissionStatus.denied
                break
            case .notDetermined:
                permissionStatus = TSPermissionStatus.notDetermined
                break
            case .authorized:
                permissionStatus = TSPermissionStatus.authorized
                break
            default: break
            }
            break
        case .videoCall:
            break
        case .location:
            if locationStatus == .notDetermined {
                LocationManager.shared.runLocationBlock {
                    permissionStatus = TSPermissionStatus.authorized
                    completionHandler(permissionStatus)
                    return
                }
                
                permissionStatus = TSPermissionStatus.firstDenied
                completionHandler(permissionStatus)
                return
            }
            
            switch locationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                permissionStatus = TSPermissionStatus.authorized
                break
            case .denied, .restricted:
                permissionStatus = TSPermissionStatus.denied
                break
            case .notDetermined:
                permissionStatus = TSPermissionStatus.notDetermined
                break
            }
            break
        case .contacts:
            if contactStatus == .notDetermined {
                CNContactStore().requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                    if access {
                        permissionStatus = TSPermissionStatus.authorized
                        completionHandler(permissionStatus)
                        return
                    }
                })
                
                permissionStatus = TSPermissionStatus.firstDenied
                completionHandler(permissionStatus)
                return
            }
            
            switch contactStatus {
            case .denied, .restricted:
                // 2.取消了授权
                permissionStatus = TSPermissionStatus.denied
                break
            case .notDetermined:
                permissionStatus = TSPermissionStatus.notDetermined
                break
            case .authorized:
                permissionStatus = TSPermissionStatus.authorized
                break
            @unknown default:
                // Check for iOS 18 specific 'limited' status
//                if #available(iOS 18, *) {
//                    if contactStatus == .limited {
//                        permissionStatus = TSPermissionStatus.limited
//                    }
//                }
                break
            }
            break
        default:
            break
        }
        
        return completionHandler(permissionStatus)
    }
    
    class func checkAuthorizeStatusByType(type: TSPermissionType, isShowBottom: Bool = false, viewController: UIViewController?, completion: @escaping EmptyClosure) {
        let photoStatus = PHPhotoLibrary.authorizationStatus()
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        let audioStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        let locationStatus = CLLocationManager.authorizationStatus()
        let contactStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        
        switch type {
        case .album:
            if photoStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization({ (newState) in
                    if #available(iOS 14, *) {
                        guard newState == .authorized || newState == .limited else {
                            return
                        }
                    } else {
                        guard newState == .authorized else {
                            return
                        }
                    }
                    
                    completion()
                })
                return
            }
            
            switch photoStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ? "album_permission".localized : "rw_photos_limited_permission_fail".localized, message: isShowBottom ? "rw_album_permission_read_write".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            case .authorized, .limited:
                completion()
            default: break
            }
            break
        case .camera:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                completion()
            default: break
            }
            break
        case .cameraAlbum:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                    PHPhotoLibrary.requestAuthorization({ (newState) in
                        if #available(iOS 14, *) {
                            if newState == .authorized || newState == .limited && granted {
                                completion()
                            }
                        } else {
                            if newState == .authorized && granted {
                                completion()
                            }
                        }
                    })
                })
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                if photoStatus == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({ (newState) in
                        if #available(iOS 14, *) {
                            guard newState == .authorized || newState == .limited else {
                                return
                            }
                        } else {
                            guard newState == .authorized else {
                                return
                            }
                        }
                        
                        completion()
                    })
                    return
                }
                
                switch photoStatus {
                case .denied, .restricted:
                    // 2.取消了授权
                    showPermissionAlert(title: isShowBottom ? "album_permission".localized : "rw_photos_limited_permission_fail".localized, message: isShowBottom ? "rw_album_permission_read_write".localized : "", isShowBottom: isShowBottom, viewController: viewController)
                case .notDetermined:
                    break
                case .authorized, .limited:
                    completion()
                default: break
                }
            default: break
            }
            break
        case .audio:
            if audioStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                    guard granted == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch audioStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ? "microphone_permission".localized : "rw_audio_limited_video_chat_fail".localized, message: isShowBottom ? "mircrophone_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                completion()
            default: break
            }
            break
        case .videoCall:
            if cameraStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (cameraGranted) in
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (audioGranted) in
                        if audioGranted && cameraGranted {
                            completion()
                        }
                    })
                })
            }
            
            switch cameraStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ? "camera_permission".localized : "rw_camera_limited_video_chat_fail".localized, message: isShowBottom ? "rw_camera_allow_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            case .authorized:
                if audioStatus == .notDetermined {
                    AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (granted) in
                        guard granted == true else {
                            return
                        }
                        completion()
                    })
                    return
                }
                
                switch audioStatus {
                case .denied, .restricted:
                    // 2.取消了授权
                    showPermissionAlert(title: isShowBottom ? "microphone_permission".localized : "rw_audio_limited_video_chat_fail".localized, message: isShowBottom ? "mircrophone_permission".localized : "", isShowBottom: isShowBottom, viewController: viewController)
                case .notDetermined:
                    break
                case .authorized:
                    completion()
                }
            default: break
            }
            break
        case .location:
            if locationStatus == .notDetermined {
                LocationManager.shared.runLocationBlock {
                    completion()
                    return
                }
            }
            
            switch locationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                completion()
            case .denied, .restricted:
                showPermissionAlert(title: isShowBottom ? "location_permission".localized : "rw_location_limited_permission_fail".localized, message: isShowBottom ? "rw_location_limited_permission_fail".localized : "", isShowBottom: isShowBottom, viewController: viewController)
            case .notDetermined:
                break
            }
            break
        case .contacts:
            if contactStatus == .notDetermined {
                CNContactStore().requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                    guard access == true else {
                        return
                    }
                    completion()
                })
                return
            }
            
            switch contactStatus {
            case .denied, .restricted:
                // 2.取消了授权
                showPermissionAlert(title: isShowBottom ?  "contact_permission".localized :"rw_contacts_limited_permission_fail".localized, message: isShowBottom ? "rw_contacts_limited_permission_fail".localized : "", isShowBottom: isShowBottom, viewController: viewController)
                break
            case .notDetermined:
                break
            case .authorized:
                completion()
                break
            @unknown default:
                // Check for iOS 18 specific 'limited' status
//                if #available(iOS 18, *) {
//                    if contactStatus == .limited {
//                        completion()
//                    }
//                }
                break
            }
            break
        default:
            break
        }
    }

    // MARK: - 转换为json字符串
    class func jsonArray(res: [Any]) -> String {
        if (!JSONSerialization.isValidJSONObject(res)) {
            print("无法解析出JSONString")
            return " "
        }
        if let data = try? JSONSerialization.data(withJSONObject: res, options: [.fragmentsAllowed,.prettyPrinted]), let JSONString = NSString(data:data as Data,encoding: String.Encoding.utf8.rawValue) as String? {
            return JSONString
        }
        return " "
    }
    
    // Check Valid Url String
    class func matchUrlInString (urlString: String) -> URL? {
        let types: NSTextCheckingResult.CheckingType = .link
        let detector = try? NSDataDetector(types: types.rawValue)
        let matches = detector?.matches(in: urlString, options: .reportCompletion, range: NSMakeRange(0, urlString.count))
        var contentUrl: URL?
        for match in matches ?? [] {
            if let url = match.url {
                contentUrl = url
            }
        }
        return contentUrl
    }
    
    // Check Valid DeepLink
    class func checkIsDeepLink(urlString: String) -> Bool {
        var isDeepLink:Bool = false
        
        guard let url = URL(string: urlString) else {
            return isDeepLink
        }
        
        if url.absoluteString.contains("/feeds") || url.absoluteString.contains("/users") || url.absoluteString.contains("/discover") || url.absoluteString.contains("/home")
            || url.absoluteString.contains("/support-system") || url.absoluteString.contains("/stickers") || url.absoluteString.contains("/refer-and-earn") || url.absoluteString.contains("/yw-home")
            || url.absoluteString.contains("/wallet") || url.absoluteString.contains("/yipps-topup") || url.absoluteString.contains("/wallet-history") || url.absoluteString.contains("/mobile-topup")
            || url.absoluteString.contains("/utility-topup") || url.absoluteString.contains("/mini-program/") || url.absoluteString.contains("/comments")
        {
            isDeepLink = true
        }
        
        return isDeepLink
    }
    //动态根据tagUsers获取ids
    class func generateMatchingUserIDs(tagUsers: [UserInfoModel], atStrings: [String]) -> [Int] {
        
        var matchingUserIDs = Set<Int>()
        
        for atString in atStrings {
            if let matchedUser = tagUsers.first(where: { $0.name.removingSpecialCharacters() == atString.removingSpecialCharacters() }) {
                matchingUserIDs.insert(matchedUser.id.intValue)  // Insert into set, duplicates are automatically handled
            }
        }
        
        return Array(matchingUserIDs)
    }
    //获取发布动态content里面所有的userIds
    class func findTSAtStrings(inputStr: String) -> [String] {
        let regx = try? NSRegularExpression(pattern: "@[^<]+?(?=</a>)", options: .caseInsensitive)
        let matches = regx!.matches(in: inputStr, options: [], range: NSRange(location: 0, length: inputStr.utf16.count))

        var atStrings = [String]()

        for match in matches {
            let range = match.range
            if let swiftRange = Range(range, in: inputStr) {
                let atString = String(inputStr[swiftRange])
                atStrings.append(atString)
            }
        }

        return atStrings
    }
    
    // 打开权限提示弹窗
    class func showLocationPermissionAlert() {
        let alert = UIAlertController(title: "rw_location_limited_permission_fail".localized, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        UIApplication.topViewController()?.present(alert, animated: true, completion: nil)
    }
}
