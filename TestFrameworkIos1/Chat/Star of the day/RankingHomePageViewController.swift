//
//  RankingHomePageViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 29/09/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

enum RankingHomePageSection {
    case live(title: UILabel, viewController: UIViewController)
    case star(title: UILabel, viewController: UIViewController)
    
    var viewController: UIViewController {
        switch self {
        case .live(_, let viewController):
            return viewController
        case .star(_, let viewController):
            return viewController
        default:
            return UIViewController()
        }
    }
    
    var title: UILabel {
        switch self {
        case .live(let label, _):
            return label
        case .star(let label, _):
            return label
        default:
            return UILabel()
        }
    }
}

class RankingHomePageViewController: TSViewController {
    
    lazy var pageSections: [RankingHomePageSection] = {
        let liveRankTitleLabel = UILabel().configure {
            $0.text = "button_live_rank".localized
            $0.applyStyle(.bold(size: 17, color: .white))
            $0.textAlignment = .center
        }
        let starRankTitleLabel = UILabel().configure {
            $0.text = "button_star_rank".localized
            $0.applyStyle(.bold(size: 17, color: .white))
            $0.textAlignment = .center
        }
        let liveRankVC = LiveRankContainerVC()
        liveRankVC.onRootScrollViewScrolled = { (offsetY) in
            self.updateNavigationView(offset: offsetY)
        }
//        let influencerVC = InfluencerContainerVC()
//        influencerVC.onRootScrollViewScrolled = { (offsetY) in
//            self.updateNavigationView(offset: offsetY)
//        }
        return [.live(title: liveRankTitleLabel, viewController: liveRankVC), .star(title: starRankTitleLabel, viewController: liveRankVC)]
    }()
    
    let navigationView = UIView().configure {
        $0.backgroundColor = .white.withAlphaComponent(0.0)
    }
    let buttonAtLeft = TSButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "iconsArrowCaretleftWhite"))
    }
    let buttonAtRight = TSButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "ic_star_info_white"))
    }
    let titleContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    let titleUnderlineView = UIView().configure {
        $0.backgroundColor = .white
    }
    
    let contentPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var currentPageIndex: Int = 0 {
        willSet {
            previousPageIndex = currentPageIndex
            if let vc = viewControllerForIndex(index: newValue) as? LiveRankContainerVC {
                self.updateNavigationView(offset: vc.rootScrollView.contentOffset.y)
            } 
//            else if let vc = viewControllerForIndex(index: newValue) as? InfluencerContainerVC {
//                self.updateNavigationView(offset: vc.rootScrollView.contentOffset.y)
//            }
            buttonAtRight.isHidden = newValue != 0
        }
    }
    private var previousPageIndex: Int = -1
    public var defaultPageIndex: Int = 0
    
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
        setupTitle()
        setupPageViewController()
        
        setActiveTitle(atIndex: defaultPageIndex)
        setViewController(atIndex: defaultPageIndex)
    }
    
    func setupTitle() {
        view.addSubview(navigationView)
        navigationView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(50 + (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
        }
        
        navigationView.addSubview(buttonAtLeft)
        buttonAtLeft.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.top.equalToSuperview().inset(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            $0.left.equalToSuperview().inset(8)
        }
        navigationView.addSubview(buttonAtRight)
        buttonAtRight.snp.makeConstraints {
            $0.width.height.equalTo(50)
            $0.top.equalToSuperview().inset(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            $0.right.equalToSuperview().inset(8)
        }
        navigationView.addSubview(titleContainer)
        titleContainer.snp.makeConstraints {
            $0.width.equalTo(pageSections.count * 100)
            $0.height.equalTo(50)
            $0.top.equalToSuperview().inset(UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
            $0.centerX.equalToSuperview()
        }
        
        for sectionIndex in 0..<pageSections.count {
            let sectionLabel = pageSections[sectionIndex].title
            titleContainer.addSubview(sectionLabel)
            sectionLabel.snp.makeConstraints {
                $0.width.equalTo(100)
                $0.top.bottom.equalToSuperview()
                $0.left.equalToSuperview().inset(sectionIndex * 100)
            }
            sectionLabel.addAction { [weak self] in
                guard let self = self else { return }
                self.setActiveTitle(atIndex: sectionIndex)
                self.setViewController(atIndex: sectionIndex)
            }
        }
        titleContainer.addSubview(titleUnderlineView)
        
        titleUnderlineView.snp.makeConstraints {
            $0.width.equalTo(80)
            $0.height.equalTo(2)
            $0.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
        }
        
        buttonAtLeft.addAction { [weak self] in
            if self?.navigationController != nil {
                self?.navigationController?.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        buttonAtRight.addAction { [weak self] in
            guard let url = URL(string: WebViewType.liveRanking.urlString) else { return }
            let webview = TSWebViewController(url: url, type: .defaultType)
            let nav = TSNavigationController(rootViewController: webview)
            self?.present(nav.fullScreenRepresentation, animated: true, completion: nil)
        }
    }
    
    func setupPageViewController() {
        addChild(contentPageViewController)
        self.view.insertSubview(contentPageViewController.view, at: 0)
        
        contentPageViewController.didMove(toParent: self)
        contentPageViewController.dataSource = self
        contentPageViewController.delegate = self
        
        contentPageViewController.view.bindToEdges()
    }
    
    private func setActiveTitle(atIndex index: Int) {
        for sectionIndex in 0..<pageSections.count {
            let section = pageSections[sectionIndex]
            section.title.applyStyle(sectionIndex == index ? .semibold(size: 17, color: .white) : .regular(size: 17, color: .white.withAlphaComponent(0.5)))
        }
                                      
        UIView.animate(withDuration: 0.3) {
          self.titleUnderlineView.snp.updateConstraints {
              $0.left.equalToSuperview().inset(index * 100 + 10)
          }
          self.view.layoutIfNeeded()
        }
        
        currentPageIndex = index
    }
    
    private func setViewController(atIndex index: Int) {
        guard let viewController = viewControllerForIndex(index: index) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.contentPageViewController.setViewControllers([viewController], direction: index > self.previousPageIndex ? .forward : .reverse, animated: true) { [weak self] (completion) in
                guard let self = self else { return }
                //didchange to new controller
            }
        }
    }
    
    private func viewControllerForIndex(index: Int) -> UIViewController? {
        guard index < pageSections.count else { return nil }
        let vc = pageSections[index].viewController
        vc.view.tag = index
        return vc
    }
    
    private func updateNavigationView(offset: CGFloat) {
        let colorOffset = offset / (((UIScreen.main.bounds.width / 3) * 2) - 50 - (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0))
        self.navigationView.backgroundColor = (currentPageIndex == 0 ? UIColor(hex: 0xF4FBFF) : .white).withAlphaComponent(colorOffset)
        for sectionIndex in 0..<pageSections.count {
            let section = pageSections[sectionIndex]
            section.title.textColor = colorOffset > 0.6 ? .black.withAlphaComponent(sectionIndex == currentPageIndex ? 1.0 : 0.5) : .white.withAlphaComponent(sectionIndex == currentPageIndex ? 1.0 : 0.5)
        }
        titleUnderlineView.backgroundColor = colorOffset > 0.9 ? AppTheme.dodgerBlue : .white
        buttonAtLeft.setImage(UIImage.set_image(named: colorOffset > 0.6 ? "iconsArrowCaretleftBlack" : "iconsArrowCaretleftWhite"))
        buttonAtRight.setImage(UIImage.set_image(named: colorOffset > 0.6 ? "ic_star_info" : "ic_star_info_white"))
    }
}

extension RankingHomePageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var viewIndex = viewController.view?.tag, viewIndex > 0 else { return nil }
        
        viewIndex -= 1
        return viewControllerForIndex(index: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var viewIndex = viewController.view?.tag, viewIndex > 0  else { return nil }
        guard viewIndex < 2 else { return nil }
        viewIndex += 1
        return viewControllerForIndex(index: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard pendingViewControllers.count > 0 else { return }
        let viewIndex = pendingViewControllers[0].view.tag
        setActiveTitle(atIndex: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let index = pageViewController.viewControllers?.first?.view.tag else { return }
        setActiveTitle(atIndex: index)
        self.currentPageIndex = index
    }
}
