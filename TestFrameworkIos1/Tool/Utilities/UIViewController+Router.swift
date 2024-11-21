//
//  UIViewController+Router.swift
//  Yippi
//
//  Created by Francis Yeap on 5/2/19.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import Foundation
import Contacts
import UIKit

extension UIViewController {
    
    func askPermission(title: String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "settings".localized, style: UIAlertAction.Style.default, handler: { action in
            let url = URL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url!) {
                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @discardableResult
    func presentAuthentication(isDismissBtnHidden: Bool, isGuestBtnHidden: Bool) -> TSNavigationController {
//        miniProgramExecutor.client?.closeCurrentApplet(true)
//        let vc = OnboardingLandingViewController()
//        //vc.showCloseButton()
        let navVC = TSNavigationController(rootViewController: UIViewController(), availableOrientations: .portrait)
//        guard !(UIApplication.topViewController() is OnboardingLandingViewController || UIApplication.topViewController() is UIAlertController) else {
//            return navVC
//        }
//        // Hide this for now
////        DispatchQueue.main.async {
////            UIApplication.topViewController()?.present(navVC.fullScreenRepresentation, animated: true, completion: nil)
////        }
        return navVC
        
    }
    
    
    func predownloadAllStickers() {
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        YippiAPI.shared.getStickerListV2(userId: "\(userID)") { (data, error) in
            guard let dataDictionary = data, let bundles = dataDictionary["data"] else {
                return
            }
            let reversedBundles = bundles.reversed()
            let stickerManager = StickerManager.shared
            let group = DispatchGroup()

            reversedBundles.forEach({ (bundle) in
                if stickerManager.isBundleDownloaded("\(bundle.bundleID)") == false {
                    group.enter()
                    stickerManager.downloadSticker(for: "\(bundle.bundleID)") {
                        group.leave()
                    } onError: { _ in
                        
                    }
                }
            })

            // save the bundle again with the correct order
            group.notify(queue: DispatchQueue.global()) {
                var bundlesToStore = [Dictionary<String, String>]()
                reversedBundles.forEach { (bundle) in
                    var bundleDictionary = Dictionary<String, String>()
                    bundleDictionary["bundle_id"] = "\(bundle.bundleID)"
                    bundleDictionary["bundle_icon"] = bundle.bundleIcon
                    bundleDictionary["bundle_name"] = bundle.bundleName
                    bundleDictionary["uid"] = "\(userID)"
                    bundleDictionary["userId"] = "\(userID)"
                    bundlesToStore.append(bundleDictionary)
                }
                stickerManager.saveDownloadedStickerBundle(bundlesToStore)
            }
        }
    }
        
    func presentFromLandingToMain(completion: EmptyClosure? = nil) {
//        TSUserNetworkingManager().getCurrentUserInfo { [weak self] (model, _, status) in
////            LaunchManager.shared.run()
//
//            self?.predownloadAllStickers()
//            // tabbar has been added as child vc
//            TSRootViewController.share.dismiss(animated: false, completion: nil)
//            if TSRootViewController.share.currentShowViewcontroller == TSRootViewController.share.tabbarVC {
//                if let model = model, model.country != "CN" {
//                    //TSRootViewController.share.tabbarVC?.selectedIndex = 4
//                }
//                //TSRootViewController.share.tabbarVC?.homepageViewController.updateModel()
//            } else {
//                // first time showing tabbar
//                TSRootViewController.share.show(childViewController: .resetTabbar)
//            }
//        }
    }
    //IM打开通讯录页面
    func handlesShowContacts(isSignUp: Bool = false) {
        TSUtil.checkAuthorizeStatusByType(type: .contacts, viewController: self, completion: {
            DispatchQueue.main.async {
//                let vc = ContactViewController()
//                vc.isSignUp = isSignUp
//                let vc = ContactMainListViewController()
//                if isSignUp {
//                    //注册打开通讯录页面
//                    vc.contactType = .signUpContact
//                }
//                self.heroPush(vc)
            }
        })
    }
}
