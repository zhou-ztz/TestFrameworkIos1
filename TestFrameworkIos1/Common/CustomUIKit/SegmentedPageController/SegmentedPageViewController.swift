//
//  SegmentedPageViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 03/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

protocol SegmentedPageViewControllerDatasource: class {
    func numberOfPages(in pageViewController: UIPageViewController) -> Int
    func segmentedPageView(pageViewController: UIPageViewController, viewControllerForPageAtIndex index: Int) -> UIViewController?
    func segmentedPageView(pageViewController: UIPageViewController, viewForPageSegmentAtIndex index: Int) -> UIView?
}
protocol SegmentedPageViewControllerDelegate: class {
    func segmentedPageView(pageViewController: UIPageViewController, didChangeToPageAtIndex index: Int)
}

enum SegmentScrollIndicatorType { case scroll, highlight(color: UIColor, isSemibold: Bool = false) }

class SegmentedPageViewController: TSViewController {
    
    // MARK: Views & Controls
    private var scrollIndicatorType: SegmentScrollIndicatorType = .scroll
    let mainStackView: UIStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fill
    }
    lazy var segmentedControl: SegmentedControlScrollView = {
        return SegmentedControlScrollView(indicatorType: scrollIndicatorType, initialIndex: self.initialPageIndex)
    }()
    let pageViewController: UIPageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    // MARK: Public Variables
    public var datasource: SegmentedPageViewControllerDatasource? {
        didSet {
            loadSegments()
            setViewController(atIndex: self.initialPageIndex)
        }
    }
    public var delegate: SegmentedPageViewControllerDelegate?
    public var previousPageIndex:Int = -1
    public var currentPageIndex:Int {
        get {
            return _currentPageIndex
        }
        set {
            previousPageIndex = currentPageIndex
            _currentPageIndex = newValue
            guard datasource != nil else { return }
            guard currentPageIndex >= 0 && currentPageIndex < numberOfPages(), currentPageIndex != previousPageIndex else { return }
            setSelectedSegment(atIndex: currentPageIndex)
            setViewController(atIndex: currentPageIndex)
        }
    }
    private var _currentPageIndex:Int = -1
    private var initialPageIndex: Int = 0
    private var titleStyle: TitledPageTitleStyle = .centerScrolling
    public var defaultBackgroundColor: UIColor = .white
    
    public var activeViewController: UIViewController? {
        get {
            return viewControllerForIndex(index: currentPageIndex)
        }
    }

    init(indicatorType: SegmentScrollIndicatorType = .scroll, titleStyle: TitledPageTitleStyle = .centerScrolling, initialIndex: Int = 0) {
        super.init(nibName: nil, bundle: nil)
        self.scrollIndicatorType = indicatorType
        self.titleStyle = titleStyle
        self.initialPageIndex = initialIndex
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.backgroundColor = defaultBackgroundColor
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSegments()
    }
    
    private func setupUI() {
        
        addChild(pageViewController)
        view.addSubview(mainStackView)
        segmentedControl.titleStyle = titleStyle
        mainStackView.addArrangedSubview(segmentedControl)
        mainStackView.addArrangedSubview(pageViewController.view)
        
        mainStackView.bindToSafeEdges()
        
        segmentedControl.snp.makeConstraints {
            $0.height.equalTo(segmentedControl.segmentedControlHeight)
        }
        
        view.setNeedsLayout()
        view.layoutIfNeeded()

        segmentedControl.onSegmentTap = { [weak self] (index) in
            guard let self = self else { return }
            self.currentPageIndex = index
        }
        
        pageViewController.didMove(toParent: self)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    
    func loadSegments() {
        let pageCount = numberOfPages()
        guard pageCount > 0 else { return }
        var segments: [UIView] = []
        for index in 0..<pageCount {
            guard let view = segmentViewForIndex(index: index) else { return }
            segments.append(view)
        }
        segmentedControl.segments = segments
    }
    
    private func setViewController(atIndex index: Int) {
        guard let viewController = viewControllerForIndex(index: index) else { return }
        pageViewController.setViewControllers([viewController], direction: index > previousPageIndex ? .forward : .reverse, animated: false) { [weak self] (completion) in
            guard let self = self else { return }
            self._currentPageIndex = index
            self.delegate?.segmentedPageView(pageViewController: self.pageViewController, didChangeToPageAtIndex: index)
        }
    }
    
    private func setSelectedSegment(atIndex index:Int) {
        segmentedControl.selectedSegmentIndex = index
    }
    
    private func viewControllerForIndex(index: Int) -> UIViewController? {
        guard let datasource = datasource else { return nil }
        guard index < datasource.numberOfPages(in: pageViewController) else { return nil }
        let viewController = datasource.segmentedPageView(pageViewController: pageViewController, viewControllerForPageAtIndex: index)
        viewController?.view.tag = index
        return viewController
    }
    
    private func segmentViewForIndex(index: Int) -> UIView? {
        guard let datasource = datasource else { return nil }
        guard index < datasource.numberOfPages(in: pageViewController) else { return nil }
        return datasource.segmentedPageView(pageViewController: pageViewController, viewForPageSegmentAtIndex: index)
    }
    
    private func numberOfPages() -> Int {
        guard let datasource = datasource else { return 0 }
        return datasource.numberOfPages(in: pageViewController)
    }
    
    public func setSelectedSegmentTitle(atIndex index:Int) {
        segmentedControl.setSelectedSegment(atIndex: index)
    }
}

extension SegmentedPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let view = viewController.view {
            var viewIndex = view.tag
            guard viewIndex != 0 else { return nil }
            viewIndex -= 1
            return viewControllerForIndex(index: viewIndex)
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var viewIndex = viewController.view.tag
        guard viewIndex < numberOfPages() else { return nil }
        guard viewIndex >= 0 else { return nil }
        viewIndex += 1
        return viewControllerForIndex(index: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard pendingViewControllers.count > 0 else { return }
        let viewIndex = pendingViewControllers[0].view.tag
        segmentedControl.setSelectedSegment(atIndex: viewIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let index = pageViewController.viewControllers?.first?.view.tag else { return }
        segmentedControl._selectedSegmentIndex = index
        segmentedControl.setSelectedSegment(atIndex: index)
        self._currentPageIndex = index
        self.delegate?.segmentedPageView(pageViewController: self.pageViewController, didChangeToPageAtIndex: index)
    }
}
