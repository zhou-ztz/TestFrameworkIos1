//
//  TSReleaseDynamicCollectionViewCell.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
// 发布动态图片展示cell

import UIKit
import Photos
import MobileCoreServices
import SDWebImage

class TSReleasePulseCollectionViewCell: UICollectionViewCell {
    var payBtnBlock: ((UIButton) -> Void)?
    var deleteImageBtnBlock: ((UIButton) -> Void)?
    /// 支付信息视图
    weak var payInfoImg: UIImageView!
    /// 蒙层
//    var coverView = UIView(frame: CGRect.zero)
    /// GIF标示
    var gifIdentityView = SDAnimatedImageView(frame: CGRect.zero)
    /// 支付操作按钮
    var payinfoSetBtn = UIButton(frame: CGRect.zero)
    /// 是否显示动态图片
    var gifImageActive: Bool = true
    /// remove image button
    var deleteImageBtn = UIButton(frame: .zero)
    /// 可以直接传UIImage，但是需要提前设置好GIF表示
    /// 或者传PHAsset，但是这样子会有性能问题，刷新的时候会闪动
    public var image: AnyObject? {
        didSet {
            if image is UIImage {
                imageView.image = image as? UIImage
                if imageView.image?.TSImageMIMEType == kUTTypeGIF as String {
                    self.gifIdentityView.isHidden = false
                } else {
                    self.gifIdentityView.isHidden = true
                }
            } else {
                guard let asset = self.image as? PHAsset else { return }
                // 判断是不是GIF
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                option.isSynchronous = false
                manager.requestImageData(for: asset, options: option) { [weak self] (imageData, type, orientation, info) in
                    guard let imageData = imageData else { return }
                    DispatchQueue.main.async {
                        if type == kUTTypeGIF as String {
                            self?.gifIdentityView.isHidden = false
                            // 动图
                            var image: UIImage!
                            if self?.gifImageActive == true {
                                image = UIImage.gif(data: imageData)
                            } else {
                                image = UIImage(data: imageData)
                            }
                            self?.imageView.image = image
                        } else {
                            self?.imageView.image = UIImage(data: imageData)
                            self?.gifIdentityView.isHidden = true
                        }
                    }
                }
            }
        }
    }
    public var imageView: SDAnimatedImageView

    override init(frame: CGRect) {
        imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        super.init(frame: frame)
        self.contentView.addSubview(imageView)
        gifIdentityView.frame = CGRect(x: self.width - 25, y: self.height - 15, width: 25, height: 15)
        gifIdentityView.backgroundColor = UIColor.clear
        gifIdentityView.image = UIImage.set_image(named: "pic_gif")
        contentView.addSubview(gifIdentityView)
        gifIdentityView.isHidden = true
        payinfoSetBtn.frame = CGRect(x: 0, y: self.height - 30, width: self.width, height: 30)
        payinfoSetBtn.backgroundColor = UIColor(white: 0, alpha: 0.2)
        payinfoSetBtn.set(font: UIFont.systemFont(ofSize: 12))
        payinfoSetBtn.setTitleColor(UIColor.white, for: .normal)
        payinfoSetBtn.isHidden = true
        payinfoSetBtn.setImage(UIImage.set_image(named: "IMG_edit_pen"), for: .normal)
        payinfoSetBtn.setTitle("set_amount".localized, for: .normal)
        payinfoSetBtn.setImage(UIImage.set_image(named: "ico_coins"), for: .selected)
        payinfoSetBtn.setTitle("set_amount".localized, for: .selected)
        payinfoSetBtn.addTarget(self, action: #selector(didSelectedPayInfoBtn(btn:)), for: .touchUpInside)
        contentView.addSubview(payinfoSetBtn)
        
        deleteImageBtn.frame = CGRect(x: self.width - 30, y: 0, width: 30, height: 30)
        deleteImageBtn.setImage(UIImage.set_image(named: "IMG_information_ico_delete"), for: .normal)
        contentView.addSubview(deleteImageBtn)
        deleteImageBtn.addAction {
            self.deleteImageBtnBlock?(self.deleteImageBtn)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = self.contentView.bounds
    }

    @objc func didSelectedPayInfoBtn(btn: UIButton) {
        self.payBtnBlock?(btn)
    }
}

extension TSReleasePulseCollectionViewCell {
    func getAssetThumbnail(asset: PHAsset) -> UIImage {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var thumbnail = UIImage()
        option.isSynchronous = true
        let size = CGSize(width: asset.pixelWidth / 10, height: asset.pixelHeight / 10)
        manager.requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: option, resultHandler: {(result, _) -> Void in
            thumbnail = result!
        })
        return thumbnail
    }
}
