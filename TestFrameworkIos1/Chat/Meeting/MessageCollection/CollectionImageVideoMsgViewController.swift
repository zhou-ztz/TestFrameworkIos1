//
//  CollectionImageVideoMsgViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/19.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate
import NIMSDK
import SDWebImage
import SVProgressHUD


class CollectionImageVideoMsgViewController: TSViewController {
    
    var favoriteModel: FavoriteMsgModel?
    var collectionMsgCall: deleteCollectionMsgCall?
    var dictModel: SessionDictModel?
    var imageAttachment: IMImageCollectionAttachment?
    var videoAttachment: IMVideoCollectionAttachment?
    var pageViewController: UIPageViewController?
    
    init(model: FavoriteMsgModel) {
        self.favoriteModel = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setCloseButton(backImage: true, titleStr: "title_favourite_msg_details".localized)
        self.setupRightNavItem()
        self.imageVideoAttachment(josnStr: self.favoriteModel?.data ?? "")
        self.setUI()
    }
    

    func setupRightNavItem() {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(onMore), for: .touchUpInside)
        button.setImage(UIImage.set_image(named: "buttonsMoreDotBlack"), for: .normal)
        button.sizeToFit()
        
        let buttonItem = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = buttonItem
    }
    
    func setUI(){
        guard let model = self.favoriteModel else {
            return
        }
        if model.type == MessageCollectionType.image {
            
            let item = GalleryItem()
            item.thumbPath = ""
            item.imageURL = imageAttachment?.url ?? ""
            item.name =  ""
            item.itemId = ""
            item.size = CGSize(width: imageAttachment?.w ?? 0, height: imageAttachment?.h ?? 0)
            let viewController = GalleryViewController(item: item, session: nil)
            viewController.ext = imageAttachment?.ext ?? ""
            viewController.view.tag = 1
            self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

            let viewControllers: [UIViewController] = [viewController]
            
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            
            self.addChild(self.pageViewController!)
            self.view.addSubview(self.pageViewController!.view)
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
            
        }else if model.type == MessageCollectionType.video {
           
            let viewController = ChatMediaVideoPlayerViewController(url: self.videoAttachment?.url ?? "")
            viewController.view.tag = 1
            self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

            let viewControllers: [UIViewController] = [viewController]
            
            self.pageViewController?.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
            
            self.addChild(self.pageViewController!)
            self.view.addSubview(self.pageViewController!.view)
            self.pageViewController?.didMove(toParent: self)
            self.edgesForExtendedLayout = .all
        }
        
    }
    
    @objc func onMore() {

        let items: [IMActionItem] = [.save, .collect_forward, .collect_delete]

//        if (items.count > 0 ) {
//            let view = IMActionListView(actions: items)
//            view.delegate = self
//        }
    }
    
    func imageVideoAttachment(josnStr: String) {
        guard let data = josnStr.data(using: .utf8) else {
            return
        }
        do {
            let model = try JSONDecoder().decode(SessionDictModel.self, from: data)
            dictModel = model

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        guard let dataAttach = dictModel?.attachment!.data(using: .utf8) else {
            return
        }
        do {
            if self.favoriteModel!.type == .image {
                let attach = try JSONDecoder().decode(IMImageCollectionAttachment.self, from: dataAttach)
                imageAttachment = attach
            }else{
                let attach = try JSONDecoder().decode(IMVideoCollectionAttachment.self, from: dataAttach)
                videoAttachment = attach
            }
            

        } catch  {
            print("jsonerror = \(error.localizedDescription)")
        }
        
        
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

}

extension CollectionImageVideoMsgViewController {
    func copyTextIM() {}
    func copyImageIM() {}
    
    func forwardTextIM() {
        let configuration = ContactsPickerConfig(title: "select_contact".localized, rightButtonTitle: "done".localized, allowMultiSelect: true, enableTeam: true, enableRecent: true, enableRobot: false, maximumSelectCount: Constants.maximumSendContactCount, excludeIds: [], members: nil, enableButtons: false, allowSearchForOtherPeople: true)
        
        let picker = NewContactPickerViewController(configuration: configuration, finishClosure: { [weak self] (contacts) in
            
            for contact in contacts {
                
                let session = NIMSession(contact.userName, type: contact.isTeam ? NIMSessionType.team : NIMSessionType.P2P)
                guard let message = CollectionMsgDataManager().messageModel(model: self?.favoriteModel) else {
                    return
                }
                
                do {
                    try NIMSDK.shared().chatManager.send(message, to: session)
                } catch {
                    print("error---= \(error.localizedDescription)")
                }
            }
        })
        self.navigationController?.pushViewController(picker, animated: true)
    }
    
    func revokeTextIM() {}
    
    func deleteTextIM() {
        var array = [NIMCollectInfo]()
        let collectInfo = NIMCollectInfo()
        collectInfo.createTime = self.favoriteModel!.createTime
        collectInfo.id = UInt(self.favoriteModel!.Id)
        array.append(collectInfo)
        NIMSDK.shared().chatExtendManager.removeCollect(array) { [weak self] (error, total) in
            if let error = error {
                self?.showError(message: error.localizedDescription)
            }else{
                self?.showError(message: "favourite_msg_delete_success".localized)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.8 ) {
                    self?.navigationController?.popViewController(animated: true)
                    if let collectMsgCall = self?.collectionMsgCall{
                        collectMsgCall!(self?.favoriteModel)
                    }
                    
                }
            }
        }
    }
    
    func translateTextIM() {}
    
    func replyTextIM() {}
    
    func handleStickerIM() {}
    
    func cancelUploadIM() {}
    
    func stickerCollectionIM() {}
    
    func voiceToTextIM() {}
    
    func messageCollectionIM() {}
    
    func saveMsgCollectionIM() {
        guard let model = self.favoriteModel else {
            return
        }
        if model.type == .image {
            weak var wself = self
            guard let imageURL = wself?.imageAttachment?.url else { return }
            SDWebImageManager.shared.imageCache.queryImage(forKey: imageURL, options: .fromCacheOnly, context: nil) { (image, data, cacheType) in
                guard let image = image else {
                    return
                }
                self.saveImageToAlbum(imageFile: image)
            }
        } else if model.type == .video {
            SVProgressHUD.show(withStatus: "downloading...".localized)

//            DispatchQueue.global(qos: .background).async { [self] in
//                if let url = URL(string: videoAttachment?.url ?? ""), let urlData = NSData(contentsOf: url) {
//                    let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
//                    let filePath="\(documentsPath)/tempFile.mp4"
//                    DispatchQueue.main.async {
//                        urlData.write(toFile: filePath, atomically: true)
//                        PHPhotoLibrary.shared().performChanges({
//                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
//                        }) { completed, error in
//                            if completed {
//                                SVProgressHUD.showSuccess(withStatus: "success_save".localized)
//                            }
//                            if (error != nil) {
//                                print("💢💢💢", error!.localizedDescription)
//                                SVProgressHUD.showError(withStatus: "fail_save".localized)
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
    
    func forwardAllImageIM() {}
    
    func deleteAllImageIM() {}
}
