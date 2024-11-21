//
//  TitledPageViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 07/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit


enum TitledPageTitleStyle {
    case fit
    case centerScrolling
    case leftScrolling
}


@objc protocol TSScrollDelegate: class {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

protocol TitledPageViewControllerDatasource: class {
    func numberOfPages(in pageViewController: UIPageViewController) -> Int
    func titledPageView(pageViewController: UIPageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController?
    func titledPageView(pageViewController: UIPageViewController, titleViewForPageTitleAtIndex index: Int) -> TitledPageViewController.TitleView?
}
protocol TitledPageViewControllerDelegate: class {
    func titledPageView(pageViewController: UIPageViewController, didChangeToPageAtIndex index: Int)
}

typealias TitledPageViewController = TitledPageViewControllerClass & TitledPageViewControllerDatasource & TitledPageViewControllerDelegate
class TitledPageViewControllerClass: TSViewController {
    
    public var customScrollViewDelegate:TSScrollDelegate?
    
    public var titleStyle: TitledPageTitleStyle = .leftScrolling {
        didSet {
            setupTitleUI()
        }
    }
    public var headerView: UIView? = nil
    
    public var titleHeight: CGFloat = 50.0
    public var titleUnderlineColor: UIColor = AppTheme.warmBlue
    public var titleUnderlineHeight: CGFloat = 2.0
    
    public weak var delegate: TitledPageViewControllerDelegate?
    public weak var datasource: TitledPageViewControllerDatasource?
    public var numberOfPages: Int {
        get {
            return datasource?.numberOfPages(in: self.contentPageViewController) ?? 0
        }
    }
    
    let rootScrollView: SimultaneousScrollView = SimultaneousScrollView(frame: .zero)
    
    let pageStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
    let titleScrollView: UIScrollView = UIScrollView().configure {
        $0.showsHorizontalScrollIndicator = false
    }
    let contentPageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    
    let rootContentStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 0
    }
    
    let titleContainerView: UIView = UIView(frame: .zero)
    let titleStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .fill
        $0.spacing = 0
    }
    let titlebottomBorder: UIView = UIView(frame: .zero)
    
    let navigationBar: NavigationView = NavigationView(frame: .zero)
    var statusBarStyle: UIStatusBarStyle = .default
    
    public var defaultSelectedIndex = 0
    
    public var yOffset: CGFloat = 0.0
    
    private var currentPageIndex: Int = 0 {
        willSet {
            previousPageIndex = currentPageIndex
        }
    }
    private var previousPageIndex: Int = -1
    
    public var activeViewController: UIViewController? {
        get {
            return viewControllerForIndex(index: currentPageIndex)
        }
    }
    var canParentViewScroll = true
    var canChildViewScroll = false
    var lastRootScrollOffsetY: CGFloat = 0
    var pullThreshold: CGFloat {
        return (headerView?.bounds.height ?? 0) + (yOffset)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRootUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    func setupRootUI() {
        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(rootScrollView)
        
        view.addSubview(navigationBar)
        navigationBar.backgroundColor = .clear
        navigationBar.snp.makeConstraints {
            $0.height.equalTo(TSNavigationBarHeight)
            $0.top.left.right.equalToSuperview()
        }
        
        rootScrollView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(TSNavigationBarHeight)
            $0.bottom.right.left.equalToSuperview()
        }
        
        rootScrollView.addSubview(rootContentStackView)
        rootContentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(yOffset)
            $0.bottom.right.left.equalToSuperview()
        }
        
        addChild(contentPageViewController)
        
        pageStackView.axis = .vertical
        pageStackView.distribution = .fill
        pageStackView.alignment = .fill
        pageStackView.spacing = 0
        
        pageStackView.addArrangedSubview(titleScrollView)
        pageStackView.addArrangedSubview(titlebottomBorder)
        pageStackView.addArrangedSubview(contentPageViewController.view)
        
        titleScrollView.snp.makeConstraints {
            $0.height.equalTo(titleHeight)
        }

        rootContentStackView.addArrangedSubview(pageStackView)
        
        pageStackView.snp.makeConstraints {
            $0.width.equalTo(UIScreen.main.bounds.width)
            $0.height.equalTo(UIScreen.main.bounds.height - (50 + TSLiuhaiHeight + TSStatusBarHeight))
        }
        
        titleScrollView.addSubview(titleContainerView)
        titleContainerView.addSubview(titleStackView)
        titlebottomBorder.snp.makeConstraints {
            $0.height.equalTo(1)
        }
        titlebottomBorder.backgroundColor = TSColor.inconspicuous.disabled
        
        contentPageViewController.didMove(toParent: self)
        contentPageViewController.dataSource = self
        contentPageViewController.delegate = self
        
        rootScrollView.delegate = self
        
        navigationBar.onStatusBarChanged = { [weak self] shouldWhite in
            self?.updateStatusBar(shouldWhite)
        }
    }
    
    func setupHeaderUI() {
        defer {
            rootScrollView.setNeedsLayout()
            rootScrollView.layoutIfNeeded()

            rootContentStackView.setNeedsLayout()
            rootContentStackView.layoutIfNeeded()
        }
        
//        if rootContentStackView.arrangedSubviews.count == 2 {
//            rootContentStackView.arrangedSubviews[0].removeFromSuperview()
//        }
        guard let newHeaderView = headerView else {
            if #available(iOS 11.0, *) {
                rootScrollView.contentInsetAdjustmentBehavior = .always
            } else {
                automaticallyAdjustsScrollViewInsets = true
            }
            return
        }
        
        rootContentStackView.insertArrangedSubview(newHeaderView, at: 0)
    }
    
    func setupTitleUI() {
        defer {
            titleStackView.setNeedsLayout()
            titleStackView.layoutIfNeeded()
            
            titleContainerView.setNeedsLayout()
            titleContainerView.layoutIfNeeded()
        }
        switch titleStyle {
        case .fit:
            titleStackView.distribution = .fillEqually
            titleStackView.snp.removeConstraints()
            titleContainerView.snp.removeConstraints()
            titleContainerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalTo(UIScreen.main.bounds.width)
                $0.height.equalTo(titleHeight)
            }
            titleStackView.bindToEdges()
        case .centerScrolling:
            titleStackView.distribution = .fill
            titleStackView.snp.removeConstraints()
            titleContainerView.snp.removeConstraints()
            titleStackView.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.bottom.equalToSuperview()
            }
            titleContainerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                let width = max(titleStackView.width, UIScreen.main.bounds.width)
                $0.width.equalTo(width)
                $0.height.equalTo(titleHeight)
            }
        case .leftScrolling:
            titleStackView.distribution = .equalSpacing
            titleStackView.snp.removeConstraints()
            titleContainerView.snp.removeConstraints()
            titleStackView.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            titleContainerView.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalTo(titleStackView.snp.width)
                $0.height.equalTo(titleHeight)
            }
        }
    }
    
    func reloadData() {
        guard numberOfPages > 0 else { return }
                
        if UserDefaults.teenModeIsEnable {
            pageStackView.makeHidden()
            rootScrollView.isScrollEnabled = false
            placeholder.set(.teenMode)
            placeholder.snp.makeConstraints {
                $0.width.equalTo(UIScreen.main.bounds.width)
                $0.height.equalTo(400)
            }
            placeholder.onTapActionButton = { [weak self] in
                guard let self = self else { return }
                let vc = TeenModeViewController()
                vc.onGetSecurityPin = { [weak self] code in
                    guard let self = self else { return }
                    self.reloadData()
                    NotificationCenter.default.post(name: Notification.Name.DashBoard.teenModeChanged, object: nil)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            rootContentStackView.addArrangedSubview(placeholder)
        } else {
            pageStackView.makeVisible()
            rootScrollView.isScrollEnabled = true
            titleStackView.removeAllArrangedSubviews()
            for index in 0..<numberOfPages {
                guard let view = titleViewForIndex(index: index) else { return }
                view.addAction { [weak self] in
                    self?.setActiveTitle(atIndex: index)
                    self?.setViewController(atIndex: index)
                }
                titleStackView.addArrangedSubview(view)
            }
            
            setActiveTitle(atIndex: defaultSelectedIndex)
            setViewController(atIndex: defaultSelectedIndex)
        }
        
        setupTitleUI()
        setupHeaderUI()
    }
    
    func updateStatusBar(_ shouldWhite: Bool) {
        if shouldWhite {
            if #available(iOS 13.0, *) {
                self.statusBarStyle = .darkContent
            } else {
                self.statusBarStyle = .default
            }
        } else {
            self.statusBarStyle = .lightContent
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func setActiveTitle(atIndex index: Int) {
        guard index < numberOfPages && index < titleStackView.arrangedSubviews.count else { return }
        for i in 0..<titleStackView.arrangedSubviews.count {
            let isActiveView = i == index
            guard let titleView = titleStackView.arrangedSubviews[i] as? TitleView else { continue }
            titleView.isActive = isActiveView
        }
        currentPageIndex = index
    }
    
    private func titleViewForIndex(index: Int) -> TitledPageViewController.TitleView? {
        guard let datasource = datasource else { return nil }
        guard index < numberOfPages else { return nil }
        return datasource.titledPageView(pageViewController: contentPageViewController, titleViewForPageTitleAtIndex: index)
    }
    
    private func setViewController(atIndex index: Int) {
        guard let viewController = viewControllerForIndex(index: index) else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.contentPageViewController.setViewControllers([viewController], direction: index > self.previousPageIndex ? .forward : .reverse, animated: true) { [weak self] (completion) in
                guard let self = self else { return }
                self.delegate?.titledPageView(pageViewController: self.contentPageViewController, didChangeToPageAtIndex: index)
            }
        }
    }
    
    private func viewControllerForIndex(index: Int) -> UIViewController? {
        guard let datasource = datasource else { return nil }
        guard index < numberOfPages else { return nil }
        let viewController = datasource.titledPageView(pageViewController: contentPageViewController, viewControllerForPageAtIndex: index)
        viewController?.view.tag = index
        if let tableVC = viewController as? TSTableViewController {
            tableVC.customScrollViewDelegate = self
        } else if let collectionVC = viewController as? TSCollectionViewController {
            collectionVC.customScrollViewDelegate = self
        }
        return viewController
    }
}

extension TitledPageViewControllerClass: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var viewIndex = viewController.view?.tag, viewIndex > 0 else { return nil }
        
        viewIndex -= 1
        return viewControllerForIndex(index: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var viewIndex = viewController.view?.tag, viewIndex > 0  else { return nil }
        guard viewIndex < numberOfPages else { return nil }
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
        self.delegate?.titledPageView(pageViewController: self.contentPageViewController, didChangeToPageAtIndex: index)
        currentPageIndex = index
    }
}

class SimultaneousScrollView: UIScrollView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        gestureRecognizer.cancelsTouchesInView = false
        if (gestureRecognizer.view is SimultaneousScrollView && otherGestureRecognizer.view?.viewController is UIPageViewController) {
            return false
        }
        if (gestureRecognizer.view is SimultaneousScrollView && otherGestureRecognizer.view is UIScrollView) {
            return true
        }
        if (otherGestureRecognizer is UITapGestureRecognizer || gestureRecognizer is UITapGestureRecognizer) {
            return true
        }
        return false
    }
}

extension TitledPageViewControllerClass: TSScrollDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        guard let activeViwController = activeViewController as? TSTableViewController, let childScrollView = activeViwController.tableView else { return }
        
        let offset = rootScrollView.contentOffset.y
        
        lastRootScrollOffsetY = offset
        
        if offset <= 0 && childScrollView.contentOffset.y > 0 {
            canParentViewScroll = false
            canChildViewScroll = true
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let activeTableView = activeViewController as? TSTableViewController
        let activeCollectionView = activeViewController as? UICollectionViewController
        
        guard (activeTableView != nil || activeCollectionView != nil) else { return }
        guard let childScrollView = activeTableView?.tableView ?? activeCollectionView?.collectionView else { return }
        
        if scrollView == rootScrollView {
            let offset = rootScrollView.contentOffset.y
            navigationBar.updateChildView(offset: offset)
            if canParentViewScroll == false {
                rootScrollView.contentOffset.y = lastRootScrollOffsetY
                canChildViewScroll = true
            } else if offset >= pullThreshold {
                rootScrollView.contentOffset.y = pullThreshold
                lastRootScrollOffsetY = pullThreshold
                canParentViewScroll = false
                canChildViewScroll = true
            }
//            if offset < 0 {
//                rootScrollView.contentOffset.y = 0
//            }
        } else {
            if canChildViewScroll == false {
                childScrollView.contentOffset.y = 0
                
            } else if childScrollView.contentOffset.y <= 0 {
                childScrollView.contentOffset.y = 0
                canParentViewScroll = true
                canChildViewScroll = false
            }
        }
    }
    
}

// MARK: Title Page Title View
extension TitledPageViewControllerClass {
    class TitleView: UIView {
        private let contentStackView: UIStackView = UIStackView(frame: .zero).configure {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 2
        }
        private var titleLabel: UILabel?
        private var imageView: UIImageView?
        
        private var text: String?
        private var activeImage: UIImage?
        private var inactiveImage: UIImage?
        private var activeColor: UIColor = AppTheme.warmBlue
        private var inactiveColor: UIColor = TSColor.normal.minor
        private var activeTextSize: CGFloat = 14.0
        
        public var isActive: Bool = false {
            didSet {
                if isActive {
                    titleLabel?.textColor = activeColor
                    titleLabel?.font = UIFont.systemFont(ofSize: activeTextSize, weight: .bold)
                    imageView?.image = activeImage
                } else {
                    titleLabel?.textColor = inactiveColor
                    titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                    imageView?.image = inactiveImage
                }
            }
        }
        
        init(frame: CGRect, title: String? = nil, activeColor: UIColor = AppTheme.warmBlue, inactiveColor: UIColor = TSColor.normal.minor, activeImage: UIImage? = nil, inactiveImage: UIImage? = nil, activeTextSize: CGFloat = 14.0) {
            super.init(frame: frame)
            self.text = title
            self.activeImage = activeImage
            self.inactiveImage = inactiveImage
            self.activeColor = activeColor
            self.inactiveColor = inactiveColor
            self.activeTextSize = activeTextSize
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            addSubview(contentStackView)
            contentStackView.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(12)
                $0.bottom.top.equalToSuperview().inset(8)
            }
            if let title = text {
                if titleLabel != nil {
                    if titleLabel?.superview != nil {
                        titleLabel?.removeFromSuperview()
                    }
                }
                titleLabel = UILabel()
                titleLabel?.text = title
                titleLabel?.textColor = inactiveColor
                titleLabel?.textAlignment = .center
                contentStackView.addArrangedSubview(titleLabel!)
            }
            if let inactiveImg = inactiveImage {
                if imageView != nil {
                    if imageView?.superview != nil {
                        imageView?.removeFromSuperview()
                    }
                }
                imageView = UIImageView(image: inactiveImg)
                contentStackView.addArrangedSubview(imageView!)
            }
        }
    }
}


// MARK: Title Page Custom Navigation Bar
extension TitledPageViewControllerClass {
    class NavigationView: UIView {
        var whiteImageBack = UIImage.set_image(named: "iconsArrowCaretleftWhite")
        var whiteImageMore = UIImage.set_image(named: "IMG_topbar_more_white")
        var imageBack = UIImage.set_image(named: "iconsArrowCaretleftBlack")
        var imageMore = UIImage.set_image(named: "IMG_topbar_more_black")
        
        let buttonAtLeft = TSButton(type: .custom)
        
        public var navigationHiddenTitleColor: UIColor = UIColor.white
        public var navigationShownTitleColor: UIColor = UIColor.black
        
        private let leftBarStackView: UIStackView = UIStackView(frame: .zero).configure {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 16
            $0.contentCompressionResistancePriority = .required
        }
        private let rightBarStackView: UIStackView = UIStackView(frame: .zero).configure {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 15
            $0.contentCompressionResistancePriority = .required
        }
        public let labelForTitle: UILabel = UILabel(frame: .zero).configure {
            $0.font = UIFont.boldSystemFont(ofSize: 18)
            $0.textColor = .white
            $0.lineBreakMode = .byTruncatingTail
            $0.horizontalCompressionResistancePriority = .defaultLow
        }
        
        public let bottomSeparator: UIView = UIView(frame: .zero).configure {
            $0.backgroundColor = TSColor.inconspicuous.disabled
        }
        private let titleStackview: UIStackView = UIStackView(frame: .zero).configure {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.alignment = .center
            $0.spacing = 8
        }
        public var avatar: AvatarView = AvatarView(type: .width26(showBorderLine: false)).configure {
            $0.makeHidden()
        }
        
        private let mainContainerView = UIStackView().configure {
            $0.axis = .horizontal
            $0.distribution = .equalCentering
            $0.alignment = .center
            $0.spacing = 16
        }
        
        let titleContainerView = UIStackView().configure {
            $0.axis = .vertical
            $0.distribution = .equalSpacing
            $0.alignment = .leading
        }
        
        public var userInfo: UserInfoModel? {
            didSet {
                guard let model = userInfo else {
                    avatar.makeHidden()
                    return
                }
                avatar.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: model.sex)
                avatar.shouldAnimate = true
                avatar.avatarInfo = model.avatarInfo()
                avatar.buttonForAvatar.addTap { [weak self] (_) in
                    guard let self = self else { return }
                    self.onTitleTapped?()
                }
                labelForTitle.font = UIFont.systemRegularFont(ofSize: 12)
                labelForTitle.textColor = .black
                avatar.makeVisible()
            }
        }
        
        public var title: String? {
            set {
                labelForTitle.text = newValue
            }
            get {
                return labelForTitle.text
            }
        }
        
        public var onBackButtonTapped: (() -> ())? = nil {
            didSet {
                guard onBackButtonTapped != nil else {
                    if buttonAtLeft.superview != nil {
                        buttonAtLeft.removeFromSuperview()
                    }
                    return
                }
                addLeftBarItem(item: buttonAtLeft, atIndex: 0)
                buttonAtLeft.addAction {
                    self.onBackButtonTapped?()
                }
            }
        }
        
        public var onTitleTapped: EmptyClosure? = nil
        public var onStatusBarChanged: ((Bool) -> Void)? = nil
        var isButtonWhite = true
        var centY: CGFloat = 0
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupUI() {
            buttonAtLeft.setImage(whiteImageBack, for: .normal)
            backgroundColor = UIColor.white.withAlphaComponent(0)
        
            addSubview(mainContainerView)
            mainContainerView.addArrangedSubview(leftBarStackView)
            mainContainerView.addArrangedSubview(titleContainerView)
            mainContainerView.addArrangedSubview(rightBarStackView)
            addSubview(bottomSeparator)
            
            mainContainerView.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
                $0.height.equalTo(50)
            }
            
            titleContainerView.snp.makeConstraints {
                $0.center.equalToSuperview()
            }
            
            titleContainerView.addArrangedSubview(titleStackview)
            titleStackview.snp.makeConstraints {
                $0.width.lessThanOrEqualTo(UIScreen.main.bounds.width / 2.5)
            }
            bottomSeparator.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.height.equalTo(1)
                $0.left.equalTo(15)
                $0.right.equalTo(-15)
                
            }

            titleStackview.addArrangedSubview(avatar)
            titleStackview.addArrangedSubview(labelForTitle)
            avatar.snp.makeConstraints {
                $0.width.height.equalTo(26)
            }
            
            titleStackview.snp.makeConstraints {
                $0.centerY.equalToSuperview()
            }
        }
        
        public func addLeftBarItem(item: UIView, atIndex index: Int = -1) {
            if index == -1 {
                leftBarStackView.addArrangedSubview(item)
            } else {
                leftBarStackView.insertArrangedSubview(item, at: index)
            }
        }
        
        public func addRightBarItem(item: UIView, atIndex index: Int = -1) {
            if index == -1 {
                rightBarStackView.addArrangedSubview(item)
            } else {
                rightBarStackView.insertArrangedSubview(item, at: index)
            }
        }
        
        public func setTitleLeftAlign() {
            titleContainerView.snp.removeConstraints()
        }
        
        func updateChildView(offset: CGFloat, shouldUpdateButtonColor: Bool = true) {
            if self.title == "more_support_system".localized {//支持系统
                return
            }
            let offset = offset
            updateBackGroundColor(offset)
            if shouldUpdateButtonColor {
                updateButton(offset)
            }
        }
        
        private func updateButton(_ offset: CGFloat) {
            var shouldWhite = offset < (self.bounds.height / 2) // expanded
        
            if self.title == "dashboard_profile".localized || self.title == "more_support_system".localized{
                //在个人中心取消顶部导航栏颜色变化 、 支持系统
                shouldWhite = false
                self.labelForTitle.isHidden = self.userInfo == nil
            }
            if userInfo != nil {
                if shouldWhite {
                    titleStackview.isHidden = true
//                    bottomSeparator.isHidden = true
                } else {
                    titleStackview.isHidden = false
//                    bottomSeparator.isHidden = false
                }
            } else {
                if shouldWhite && buttonAtLeft.imageView?.image != whiteImageBack {
                    isButtonWhite = true
                    buttonAtLeft.setImage(whiteImageBack, for: .normal)
//                    bottomSeparator.isHidden = true
                } else if !shouldWhite && buttonAtLeft.imageView?.image != imageBack {
                    isButtonWhite = false
                    buttonAtLeft.setImage(imageBack, for: .normal)
//                    bottomSeparator.isHidden = false
                }
                self.onStatusBarChanged?(shouldWhite)
            }
        }

        private func updateBackGroundColor(_ offset: CGFloat) {
            let colorOffset = offset / self.bounds.height
            backgroundColor = UIColor.white.withAlphaComponent(colorOffset)
        }
    }
}

