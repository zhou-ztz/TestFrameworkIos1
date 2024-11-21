//
//  LiveRankContainerVC.swift
//  Yippi
//
//  Created by Jerry Ng on 30/09/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class LiveRankContainerVC: TSViewController {
    
    let rootScrollView = SimultaneousScrollView()
    
    lazy var liveStarListView: LiveStarListViewController = {
        let vc = LiveStarListViewController(feedId: -1, hostInfo: nil, isHost: false, isPortrait: true, entryType: .homepage, selectedLanguage: userConfiguration?.searchLanguageCode)
        vc.extraScrollViewDelegate = self
        vc.onShowUserProfileHandler = { [weak self] userInfo in
            DispatchQueue.main.async {
                vc.dismiss(animated: true) {
                    self?.onShowHomepageVC(userInfo: userInfo as! UserInfoModel)
                }
            }
        }
        return vc
    }()
    
    private var canParentViewScroll = true
    private var isDrag = true
    private var canChildViewScroll = false
    private var lastRootScrollOffsetY: CGFloat = 0
    private var fixedScrollOffsetPoint: CGFloat?
    private var pullThreshold: CGFloat {
        return ((UIScreen.main.bounds.width / 3) * 2) - (50 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
    }
    
    public var onRootScrollViewScrolled: ((CGFloat)->())? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addChild(liveStarListView)
        rootScrollView.contentInsetAdjustmentBehavior = .never
        rootScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        rootScrollView.delegate = self
        view.addSubview(rootScrollView)
        rootScrollView.bindToEdges()
        
        let bannerImageView = UIImageView(image: UIImage.set_image(named: "bkSOTDListBanner"))
        bannerImageView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(((UIScreen.main.bounds.width / 3) * 2))
        }
        liveStarListView.view.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(UIScreen.main.bounds.height - (50 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)))
        }
        
        let stackView = UIStackView(arrangedSubviews: [bannerImageView, liveStarListView.view])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        
        rootScrollView.addSubview(stackView)
        stackView.bindToEdges()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func onShowHomepageVC(userInfo: UserInfoType) {
//        let vc = HomePageViewController(userId: userInfo.userIdentity)
//        let navController = TSNavigationController(rootViewController: vc, availableOrientations: [.portrait]).fullScreenRepresentation
//        navController.modalTransitionStyle = .crossDissolve
//        self.present(navController, animated: true, completion: nil)
    }
}

extension LiveRankContainerVC: TSScrollDelegate, UIScrollViewDelegate {
    //Note: currently childScrollView is undraggable and unscrollable due insufficient height,
    //      if there is any changes on the childScrollView height, please refer to
    //      TSScrollDelegate methods defined on InfluencerContainerVC
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let childScrollView = liveStarListView.liveListViewContainer.activeTableView
        
        let offset = rootScrollView.contentOffset.y
        
        lastRootScrollOffsetY = offset
        
        if offset <= 0 && childScrollView.contentOffset.y > 0 {
            canParentViewScroll = false
            //canChildViewScroll = true
        }
        
        isDrag = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let childScrollView = liveStarListView.liveListViewContainer.activeTableView

        if scrollView == rootScrollView {
            onRootScrollViewScrolled?(rootScrollView.contentOffset.y)
            let offset = rootScrollView.contentOffset.y
            if canParentViewScroll == false {
                rootScrollView.contentOffset.y = lastRootScrollOffsetY
                //canChildViewScroll = true
            } else if offset >= pullThreshold {
                rootScrollView.contentOffset.y = pullThreshold
                lastRootScrollOffsetY = pullThreshold
                canParentViewScroll = false
                //canChildViewScroll = true
            }
            
            if isDrag && offset < pullThreshold{
                canParentViewScroll = true
                //canChildViewScroll = false
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isDrag = false
    }
}

//Only use this for controlling when LiveRankContainerVC have one scroll view
//class LiveRankSingleScrollController{
//    lastScroll =
//}
