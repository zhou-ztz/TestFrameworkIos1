//
//  FeedListCellActionManager.swift
//  Yippi
//
//  Created by ChuenWai on 09/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class FeedListCellActionManager: NSObject {
    static let shared = FeedListCellActionManager()

    func checkShowLandingVC() {
        if TSCurrentUserInfo.share.isLogin == false {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
    }
    
    func translate(feedId: String, onComplete: ((String) -> Void)?) {
        
        FeedListNetworkManager.translateFeed(feedId: feedId) { (translateTexts) in
            onComplete?(translateTexts)
        } failure: { (message) in
            UIViewController.showBottomFloatingToast(with: "", desc: message)
        }

    }

    func didClickCell(parentVC: UIViewController?, model: FeedListCellModel, atIndex: Int, feedListType: FeedListType, onToolbarUpdated: onToolbarUpdate?) {

        guard let parentVC = parentVC else { return }

        guard let feedId = model.id["feedId"] else {
            parentVC.showError()
            return
        }

        parentVC.navigation(navigateType: .loadingOverlay)

        switch model.feedType {
        case .normalText, .repost, .share, .picture:
            parentVC.navigation(navigateType: .feedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, isVideoFeed: false, feedType: feedListType, afterTime: model.afterTime, onToolbarUpdated: onToolbarUpdated))
            
        case .video:
            parentVC.navigation(navigateType: .feedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, isVideoFeed: true, feedType: feedListType, afterTime: model.afterTime, onToolbarUpdated: onToolbarUpdated))
            
        case .live:
            if model.liveModel?.status == 1 {
                parentVC.navigation(navigateType: .navigateLive(feedId: feedId))
            } else {
                parentVC.navigation(navigateType: .feedDetail(feedId: feedId, isTapMore: false, isClickCommentButton: false, isVideoFeed: true, feedType: feedListType, afterTime: model.afterTime, onToolbarUpdated: onToolbarUpdated))
            }
        case .miniVideo:
            parentVC.navigation(navigateType: .miniVideo(feedListType: feedListType, currentVideo: model, onToolbarUpdated: onToolbarUpdated))
        }
    }
}
