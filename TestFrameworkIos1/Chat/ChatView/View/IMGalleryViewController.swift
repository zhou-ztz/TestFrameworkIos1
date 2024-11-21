//
//  IMGalleryViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/11.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class IMSingleSnapView: UIImageView {
    
    var progressView: UIProgressView!

    var messageObject: NIMCustomObject!
    
    init(frame: CGRect, object: NIMCustomObject, baseView: UIView){
        super.init(frame: frame)
        messageObject = object
        progressView = UIProgressView()
        progressView.width = 200 * (ScreenWidth / 320.0 )
        progressView.isHidden = true
        progressView.progressTintColor = .blue
        
        self.addSubview(progressView)
        setUI(baseView: baseView)
      
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been Float(implemen)ted")
    }
    
    func setUI(baseView: UIView){
        //self.autoresizingMask = .flexibleWidth
        // By Kit Foong (set IM display picture background to transparent)
        //self.backgroundColor = .black
        self.backgroundColor = .clear
        
        self.contentMode = .scaleAspectFit
        self.isUserInteractionEnabled = false
        
        self.progressView.centerY = self.height * 0.5
        self.progressView.centerX = self.width  * 0.5
        
        baseView.presentSnapView(view: self, animated: true) { [self] in
            guard let attachment = messageObject.attachment as? IMSnapchatAttachment else {return}
            self.sd_setImage(with: URL(string: attachment.url), completed: nil)
            if FileManager.default.fileExists(atPath: attachment.filePath) {
                self.image = UIImage(contentsOfFile: attachment.filePath)
                self.setProgress(progress: 1)
            }else {
                self.downloadImage(url: attachment.url)
            }
            
        }
        
        
    }
    
    func setProgress(progress: CGFloat){
        self.progressView.setProgress(Float(progress), animated: true)
      
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    
    func downloadImage(url: String){
        progressView.isHidden = false
        self.sd_setImage(with: URL(string: url), placeholderImage: nil, options: [.queryMemoryData], context: nil) { [weak self] (receivedSize, expectedSize, targetURL) in
            DispatchQueue.main.async {
                self?.setProgress(progress: CGFloat(receivedSize) / CGFloat(expectedSize))
            }
            
        } completed: { [weak self] (image, error, cacheType, imageURL) in
            DispatchQueue.main.async {
                self?.setProgress(progress: 1)
                self?.progressView.isHidden = true
            }
            
        }
    }
}

class IMGalleryViewController: TSViewController {
    
    var onceToken: Bool = false
    var galleryImageView: UIImageView!
    //NTESGalleryItem *currentItem;
    //NIMSession *session;
    var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        self.scrollView = UIScrollView(frame: self.view.bounds)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.scrollView)

    }
    
    open func alertSingleSnapViewWithMessage(message: NIMMessage, baseView: UIView) -> UIImageView? {
        guard  let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMSnapchatAttachment else {
            return nil
        }
        
        let galleryImageView = IMSingleSnapView(frame: UIScreen.main.bounds, object: object, baseView: baseView)
        galleryImageView.autoresizingMask = .flexibleWidth
        galleryImageView.backgroundColor = .black
        galleryImageView.contentMode = .scaleAspectFit
        galleryImageView.isUserInteractionEnabled = false
        
        galleryImageView.presentSnapView(view: baseView, animated: true) {
            
        }

        return galleryImageView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !onceToken {
            self.loadImage()
            onceToken = true
        }
    }
    
    func loadImage(){
        
        var insets = UIEdgeInsets.zero
        
        if #available(iOS 11.0, *)
        {
            insets = self.scrollView.adjustedContentInset
        }
        else
        {
            insets = self.scrollView.contentInset
        }
        //self.scrollView.delegate = self
        self.scrollView.minimumZoomScale = 0.37
        self.scrollView.maximumZoomScale = 1.0
        self.scrollView.zoomScale = 0.37
        self.scrollView.contentSize = CGSize(width: self.scrollView.width - insets.left - insets.right,
                                             height: self.scrollView.height - insets.top - insets.bottom)
        
    }

    func layoutGallery(size: CGSize)
    {
        self.galleryImageView.size = self.scrollView.contentSize
        self.galleryImageView.contentMode = .scaleAspectFit
        self.galleryImageView.centerY = self.galleryImageView.height * 0.5
    }

}


extension UIView {
    
    private struct AssociatedKeys {
        static var PresentedViewAddress = "PresentedViewAddress"
        static var PresentingViewAddress = "PresentingViewAddress"
        static var HideViewsAddress = "HideViewsAddress"
    }

    func presentSnapView(view: UIView, animated: Bool, complete: @escaping () -> Void ){

        guard let window = UIApplication.shared.windows.last else {
            return
        }
        
        window.addSubview(view)
//        objc_setAssociatedObject(self, &AssociatedKeys.PresentedViewAddress, view, .OBJC_ASSOCIATION_RETAIN)
//        objc_setAssociatedObject(view, &AssociatedKeys.PresentingViewAddress, self, .OBJC_ASSOCIATION_RETAIN)

        if animated {
            self.doSnapAlertAnimate(view: view, complete: complete)
        }else{
            view.center = window.center
        }
    }
    
    func doSnapAlertAnimate(view: UIView, complete: @escaping () -> Void) {
        guard let window = UIApplication.shared.windows.last else {
            return
        }
        let bounds = window.bounds
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        scaleAnimation.duration = 0.25
        scaleAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1, height: 1))
        scaleAnimation.toValue = NSValue(cgRect: bounds)
        
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.duration = 0.25
        //moveAnimation.fromValue = NSValue(cgPoint: superview!.convert(center, to: nil))
        moveAnimation.toValue = NSValue(cgPoint: window.center)
        
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 0.25
        group.animations = [scaleAnimation, moveAnimation]
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        group.fillMode = CAMediaTimingFillMode.forwards
        group.isRemovedOnCompletion = false
        group.autoreverses = false
        
        hidAllSubView(view: view)
        
        view.layer.add(group, forKey: "groupAnimationAlert")
        
        weak var wself = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25, execute: {
            guard let self = wself else { return }
//            view.layer.bounds = bounds
//            view.layer.position = self.superview!.center
//            self.showAllSubview(view: view)
            complete()

        })
    }
    
 
//    func presentedView() -> UIView{
//        let view =  objc_getAssociatedObject(self, &AssociatedKeys.PresentedViewAddress) as! UIView
//        return view
//    }

    func dismissPresentedView(animated: Bool, complete: @escaping () -> Void){
        //let view =  objc_getAssociatedObject(self, &AssociatedKeys.PresentedViewAddress) as! UIView
        if animated {
            self.doHideAnimate(alertView: self, complete: complete)
        }else{
            self.removeFromSuperview()
            //self.cleanAssocaiteObject()
        }
    }
    
    func doHideAnimate(alertView: UIView, complete: @escaping () -> Void){
       
        let bounds = alertView.bounds
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        scaleAnimation.duration = 0.25
        scaleAnimation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 1, height: 1))
        let position = self.center
      
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.duration = 0.25
        moveAnimation.toValue = NSValue(cgPoint: superview!.convert(center, to: nil))
        
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 0.25
        group.animations = [scaleAnimation, moveAnimation]
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        group.fillMode = CAMediaTimingFillMode.forwards
        group.isRemovedOnCompletion = false
        group.autoreverses = false
        
        alertView.layer.bounds    = self.bounds
        alertView.layer.position  = position
        alertView.layer.needsDisplayOnBoundsChange = true
        
        hidAllSubView(view: alertView)
        alertView.backgroundColor = .clear
        alertView.layer.add(group, forKey: "groupAnimationHide")
        
        weak var wself = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.25 , execute: {
            guard let self = wself else { return }
            alertView.removeFromSuperview()
            //self.cleanAssocaiteObject()
            //self.showAllSubview(view: alertView)
            complete()
        })
    }
    
    func cleanAssocaiteObject(){
        objc_setAssociatedObject(self, &AssociatedKeys.PresentedViewAddress, nil, .OBJC_ASSOCIATION_RETAIN)
        objc_setAssociatedObject(self, &AssociatedKeys.PresentingViewAddress, nil, .OBJC_ASSOCIATION_RETAIN)
        //objc_setAssociatedObject(self, &AssociatedKeys.HideViewsAddress, nil, .OBJC_ASSOCIATION_RETAIN)
       
    }
    
}

