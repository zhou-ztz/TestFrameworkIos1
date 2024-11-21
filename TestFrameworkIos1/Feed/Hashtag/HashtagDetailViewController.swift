//
//  HashtagDetailViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 22/03/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

enum HashtagSectionType {
    case gallery, live, miniVideo, moments
    
    var title: String {
        switch self {
        case .gallery:
            return "filter_favourite_photos".localized
        case .live:
            return "profile_tab_live".localized
        case .miniVideo:
            return "profile_tab_mini_videos".localized
        case .moments:
            return "profile_tab_feed".localized
        }
    }
}

class HashtagDetailViewController: TitledPageViewController {
    
    private(set) var hashtagId : Int
    private(set) var hashtagName: String?
    
    var tabType: [HashtagSectionType] = [.moments, .gallery, .live, .miniVideo]
    lazy var viewControllers: [UIViewController] = {
        return tabType.compactMap { type in
            switch type {
            case .gallery:
                let vc = HashtagGalleryViewController(hashtagId: self.hashtagId)
                vc.scrollDelegate = self
                vc.onBannerLoaded = { [weak self] (bannerModel) in
                    self?.setBannerModel(model: bannerModel)
                }
                vc.onChildFetched = { [weak self] (model) in
                    guard let self = self else { return }
                    if self.rootScrollView.mj_header.isRefreshing {
                        self.rootScrollView.mj_header.endRefreshing()
                    }
                    self.dismissLoading()
                }
                return vc
            case .live:
                let vc = HashtagLiveViewController(hashtagId: self.hashtagId)
                vc.scrollDelegate = self
                vc.delegate = self
                vc.parentVC = self
                vc.onBannerLoaded = { [weak self] (bannerModel) in
                    self?.setBannerModel(model: bannerModel)
                }
                vc.onChildFetched = { [weak self] (model) in
                    guard let self = self else { return }
                    if self.rootScrollView.mj_header.isRefreshing {
                        self.rootScrollView.mj_header.endRefreshing()
                    }
                    self.dismissLoading()
                }
                return vc
            case .miniVideo:
                let vc = HashtagMiniVideoCollectionView(hashtagId: self.hashtagId)
                vc.scrollDelegate = self
                vc.onBannerLoaded = { [weak self] (bannerModel) in
                    self?.setBannerModel(model: bannerModel)
                }
                vc.onChildFetched = { [weak self] (model) in
                    guard let self = self else { return }
                    if self.rootScrollView.mj_header.isRefreshing {
                        self.rootScrollView.mj_header.endRefreshing()
                    }
                    self.dismissLoading()
                }
                return vc
            case .moments:
                let vc = HashTagFeedViewController(hashtagId: self.hashtagId)
                vc.scrollDelegate = self
                vc.delegate = self
                vc.parentVC = self
                vc.onBannerLoaded = { [weak self] (bannerModel) in
                    self?.setBannerModel(model: bannerModel)
                }
                vc.onChildFetched = { [weak self] (model) in
                    guard let self = self else { return }
                    if self.rootScrollView.mj_header.isRefreshing {
                        self.rootScrollView.mj_header.endRefreshing()
                    }
                    self.dismissLoading()
                }
                return vc
            }
        }
    }()
    
    private let bannerView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 3)).configure {
        $0.contentMode = .scaleAspectFill
    }
    private let hashtagNameLabel = UILabel()
    private let postCountLabel = UILabel()
    
    public var defaultToTab: HashtagSectionType = .gallery
    private var currentIndex: Int = 0
    
    private var bannerModel: HashtagBannerModel? = nil
    
    var onReloadLive: ((Int) -> Void)?
    
    let header = UIStackView(frame: .zero)
    let navigationSpacing = UIView()
    
    init(hashtagId: Int, hashTagName: String?) {
        self.hashtagId = hashtagId
        self.hashtagName = hashTagName
        super.init(nibName: nil, bundle: nil)
        self.yOffset = -(UIApplication.shared.statusBarFrame.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.makeHidden()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.makeVisible()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoading(backgroundColor: .white)
        self.view.backgroundColor = .white
        self.navigationBar.labelForTitle.textColor = .clear
        self.navigationBar.title = hashtagName
        self.navigationBar.setTitleLeftAlign()
        self.navigationBar.navigationHiddenTitleColor = .clear
        self.navigationBar.onBackButtonTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        self.navigationBar.bottomSeparator.backgroundColor = .clear
        
        delegate = self
        datasource = self
        titleStyle = .leftScrolling
        headerView = header
        setupHeaderView()
        
        rootScrollView.mj_header = TSRefreshHeader(refreshingBlock: { [weak self] in
            if let galleryController = self?.activeViewController as? HashtagGalleryViewController {
                galleryController.loadDataSource()
            } else if let liveController = self?.activeViewController as? HashtagLiveViewController {
                liveController.fetch()
            } else if let liveController = self?.activeViewController as? HashtagMiniVideoCollectionView {
                liveController.loadData()
            } else if let liveController = self?.activeViewController as? HashTagFeedViewController {
                liveController.fetch()
            }
        })
        
        self.reloadData()
        
        if !(TSReachability.share.isReachable()) {
            self.showError(message: "network_is_not_available".localized)
        }
    }
    
    private func setBannerModel(model: HashtagBannerModel) {
        print(rootScrollView.contentOffset.y)
        if (rootScrollView.contentOffset.y + UIApplication.shared.statusBarFrame.size.height) < 30 {
            self.navigationBar.labelForTitle.textColor = .clear
        } else {
            self.navigationBar.labelForTitle.textColor = .black
        }
        if let bannerURLString = model.bannerUrl, !bannerURLString.isEmpty, let bannerURL = URL(string: bannerURLString) {
            navigationSpacing.isHidden = true
            bannerView.isHidden = false
            bannerModel = model
            bannerView.sd_setImage(with: bannerURL, completed: nil)
            
            header.snp.updateConstraints {
                $0.height.equalTo((UIScreen.main.bounds.width / 2) + 8 + (60 + 8))
            }
            if (rootScrollView.contentOffset.y + UIApplication.shared.statusBarFrame.size.height) < 30 {
                navigationBar.buttonAtLeft.setImage(UIImage.set_image(named: "IMG_topbar_back_white"), for: .normal)
            } else {
                navigationBar.buttonAtLeft.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
            }
        } else {
            navigationSpacing.isHidden = false
            bannerView.isHidden = true
            
            header.snp.updateConstraints {
                $0.height.equalTo(70 + 8 + 60 + 8)
            }
            if (rootScrollView.contentOffset.y + UIApplication.shared.statusBarFrame.size.height) < 30 {
                navigationBar.buttonAtLeft.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
            }
        }
        
        bannerView.addAction { [weak self] in
            if let bannerLink = model.link, let url = URL(string: bannerLink) {
                self?.navigation(navigateType: .pushURL(url: url))
            }
        }
        
        hashtagNameLabel.text = model.name
        postCountLabel.text = String(format: "hashtag_posts_count".localized, model.count.abbreviated)
    }
    
    private func setupHeaderView() {
        header.axis = .vertical
        header.distribution = .fill
        header.alignment = .fill
        header.spacing = 8
        
        header.snp.makeConstraints {
            $0.height.equalTo((UIScreen.main.bounds.width / 2) + 8 + (60 + 8))
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        header.addArrangedSubview(bannerView)
        header.addArrangedSubview(navigationSpacing)
        navigationSpacing.isHidden = true
        navigationSpacing.snp.makeConstraints {
            $0.height.equalTo(70)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        let hashtagIcon = UIImageView(image: UIImage.set_image(named: "icHashtag"))
        hashtagNameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        postCountLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        
        let headerTitleContainer = UIView()
        
        headerTitleContainer.addSubview(hashtagIcon)
        headerTitleContainer.addSubview(hashtagNameLabel)
        headerTitleContainer.addSubview(postCountLabel)
        
        hashtagNameLabel.snp.makeConstraints {
            $0.top.right.equalToSuperview()
            $0.height.equalTo(30)
            $0.left.equalToSuperview().inset(54)
        }
        
        postCountLabel.snp.makeConstraints {
            $0.top.equalTo(hashtagNameLabel.snp.bottom)
            $0.right.bottom.equalToSuperview()
            $0.height.equalTo(30)
            $0.left.equalToSuperview().inset(54)
        }
        
        headerTitleContainer.snp.makeConstraints {
            $0.height.equalTo(60)
        }
        
        hashtagIcon.snp.makeConstraints {
            $0.height.width.equalTo(25)
            $0.centerY.equalTo(hashtagNameLabel.snp.centerY)
            $0.left.equalToSuperview().inset(12)
        }
        header.addArrangedSubview(headerTitleContainer)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == rootScrollView {
            let offset = rootScrollView.contentOffset.y

            navigationBar.updateChildView(offset: bannerView.isHidden ? (offset + 70 + UIApplication.shared.statusBarFrame.size.height) : offset + UIApplication.shared.statusBarFrame.size.height)
            if canParentViewScroll == false {
                rootScrollView.contentOffset.y = lastRootScrollOffsetY
                canChildViewScroll = true
            } else if offset >= pullThreshold {
                rootScrollView.contentOffset.y = pullThreshold
                lastRootScrollOffsetY = pullThreshold
                canParentViewScroll = false
                canChildViewScroll = true
            }
            if bannerView.isHidden {
                if navigationBar.buttonAtLeft.currentImage != UIImage.set_image(named: "iconsArrowCaretleftBlack") {
                    navigationBar.buttonAtLeft.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
                }
                
                if (offset + UIApplication.shared.statusBarFrame.size.height) > 30 {
                    navigationBar.labelForTitle.textColor = .black
                } else {
                    navigationBar.labelForTitle.textColor = .clear
                }
            }
            
        } else {
            if canChildViewScroll == false {
                scrollView.contentOffset.y = 0
                
            } else if scrollView.contentOffset.y <= 0 {
                scrollView.contentOffset.y = 0
                canParentViewScroll = true
                canChildViewScroll = false
            }
        }
    }
}

extension HashtagDetailViewController {
    func numberOfPages(in pageViewController: UIPageViewController) -> Int {
        return tabType.count
    }
    
    func titledPageView(pageViewController: UIPageViewController, didChangeToPageAtIndex index: Int) {
        self.currentIndex = index
    }
    
    func titledPageView(pageViewController: UIPageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController? {
        guard index < viewControllers.count, viewControllers.count > 0 else { return nil }
        return viewControllers[index]
    }
    
    func titledPageView(pageViewController: UIPageViewController, titleViewForPageTitleAtIndex index: Int) -> TitledPageViewControllerClass.TitleView? {
        let title = tabType[index].title
        
        return TitledPageViewControllerClass.TitleView(frame: CGRect(origin: .zero, size: CGSize(width: 150, height: 40)), title: title, activeColor: .black, activeTextSize: 18)
    }
}

extension HashtagDetailViewController: BaseFeedDelegate {
    
    func dismiss() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func reloadLive(feedId: Int) {
        self.onReloadLive?(feedId)
        self.navigationController?.popViewController(animated: true)
    }
}

//extension HashtagDetailViewController: TSAdvertItemViewDelegate {
//    func item(view: TSAdvertItemView, didSelectedItemWithLink link: String?, imageURL: String?, title: String?) {
//        
//    }
//}
