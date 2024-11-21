//
//  MediaGalleryPageViewController.swift
//  Yippi
//
//  Created by Khoo on 18/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class MediaGalleryPageViewController: TSViewController {
    var scollToFocus: Bool = false
    var calendar: Calendar? = nil
    var titles: [AnyHashable]?
    var contents: [String : Any]?
    
    var objects: [MediaPreviewObject]?
    var pageViewController: UIPageViewController?
    var focusObject: MediaPreviewObject?
    var session: NIMSession?
    var showMore = false
    
    init(objects: [MediaPreviewObject], focusObject: MediaPreviewObject, session: NIMSession , showMore: Bool) {
        self.session = session
        self.objects = objects
        self.focusObject = focusObject
        self.showMore = showMore
        calendar = Calendar.current
        contents = [String : Any]()
        titles = [String]()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton(backImage: true, titleStr: "pic_video".localized)
        
        if showMore {
            self.setupRightNavItem()
        }
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self
        self.pageViewController!.dataSource = self
                
        if let focusObject = focusObject, let objects = self.objects {
            let index = self.indexOf(object: focusObject)
            
            let object = objects[index]
            let initialViewController = self.viewControllerWithPageIndex(pageIndex: index, onPlayVideo: focusObject.objectId == object.objectId)
            initialViewController!.view.tag = index
            let viewControllers: [UIViewController] = [initialViewController!]

            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)

            self.addChild(self.pageViewController!)
            self.view.addSubview(self.pageViewController!.view)
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
        }
    }
    
    func indexOf(object: MediaPreviewObject) -> Int {
        var row = objects!.index(of: object)
        row = (row != NSNotFound ? row : 0)
        
        return row ?? 0
    }
    
    func setupRightNavItem() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        
        button.setImage(UIImage.set_image(named: "icon_gallery_more_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "icon_gallery_more_pressed"), for: .highlighted)
        button.sizeToFit()
        
        let buttonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    @objc func onMore() {
        let session: NIMSession = NIMSession(self.session!.sessionId, type: self.session!.sessionType)
        let viewController = ChatMediaViewController.init(session: session)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Custom methods
    func viewControllerWithPageIndex(pageIndex: Int, onPlayVideo: Bool) -> UIViewController? {
        if pageIndex < 0 || pageIndex >= self.objects!.count {
            return nil
        }
        
        let object = self.objects![pageIndex]
        
        if object.type == MediaPreviewType.video {
            let item = VideoViewItem(videoObject: object)
            let viewController = ChatMediaVideoPlayerViewController(url: item.url)
            viewController.view.tag = pageIndex
            return viewController
        } else {
            let item = GalleryItem()
            item.thumbPath = object.thumbPath!
            item.imageURL = object.url ?? ""
            item.name = object.displayName ?? ""
            item.itemId = object.objectId!
            item.size = object.imageSize
            
            let viewController = GalleryViewController(item: item, session: nil)
            viewController.ext = NSString(string: object.thumbPath!).pathExtension as String
            viewController.view.tag = pageIndex
            return viewController
        }
    }
}

extension MediaGalleryPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewControllerWithPageIndex(pageIndex: index + 1, onPlayVideo: false)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = viewController.view.tag
        return self.viewControllerWithPageIndex(pageIndex: index-1, onPlayVideo: false)
    }
}
