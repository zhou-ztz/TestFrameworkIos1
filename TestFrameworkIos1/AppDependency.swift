//
//  AppDependency.swift
//  Yippi
//
//  Created by Yong Tze Ling on 16/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

import NIMSDK
import Photos
import Combine
//import NIMPrivate

class AppDependency: CoreDependencyType {
    func resolveViewControllerFactory() -> ViewControllerFactoryType {
        return ViewControllerFactory()
    }
    
    func resolveUtilityFactory() -> UtilityFactoryType {
        return UtilityFactory()
    }
    
    func resolvePopupDialogFactory() -> PopupDialogFactoryType {
        return PopupDialogFactory()
    }
    
    func resolveViewFactory() -> ViewFactoryType {
        return ViewFactory()
    }

}

class ViewFactory: ViewFactoryType {

    func makeSpeechView(height: CGFloat, callBackHandler: DidEnterSpeech?) -> UIView {
        
        let view: UIView = UIView().configure {
            $0.size = CGSize(width: UIScreen.main.bounds.width, height: height)
            $0.backgroundColor = .green
        }
        
        return view
    }
    
    func makeInputContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool,  _ isCamera: Bool, _ assets: [PHAsset]?, _ isFullImage: Bool) -> Void) ->  UIView {
        let view = InputPictrueContainer(frame: frame, callBackHandler: callBackHandler)
        
        return view
    }
    func makeInputFileContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool, _ url: URL?) -> Void) ->  UIView {
        let view = InputFileContainer(frame: frame, callBackHandler: callBackHandler)
        
        return view
    }
    func makeInputLocalContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool, _ title: String, _ coordinate: CLLocationCoordinate2D) -> Void) ->  UIView {
        let view = InputLocalContainer(frame: frame, callBackHandler: callBackHandler)

        return view
    }
    
    func makeTopIndicatorView(message: String) -> Void{
        let vc = UIApplication.shared.keyWindow?.rootViewController as! UIViewController
        vc.showTopIndicator(status: .faild, message)
    }
    
    func makeEmptySearchChatPlaceholder() -> UIView {
        let view = Placeholder()
        view.set(.empty)
        return view
    }
    
    func makeEmptyChatPlaceholder() -> UIView {
        let view = Placeholder()
        view.set(.emptyChat)
        return view
    }
    
    func makeNetworkErrorPlaceholder() -> UIView {
        let view = Placeholder()
        view.set(.network)
        return view
    }
}


@objc public protocol ViewControllerProtocol: NSObjectProtocol { }
extension ViewControllerProtocol where Self: UIViewController { }

@objc public protocol SendEggInChatViewControllerType: ViewControllerProtocol {}
@objc public protocol EggDetailViewControllerType: ViewControllerProtocol {}
@objc public protocol BeautyCameraViewControllerType: ViewControllerProtocol {}

class ViewControllerFactory: ViewControllerFactoryType {
    func makeBeautyCameraViewController(completion: @escaping CameraHandler) -> UIViewController {
        let camera = CameraViewController()
        camera.allowPickingVideo = true
        camera.onSelectPhoto = completion
        camera.enableMultiplePhoto = true
        return camera.fullScreenRepresentation
    }

    func makeEggDetailViewController(info: ClaimEggResponse, isSender: Bool, isGroup: Bool) -> UIViewController {
        let vc = UIStoryboard(name: "Egg", bundle: Bundle.main).instantiateViewController(withIdentifier: "egg_detail") as! EggDetailViewController
        vc.info = info
        vc.isSender = isSender
        vc.isGroup = isGroup
        return vc
    }
    
    func makeSendEggInChatViewController(typePersonal: Bool, fromUser: String, toUser: String, numberOfMember: Int, completion: TransactionFinishClosure?) -> UIViewController {
        let vc = RedPacketViewController(transactionType: (typePersonal == true ? .personal : .group),
                                             fromUser: fromUser,
                                             toUser: toUser,
                                             numberOfMember:numberOfMember,
                                             completion:completion)
        
//        let vc = YPTransactionViewController(transactionType: (typePersonal == true ? .personal : .group),
//                                             fromUser: fromUser,
//                                             toUser: toUser,
//                                             numberOfMember:numberOfMember,
//                                             completion:completion)
        let nav = TSNavigationController(rootViewController: vc)
        return nav
    }
    
    func makeRewardViewController(recipient: Recipient, rewardType: RewardType) -> UIViewController {
        return UIViewController()
    }
    
    func makeUserHomepageViewController(userId: Int, userName: String) -> UIViewController {
        return UIViewController()//HomePageViewController(userId: userId, username: userName)
    }
    
    func makeUserHomepageViewControllerFromChatroom(userId: Int, userName: String, isTeam: Bool) -> UIViewController {
        return UIViewController()//HomePageViewController(userId: userId, username: userName, isTeam: isTeam)
    }
    
    func makeTeamCardViewController(teamId: String) -> UIViewController {
        return GroupChatDetailViewController(teamId: teamId)
//        return GroupChatDetailTableViewController(teamId: teamId)
    }
    
    func makeStickerMainViewController() -> UIViewController {
        return StickerMainViewController()
    }
    
    func makeCustomerStickerViewController(stickerId: String) -> UIViewController {
        
        let vc = CustomerStickerViewController(sticker: stickerId)
        
        return vc
    }
    
    func makeSpeechTyperViewController(height: CGFloat = 0, callBackHandler: DidEnterSpeech?) {
        let vc = SpeechTyperViewController()
        let tDelegate = TransitioningDelegate(height: height)
        vc.closure = callBackHandler
        vc.collapseFrameHeight = height
        vc.transitionDelegate = tDelegate
        vc.transitioningDelegate = tDelegate
        vc.modalPresentationStyle = .custom
        
        PopupWindowManager.shared.changeKeyWindow(rootViewController: vc, height: height)
    }
    
    func dimissSpeechTyperViewController() {
        PopupWindowManager.shared.changeKeyWindow(rootViewController: nil, animated: false)
    }

    func makeMyStickerViewController() -> UIViewController {
        return MyStickersViewController()
    }
    
    func makeStickerDetailViewController(bundleId: String) -> UIViewController {
        return StickerDetailViewController(bundleId: bundleId)
    }
    
    func makeFeedDetail(feedId: Int) -> UIViewController {
//        return UIViewController()
        return FeedInfoDetailViewController(feedId: feedId, onToolbarUpdated: nil)
    }
    
    func makeContactPicker(configuration: ContactsPickerConfig, completion: (([ContactData]) -> Void)?) -> UIViewController {
        return ContactsPickerViewController(configuration: configuration, finishClosure: { (contacts) in
            completion?(contacts)
        })
    }

    func makeCreateGroupViewController(member: [String], completion: createGroupFinishBlock?) -> UIViewController {
        return CreateGroupViewController(member: member, completion: completion)
    }
    
    func makeChatMediaViewController(sessionId: String, type: NSInteger) -> UIViewController {
        let session: NIMSession = NIMSession(sessionId, type: NIMSessionType(rawValue: type)!)
        return ChatMediaViewController.init(session: session)
    }

    func makeChatMediaVideoPlayerViewController(url: String) -> UIViewController {
        return ChatMediaVideoPlayerViewController(url: url)
    }
    
    func makeNIMVideoPlayerViewController(url: String) -> UIViewController {
        return NIMChatroomplayerViewController(url: url)
    }
    
    func makeTSAlertController(url: NSURL, message: Any?, parentVC: UIViewController, title: String, messageDisplay: String, onSend: @escaping (Any?, URL?) -> Void)
    {
        let alert = TSAlertController(title: title, message: messageDisplay, style: .alert, hideCloseButton: true, animateView: false)

        let dismissAction = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel) { (_) in
            alert.dismiss()
        }

        if let message = message as? NIMMessage {
            let sendAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { (_) in
                onSend(message, nil)
                alert.dismiss()
            }

            alert.addAction(sendAction)
        } else {
            let sendAction = TSAlertAction(title: "send".localized, style: TSAlertActionStyle.theme) { (_) in
                onSend(nil, url as URL)
                alert.dismiss()
            }

            alert.addAction(sendAction)
        }

        alert.addAction(dismissAction)

        parentVC.present(alert, animated: false, completion: nil)
    }
    
    func makeIMActionListView(delegateTarget: Any, actionArray: [Any]) -> UIView {
        let view = IMActionListView(actionArray: actionArray as? [Int] ?? [])
//        if let target = delegateTarget as? ActionListDelegate {
//            view.delegate = target
//        }
        return view
    }
    
    
    func makeWebview(title: String?, link: URL) -> UIViewController {
        let vc = TSWebViewController(url: link, type: .defaultType, title: title)
        return vc
    }
    
    func makeMessageRequestListTableViewController() -> UIViewController {
        let vc = MessageRequestListTableViewController()
        return vc
    }
    
    func makeGroupNotificationTableVC() -> UIViewController {
        let vc = GroupNotificationTableVC()
        return vc
    }
    
    func makeArticleViewController (id: Int) -> UIViewController {
        let vc = UIViewController()
//        TSCurrentUserInfo.share.newsViewStatus.addViewed(newsId: id)
        return vc
    }
    
    func makeCustomerStickerDialogView(imageUrl: String, customStickerId: String, callBackHandler: @escaping(_ isCompleted: Int) -> Void) -> UIViewController{
        var isDelete = false
        var stickerList = [CustomerStickerItem]()
        StickerManager.shared.getCustomerStickerList {(stickerItems) in
            if let stickers = stickerItems {
                stickerList = stickers
                for sticker in stickers {
                    if sticker.customStickerId == customStickerId {
                        isDelete = true
                    }
                }
            }
        }
        
       // let isMaxNum = (stickerList.count >= 150 && isDelete == false) ? true : false
        let dialog = CustomerStickerPopView(frame: CGRect(x: 0, y: 0, width: 300, height: 270), imageUrl: imageUrl, isDelete: isDelete, stickerId: customStickerId, isMaxNum: false)
        let popup = TSAlertController(style: .popup(customview: dialog), animateView: false)
        popup.modalPresentationStyle = .overFullScreen
        dialog.okBtnClosure = { (index) in
            popup.dismiss()
            callBackHandler(index)
            
        }
        return popup
    }
    
    func makeCustomerStickerMaxNumDialogView(imageUrl: String, customStickerId: String, callBackHandler: @escaping(_ isCompleted: Int) -> Void) -> UIViewController{
        let dialog = CustomerStickerPopView(frame: CGRect(x: 0, y: 0, width: 300, height: 270), imageUrl: imageUrl, isDelete: false, stickerId: customStickerId, isMaxNum: true)
        let popup = TSAlertController(style: .popup(customview: dialog), animateView: false)
        popup.modalPresentationStyle = .overFullScreen
        dialog.okBtnClosure = { (index) in
            popup.dismiss()
            callBackHandler(index)
            
        }
        return popup
    }
    
    func makeCallViewController(sessionId: String, video: Bool) -> UIViewController {
        let vc =  video ? VideoCallController(callee: sessionId) : AudioCallController(callee: sessionId)
        return vc
    }
    
    func makeIMChatViewController(sessionId: String, type: Int, unread: Int, searchMessageId: String) -> UIViewController {
        let session = NIMSession(sessionId, type: NIMSessionType(rawValue: type) ?? NIMSessionType.P2P)
        let vc =  IMChatViewController(session: session, unread: unread)
        vc.searchMessageId = searchMessageId
        return vc
    }
    
    func makeNTESSessionListTableVC(member members: [UserAvatarUI], keyword key: String) -> UIViewController {
        let vc = NTESSessionSearchListMoreVC()
        vc.members = members
        vc.keyword = key
        return vc
    }
    
    func makeWhiteBoardCallingViewController(type: Int, room: String, sessionID: String, members: [String], isManager: Bool, isP2p: Bool, senderAccount: String) -> UIViewController? {
         guard !(UIApplication.topViewController() is IMWhiteboardCallingViewController) else {
             return nil
         }
         
         let vc =  IMWhiteboardCallingViewController(nibName: "IMWhiteboardCallingViewController", bundle: Bundle(for: IMWhiteboardCallingViewController.self))
         var session = NIMSession(sessionID, type: .P2P)
         if type == 1 {
             session = NIMSession(sessionID, type: .team)
         }
         vc.initWithChatroom(room: room, session: session, members: members, isManager: isManager, isP2p: isP2p, senderAccount: senderAccount)
         return vc

     }
    
    func makeIMChatViewController(sessionId: String, type: Int, unRead: Int) -> UIViewController {
        var session = NIMSession(sessionId, type: .P2P)
        if type == 1 {
            session = NIMSession(sessionId, type: .team)
        }else if type == 2 {
            session = NIMSession(sessionId, type: .chatroom)
        }
        let vc = IMChatViewController(session: session, unread: unRead)
        return vc
    }
    
    func makeIMDeleteTSAlertController(name: String, parentVC: UIViewController, title: String, onDelete: @escaping (_ onDelete: Bool) -> Void) {
        let alert = TSAlertController(title: title, message: name, style: .alert, hideCloseButton: false, animateView: false)

        let dismissAction = TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel) { (_) in
            alert.dismiss()
        }

        let deleteAction = TSAlertAction(title: "delete".localized, style: TSAlertActionStyle.theme) { (_) in
            onDelete(true)
            alert.dismiss()
        }

        alert.addAction(deleteAction)
        alert.addAction(dismissAction)

        parentVC.present(alert, animated: false, completion: nil)

    }
    
    func makePostShortVideoView(coverImage: UIImage?, url: URL) -> UIViewController {
        let vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
        vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: url)
      //  vc.soundId = BEManager.shared.selectedMusic?.id
        vc.isMiniVideo = true
        return vc
    }
    
    func makeCancelEditVideoAlert(completion: @escaping () -> Void) -> UIViewController {
        let vc = TSAlertController(title: "ve_exit".localized, message: "ve_exit_hint".localized, style: .alert, hideCloseButton: true)
        vc.addAction(TSAlertAction(title: "ve_cancel".localized, style: TSAlertActionStyle.cancel, handler: nil))
        vc.addAction(TSAlertAction(title: "ve_confirm".localized, style: TSAlertActionStyle.default, handler: { _ in
            completion()
        }))
        return vc
    }
    
    func makeMusicPickerView(duration: CGFloat, completion: @escaping (URL, String) -> Void) -> UIViewController {
        let vc = UIViewController()
//        vc.musicDidSelect = { url, name in
//            completion(url, name)
//        }
        return vc
    }
    
    func makeImagePicker() -> UIViewController {
        let vc = UIViewController.topMostController
        
        return vc ?? UIViewController()
    }
}

class PopupDialogFactory: PopupDialogFactoryType {
    @objc func makeEnterPasswordDialog(buttonAction: DidEnterPasswordClosure?) -> UIViewController {

        let vc = EnterPasswordDialog(title: "text_enter_password".localized,
                                     message: "warning_enter_pwd".localized,
                                     buttonText: "submit".localized,
                                     buttonAction: buttonAction)
       
        let alert = TSAlertController(style: .popup(customview: vc.view), hideCloseButton: true)
        alert.addChild(vc)
        vc.popup = alert
        return alert
    }
}

private var cancellables = Set<AnyCancellable>()

class UtilityFactory: UtilityFactoryType {
    
    @objc func getCurrentUserId() -> Int {
        return CurrentUserSessionInfo?.userIdentity ?? -1
    }
    
    @objc func resetLanguage() {
        userConfiguration?.countryRefreshTime = nil
        userConfiguration?.save()
    }
        
    @objc func navigateToLive(feedId: Int, viewController: UIViewController, completion: ((Bool) -> ())?) {
        viewController.navigateLive(feedId: feedId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { res in
                switch res {
                case .failure(let _):
                    completion?(false)
                    
                case .finished: break
                }
                cancellables.removeFirst()
            }, receiveValue: { _ in
                completion?(true)
            }).store(in: &cancellables)
    }

    @objc func getUserID(username: String, onComplete: ((Int) -> ())?) {
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [username]) { (models, msg, status) in
            guard let modelArray = models, let model = modelArray.first else {
                onComplete?(-1)
                return
            }

            onComplete?(model.userIdentity)
        }
    }
    
    @objc func getIsFriend(username: String, onComplete: ((Bool) -> ())?) {
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [username], complete: { (models, msg, status) in

            guard let models = models else {
                onComplete?(true)
                return
            }
            
            if status {
                models.forEach { user in
                    user.save()
                }
            }
            
            let model = models.first
            guard let relationship = model?.relationshipWithCurrentUser else {
                onComplete?(true)
                return
            }
            
            if case FollowStatus.eachOther = relationship.status {
                onComplete?(true)
            } else {
                onComplete?(false)
            }
        })
    }
    
    @objc func getWhiteListType(username:String, onComplete: (([String]?) -> ())?){
        TSUserNetworkingManager().getUsersInfo(usersId: [], names: [], userNames: [username], complete: { (models, _, _) in
            guard let models = models else {
                onComplete?(nil)
                return
            }
            
            let model = models.first
            
            guard let whiteListType = model?.whiteListType else {
                onComplete?(nil)
                return
            }
            
            onComplete?(StringArrayTransformer.transformToJSON(whiteListType))
        })
    }
    
    @objc func getMessageRequestCount() {
//        LaunchManager.shared.updateLaunchConfigInfo { (status) in
//            if status == true {
//                if TSAppConfig.share.launchInfo?.showMessageRequest == true {
//                    MessageRequestNetworkManager().getMessageReqCount()
//                }
//            }
//        }
    }
    
    @objc func translateTexts(string: String, onSuccess: ((String) -> Void)?, onFailure: ((String, Int) -> Void)?) {
        ChatroomNetworkManager().translateTexts(message: string, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    @objc func messageRequestCount() -> Int {
        return ChatMessageManager.shared.requestCount()
    }
    
    @objc func showMessageRequest() -> Bool {
        return TSAppConfig.share.launchInfo?.showMessageRequest ?? false
    }
    
    @objc func downloadSticker(bundleId: String, completion: (() -> Void)?, onError: @escaping (String) -> Void) {
        StickerManager.shared.downloadSticker(for: bundleId, completion: completion, onError: onError)
    }
    
    @objc func stopVideoPlayer() {
        if VideoPlayer.shared.isPlaying {
            VideoPlayer.shared.stop()
        }
    }

    @objc func loadOwnStickerList(completion: ((Bool) -> ())?) {
        StickerManager.shared.loadOwnStickerList(completion: completion)
    }
    

    @objc func loadCustomerStickerList(completion: @escaping( _ stickers: [CustomerStickerItem]?) -> Void){
        guard let userID = CurrentUserSessionInfo?.userIdentity else { return }
        let documentsPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        if !FileManager.default.fileExists(atPath: documentsPath + "/customerSticker/" + "/\(userID)/") {
            StickerManager.shared.fetchMyCustomerStickers(first: 10000, after: "", callBackHandler: completion)
        }else{
            StickerManager.shared.getCustomerStickerList(callBackHandler: completion)
        }
    }

    @objc func openMiniProgram(appId: String, path: String, parentVC: UIViewController, completion: @escaping ((Bool, Error?) -> Void)) {
      //  miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: parentVC)
    }

    @objc func handleWeb(url: URL, currentVC: UIViewController) {
        TSUtil.pushURLDetail(url: url, currentVC: currentVC)
    }
    
    @objc func getFriendList(userId: Int, keyWord: String, onComplete: (([UserAvatarUI]) -> ())?){
        var friends = [UserAvatarUI]()
        let extras = TSUtil.getUserID(remarkName: keyWord)
        TSUserNetworkingManager().user(identity: (CurrentUserSessionInfo?.userIdentity ?? -1), fansOrFollowList: .friends, keyword: keyWord, extra: extras) {(userModels, networkError) in
            guard let users = userModels else {
             onComplete?(friends)
                return
            }
            
            for item in users {
                friends.append(UserAvatarUI(username: item.username, avatarUrl: item.avatarUrl, displayname: item.displayName, verificationIcon: item.verificationIcon, verificationType: item.verificationType))
            }
            onComplete?(friends)
            
        }
    }
    
    @objc func getAvatarImage(userName: String, onComplete: ((String) -> ())?) {
        onComplete?(TSUserNetworkingManager().profileImageURL(userName))
    }
}
