//
//  TSPicturePreviewVC.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/3.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos
import SDWebImage

class TSPicturePreviewVC: TSViewController, UIScrollViewDelegate, TSPicturePreviewItemDelegate, TSCustomAcionSheetDelegate {
    
    /// 判断是否有图片查看器正在显示
    static var isShowing = false
    
    /// 图片数据
    var imageObjects: [TSImageObject] = []
    /// 图片位置
    var smallImagesFrame: [CGRect] = []
    /// 图片
    var smallImages: [UIImage?] = []
    
    /// 当前页数
    var currentPage: Int = 0
    /// 图片 item 的 tag
    let tagForScrollowItem = 200
    
    /// scroll view
    let scrollow = UIScrollView()
    /// 分页控制器
    let pageControl = UIPageControl(frame: CGRect(x: 0, y: 40, width: UIScreen.main.bounds.width, height: 6))
    /// 保存图片弹窗
    var alert: TSCustomActionsheetView?
    /// 动画 ImageView
    let animationImageView = SDAnimatedImageView()
    
    // 补丁属性，在视图 dismiss 的时候回调
    var dismissBlock: (() -> Void)?
    /// 购买了图片的回调
    var paidBlock: ((Int) -> Void)?
    /// 原app是否隐藏
    var isAppHiddenStatusbar = false
    /// 是否显示动画
    var isEnableAnimation = true
        
    // MARK: - Lifecycle
    init(objects: [TSImageObject], imageFrames: [CGRect], images: [UIImage?], At index: Int) {
        super.init(nibName: nil, bundle: nil)
        imageObjects = objects
        smallImages = images
        smallImagesFrame = imageFrames
        currentPage = index
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollow.backgroundColor = UIColor.red
        setUI()
    }
    
    convenience init(objects: [(url: String, res: TSImageObject)], imageFrames: [CGRect], images: [UIImage?], At index: Int) {
        let resources = objects.compactMap { $0.res }
        self.init(objects: resources, imageFrames: imageFrames, images: images, At: index)
        
        
    }
    
    convenience init(objects: [Int], imageFrames: [CGRect], images: [UIImage?], At index: Int) {
        let resources = objects.compactMap {
            fileID -> TSImageObject in
            let object = TSImageObject()
            let imageUrl = TSDownloadNetworkNanger.share.imageUrlStringWithImageFileId(fileID)
            object.netImageUrl = imageUrl
            let subIndex = (TSAppConfig.share.rootServerAddress + TSURLPathV2.path.rawValue + TSURLPathV2.Download.files.rawValue as NSString).length
            if let fileId = Int((imageUrl as NSString).substring(from: subIndex + 1)) {
                object.storageIdentity = fileID
            }
            object.cacheKey = ""
            object.width = 0
            object.height = 0
            object.mimeType = ""
            
            return object
        }
        self.init(objects: resources, imageFrames: imageFrames, images: images, At: index)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollow.setContentOffset(CGPoint(x: CGFloat(currentPage) * self.view.bounds.width, y: 0), animated: false)
        isAppHiddenStatusbar = UIApplication.shared.isStatusBarHidden
    }
    
    // MARK: - Custom user interface
    func setUI() {
        // 限制图片显示的数量
        let imageCount = imageObjects.count
        
        self.automaticallyAdjustsScrollViewInsets = false
        scrollow.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        scrollow.backgroundColor = UIColor.black
        scrollow.showsHorizontalScrollIndicator = false
        scrollow.contentOffset = CGPoint.zero
        scrollow.delegate = self
        scrollow.bounces = false
        scrollow.isPagingEnabled = true
        scrollow.contentSize = CGSize(width: self.view.bounds.width * CGFloat(imageCount), height: self.view.bounds.height)
        for index in 0..<imageCount {
            let previewItem = TSPicturePreviewItem(frame: CGRect(x: CGFloat(index) * UIScreen.main.bounds.width, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
            previewItem.delegate = self
            previewItem.superVC = self
            previewItem.tag = tagForScrollowItem + index
            if smallImages.count > 0, smallImages.count > index, let smallImage = smallImages[index] {
                if currentPage == index {
                    previewItem.setInfo(imageObjects[index], smallImage: smallImage, loadGif: true)
                } else {
                    previewItem.setInfo(imageObjects[index], smallImage: smallImage)
                }
            } else {
                if currentPage == index {
                    previewItem.setInfo(imageObjects[index], smallImage: nil, loadGif: true)
                } else {
                    previewItem.setInfo(imageObjects[index], smallImage: nil)
                }
            }
            scrollow.addSubview(previewItem)
        }
        // page control
        pageControl.numberOfPages = imageObjects.count
        pageControl.currentPage = currentPage
    }
    
    /// 设置显示的动画视图
    func setShowAnimationUX() {
        view.backgroundColor = UIColor.clear
        if smallImagesFrame.count > 0 && smallImages.count > 0 {
            animationImageView.frame = smallImagesFrame[currentPage]
            animationImageView.image = smallImages[currentPage]
            animationImageView.isHidden = false
        } else {
            animationImageView.image = nil
            animationImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
            animationImageView.isHidden = true
        }
        animationImageView.contentMode = .scaleAspectFill
        animationImageView.backgroundColor = TSColor.inconspicuous.disabled
        view.addSubview(animationImageView)
    }
    
    /// 设置隐藏的动画视图
    func setDismissAnimationUX() {
        let item = getPicturePreviewItem(at: currentPage)
        let imageViewFrame = item.imageViewFrame
        animationImageView.frame = imageViewFrame
        animationImageView.image = item.imageView.image
        view.backgroundColor = UIColor.black
        view.addSubview(animationImageView)
        scrollow.removeFromSuperview()
        pageControl.removeFromSuperview()
    }
    
    // MARK: - Delegate
    
    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        currentPage = Int(round(offset.x / self.view.bounds.width))
        pageControl.currentPage = currentPage
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset
        currentPage = Int(round(offset.x / self.view.bounds.width))
        pageControl.currentPage = currentPage
        
        imageObjects[currentPage].locCacheKey = ""
        imageObjects[currentPage].set(shouldChangeCache: true)
        
        guard  imageObjects[currentPage].mimeType == "image/gif" ,let preview = scrollow.viewWithTag(currentPage + tagForScrollowItem) as? TSPicturePreviewItem else { return }
        
        if smallImages.count > 0, smallImages.count > currentPage, let smallImage = smallImages[currentPage] {
            preview.setInfo(imageObjects[currentPage], smallImage: smallImage, loadGif: true)
        } else {
            preview.setInfo(imageObjects[currentPage], smallImage: nil, loadGif: true)
        }
    }
    
    // MARK: TSPicturePreviewItemDelegate
    /// 单击 cell
    func itemDidSingleTaped(_ cell: TSPicturePreviewItem) {
        dismiss()
    }
    
    /// 长按 cell
    func itemDidLongPressed(_ cell: TSPicturePreviewItem) {
        guard alert?.superview == nil else {
            return
        }
        alert = TSCustomActionsheetView(titles: ["save_to_album".localized])
        alert!.delegate = self
        alert!.show()
    }
    
    /// 完成了保存图片
    func item(_ item: TSPicturePreviewItem, didSaveImage error: Error?) {
        let indicator = TSIndicatorWindowTop(state: error == nil ? .success : .faild, title: error == nil ? "save_success".localized : "picture_save_fail".localized)
        indicator.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval)
    }
    
    /// 购买了某张图片
    func itemFinishPaid(_ item: TSPicturePreviewItem) {
        paidBlock?(currentPage)
    }
    
    /// 代理直接执行保存图片
    func itemSaveImage(item: TSPicturePreviewItem) {
        self.saveImage()
    }
    
    /// 执行保存图片
    func saveImage() {
        // 检查写入相册的授权
        TSUtil.checkAuthorizeStatusByType(type: .album, isShowBottom: true, viewController: nil, completion: {
            DispatchQueue.main.async {
                self.storeImageToAlbum()
            }
        })
    }
    
    private func storeImageToAlbum() {
        guard let image = getPicturePreviewItem(at: currentPage).imageView.image else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        self.showTopIndicator(status: error == nil ? .success : .faild, error == nil ? "save_success".localized : "picture_save_fail".localized)
    }
    
    // MARK: TSCustomAcionSheetDelegate
    /// 点击 "保存图片"
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if index == 0 {
            self.saveImage()
        }
    }
    
    // MARK: - Public
    
    /// 过渡动画的时间
    let transitionAnimationTimeInterval: TimeInterval = 0.3
    
    /// 显示图片查看器
    func show() {
        if TSPicturePreviewVC.isShowing {
            return
        }
        TSPicturePreviewVC.isShowing = true
        self.view.frame = UIScreen.main.bounds
//        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//            appDelegate.popupWindow = UIWindow(frame: UIScreen.main.bounds)
//            appDelegate.popupWindow!.rootViewController = self
//            appDelegate.popupWindow!.makeKeyAndVisible()
//        }
        setShowAnimationUX()
        let item = getPicturePreviewItem(at: currentPage)
        /// ST Todo
        if isEnableAnimation {
            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
                self.animationImageView.frame = item.imageViewFrame
                self.view.backgroundColor = UIColor.black
            }) { (_) in
                self.view.addSubview(self.scrollow)
                if self.imageObjects.count > 1 {
                    self.view.addSubview(self.pageControl)
                }
                self.animationImageView.removeFromSuperview()
            }
        } else {
            UIView.animate(withDuration: transitionAnimationTimeInterval, delay: 0.0, options: .curveEaseIn, animations: {
                self.animationImageView.alpha = 1.0
                self.view.backgroundColor = UIColor.black
            }, completion: { (_) in
                self.view.addSubview(self.scrollow)
                if self.imageObjects.count > 1 {
                    self.view.addSubview(self.pageControl)
                }
                self.animationImageView.removeFromSuperview()
            })
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isAppHiddenStatusbar
    }
    
    /// 隐藏图片查看器
    func dismiss() {
        TSPicturePreviewVC.isShowing = false
        setDismissAnimationUX()
        
//        if isEnableAnimation {
//            UIView.animate(withDuration: transitionAnimationTimeInterval, animations: {
//                if self.smallImagesFrame.count > 0, self.smallImagesFrame.count > self.currentPage {
//                    self.animationImageView.frame = self.smallImagesFrame[self.currentPage]
//                } else {
//                    self.animationImageView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)
//                }
//                self.view.backgroundColor = UIColor.clear
//                self.animationImageView.alpha = 0.3
//            }) { (_) in
//                self.dismissBlock?()
//                self.view.removeFromSuperview()
//                self.removeFromParent()
//                self.removeFromParent()
//                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                    appDelegate.popupWindow?.removeFromSuperview()
//                    appDelegate.popupWindow = nil
//                    appDelegate.window?.makeKeyAndVisible()
//                }
//            }
//        } else {
//            UIView.animate(withDuration: transitionAnimationTimeInterval, delay: 0.0, options: .curveEaseOut, animations: {
//                self.animationImageView.alpha = 0.2
//            }, completion: { (_) in
//                self.dismissBlock?()
//                    self.view.removeFromSuperview()
//                    self.removeFromParent()
//                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                        appDelegate.popupWindow?.removeFromSuperview()
//                        appDelegate.popupWindow = nil
//                        appDelegate.window?.makeKeyAndVisible()
//                    }
//                })
//        }
    }
    
    // MARK: - Private
    
    /// 获取图片查看器的图片位置
    func getPicturePreviewItem(at index: Int) -> TSPicturePreviewItem {
        let item = (scrollow.viewWithTag(tagForScrollowItem + currentPage) as? TSPicturePreviewItem)!
        return item
    }
}
