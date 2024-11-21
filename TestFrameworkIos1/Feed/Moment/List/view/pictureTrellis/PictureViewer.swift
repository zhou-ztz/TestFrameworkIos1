//
//  PictureViewer.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  单张图片加载视图

import UIKit
import RealmSwift
import SDWebImage


class PictureViewer: UIControl {

    /// 图片数据 model
    public var model = PaidPictureModel() {
        didSet {
            loadModel()
        }
    }
    /// 图片
    var picture: UIImage? {
        return pictureView.image
    }
    /// 在屏幕上的 frame
    var frameOnScreen: CGRect {
        let screenOrigin = pictureView.convert(pictureView.frame.origin, to: nil)
        return CGRect(origin: screenOrigin, size: size)
    }

    /// 屏幕比例
    internal let scale = UIScreen.main.scale
    // 加载图片的网络请求头
//    internal let modifier = AnyModifier { request in
//        var r = request
//        if let authorization = TSCurrentUserInfo.share.accountToken?.token {
//            r.setValue("Bearer " + authorization, forHTTPHeaderField: "Authorization")
//        }
//        return r
//    }

    /// 图片占位图
    internal var placeholder: UIImage {
        return cacheImage ?? UIImage.create(with: TSColor.inconspicuous.disabled, size: frame.size)
    }
    /// 缓存图片
    var cacheImage: UIImage?
    var shouldAnimateGif: Bool = false
    /// 长图标识
    let longiconView = FadeImageView()
    /// 图片视图
    let pictureView = FadeImageView()
    
    // MARK: - 生命周期
    init() {
        super.init(frame: .zero)
        setUI()
        setNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.PaidImage.buyPic, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
    }

    // MARK: - UI

    /// 设置基础视图
    internal func setUI() {
        // 1.图片视图
        pictureView.contentScaleFactor = UIScreen.main.scale
        pictureView.contentMode = .scaleAspectFill
        pictureView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        pictureView.clipsToBounds = true
        pictureView.backgroundColor = TSColor.inconspicuous.background
        addSubview(pictureView)
        // 2.长图标识
        let image = UIImage.set_image(named: "IMG_pic_longpic")
        longiconView.image = image
        longiconView.sizeToFit()
        addSubview(longiconView)
    }

    fileprivate func loadModel() {
        // 2.长图标识
        longiconView.isHidden = !(model.originalSize.isLongPictureSize() && model.shouldShowLongicon)
        // 动图标示
        if model.mimeType == "image/gif" {
            longiconView.isHidden = false
            longiconView.image = UIImage.set_image(named: "pic_gif")
            longiconView.sizeToFit()
        } else {
            longiconView.image = UIImage.set_image(named: "IMG_pic_longpic")
            longiconView.sizeToFit()
        }
        // 1.加载图片
        loadPicture()
    }

    /// 加载图片
    internal func loadPicture(forceToRefresh: Bool = false) {
        // 0.刷新子视图 frame
        updateChildviews()
        
        if let cacheKey = model.cache, SDImageCache.shared.diskImageDataExists(withKey: cacheKey) {
            if shouldAnimateGif {
                pictureView.image = SDImageCache.shared.imageFromDiskCache(forKey: cacheKey)
            } else {
                pictureView.image = UIImage(data: SDImageCache.shared.diskImageData(forKey: cacheKey) ?? Data())
            }
            return
        }
        // 4.如果有网络链接，再加载网络图片（网络加载出的图片会覆盖缓存图片）
        if let url = model.url {
            let imageUrl: String = model.mimeType == "image/gif" ? url : url.appending("?cover=true")
            
            if shouldAnimateGif {
                pictureView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"), options: [SDWebImageOptions.lowPriority, .refreshCached], completed: nil)
                pictureView.shouldCustomLoopCount = true
                pictureView.animationRepeatCount = 0
            } else {
                pictureView.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage.set_image(named: "icPicturePostPlaceholder"), options: [SDWebImageOptions.lowPriority, .refreshCached, .decodeFirstFrameOnly], completed: nil)
            }
        }
    }
    
// https://cdn.joinyippi.com/2019/10/04/0823/9iaxGjA91zdmrpWhtiB2NfiDqyjpLmphdJUTQvth.jpeg?x-oss-process=image%2Fquality%2Cq_90%2Fresize%2Cm_mfit%2Cw_50%2Ch_50%2Fauto-orient%2C1

    /// 刷新子视图 frame
    internal func updateChildviews() {
        // 1.图片视图
        pictureView.frame = bounds
        // 2.长图标识
        let iconX = frame.width - longiconView.width - 4
        let iconY = frame.height - longiconView.height - 4
        longiconView.frame = CGRect(origin: CGPoint(x: iconX, y: iconY), size: longiconView.size)
    }

    /// 更新监听的 token
    func setNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(forceRefreshImage(notification:)), name: NSNotification.Name.PaidImage.buyPic, object: nil)
    }

    @objc func forceRefreshImage(notification: Notification) { }
}

extension String {

    func smallPicUrl(oss: String? = "", showingSize: CGSize, quality: CGFloat = 90) -> String {
        /// 文档 https://slimkit.github.io/docs/api-v2-core-file-storage.html
        /*
         名称    描述
         w    可选，指定图片宽度
         h    可选，指定图片高度
         q    可选，指定图片质量，0 - 90
         b    可选，指定图片高斯模糊程度，0 - 100
         */
        // 尺寸设置为 CGSize.zero，获取原图
        if showingSize == CGSize.zero {
            let imageUrl = self
            return imageUrl
        }
        
        let height = floor(showingSize.width * 2.0)
        let width = floor(showingSize.height * 2.0)
        
        
        if let component = URLComponents(string: self), let index = self.range(of: component.host.orEmpty)?.upperBound, component.host?.hasPrefix("cdn.yiartkeji") ?? false {
            var imageUrl = self
            let heightBool = height > (UIScreen.main.bounds.height * UIScreen.main.scale)
            let widthBool = width > (UIScreen.main.bounds.width * UIScreen.main.scale)

            let stringContent = component.path.contains("cdn-cgi") ? "image/width=\(heightBool || widthBool ? UIScreen.main.bounds.height : height),quality=\(quality)/" : "/cdn-cgi/image/width=\(heightBool || widthBool ? UIScreen.main.bounds.height : height),quality=\(quality)"
            
            imageUrl.insert(contentsOf: stringContent , at: index)
            
            return imageUrl
        }
        
        /// 特别大的图片直接获取原图不要传递宽高参数，会导致无法显示
        if height > (UIScreen.main.bounds.height * UIScreen.main.scale) || width > (UIScreen.main.bounds.width * UIScreen.main.scale) {
            let imageUrl = self + "?w=\(UIScreen.main.bounds.height)&h=\(UIScreen.main.bounds.width)&q=\(quality)"
            return imageUrl
        }
        
        let imageUrl = self + "?w=\(height)&h=\(width)&q=\(quality)"
        return imageUrl
    }
}
