//
//  NavigationController.swift
//  ImagePicker
//
//  Created by GorCat on 2017/6/22.
//  Copyright © 2017年 GorCat. All rights reserved.
//

import UIKit
import Photos
import TZImagePickerController
class TSImagePickerViewController: UINavigationController {

    /// 已选择的图片数组
    var selectedImages: [PHAsset] = []
    /// 增加了最大选择数量
    var maxSelectedCount = 0

    /// 相册数据管理类。这里没有直接初始化，直接初始化会内存泄漏，原因不明
    var dataManager: PhotosDataManager?

    /// 是否显示下方工具栏
    var isToolBarShow = true

    // MARK: - Public
    func show() {
        let topVC = UIApplication.topViewController()
        topVC?.present(self, animated: true, completion: nil)
    }

    func dismiss() {
        dismiss(animated: true, completion: nil)
    }

}

extension UIApplication {
    class func topViewController(viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(viewController: nav.visibleViewController)
        } else if let tab = viewController as? UITabBarController, let selected = tab.selectedViewController {
            return topViewController(viewController: selected)
        } else if let presented = viewController?.presentedViewController {
            return topViewController(viewController: presented)
        } else if let child = viewController?.children.last {
            return child
        }
        
        return viewController
    }
}

// MARK: - 初始化方法
extension TSImagePickerViewController {

    /// 可选多张图片的选择器
    ///
    /// - Note: 需要相机、相册同时授权
    ///
    /// - Parameters:
    ///   - maxmumCount: 可选图片的最大张数
    ///   - complete: 结果
    class func album(maxmumCount: Int, selectedAssets: [PHAsset]?, finish complete: (([UIImage], [PHAsset]) -> Void)?) -> TSImagePickerViewController {

        // 1.创建图片选择器
        let table = AlbumTableVC.photoTableVC()
        let nav = TSImagePickerViewController(rootViewController: table)

        // 2.配置图片选择器的信息
        nav.isToolBarShow = true
        nav.maxSelectedCount = maxmumCount
        nav.dataManager = PhotosDataManager()
        if let selectedAsset = selectedAssets {
            nav.selectedImages = selectedAsset
        }

        // 设置选择器的结束操作
        table.setFinish(operation: complete)

        /*
         3.设置需求效果
         需求：相册第一个界面要为 “所有图片”，并且可以从 “所有图片” 返回 table
         */
        // 3.1 创建 “所有图片” 视图控制器
        let collection = AlbumCollectionVC()
        let models = nav.dataManager!.getAlbumList()
        collection.setInfo(albumModel: models[0])
        collection.setFinish(operation: complete)

        // 3.2 让视图控制器推送到 “所有图片”
        nav.pushViewController(collection, animated: false)

        return nav
    }

    /// 可裁切的，相册图片选择器
    ///
    /// - Note: 需要相册、相机同时授权
    ///
    /// - Parameters:
    ///   - cropType: 裁切的图片类型
    ///   - operation: 裁切结束的操作
    /// - Returns: 图片选择器
    class func canCropAlbum(cropType: ImagePickerCropType, finish complete: ((UIImage) -> Void)?) -> TSImagePickerViewController {

        // 1.创建图片选择器
        let table = AlbumTableVC.photoTableVC()
        let nav = TSImagePickerViewController(rootViewController: table)

        // 2.配置图片选择器的信息
        // 完成操作
        let finishBlock = { [weak table, weak nav] (images: [UIImage], assets: [PHAsset]) in
            guard table != nil, let weakNav = nav else {
                return
            }
            // 选择结束后，跳转到裁切界面
            let crop = ImageCropVC(type: cropType)
            crop.setImage(image: images.first!)
            crop.setFinish(operation: { [weak table, weak nav] (image) in
                guard table != nil, let weakNav = nav else {
                    return
                }
                complete?(image)
                weakNav.dismiss()
            })
            weakNav.pushViewController(crop, animated: true)
        }
        nav.isToolBarShow = false
        nav.dataManager = PhotosDataManager()

        // 设置选择器的结束操作
        table.setFinish(operation: finishBlock)

        /*
         3.设置需求效果
         需求：相册第一个界面要为 “所有图片”，并且可以从 “所有图片” 返回 table
        */
        // 3.1 创建 “所有图片” 视图控制器
        let collection = AlbumCollectionVC()
        let models = nav.dataManager!.getAlbumList()
        collection.setInfo(albumModel: models[0])
        collection.setFinish(operation: finishBlock)

        // 3.2 让视图控制器推送到 “所有图片”
        nav.pushViewController(collection, animated: false)

        return nav
    }

    /// 可裁切的，相机图片选择器
    ///
    /// - Note: 需要相机授权
    ///
    /// - Parameters:
    ///   - cropType: 裁切的图片类型
    ///   - operation: 裁切结束的操作
    /// - Returns: 图片选择器 / rawImage
    class func canCropCamera(cropType: ImagePickerCropType, finish complete: ((UIImage, UIImage) -> Void)?) -> TSImagePickerViewController {
        // 1.创建相机视图控制器
        let camera = CameraVC.camera()
        let nav = TSImagePickerViewController(rootViewController: camera)

        // 2.设置 相机 结束操作
        camera.setFinish { [weak camera, weak nav] (cameraImage) in
            guard camera != nil, let weakNav = nav else {
                return
            }
            let lzImage = LZImageCropping()
            if cropType == .squart {
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.width - 80, height: UIScreen.main.bounds.width - 80)
            } else {
                lzImage.cropSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width / 2.0)
            }
            lzImage.image = cameraImage
            lzImage.isRound = false
            lzImage.didFinishPickingImage = {(image) ->() in
                guard image != nil else {
                    return
                }
                complete?(image!, cameraImage)
                weakNav.dismiss()
                weakNav.dismiss()
            }
            weakNav.present(lzImage, animated: true, completion: {
                
            })
//            let crop = ImageCropVC(type: cropType)
//            crop.setImage(image: cameraImage)
//            weakNav.pushViewController(crop, animated: true)
//
//            // 3.设置 裁切 结束操作
//            crop.setFinish(operation: { [weak crop] (cropImage) in
//                guard crop != nil else {
//                    return
//                }
//                complete?(cropImage)
//                weakNav.dismiss()
//            })
        }
        return nav
    }

    /// 相机图片选择器
    ///
    /// - Note: 需要相机授权
    ///
    /// - Parameters:
    ///   - operation: 照相结束的操作
    /// - Returns: 图片选择器
    class func camera(finish complete: ((UIImage) -> Void)?) -> TSImagePickerViewController {
        // 1.创建相机视图控制器
        let camera = CameraVC.camera()
        let nav = TSImagePickerViewController(rootViewController: camera)

        // 2.设置 相机 结束操作
        camera.setFinish(operation: complete)

        return nav
    }
}

// MARK: - Other
extension TSImagePickerViewController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.isEmpty == false {
            let backBarItem = UIBarButtonItem(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"), style: .plain, target: self, action: #selector(popBack))
            viewController.navigationItem.leftBarButtonItem = backBarItem
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }

    @objc func popBack() {
        self.popViewController(animated: true)
    }
}

// MARK: - Protocol

/// data 管理类使用协议。
/// - Note: TSImagePickerViewController 的 viewControllers 遵守此协议后，可通过 dataManager() 方法获取到数据管理类
protocol ImagePickerDataUsable {
}

extension ImagePickerDataUsable where Self: UIViewController {

    /// 获取导航栏
    func nav() -> TSImagePickerViewController? {
        let navVC = navigationController as? TSImagePickerViewController
        return navVC
    }

    /// 相册数据管理类
    ///
    /// - Returns: 相册数据管理类
    func dataManager() -> PhotosDataManager? {
        let navVC = navigationController as? TSImagePickerViewController
        guard let nav = navVC else { return nil }
        if nav.dataManager == nil {
            nav.dataManager = PhotosDataManager()
        }
        return nav.dataManager!
    }

    func isToolBarShow() -> Bool? {
        let navVC = navigationController as? TSImagePickerViewController
        guard let nav = navVC else { return nil }
        return nav.isToolBarShow
    }
}
