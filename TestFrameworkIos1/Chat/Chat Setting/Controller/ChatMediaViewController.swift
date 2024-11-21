//
//  ChatMediaViewController.swift
//  Yippi
//
//  Created by Tinnolab on 09/10/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK

class ChatMediaViewController: TSViewController {
    /// 头部可滑动的标签选择视图
    var tagScrollView: ChatMediaTagScrollView? = nil
    /// 主视图
    var rootScrollView: UIScrollView? = nil
    
    var photoVideoObjects: [MediaPreviewObject] = []
    var filesObjects: [NIMFileObject] = []
    
    let session: NIMSession
    
    init(session: NIMSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton(backImage: true, titleStr: "photo_video_files".localized)
        
        /// 顶部可滑动的标签栏
        self.tagScrollView = ChatMediaTagScrollView(frame: CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: 44))
        self.tagScrollView?.delegate = self
        self.view.addSubview(self.tagScrollView!)
        
        /// 左右滑动的列表根视图
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20
        self.rootScrollView = UIScrollView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)!, width: ScreenSize.ScreenWidth, height: ScreenSize.ScreenHeight - navigationBarHeight - (self.tagScrollView?.frame.maxY)!))
        self.rootScrollView?.backgroundColor = TSColor.inconspicuous.background
        self.rootScrollView?.delegate = self
        self.rootScrollView?.isPagingEnabled = true
        self.rootScrollView?.showsHorizontalScrollIndicator = false
        self.view.addSubview(self.rootScrollView!)
        
        let grayLine = UIView(frame: CGRect(x: 0, y: (self.tagScrollView?.frame.maxY)! - 1, width: ScreenSize.ScreenWidth, height: 1))
        grayLine.backgroundColor = TSColor.inconspicuous.disabled
        self.view.addSubview(grayLine)
        
        self.view.bringSubviewToFront(self.rootScrollView!)
        self.view.bringSubviewToFront(grayLine)
        
        self.tagScrollView?.updateTags(WithTags: ["Photos & Video","Files"])
        self.getPhotoVideoFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func addChildVC() {
        let navigationBarHeight = (self.navigationController?.navigationBar.frame.height)! + 20
        let height = ScreenSize.ScreenHeight - navigationBarHeight - (self.tagScrollView?.frame.maxY ?? 44)
        
        let mediaVC = MediaPreviewViewController.init(objects: self.photoVideoObjects, focusObject:MediaPreviewObject(), session: self.session)
        mediaVC.view.frame = CGRect(x: 0, y: 0, width: ScreenSize.ScreenWidth, height: rootScrollView?.frame.size.height ?? height)
        self.addChild(mediaVC)
        self.rootScrollView?.addSubview(mediaVC.view)
        
        let vc = FilesPreviewTableViewController.init(filesObjects: self.filesObjects)
        vc.view.frame = CGRect(x: ScreenSize.ScreenWidth, y: 0, width: ScreenSize.ScreenWidth, height: rootScrollView?.frame.size.height ?? height)
        self.addChild(vc)
        self.rootScrollView?.addSubview(vc.view)
        
        self.rootScrollView?.contentSize = CGSize(width: ScreenSize.ScreenWidth * 2, height: 0)
    }
    
    func getPhotoVideoFile() {
        let option = NIMMessageSearchOption()
        option.limit = 0
        option.messageTypes = [NSNumber(value: NIMMessageType.image.rawValue), NSNumber(value: NIMMessageType.video.rawValue), NSNumber(value: NIMMessageType.file.rawValue)]
        
        NIMSDK.shared().conversationManager.searchMessages(self.session, option: option) { [weak self] (error, messages) in
            guard let self = self else { return }
            var photoVideoObjects: [MediaPreviewObject] = []
            var filesObjects: [NIMFileObject] = []
            if let messages = messages {
                //显示的时候新的在前老的在后，逆序排列
                //如果需要微信的显示顺序，则直接将这段代码去掉即可
                let array: [NIMMessage] = NSMutableArray(array: messages).reverseObjectEnumerator().allObjects as! [NIMMessage]
                
                for message: NIMMessage in array {
                    switch message.messageType {
                    case NIMMessageType.video:
                        if let object = self.previewObjectByVideo(object: message.messageObject as! NIMVideoObject) {
                            photoVideoObjects.append(object)
                        }
                        break
                    case NIMMessageType.image:
                        if let object = self.previewObjectByImage(object: message.messageObject as! NIMImageObject) {
                            photoVideoObjects.append(object)
                        }
                        break
                    case NIMMessageType.file:
                        if let object = message.messageObject {
                            filesObjects.append(object as! NIMFileObject)
                        }
                        break
                    default:
                        break
                    }
                }
                self.photoVideoObjects = photoVideoObjects
                self.filesObjects = filesObjects
                self.addChildVC()
            }
        }
    }
    
    func previewObjectByVideo(object: NIMVideoObject) -> MediaPreviewObject? {
        guard let msgObj = object.message else { return nil }
        
        let previewObject: MediaPreviewObject = MediaPreviewObject()
        previewObject.objectId      = msgObj.messageId
        previewObject.thumbPath     = object.coverPath
        previewObject.thumbUrl      = object.coverUrl
        previewObject.path          = object.path
        previewObject.url           = object.url
        previewObject.type          = MediaPreviewType.video
        previewObject.timestamp     = msgObj.timestamp
        previewObject.displayName   = object.displayName
        previewObject.duration      = TimeInterval(object.duration)
        previewObject.imageSize     = object.coverSize
        return previewObject
    }
    
    func previewObjectByImage(object: NIMImageObject) -> MediaPreviewObject? {
        guard let msgObj = object.message else { return nil }
        
        let previewObject: MediaPreviewObject = MediaPreviewObject()
        previewObject.objectId      = msgObj.messageId
        previewObject.thumbPath     = object.thumbPath
        previewObject.thumbUrl      = object.thumbUrl
        previewObject.path          = object.path
        previewObject.url           = object.url
        previewObject.type          = MediaPreviewType.image
        previewObject.timestamp     = msgObj.timestamp
        previewObject.displayName   = object.displayName
        previewObject.imageSize     = object.size
        return previewObject
    }
}

// MARK: - ChatMediaTagScrollViewDelegate
extension ChatMediaViewController: ChatMediaTagScrollViewDelegate {
    func selectedTag(WithTagIndex index: Int) {
        self.rootScrollView?.setContentOffset(CGPoint(x: ScreenSize.ScreenWidth * CGFloat(index), y: 0), animated: false)
    }
}

// MARK: - scrollviewDelegate
extension ChatMediaViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.tagScrollView?.setTitleButtonStyle(WithContentOffSetXPoint: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.tagScrollView?.setButtonOffSet(scrollViewContentOffSetX: scrollView.contentOffset.x)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let VCIndex = (self.rootScrollView?.contentOffset.x)! / ScreenSize.ScreenWidth
        /**
         * 注意：在添加列表子控制器前添加了tagSettingVC这个子控制器 所以这里
         * 的懒加载数组序号应该整体右移，且当子控制器为tagSettingVC的时候不执行添加
         * 操作
         **/
        let childVC = self.children[Int(VCIndex + 1)]
        if childVC.view.superview != nil {
            return
        }
        /// tagSettingVC 的view tag值
        if childVC.view.tag == 9_999 {
            return
        }
        childVC.view.frame = (self.rootScrollView?.bounds)!
        childVC.view.tag = -1 /// 添加标记 用于重新刷新界面的时候清空以前的视图
        self.rootScrollView?.addSubview(childVC.view)
    }
}


