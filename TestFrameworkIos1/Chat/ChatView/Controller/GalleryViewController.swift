//
//  GalleryViewController.swift
//  Yippi
//
//  Created by Khoo on 12/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SDWebImage
import NIMSDK

class GalleryItem {
    var item: String?
    var itemId: String?
    var thumbPath: String?
    var imageURL: String?
    var name: String?
    var size = CGSize.zero
}

class GalleryViewController: TSViewController {
    let pageIndex: Int = 0
    
    @IBOutlet var galleryImageView: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    var gallerySdImageView = SDAnimatedImageView()

    var currentItem: GalleryItem?
    var session: NIMSession?
    var onceToken: Bool = false
    var ext: String = ""

    init(item: GalleryItem?, session: NIMSession?) {
        super.init(nibName: "GalleryViewController", bundle: nil)
        currentItem = item
        self.session = session
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = .black
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.galleryImageView.isHidden = true
        self.scrollView.addSubview(self.gallerySdImageView)
    }
    
    override func viewDidLayoutSubviews() {
        if !onceToken {
            self.loadImage()
            onceToken = true
        }
    }
    
    func loadImage () {
        var insets: UIEdgeInsets = .zero
        
        if #available(iOS 11.0, *) {
            insets = self.scrollView.adjustedContentInset;
        } else {
            insets = self.scrollView.contentInset
        }
        
        self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.37
        self.scrollView.maximumZoomScale = 1
        self.scrollView.zoomScale = 0.37
        self.scrollView.contentSize = CGSize(width: self.scrollView.width - insets.left - insets.right, height: self.scrollView.height - insets.top - insets.bottom)

        self.layoutGallery(size: currentItem!.size)
        
        weak var wself = self
        let url = URL(string: currentItem!.imageURL!)
        if ext == "gif" {
            self.galleryImageView.isHidden = true
            self.gallerySdImageView.isHidden = false
            self.gallerySdImageView.sd_setImage(with: url, placeholderImage: UIImage(contentsOfFile: (currentItem?.thumbPath)!), options: []) { (image, error, type, imageUrl) in
                DispatchQueue.main.async {
                    if error == nil {
                        guard let image = image else { return }
                        wself?.layoutGallery(size: image.size)
                        wself?.gallerySdImageView.image = image
                    }
                }
            }
        }else{
            self.gallerySdImageView.isHidden = true
            self.galleryImageView.isHidden = false
            self.galleryImageView.sd_setImage(with: url, placeholderImage: UIImage(contentsOfFile: (currentItem?.thumbPath)!), options: []) { (image, error, type, imageUrl) in
                DispatchQueue.main.async {
                    if error == nil {
                        guard let image = image else { return }
                        wself?.layoutGallery(size: image.size)
                        wself?.galleryImageView.image = image
                    }
                }
            }
        }
        
        
        
        
        if self.session != nil{
            self.setupRightNavItem()
        }
        
        if (currentItem?.name?.count ?? 0) != 0{
            self.navigationItem.title = currentItem?.name
        }
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressImageView(gestureRecognizer:)))
        self.scrollView.addGestureRecognizer(recognizer)
    }
    
    func layoutGallery (size: CGSize) {
        self.galleryImageView.size = self.scrollView.contentSize
        self.galleryImageView.contentMode = .scaleAspectFit
        self.galleryImageView.centerY = self.view.height * 0.5//self.galleryImageView.height * 0.5
        
        self.gallerySdImageView.size = self.scrollView.contentSize
        self.gallerySdImageView.contentMode = .scaleAspectFit
        self.gallerySdImageView.centerY = self.view.height * 0.5 //self.gallerySdImageView.height * 0.5
        self.gallerySdImageView.centerX = self.view.width * 0.5
    }
    
    func setupRightNavItem () {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore(_:)), for: .touchUpInside)
        button.setImage(UIImage.set_image(named: "icon_gallery_more_normal"), for: .normal)
        button.setImage(UIImage.set_image(named: "icon_gallery_more_normal"), for: .normal)
        button.sizeToFit()
        let buttonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    private func saveImageToAlbum(imageFile: UIImage) {
        TSUtil.checkAuthorizeStatusByType(type: .album, viewController: self, completion: {
            DispatchQueue.main.async {
                UIImageWriteToSavedPhotosAlbum(imageFile, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        })
    }
    
    //MARK: - Add image to Library
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "success_unsave".localized, message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "success_save".localized, message: "photo_saved_success".localized, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "ok".localized, style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func onMore (_ sender: Any) {
        
    }
    
    @objc func onLongPressImageView(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let controller = UIAlertController()
            weak var wself = self
            guard let imageURL = wself?.currentItem?.imageURL else { return }
            SDWebImageManager.shared.imageCache.queryImage(forKey: imageURL, options: .fromCacheOnly, context: nil) { (image, data, cacheType) in
                var image = image
                if image == nil {
                    image = wself?.galleryImageView.image
                } else {
                    let saveAction = UIAlertAction(title: "save_to_album".localized, style: .default) { (action) in
                        self.saveImageToAlbum(imageFile: image!)
                    }
                    
                    let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
                    
                    controller.addAction(saveAction)
                    controller.addAction(cancelAction)
                    
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    func previewObjectByVideo (object: NIMVideoObject) -> MediaPreviewObject {
        let previewObject = MediaPreviewObject()
        previewObject.objectId = object.message?.messageId
        previewObject.thumbPath = object.coverPath
        previewObject.thumbUrl  = object.coverUrl
        previewObject.path      = object.path
        previewObject.url       = object.url
        previewObject.type      = MediaPreviewType.video
        previewObject.timestamp = object.message!.timestamp
        previewObject.displayName = object.displayName
        previewObject.duration  = TimeInterval(object.duration)
        previewObject.imageSize = object.coverSize
        
        return previewObject
    }
    
    func previewObjectByImage(object: NIMImageObject) -> MediaPreviewObject {
        let previewObject = MediaPreviewObject()
        previewObject.objectId = object.message!.messageId
        previewObject.thumbPath = object.thumbPath
        previewObject.thumbUrl  = object.thumbUrl
        previewObject.path      = object.path
        previewObject.url       = object.url
        previewObject.type      = MediaPreviewType.image
        previewObject.timestamp = object.message!.timestamp
        previewObject.displayName = object.displayName
        previewObject.imageSize = object.size
        return previewObject;
    }
    
    func alertSingleSnapViewWithMessage(message: NIMMessage, baseView view:UIView) -> UIView? {
        let messageObject = message.messageObject as? NIMCustomObject
        // TODO: Add one more snapchat attachment condition
        if !(messageObject is NIMCustomObject) {
            return nil
        }
        
        let galleryImageView = SingleSnapView(frame: UIScreen.main.bounds, object: messageObject!)
        galleryImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        galleryImageView.backgroundColor = .black
        galleryImageView.contentMode = .scaleAspectFit
        
        galleryImageView.isUserInteractionEnabled = false
        
        return galleryImageView
    }
}

extension GalleryViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.galleryImageView
    }
}

class SingleSnapView: UIImageView {
    let progressView: UIProgressView!
    let messageObject: NIMCustomObject!
    
    init(frame: CGRect, object: NIMCustomObject) {
        messageObject = object
        progressView = UIProgressView(frame: .zero)
        let width = 200 * Constants.Layout.UIScreenWidth/320
        progressView.width = width
        progressView.isHidden = true
        
        super.init(frame: frame)
        addSubview(progressView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(progress: Float) {
        self.progressView.setProgress(progress, animated: false)
        self.progressView.isHidden = progress>0.99
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.progressView.centerY = self.height * 0.5
        self.progressView.centerX = self.width * 0.5
    }
}
