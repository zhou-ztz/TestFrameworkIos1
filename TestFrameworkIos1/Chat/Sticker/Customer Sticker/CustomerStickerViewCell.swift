//
//  CustomerStickerViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/22.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

import FLAnimatedImage
import SDWebImage

protocol CustomerStickerViewCellDelegate: class {
    
    func selectItem(indexPath: IndexPath)
}

class CustomerStickerViewCell: UICollectionViewCell {
    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var selectBtn: UIButton!
    var imageView = SDAnimatedImageView()
    var indexPath: IndexPath!
    weak var delegate: CustomerStickerViewCellDelegate?
    static let cellIdentifier = "CustomerStickerViewCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .white
        bgImage.contentMode = .scaleAspectFit
        icon.isHidden = true
        icon.image = UIImage.set_image(named: "add_sticker")?.withRenderingMode(.alwaysOriginal)
        imageView.contentMode = .scaleAspectFit
        bgImage.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalTo(0)
        }
        bgImage.bringSubviewToFront(self.selectBtn)
        selectBtn.layer.cornerRadius = 18 / 2.0
        selectBtn.layer.masksToBounds = true
//        selectBtn.layer.borderWidth = 1
//        selectBtn.layer.borderColor = UIColor(hex: 0xededed).cgColor
        selectBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
        selectBtn.setImage(UIImage.set_image(named: "icon_accessory_normal"), for: .normal)
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        self.delegate?.selectItem(indexPath: self.indexPath)
    }
    
    public func setSticker(sticker: CustomerStickerItem, indexPath: IndexPath){
        self.indexPath = indexPath
       // self.bgImage.sd_setImage(with: URL(string: sticker.stickerUrl ?? ""), completed: nil)
        if let url = sticker.stickerUrl{
            imageView.sd_setImage(with: URL(string: url)!, completed: nil)
        }
  
    }
    
    public func setData(asset: PHAsset, indexPath: IndexPath){
        // 判断是不是GIF
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        option.isSynchronous = false
        manager.requestImageData(for: asset, options: option) { [weak self] (imageData, type, orientation, info) in
            guard let imageData = imageData else { return }
            DispatchQueue.main.async {
                if type == kUTTypeGIF as String {
                    self?.bgImage.image = UIImage.gif(data: imageData)
                } else {
                    self?.bgImage.image = UIImage(data: imageData)
                }
            }
        }
    }

}
