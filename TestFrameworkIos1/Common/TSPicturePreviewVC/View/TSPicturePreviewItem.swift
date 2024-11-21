//
//  TSPicturePreviewCell.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/4.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit

import SDWebImage
import RealmSwift
import AssetsLibrary
import MobileCoreServices

/// cell 的代理方法
protocol TSPicturePreviewItemDelegate: class {
    /// 单击了 cell
    func itemDidSingleTaped(_ item: TSPicturePreviewItem)
    /// 长按 cell
    func itemDidLongPressed(_ item: TSPicturePreviewItem)
    /// 保存图片操作完成
    func item(_ item: TSPicturePreviewItem, didSaveImage error: Error?)
    /// 购买了某张图
    func itemFinishPaid(_ item: TSPicturePreviewItem)
    /// 保存图片
    func itemSaveImage(item: TSPicturePreviewItem)
}

class TSPicturePreviewItem: UIView, UIScrollViewDelegate {
    weak var superVC: TSPicturePreviewVC?
    /// 图片数据模型
    var imageObject: TSImageObject?
    /// 滚动视图
    private var scrollView = UIScrollView()
    private var imageContainerView = UIView()
    /// 购买按钮
    var buttonForBuyRead: TSColorLumpButton = {
        let button = TSColorLumpButton.initWith(sizeType: .large)
        button.setTitle("see_origin_photo_pay".localized, for: .normal)
        return button
    }()
    /// 成为会员按钮
    var buttonForVIP: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    /// 图片视图
    var imageView = SDAnimatedImageView()
    /// 图片的位置
    var imageViewFrame: CGRect {
        return imageContainerView.frame
    }

    /// 保存图片的开关
    var canBeSave = false

    /// 代理
    weak var delegate: TSPicturePreviewItemDelegate?

    /// 占位图
    var placeholder: UIImage?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUI()
    }

    // MARK: - Custom user interface
    private func setUI() {
        // scrollview
        scrollView.frame = self.bounds
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2.5
        scrollView.isMultipleTouchEnabled = true
        scrollView.delegate = self
        scrollView.scrollsToTop = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delaysContentTouches = false
        scrollView.canCancelContentTouches = true
        scrollView.alwaysBounceVertical = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }

        // imageContainer
        imageContainerView.clipsToBounds = true
        imageContainerView.backgroundColor = .clear

        // imageview
        imageView.clipsToBounds = true

        // 成为会员按钮
        buttonForVIP.frame = CGRect(x: (UIScreen.main.bounds.width - 190) / 2, y: buttonForBuyRead.frame.maxY + 15, width: 190, height: 17)
        buttonForVIP.addTarget(self, action: #selector(VIPButtonTaped(_:)), for: .touchUpInside)
        buttonForVIP.isHidden = true

        // gesture
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.3
        longPress.require(toFail: doubleTap)
        singleTap.require(toFail: doubleTap)
        addGestureRecognizer(singleTap)
        addGestureRecognizer(doubleTap)
        addGestureRecognizer(longPress)

        addSubview(scrollView)
        addSubview(buttonForBuyRead)
        addSubview(buttonForVIP)
        scrollView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
    }

    // MARK: - Public
    /// 加载视图
    func setInfo(_ object: TSImageObject, smallImage: UIImage?, loadGif: Bool = false) {
        /// 1.刷新布局
        imageContainerView.frame = CGRect(x:0, y:0, width: frame.width, height: imageContainerView.bounds.height)
        let imageWidth = (smallImage?.size.width).orZero
        let imageHeight = (smallImage?.size.height).orZero
        if imageHeight / imageWidth > UIScreen.main.bounds.height / UIScreen.main.bounds.width {
            let height = floor(imageHeight / (imageWidth / UIScreen.main.bounds.width))
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
        } else {
            var height = imageHeight / imageWidth * frame.width
            if height < 1 || height.isNaN {
                height = frame.height
            }
            height = floor(height)
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
            imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }

        if imageContainerView.frame.height > frame.height && imageContainerView.frame.height - frame.height <= 1 {
            var originFrame = imageContainerView.frame
            originFrame.size.height = frame.height
            imageContainerView.frame = originFrame
        }

        scrollView.contentSize = CGSize(width: frame.width, height: max(imageContainerView.frame.height, frame.height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.height > frame.height
        imageView.frame = imageContainerView.bounds
        // 2.加载图片
        imageObject = object
        canBeSave = false // not being used at the moment
        imageView.contentMode = .scaleAspectFit

         if object.mimeType == "image/gif" {
             imageView.shouldCustomLoopCount = true
             imageView.animationRepeatCount = 0
             imageView.sd_setImage(with: object.storageIdentity.imageUrl().urlValue,
                                          placeholderImage: smallImage,
                                          options: loadGif ? [.highPriority, .refreshCached] : [.highPriority, .decodeFirstFrameOnly],
                                          completed: nil)

         } else {
            imageView.sd_setImage(with: object.storageIdentity.imageUrl().smallPicUrl(showingSize: imageViewFrame.size).urlValue,
                                          placeholderImage: smallImage,
                                          options: .highPriority,
                                          completed: nil)

         }
        // 1.判断图片是否需要付费

        // 2.1 查看收费（下载收费，在长按后点击了“保存到手机相册”时，进行拦截）
        if object.type == "read" && object.paid.value == false {
            // 关闭保存图片的操作
            canBeSave = false
            // 显示购买按钮
            buttonForBuyRead.isHidden = false
            // 显示成为会员按钮
            buttonForBuyRead.isHidden = false
        }
        // 兼容处理
        // 如果只有图片，没有TSImageObject而是直接通过Image展示的情况，比如聊天列表查看大图
        if object.storageIdentity == 0 {
            self.canBeSave = true
        }
    }

    func changePictureFrame(image: UIImage?) {
        imageContainerView.frame = CGRect(x:0, y:0, width: frame.width, height: imageContainerView.bounds.height)
        let imageWidth = image!.size.width
        let imageHeight = image!.size.height
        if imageHeight / imageWidth > UIScreen.main.bounds.height / UIScreen.main.bounds.width {
            let height = floor(imageHeight / (imageWidth / UIScreen.main.bounds.width))
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
        } else {
            var height = imageHeight / imageWidth * frame.width
            if height < 1 || height.isNaN {
                height = frame.height
            }
            height = floor(height)
            var originFrame = imageContainerView.frame
            originFrame.size.height = height
            imageContainerView.frame = originFrame
            imageContainerView.center = CGPoint(x:self.imageContainerView.center.x, y:self.bounds.height / 2)
        }
        if imageContainerView.frame.height > frame.height && imageContainerView.frame.height - frame.height <= 1 {
            var originFrame = imageContainerView.frame
            originFrame.size.height = frame.height
            imageContainerView.frame = originFrame
        }
        scrollView.contentSize = CGSize(width: frame.width, height: max(imageContainerView.frame.height, frame.height))
        scrollView.scrollRectToVisible(bounds, animated: false)
        scrollView.alwaysBounceVertical = imageContainerView.frame.height > frame.height
        imageView.frame = imageContainerView.bounds
    }

    /// 完成了保存图片
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let delegate = delegate {
            delegate.item(self, didSaveImage: error)
        }
    }

    // GIF保存结果
    func gifImageDidFinishSavingWithError(error: Error?) {
        if let delegate = delegate {
            delegate.item(self, didSaveImage: error)
        }
    }

    // MARK: - Button click
    /// 单击 cell
    @objc func singleTap(_ gusture: UITapGestureRecognizer) {
        if let delegate = delegate {
            delegate.itemDidSingleTaped(self)
        }
    }

    /// 双击 cell
    @objc func doubleTap(_ gusture: UITapGestureRecognizer) {
        if scrollView.zoomScale > 1.0 {
            // 状态还原
            scrollView.setZoomScale(1.0, animated: true)
        } else {
            let touchPoint = gusture.location(in: imageView)
            let newZoomScale = scrollView.maximumZoomScale
            let xsize = frame.size.width / newZoomScale
            let ysize = frame.size.height / newZoomScale

            scrollView.zoom(to: CGRect(x: touchPoint.x - xsize / 2, y: touchPoint.y - ysize / 2, width: xsize, height: ysize), animated: true)
        }
    }

    /// 长按 cell
    @objc func longPress(_ gusture: UILongPressGestureRecognizer) {
        if gusture.state == .began {
            if let delegate = delegate {
                if canBeSave {
                    delegate.itemDidLongPressed(self)
                }
            }
        }
    }

    /// 点击了成为会员按钮
    @objc func VIPButtonTaped(_ sender: UIButton) {
        // [长期注释] 成为会员
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageContainerView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        imageContainerView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }

}
