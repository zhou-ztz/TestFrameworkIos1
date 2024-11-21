//
// Created by Francis Yeap on 27/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import SwiftEntryKit

private enum ResponseSegment: Int {
    case comment = 0
    case reaction = 1

    init?(rawValue: Int)  {
        switch rawValue {
        case 0: self = .comment
        case 1: self = .reaction
        default: return nil
        }
    }
}

class ResponsePageController: TSViewController {

    private var segments: [ResponseSegment] = [.comment, .reaction]
    fileprivate var activeSegments: ResponseSegment = .comment
    private(set) var theme: Theme = .white
    
    private lazy var segmentView: SegmentView = {
        let segment: SegmentView = SegmentView(configs: [HeadingSelectionViewStyles.largeText(text: "comment", highlightColor: UIColor.black, unhighlightColor: UIColor.black, indicatorColor: UIColor.clear),
                                                         ])
        return segment
    }()
    lazy var titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.applyStyle(.regular(size: 14, color:.black))
        label.text = "comment".localized
        label.textAlignment = .center
        return label
    }()

    private let closeButton = UIButton()
    private(set) var feed: FeedListCellModel
    private lazy var reactionController = { return ReactionController(theme: self.theme, feedId: feed.idindex) }()
    private lazy var commentController = { return CommentPageController(theme: self.theme, feedId: feed.idindex, feedOwnerId: feed.userId, feedItem: feed) }()

    private let pagecontroller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private let contentstack = UIStackView().configure { v in
        v.axis = .vertical
        v.spacing = 8
        v.distribution = .fill
        v.alignment = .leading
    }

    private var onToolbarUpdated: onToolbarUpdate?
    
    init(theme: Theme, feed: FeedListCellModel, defaultSegment: Int = 0, onToolbarUpdate: onToolbarUpdate?) {
        self.feed = feed
        super.init(nibName: nil, bundle: nil)
        self.theme = theme
        self.activeSegments = segments[defaultSegment]
        self.onToolbarUpdated = onToolbarUpdate
        
  
        commentController.onLoaded = { [weak self] count in
            self?.feed.toolModel?.commentCount = count
            guard let self = self else { return }
            self.onToolbarUpdated?(self.feed)
        }
        
        reactionController.onLoaded = { [weak self] stats in
           
        }
    }
    
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        updateTheme()
        setClearNavBar()
        self.setLeftAlignedNavigationItemView(titleLabel)
        self.edgesForExtendedLayout = []

        closeButton.setImage(UIImage.set_image(named: "ic_gray_close"))
        closeButton.contentEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didReciveAvatarDidClick), name: NSNotification.Name.AvatarButton.DidClick, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AvatarButton.DidClick, object: nil)
    }

    private func updateTheme() {
        switch theme {
        case .white:
            view.backgroundColor = .white
            navigationController?.navigationBar.barTintColor = UIColor.white
            closeButton.tintColor = .black
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.backgroundColor = .white
            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = .white
                self.navigationController?.navigationBar.standardAppearance = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            }
            
        case .dark:
            view.backgroundColor = AppTheme.materialBlack
            navigationController?.navigationBar.barTintColor = AppTheme.materialBlack
            closeButton.tintColor = .white
            navigationController?.navigationBar.tintColor = AppTheme.materialBlack
            navigationController?.navigationBar.isTranslucent = false
            navigationController?.navigationBar.backgroundColor = AppTheme.materialBlack
            if #available(iOS 15, *) {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = AppTheme.materialBlack
                self.navigationController?.navigationBar.standardAppearance = appearance
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
            }
        }
    }

    private func setup() {
        view.backgroundColor = .white
        view.addSubview(contentstack)
        contentstack.snp.makeConstraints { v in
            v.top.left.right.equalToSuperview()
            v.bottom.lessThanOrEqualToSuperview()
        }

        self.navigationController?.navigationBar.roundCorners([.topLeft, .topRight], radius: 10)
        self.navigationController?.navigationBar.clipsToBounds = true
        
        let leftPaddingView = UIView(frame: CGRectMake(0, 0, 15, 15))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftPaddingView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
        
        closeButton.addTap { [weak self] (_) in
            self?.dismiss(animated: true, completion: nil)
        }

        addChild(commentController)
        addChild(reactionController)

        view.addSubview(commentController.view)
        view.addSubview(reactionController.view)

        commentController.didMove(toParent: self)
        reactionController.didMove(toParent: self)

        commentController.view.bindToEdges()
        reactionController.view.bindToEdges()
        
        updateSegmentView()
        
        segmentView.didSelectIndex = { [weak self] index in
            guard let self = self else { return }
            let segment = self.segments[index]
            self.activeSegments = segment
            self.updateSegmentView()
        }
    }
    
    private func updateSegmentView() {
        
        switch activeSegments {
        case .comment:
            self.commentController.view.makeVisible()
            self.reactionController.view.makeHidden()
            self.view.bringSubviewToFront(self.commentController.view)

        case .reaction:
            self.reactionController.view.makeVisible()
            self.commentController.view.makeHidden()
            self.view.bringSubviewToFront(self.reactionController.view)
        }
    }
    
    @objc func didReciveAvatarDidClick() {
        self.dismiss(animated: true, completion: nil)
    }
}
//
//private class PageHandler: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
//
//    weak var responseController: ResponsePageController?
//    weak var pageController: UIPageViewController? {
//        didSet {
//            pageController?.delegate = self
//            pageController?.dataSource = self
//        }
//    }
//
//    init(responseController: ResponsePageController) {
//        self.responseController = responseController
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        guard let pageController = self.pageController else { return }
//        guard let responseController = self.responseController else { return }
//        if let currentVC = pageController.viewControllers?.first as? CommentPageController {
//            responseController.activeSegments = .comment
//        } else if let currentVC = pageController.viewControllers?.first as? ResponsePageController {
//            responseController.activeSegments = .reaction
//        }
//
//
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        guard let pageController = self.pageController else { return nil }
//        guard let responseController = self.responseController else { return nil }
//        if let currentVC = pageController.viewControllers?.first as? CommentPageController {
//            return nil
//        } else if let currentVC = pageController.viewControllers?.first as? ResponsePageController {
//            return CommentPageController(theme: responseController.theme)
//        }
//
//        return nil
////
////        guard let pageController = self.pageController else { return nil }
////        guard let responseController = self.responseController else { return nil }
////
////        switch responseController.activeSegments {
////        case .reaction: return CommentPageController(theme: responseController.theme)
////        case .comment: return nil
////        }
////        let newIndex = curIndex - 1
////        guard let beforeSegment = ResponseSegment(rawValue: newIndex) else { return nil }
////
////        switch beforeSegment {
////        case .comment:return  CommentPageController(theme: responseController.theme)
////        case .reaction: return  ReactionController(theme: responseController.theme)
////        default: return nil
////        }
//
////        guard let currentVC = pageController.viewControllers?.first as? CommentPageController else { return nil }
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//
//        guard let pageController = self.pageController else { return nil }
//        guard let responseController = self.responseController else { return nil }
//        if let currentVC = pageController.viewControllers?.first as? CommentPageController {
//            return ReactionController(theme: responseController.theme, reference: responseController)
//        } else if let currentVC = pageController.viewControllers?.first as? ResponsePageController {
//            return nil
//        }
////        switch responseController.activeSegments {
////        case .reaction: return nil
////        case .comment: return
////        let newIndex = curIndex + 1
////        guard let nextSegment = ResponseSegment(rawValue: newIndex) else { return nil }
////
////        switch nextSegment {
////        case .comment: return CommentPageController(theme: responseController.theme)
////        case .reaction: return ReactionController(theme: responseController.theme)
////        default: return nil
////        }
//
//        return nil
//    }
//}
