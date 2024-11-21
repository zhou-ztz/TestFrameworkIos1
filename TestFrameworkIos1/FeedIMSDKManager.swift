//
//  FeedIMSDKManager.swift
//  feedIMSDKDemo
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/10/28.
//

import UIKit
import Lokalise
import IQKeyboardManagerSwift
import NIMSDK
import RealmSwift

enum ShowPinType {
    case egg, purchase
    
    var text: String {
        switch self {
        case .egg: return "text_send_egg_bio_auth".localized
        case .purchase: return "text_purchase_with_bio_auth".localized
        }
    }
}


protocol FeedIMSDKManagerDelegate: AnyObject {
    /// 跳转个人主页
    func didClickHomePage(userId: Int, username: String?, nickname: String?, shouldShowTab: Bool, isFromReactionList: Bool, isTeam: Bool)
    /// 密码弹窗
    func didShowPin(type: ShowPinType, completion: ((String) -> Void)?, cancel: EmptyClosure?, needDisplayError: Bool)
    /// 跳转小程序
    func didOpenMiniProgram(appId: String, path: String?)
    /// deeplink
    func didShowDeeplink(urlString: String)
    /// 发布动态跳转，获取发布动态进度
    func didChangeCreateFeedProgressStatus(status: PostProgressStatus)
    /// 扫码跳转
    func didClickScanQR()
    /// 附近的人跳转
    func didClickNearbyPeople()
    /// 通讯录跳转
    func didClickContacts()
}

class FeedIMSDKManager: NSObject, NIMLoginManagerDelegate {
    
    static let shared = FeedIMSDKManager()
    
    weak var delegate: FeedIMSDKManagerDelegate?

    var param: FeedIMLoginParam!
    
    func initSDK(_ param: FeedIMLoginParam, delegate: FeedIMSDKManagerDelegate?){
        self.delegate = delegate
        self.param = param
        
        setupLokalise()
        
        AppEnvironment.setup {
            
        }
        
        initNIM()
        setupIQKeyboardManager()
        DependencyContainer.shared.register(AppDependency())
        TSNavigationController.initializeNavigationBar()
        
    }
    
    
    private func initNIM(){
        NIMSDKManager.shared.setup(self, currentUser: AppEnvironment.current.currentUser)
    }
    
    func setupIQKeyboardManager() {
        TSKeyboardToolbar.share.configureKeyboard()
        TSKeyboardToolbar.share.keyboardStopNotice()
    }
    
    
    func setupLokalise() {
        LocalizationManager.applyAppLanguage()
        
        Lokalise.shared.setProjectID(self.param.lokaliseProjectID, token: self.param.lokaliseSDKToken)
        Lokalise.shared.swizzleMainBundle()
        
#if DEBUG
        Lokalise.shared.localizationType = LokaliseLocalizationType.prerelease
        TSRootViewController.share.lastLocalizationType = Lokalise.shared.localizationType.rawValue
#else
        Lokalise.shared.localizationType = LokaliseLocalizationType.release
#endif
        
        checkLokaliseUpdate()
    }
    func checkLokaliseUpdate() {
        Lokalise.shared.checkForUpdates { (updated, error) in
            LogManager.Log("Lokalise: Updated \(updated)\nError: \(String(describing: error))", loggingType: .others)
        }
    }
}
