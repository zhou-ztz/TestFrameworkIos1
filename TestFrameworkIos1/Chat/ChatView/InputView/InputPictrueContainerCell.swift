//
//  InputPictrueContainerCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/12/10.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices

protocol InputPictrueContainerCellDelegate: class {
    func didSelectItem(indexPath: IndexPath, isSelect: Bool)
}


class InputPictrueContainerCell: UICollectionViewCell {
    
    @IBOutlet weak var camera: UIImageView!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var selectBtn: UIButton!
    
    let  TZScreenScale = ScreenWidth > 700 ? 1.5 : 2.0
    var imageRequestID: PHImageRequestID = 0
    var indexPath: IndexPath!
    var representedAssetIdentifier = ""
    weak var delegate: InputPictrueContainerCellDelegate?
    static let cellIdentifier = "InputPictrueContainerCell"
    class func nib() -> UINib {
        return UINib(nibName: cellIdentifier, bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        icon.contentMode = .scaleAspectFill
        camera.isHidden = true
        selectBtn.layer.cornerRadius = 18 / 2.0
        selectBtn.layer.masksToBounds = true
//        selectBtn.layer.borderWidth = 1
//        selectBtn.layer.borderColor = UIColor(hex: 0xededed).cgColor
        selectBtn.setImage(UIImage.set_image(named: "ic_rl_checkbox_selected"), for: .selected)
        selectBtn.setImage(UIImage.set_image(named: "selectDef"), for: .normal)
        camera.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalTo(28)
        }
        
    }
    
    @IBAction func selectAction(_ sender: UIButton) {
        //sender.isSelected = !sender.isSelected
        self.delegate?.didSelectItem(indexPath: self.indexPath, isSelect: sender.isSelected)
    }
    
    public func setData(asset: PHAsset, indexPath: IndexPath){
        self.indexPath = indexPath
        self.representedAssetIdentifier = asset.localIdentifier
        let width = (ScreenWidth - 28) / 4.0
        let imageRequestID: PHImageRequestID = getPhotoWithAsset(asset: asset,photoWidth: width, networkAccessAllowed: false) {[weak self] (photo, info, isDrag) in
            guard let self = self else {
                return
            }
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.icon.image = photo
                self.setNeedsLayout()
            }else{
                PHImageManager.default().cancelImageRequest(self.imageRequestID)
            }
            if !isDrag {
                self.imageRequestID = 0
            }
                
        }
        
        if ((imageRequestID != 0) && (self.imageRequestID != 0) && imageRequestID != self.imageRequestID) {
            PHImageManager.default().cancelImageRequest(self.imageRequestID)
            
        }
        self.imageRequestID = imageRequestID
    }
    
    func getPhotoWithAsset(asset: PHAsset, photoWidth: CGFloat, networkAccessAllowed: Bool,  completion: @escaping ((UIImage, [AnyHashable: Any], Bool)->())) -> PHImageRequestID {
        var imageSize: CGSize
        let aspectRatio = CGFloat(asset.pixelWidth / asset.pixelHeight)
        var pixelWidth = photoWidth * TZScreenScale
        // 超宽图片
        if (aspectRatio > 1.8) {
            pixelWidth = pixelWidth * aspectRatio
        }
        // 超高图片
        if (aspectRatio < 0.2) {
            pixelWidth = pixelWidth * 0.5
        }
        let pixelHeight = pixelWidth / aspectRatio
        imageSize = CGSizeMake(pixelWidth, pixelHeight)
        
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        let imageRequestID =  PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: option) { [weak self] (result, info) in
            let cancelled = info?[PHImageCancelledKey]
            if cancelled == nil , let img = result, let info = info {
                
                completion(img, info, (info[PHImageResultIsDegradedKey] as? Bool) ?? false)
                
            }
           
            
        }
        return imageRequestID;
        
    }
    
}
