//  TSViewController+Navigator.swift
//  Yippi
//
//  Created by francis on 08/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import TZImagePickerController
import Combine
import UIKit
import NIMSDK

private var cancellables = Set<AnyCancellable>()

enum ErrorFunctionThrowsError: Error {
    case error
}

extension UIViewController {
    func showSubscriptionStatusHomePage() {
//        SubscriptionStatusRequestType().execute { [weak self] (responseModel) in
//            guard let self = self else { return }
//            guard let model = responseModel else { return }
//            
//            let vc = SubscriptionHomePageViewController(model: model)
//            self.navigationController?.pushViewController(vc, animated: true)
//            
//        } onError: { (error) in
//            print(error.localizedDescription)
//        }
    }
    
    func startKycFlow() {
//        let loading = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
//        loading.show()
//        
//        TSUserNetworkingManager().getUserCertificate { [weak self] (certificateObject) in
//            defer { loading.dismiss() }
//            
//            guard let self = self else { return }
//            guard let certificateObject = certificateObject else {
//                self.showError(message: "network_problem".localized)
//                return
//            }
//            
//            let status = certificateObject.status
//            
//            switch status {
//                
//            case 0, 5:
//                DispatchQueue.main.async {
//                    let next = UIStoryboard(name: "Verify", bundle: Bundle.main).instantiateViewController(withIdentifier: "verify_thankyou") as! VerifyThankyouViewController
//                    next.configure(with: "verify_process_title".localized, text: "verify_process_text".localized)
//                    self.present(TSNavigationController(rootViewController: next).fullScreenRepresentation, animated: true, completion: nil)
//                }
//            case 1:
//                DispatchQueue.main.async {
//                    let next = UIStoryboard(name: "Verify", bundle: Bundle.main).instantiateViewController(withIdentifier: "verify_thankyou") as! VerifyThankyouViewController
//                    next.configure()
//                    self.present(TSNavigationController(rootViewController: next).fullScreenRepresentation, animated: true, completion: nil)
//                }
//            case 4:
//                DispatchQueue.main.async {
//                    let next = UIStoryboard(name: "Verify", bundle: Bundle.main).instantiateViewController(withIdentifier: "verify_thankyou") as! VerifyThankyouViewController
//                    next.configure(with: "verify_request_bank_title".localized, text: "verify_request_bank_text".localized, certDetails: certificateObject)
//                    self.present(TSNavigationController(rootViewController: next).fullScreenRepresentation, animated: true, completion: nil)
//                }
//                
//            case 6:
//                DispatchQueue.main.async {
//                    let vc = BankVerificationViewController()
//                    self.navigationController?.pushViewController(vc, animated: true)
//                }
//            default:
//                DispatchQueue.main.async {
//                    let verifyVC = VerificationGetStartedViewController()
//                    self.present(TSNavigationController(rootViewController: verifyVC).fullScreenRepresentation, animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    func startPinFlow() {
//        let vc = SecurityPinOnboard(type: .setup)
//        let nav = TSNavigationController(rootViewController: vc)
//        self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    private func navigatePin() {
//        guard let user = TSCurrentUserInfo.share._userInfo else { return }
//        if user.phone.orEmpty.isEmpty {
//            let controller = PhoneNumberOnboardController()
//            controller.onPhoneNumberSet = { [weak self] in
//                controller.dismiss(animated: true)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self?.startPinFlow()
//                }
//            }
//            self.heroPush(controller)
//        } else {
//            self.startPinFlow()
//        }
    }
    
    @objc func showShortVideoPickerVC() {
        DispatchQueue.main.async
        {
            guard let imagePickerVC = TZImagePickerController(maxImagesCount: 1, columnNumber: 4, delegate: self as? TZImagePickerControllerDelegate, pushPhotoPickerVc: true) else {
                return
            }
            imagePickerVC.maxEditVideoTime = 60 * 5
            imagePickerVC.timeout = 60 * 3
            imagePickerVC.isSelectOriginalPhoto = false
            imagePickerVC.allowTakePicture = false
            imagePickerVC.allowTakeVideo = false
            imagePickerVC.allowPickingVideo = true
            imagePickerVC.allowPickingImage = false
            imagePickerVC.allowPickingGif = false
            imagePickerVC.allowPickingMultipleVideo = false
            imagePickerVC.sortAscendingByModificationDate = false
            imagePickerVC.navigationBar.barTintColor = UIColor.white
            imagePickerVC.photoSelImage =  UIImage.set_image(named: "ic_rl_checkbox_selected")
            imagePickerVC.previewSelectBtnSelImage = UIImage.set_image(named: "ic_rl_checkbox_selected")
            imagePickerVC.preferredLanguage = LocalizationManager.getCurrentLanguage()
            var dic = [NSAttributedString.Key: Any]()
            dic[NSAttributedString.Key.foregroundColor] = UIColor.black
            imagePickerVC.navigationBar.titleTextAttributes = dic
            self.present(imagePickerVC.fullScreenRepresentation, animated: true)
        }
    }
    
    @objc func showCameraVC(_ enableMultiplePhoto: Bool = false,
                            selectedAssets: [PHAsset] = [],
                            selectedImages: [Any] = [],
                            allowEdit: Bool = false,
                            onSelectPhoto: CameraHandler? = nil,
                            onDismiss: EmptyClosure? = nil) {
        DispatchQueue.main.async {
            let camera = CameraViewController()
            camera.enableMultiplePhoto = enableMultiplePhoto
            camera.selectedAsset = selectedAssets
            camera.selectedImage = selectedImages
            camera.onSelectPhoto = onSelectPhoto
            camera.onDismiss = onDismiss
            camera.allowEdit = allowEdit
            let nav = TSNavigationController(rootViewController: camera).fullScreenRepresentation
            self.present(nav, animated: true)
        }
    }
    
    @objc func showMiniVideoRecorder() {
        DispatchQueue.main.async {
            let nav = TSNavigationController(rootViewController: MiniVideoRecorderViewController())
            self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    func presentPopup(alert: TSAlertController, actions: [TSAlertAction] = []) {
        self.resignFirstResponder()
        
        for action in actions  {
            alert.addAction(action)
        }
        
        alert.modalPresentationStyle = .overFullScreen
        
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.fade
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeIn)
        
        if let window = self.view.window {
            window.layer.add(transition, forKey: kCATransition)
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: false, completion: nil)
        }
    }
    
    func presentLiveListView() {
//        var userInfo: UserInfoModel? = nil
//        
//        TSUserNetworkingManager().getUserInfo(userId: (CurrentUserSessionInfo?.userIdentity).orZero) { [weak self] (model, message, status) in
//            
//            if let model = model, status == true {
//                userInfo = model
//            }
//            
//            let language = UserDefaults.selectedFilterLanguage
//            let vc = LiveStarListViewController(feedId: -1, hostInfo: userInfo, isHost: false, isPortrait: true, type: .starOfTheDay, topLeftIcon: "", entryType: .homepage, selectedLanguage: language)
//            self?.present(vc.fullScreenRepresentation,
//                          animated: true,
//                          completion: nil)
//            
//        }
        
    }
    
    func pushToFeedDetail(feedId: Int, isTapMore: Bool, isClickCommentButton: Bool, isVideoFeed:Bool = true, isDeepLink: Bool = false, feedType: FeedListType = .recommend, afterTime: String = "", onToolbarUpdated: onToolbarUpdate?) {
        let detailVC = FeedInfoDetailViewController(feedId: feedId, isTapMore: isTapMore, isClickCommentButton: isClickCommentButton, isVideoFeed: isVideoFeed, onToolbarUpdated: onToolbarUpdated)
        detailVC.type = feedType
        detailVC.afterTime = afterTime
        if #available(iOS 11, *), isDeepLink == false {
            if self is UINavigationController {
                (self as! UINavigationController).pushViewController(detailVC, animated: true)
                return
            } else if let navigation = self.navigationController {
                navigation.pushViewController(detailVC, animated: true)
                return
            }
        }
        detailVC.setCloseButton(backImage: true)
        self.present(TSNavigationController(rootViewController: detailVC).fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func navigateLive(data: LiveEntityModel, isSubscriptionGroup: Bool = false) {
//         if isSubscriptionGroup {
//             let livePlayer = YippiLivePlayerViewController(feedId: data.feedId.intValue, entry: .live(object: data))
//             livePlayer.isSubscriptionGroup = isSubscriptionGroup
//             let nav = TSNavigationController(rootViewController: livePlayer, availableOrientations: [.portrait, .landscape]).build({ (nav) in
//                 nav.setNavigationBarHidden(true, animated: false)
//             })
//             DispatchQueue.main.async {
//                 self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
//             }
//         } else {
//             let livePlayer = TSNavigationController(rootViewController: LiveHorizontalPageController(entry: .live(object: data)), availableOrientations: [.portrait, .landscape]).build({ (nav) in
//                 nav.setNavigationBarHidden(true, animated: false)
//             }).fullScreenRepresentation
//             
//             DispatchQueue.main.async {
//                 self.present(livePlayer, animated: true, completion: nil)
//             }
//         }
     }
     
     func navigateLive(data: [LiveEntityModel], index: Int) {
         
//         let configs = data.compactMap {
//             return YippiLivePlayerViewController.EntryType.live(object: $0)
//         }
//         
//         self.navigation(navigateType: .navigateLiveList(liveConfigs: configs, index: index))
     }
     
     @discardableResult
    func navigateLive(feedId: Int, isDeepLink: Bool = false, isSubscriptionGroup: Bool = false) -> Future<Bool, Error> {
        return Future() { promise in
            FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (feedModel, failureMessage, status, networkResult) in
                guard let listModel = feedModel, status == true else {
                    if failureMessage != nil {
                        self?.showError(message: "review_dynamic_deleted".localized)
                    }
                    promise(.failure(ErrorFunctionThrowsError.error))
                    return
                }
                
                let model = FeedListCellModel(feedListModel: listModel)
                
                DispatchQueue.main.async {
                    if let liveModel = model.liveModel, liveModel.status != YPLiveStatus.finishProcess.rawValue {
                        if isSubscriptionGroup {
//                            let livePlayer = YippiLivePlayerViewController(feedId: model.idindex, entry: .moment(object: model))
//                            livePlayer.isSubscriptionGroup = isSubscriptionGroup
//                            let nav = TSNavigationController(rootViewController: livePlayer, availableOrientations: [.portrait, .landscape]).build({ (nav) in
//                                nav.setNavigationBarHidden(true, animated: false)
//                            })
//                            self?.present(nav.fullScreenRepresentation, animated: true, completion: nil)
                        } else {
//                            let livePlayer = LiveHorizontalPageController(entry: .moment(object: model))
//                            let nav = TSNavigationController(rootViewController: livePlayer, availableOrientations: [.portrait, .landscape]).build({ (nav) in
//                                nav.setNavigationBarHidden(true, animated: false)
//                            })
//                            self?.present(nav.fullScreenRepresentation, animated: true, completion: nil)
                        }
                    } else if model.videoType == 2 {
                          self?.navigation(navigateType: .miniVideo(feedListType: .detail(feedId: model.idindex), currentVideo: nil, onToolbarUpdated: nil))
                    }
                                  // MARK: No need for now, need sync with android
             //                     else if model.feedType == .picture {
             //                         if let imageId = model.pictures.first?.file {
                    //                             self?.navigation(navigateType: .innerFeedSingle(feedId: model.idindex, placeholderImage: nil, transitionId: UUID().uuidString, imageId: imageId))
                    //                         }
                    //                     }
                    else {
                        self?.pushToFeedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, isDeepLink: isDeepLink, onToolbarUpdated: nil)
                    }
                    promise(.success(true))
                }
            }
            
        }
    }

    @objc func presentVideoCall(notification: NSNotification) {
        guard let caller = notification.userInfo?["invitor"] as? String ,let isFromGroup = notification.userInfo?["isFromGroup"] as? Bool, let channelId = notification.userInfo?["channelId"] as? String, let channelName = notification.userInfo?["channelName"] as? String, let requestId = notification.userInfo?["requestId"] as? String else { return }
        presentCalls(types: NIMSignalingChannelType.video, caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
    }
    
    @objc func presentAudioCall(notification: NSNotification) {
        guard let caller = notification.userInfo?["invitor"] as? String ,let isFromGroup = notification.userInfo?["isFromGroup"] as? Bool, let channelId = notification.userInfo?["channelId"] as? String, let channelName = notification.userInfo?["channelName"] as? String, let requestId = notification.userInfo?["requestId"] as? String else { return }
        presentCalls(types: NIMSignalingChannelType.audio, caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
        
    }
    //群呼
    @objc func presentTeamCall(notification: NSNotification){
        
        if VideoPlayer.shared.isPlaying { VideoPlayer.shared.stop() }
        let topVC = TSViewController.topMostController
        let teamId = notification.userInfo?["teamId"] as? String
        let members = notification.userInfo?["members"] as? [String]
        guard let caller = notification.userInfo?["invitor"] as? String ,let isFromGroup = notification.userInfo?["isFromGroup"] as? Bool, let channelId = notification.userInfo?["channelId"] as? String, let channelName = notification.userInfo?["channelName"] as? String, let requestId = notification.userInfo?["requestId"] as? String  else { return }
        let channelInfo = IMTeamMeetingCalleeInfo()
        channelInfo.requestId = requestId
        channelInfo.channelId = channelId
        channelInfo.channelName = channelName
        channelInfo.caller = caller
        channelInfo.teamId = teamId ?? ""
        channelInfo.members = members ?? []
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            DispatchQueue.main.async {
                let vc = IMTeamMeetingViewController(channelInfo: channelInfo)
                topVC?.present(vc.fullScreenRepresentation, animated: true, completion: nil)
            }
        })
        
        
    }
    
    private func presentCalls(types: NIMSignalingChannelType, caller: String, channelId: String, channelName: String, requestId: String) {
        if VideoPlayer.shared.isPlaying { VideoPlayer.shared.stop() }
        
        let topVC = TSViewController.topMostController
        TSUtil.checkAuthorizeStatusByType(type: .videoCall, viewController: self, completion: {
            switch (types) {
            case .video:
                DispatchQueue.main.async {
                    let vc = VideoCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
                    vc.callInfo.callType = .video
                    topVC?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
                }
                
            case .audio:
                DispatchQueue.main.async {
                    let vc = VideoCallController(caller: caller, channelId: channelId, channelName: channelName, requestId: requestId)
                    vc.callInfo.callType = .audio
                    topVC?.present(TSNavigationController(rootViewController: vc).fullScreenRepresentation, animated: true, completion: nil)
                }
                
            default: break
            }
        })
        
        
        
    }
    
    private func pushToMiniVideo(_ video: FeedListCellModel?, type: FeedListType, onToolbarUpdate: onToolbarUpdate?) {
        var videos: [FeedListCellModel] = []
        if let video = video {
            videos = [video]
        }
        let player = MiniVideoPageViewController(type: type, videos: videos, focus: 0, onToolbarUpdate: onToolbarUpdate, tagVoucher: video?.tagVoucher)
        self.present(TSNavigationController(rootViewController: player).fullScreenRepresentation,
                     animated: true,
                     completion: nil)
    }
    
    
    func navigation(navigateType: Navigator) {
        switch navigateType {
        case .navigatePin:
            self.navigatePin()
            
        case let .navigateLive(feedId):
            self.navigateLive(feedId: feedId)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let _):
                        self?.navigationController?.endLoading()
                        UIViewController.showBottomFloatingToast(with: "please_retry_option".localized, desc: "")
                        
                    case .finished: break
                    }
                    
                    cancellables.removeAll()
                }, receiveValue: { [weak self] success in
                    self?.navigationController?.endLoading()
                }).store(in: &cancellables)
            
        case let .feedDetail(feedId, isTapMore, isClickCommentButton, isVideoFeed, feedType, afterTime, onToolbarUpdated):
            pushToFeedDetail(feedId: feedId, isTapMore: isTapMore, isClickCommentButton: isClickCommentButton, isVideoFeed: isVideoFeed, feedType: feedType, afterTime: afterTime, onToolbarUpdated: onToolbarUpdated)
            
        case let .innerFeedSingle(feedId, placeholderImage, transitionId, imageId)://, onToolbarUpdated):
            let dest = FeedDetailImagePageController(config: .single(feedId: feedId, transitionId: transitionId, placeholderImage: placeholderImage, imageId: imageId), completeHandler: nil, onToolbarUpdated: nil)
            dest.hero.isEnabled = true
            let nav = TSNavigationController(rootViewController: dest, availableOrientations: .portrait).fullScreenRepresentation
            nav.hero.isEnabled = true
            
            self.present(nav, animated: true, completion: nil)
            
        case let .innerFeedList(data, mediaType, listType, tappedIndex, placeholderImage, transitionId, isClickComment, isTranslateText, completeHandler, onToolbarUpdated, translateHandler,  callback):
            let dest = FeedDetailImagePageController(config: .list(data: data, tappedIndex: tappedIndex, mediaType: .image, listType: listType, transitionId: transitionId, placeholderImage: placeholderImage, isClickComment: isClickComment, isTranslateText: isTranslateText), completeHandler: completeHandler, onToolbarUpdated: onToolbarUpdated, translateHandler: translateHandler)
            dest.onRefresh = callback
            dest.hero.isEnabled = true
            let nav = TSNavigationController(rootViewController: dest, availableOrientations: .portrait).fullScreenRepresentation
            nav.hero.isEnabled = true
            
            self.present(nav, animated: true, completion: nil)
            
        case .loadingOverlay:
            self.navigationController?.loadingOverlay()
            
        case .endLoadingOverlay:
            self.navigationController?.endLoading()
            
        case let .pushView(viewController)://, onToolbarUpdated):
            if let nav = self.navigationController {
                nav.pushViewController(viewController, animated: true)
            } else {
                let nav = TSNavigationController(rootViewController: viewController)
                nav.setCloseButton(backImage: true)
                self.present(nav.fullScreenRepresentation,
                             animated: true,
                             completion: nil)
            }
            
        case let .presentView(viewController)://, onToolbarUpdated):
            self.present(viewController, animated: true, completion: nil)
            // By Kit Foong (Use Navigation Controller instead of UIViewController)
            //            let nav = TSNavigationController(rootViewController: viewController).fullScreenRepresentation
            //            self.present(nav, animated: true, completion: nil)
            
        case let .pushURL(url):
            TSUtil.pushURLDetail(url: url, currentVC: self)
            
        case let .miniVideo(feedListType, currentVideo, onToolbarUpdated):
            self.pushToMiniVideo(currentVideo, type: feedListType, onToolbarUpdate: onToolbarUpdated)
//        case .navigateLiveList(liveConfigs: let liveConfigs, index: let index):
//            break
        }
    }
    
    func navigateToSingleDetail(_ feedId: Int) {
        
        self.showLoading()
        
        FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (model, errorMsg, status, networkResult) in
            
            defer {
                self?.dismissLoading()
            }
            
            guard let model = model, status else {
                self?.showTopFloatingToast(with: errorMsg.orEmpty, desc: "")
                return
            }
            
            let cellModel = FeedListCellModel(feedListModel: model)
            
            switch cellModel.feedType {
            case .live:
                if let liveModel = model.liveModel, liveModel.status != YPLiveStatus.finishProcess.rawValue {
//                    let player = YippiLivePlayerViewController(feedId: feedId, entry: .moment(object: cellModel))
//                    self?.navigation(navigateType: .presentView(viewController: player.fullScreenRepresentation))
                } else {
                    let detail = FeedInfoDetailViewController(feedId: feedId, onToolbarUpdated: nil)
                    self?.navigation(navigateType: .pushView(viewController: detail))
                }
                
            case .miniVideo:
                let player = MiniVideoPageViewController(type: .detail(feedId: feedId), videos: [], focus: 0, onToolbarUpdate: nil, tagVoucher: cellModel.tagVoucher)
                self?.navigation(navigateType: .presentView(viewController: player.fullScreenRepresentation))
                
            case .picture:
//                if let imageId = cellModel.pictures.first?.file {
//                    self?.navigation(navigateType: .innerFeedSingle(feedId: feedId, placeholderImage: nil, transitionId: nil, imageId: imageId))
//                }
                self?.pushToFeedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, onToolbarUpdated: nil)
            default:
                self?.pushToFeedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, onToolbarUpdated: nil)
            }
        }
    }
}

// MARK: 二维码
extension UIViewController {
//    func presentScanQRViewController(tabType: RewardsLinkQrTabType = .scan, fromMP: Bool = false, gintelProduct: GintellPackageModel? = nil, onSuccessPurchase: ((Int) -> Void)? = nil, isPop: Bool = false) {
//        /// 扫一扫加好友
//        let vc = RewardsLinkQRCodeViewController()
//        vc.qrContent =  CurrentUserSessionInfo?.username ?? ""
//        vc.avatarString = (CurrentUserSessionInfo?.avatarUrl).orEmpty
//        vc.nameString = CurrentUserSessionInfo?.name ?? ""
//        vc.introString = CurrentUserSessionInfo?.bio ?? ""
//        vc.uidStirng = CurrentUserSessionInfo?.userIdentity ?? 0
//        vc.tabType = tabType
//        vc.fromMP = fromMP
//        vc.gintelProduct = gintelProduct
//        vc.isPop = isPop
//        // vc.qrType = self.qrType
//        vc.onSuccessPurchase = { [weak self] seconds in
//            onSuccessPurchase?(seconds)
//        }
//        vc.onCapture = { [weak self] result in
//            guard let self = self else { return }
//            let loader = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
//            
//            switch result {
//            case let .miniProgram(program):
//                break
//            case let .success(entry, content):
//                switch entry {
//                case .group:
//                    loader.show()
//                    NIMSDK.shared().teamManager.fetchTeamInfo(content) { (error, team) in
//                        DispatchQueue.main.async {
//                            if let error = error {
//                                loader.dismiss()
//                                self.showError(message: error.localizedDescription)
//                                return
//                            }
//                            loader.dismiss()
//                            let imJoin = IMJionTeamViewController(team: team!)
//                            
//                            if let nav = self.navigationController {
//                                nav.pushViewController(imJoin, animated: true)
//                            } else {
//                                vc.heroPush(imJoin)
//                            }
//                        }
//                    }
//                case .user:
//                    if let nav = self.navigationController {
//                        nav.pushViewController(HomePageViewController(userId: 0, username: content), animated: true)
//                    } else {
//                        vc.heroPush(HomePageViewController(userId: 0, username: content))
//                    }
//                case .transfer:
//                    let username = TSCurrentUserInfo.share.userInfo?.username
//                    let targetUsername = content
//                    self.startTransaction(on: vc, user: username.orEmpty, toUser: targetUsername, asPopup: true)
//                    break
//                case .web:
//                    let qrLogin = QRLoginConfirmationVC(content: content)
//                    qrLogin.modalPresentationStyle = .fullScreen
//                    if let nav = self.navigationController {
//                        self.present(qrLogin, animated: true, completion: nil)
//                    } else {
//                        vc.present(qrLogin, animated: true, completion: nil)
//                    }
//                case .merchant:
//                    let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "checkoutVoucher") as! CheckoutVoucherViewController
//                    vc.branchId = content
//                    if let nav = self.navigationController {
//                        nav.pushViewController(vc, animated: true)
//                    } else {
//                        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//                        UIApplication.topViewController()?.heroPush(nav)
//                    }
//                    break
//                }
//            case .fail(let message):
//                //self?.showError(message: message)
//                break
//            }
//        }
//        
//        if let nav = self.navigationController {
//            nav.pushViewController(vc, animated: true)
//        } else {
//            let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//            UIApplication.topViewController()?.heroPush(nav)
//        }
//    }
    
//    func navigateScreenAfterScan(on vc: UIViewController, result: CaptureResult) {
//        let loader = TSIndicatorWindowTop(state: .loading, title: "loading".localized)
//        
//        switch result {
//        case let .miniProgram(program):
//            break
//        case let .success(entry, content):
//            switch entry {
//            case .group:
//                loader.show()
//                NIMSDK.shared().teamManager.fetchTeamInfo(content) { (error, team) in
//                    DispatchQueue.main.async {
//                        if let error = error {
//                            loader.dismiss()
//                            self.showError(message: error.localizedDescription)
//                            return
//                        }
//                        loader.dismiss()
//                        let imJoin = IMJionTeamViewController(team: team!)
//                        
//                        if let nav = self.navigationController {
//                            nav.pushViewController(imJoin, animated: true)
//                        } else {
//                            vc.heroPush(imJoin)
//                        }
//                    }
//                }
//            case .user:
//                if let nav = self.navigationController {
//                    nav.pushViewController(HomePageViewController(userId: 0, username: content), animated: true)
//                } else {
//                    vc.heroPush(HomePageViewController(userId: 0, username: content))
//                }
//            case .transfer:
//                let username = TSCurrentUserInfo.share.userInfo?.username
//                let targetUsername = content
//                self.startTransaction(on: vc, user: username.orEmpty, toUser: targetUsername, asPopup: true)
//                break
//            case .web:
//                let qrLogin = QRLoginConfirmationVC(content: content)
//                qrLogin.modalPresentationStyle = .fullScreen
//                if let nav = self.navigationController {
//                    self.present(qrLogin, animated: true, completion: nil)
//                } else {
//                    vc.present(qrLogin, animated: true, completion: nil)
//                }
//            case .merchant:
//                let vc = UIStoryboard(name: "Voucher", bundle: Bundle.main).instantiateViewController(withIdentifier: "checkoutVoucher") as! CheckoutVoucherViewController
//                vc.branchId = content
//                self.heroPush(TSNavigationController(rootViewController: vc).fullScreenRepresentation)
//            }
//        case .fail(let message):
//            //self?.showError(message: message)
//            break
//        }
//    }
    
//    func startTransaction(on vc: UIViewController, user: String, toUser: String, numberOfMember: Int = 1, asPopup: Bool = true) {
//        let destination = RedPacketViewController(
//            transactionType: .yippsTransfer,
//            fromUser: user,
//            toUser: toUser,
//            numberOfMember: numberOfMember,
//            completion: { [weak self] (_, _, message) in
//                guard let self = self else { return }
//                self.navigationController?.showSuccess(message: message)
//                self.navigationController?.popToRootViewController(animated: true)
//            })
//        if asPopup == true {
//            vc.heroPush(TSNavigationController(rootViewController: destination).fullScreenRepresentation)
//        } else {
//            vc.navigationController?.pushViewController(destination, animated: true)
//        }
//    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

enum Navigator {
    case navigatePin
    case navigateLive(feedId: Int)
    //case navigateLiveList(liveConfigs: [YippiLivePlayerViewController.EntryType], index: Int)
    case feedDetail(feedId: Int, isTapMore: Bool, isClickCommentButton: Bool, isVideoFeed: Bool, feedType: FeedListType = .recommend, afterTime: String = "", onToolbarUpdated: onToolbarUpdate?)
    case innerFeedSingle(feedId: Int, placeholderImage: UIImage?, transitionId: String?, imageId: Int)//, onToolbarUpdated: ((FeedListCellModel) -> Void)?)
    case innerFeedList(data: [FeedListCellModel], mediaType: FeedMediaType, listType: FeedListType,
                       tappedIndex: Int, placeholderImage: UIImage?, transitionId: String?, isClickComment: Bool = false, isTranslateText: Bool = false,
                       completeHandler: ((Int, String) -> Void)?, onToolbarUpdated: onToolbarUpdate? = nil, translateHandler: ((Bool) -> Void)? = nil, callback: EmptyClosure? = nil)
    case miniVideo(feedListType: FeedListType, currentVideo: FeedListCellModel?, onToolbarUpdated: onToolbarUpdate?)
    case loadingOverlay
    case endLoadingOverlay
    case presentView(viewController: UIViewController)//, onToolbarUpdated: ((FeedListCellModel) -> Void)?)
    case pushView(viewController: UIViewController)//, onToolbarUpdated: ((FeedListCellModel) -> Void)?)
    case pushURL(url: URL)
}
