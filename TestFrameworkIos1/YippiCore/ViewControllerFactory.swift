//
// Copyright © 2018 Toga Capital. All rights reserved.
//
import Foundation
import Photos
import UIKit

public typealias DidEnterSpeech = (String?) -> Void

@objc public protocol ViewFactoryType {
    
    @objc func makeSpeechView(height: CGFloat, callBackHandler: DidEnterSpeech?) ->  UIView
    
    @objc func makeInputContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool, _ isCamera: Bool, _ assets: [PHAsset]?, _ isFullImage: Bool) -> Void) ->  UIView
    
    
    @objc func makeInputFileContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool, _ url: URL?) -> Void) ->  UIView
    
    @objc func makeInputLocalContainerView(frame: CGRect, callBackHandler: @escaping(_ isSend: Bool, _ title: String, _ coordinate: CLLocationCoordinate2D) -> Void) ->  UIView
    
    @objc func makeTopIndicatorView(message: String) -> Void
    
    @objc func makeEmptySearchChatPlaceholder() -> UIView
    
    @objc func makeEmptyChatPlaceholder() -> UIView
    
    @objc func makeNetworkErrorPlaceholder() -> UIView
    
}

/// NIM calling methods from Yippi
@objc public protocol ViewControllerFactoryType {
    @objc func makeEggDetailViewController(info: ClaimEggResponse, isSender: Bool, isGroup: Bool) ->  UIViewController
    
    @objc func makeSendEggInChatViewController(typePersonal: Bool, fromUser: String, toUser: String, numberOfMember: Int, completion: TransactionFinishClosure?) ->  UIViewController

   // func makeBeautyCameraViewController(completion: @escaping CameraHandler) -> UIViewController
    /// Show contact picker, normal used in NIM.
    @objc func makeContactPicker(configuration: ContactsPickerConfig, completion: (([ContactData]) -> Void)?) -> UIViewController

    @objc func makeRewardViewController(recipient: Recipient, rewardType: RewardType) -> UIViewController
    /// Show user home page
    @objc func makeUserHomepageViewController(userId: Int, userName: String) -> UIViewController
    @objc func makeUserHomepageViewControllerFromChatroom(userId: Int, userName: String, isTeam : Bool) -> UIViewController
    /// Show group detail/setting
    @objc func makeTeamCardViewController(teamId: String) -> UIViewController
    /// Tap on + icon in keyboard emoticon container, show sticker home page.
    @objc func makeStickerMainViewController() -> UIViewController
    @objc func makeCustomerStickerViewController(stickerId: String) -> UIViewController
    
    @objc func makeSpeechTyperViewController(height: CGFloat, callBackHandler: DidEnterSpeech?)
    
    @objc func dimissSpeechTyperViewController()

    /// Tap on setting in chat input, navigate to my sticker list
    @objc func makeMyStickerViewController() -> UIViewController
    /// Tap on shared sticker in IM
    @objc func makeStickerDetailViewController(bundleId: String) -> UIViewController
    /// When tap on shared post in IM, show feed detail with feedid given
    @objc func makeFeedDetail(feedId: Int) -> UIViewController
    /// Show create group page
    @objc func makeCreateGroupViewController(member: [String], completion: createGroupFinishBlock?) -> UIViewController
    /// Show Chat Media ViewController
    @objc func makeChatMediaViewController(sessionId: String, type: NSInteger) -> UIViewController
    /// Show Chat Media Video Player View Controller
    @objc func makeChatMediaVideoPlayerViewController(url: String) -> UIViewController
    /// Show NIM chat message video player view controller
    @objc func makeNIMVideoPlayerViewController(url: String) -> UIViewController
    @objc func makeTSAlertController(url: NSURL, message:Any?, parentVC: UIViewController, title: String, messageDisplay: String, onSend: @escaping (_ message: Any?, _ url: URL?) -> Void)
    @objc func makeIMActionListView(delegateTarget: Any, actionArray: [Any]) -> UIView
    @objc func makeWebview(title: String?, link: URL) -> UIViewController
    @objc func makeMessageRequestListTableViewController() -> UIViewController
    @objc func makeGroupNotificationTableVC() -> UIViewController
    @objc func makeArticleViewController (id: Int) -> UIViewController
    
    @objc func makeCustomerStickerDialogView(imageUrl: String, customStickerId: String, callBackHandler: @escaping(_ isCompleted: Int) -> Void) -> UIViewController
    @objc func makeCustomerStickerMaxNumDialogView(imageUrl: String, customStickerId: String, callBackHandler: @escaping(_ isCompleted: Int) -> Void) -> UIViewController

    @objc func makeCallViewController(sessionId: String, video: Bool) -> UIViewController
    @objc func makeIMChatViewController(sessionId: String, type: Int, unread: Int, searchMessageId: String) -> UIViewController
    @objc func makeNTESSessionListTableVC(member: [UserAvatarUI], keyword: String) -> UIViewController
    @objc func makeWhiteBoardCallingViewController(type: Int, room: String, sessionID: String, members: [String], isManager: Bool, isP2p: Bool, senderAccount: String) -> UIViewController?

    @objc func makeIMChatViewController(sessionId: String, type: Int, unRead: Int) -> UIViewController

    @objc func makeIMDeleteTSAlertController(name: String, parentVC: UIViewController, title: String, onDelete: @escaping (_ onDelete: Bool) -> Void)
    
    @objc func makeMusicPickerView(duration: CGFloat, completion: @escaping (URL, String) -> Void) -> UIViewController
    
    @objc func makePostShortVideoView(coverImage: UIImage?, url: URL) -> UIViewController
    @objc func makeCancelEditVideoAlert(completion: @escaping () -> Void) -> UIViewController
    
    @objc func makeImagePicker() -> UIViewController
}

@objc public protocol UtilityFactoryType {
    @objc func resetLanguage()
    @objc func getCurrentUserId() -> Int
    @objc func getUserID(username: String, onComplete: ((Int) -> ())?)
    @objc func getIsFriend(username: String, onComplete: ((Bool) -> ())?)
    @objc func getMessageRequestCount()
    @objc func messageRequestCount() -> Int
    @objc func showMessageRequest() -> Bool
    @objc func navigateToLive(feedId: Int, viewController: UIViewController, completion: ((Bool) -> ())?)
    @objc func getWhiteListType(username:String ,onComplete: (([String]?) -> ())?)
    @objc func downloadSticker(bundleId: String, completion: (() -> Void)?, onError: @escaping (String) -> Void)
    @objc func stopVideoPlayer()
    @objc func translateTexts(string: String, onSuccess: ((String) -> Void)?, onFailure:((String, Int) -> Void)?)
    @objc func loadOwnStickerList(completion: ((Bool) -> ())?)
    @objc func handleWeb(url: URL, currentVC: UIViewController)
    @objc func loadCustomerStickerList(completion: @escaping( _ stickers: [CustomerStickerItem]?) -> Void)
    @objc func openMiniProgram(appId: String, path: String, parentVC: UIViewController, completion: @escaping ((Bool, Error?) -> Void))
    @objc func getFriendList(userId: Int, keyWord: String, onComplete: (([UserAvatarUI]) -> ())?)
    @objc func getAvatarImage(userName: String, onComplete: ((String) -> ())?)
}
