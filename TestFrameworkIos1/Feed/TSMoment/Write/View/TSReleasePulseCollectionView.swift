//
//  TSReleaseDynamicCollectionView.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  展示图片的collectionView

import UIKit

enum LinkType {
    case UniversalApi
    case UniversalWeb
    case UniversalRegister
    case Deep
}

struct PostPhotoExtension  {
    var data: Data?
    var type: String?
}

struct PostVideoExtension {
    var data: Data?
}

protocol didselectCellDelegate: NSObjectProtocol {
    /// 点击了进入相册按钮 最小为0
    func didSelectCell(index: Int)

    /// 点击了付费信息按钮
    func didSelectedPayInfoBtn(btn: UIButton)
    
    /// delete image button did tapped
    func didTapDeleteImageBtn(btn: UIButton)
}

enum PayInfoType: Int {
    case not = 0
    case edit
    case lock
}

class TSReleasePulseCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

    // cell个数
    let cellCount: CGFloat = 4.0
    // 间距
    let spacing: CGFloat = 5.0
    // 边框宽度
    let frameWidth: CGFloat = 0.5
    // 最大图片数量
    var maxImageCount: Int = 0
    // 代理
    weak var didselectCellDelegate: didselectCellDelegate? = nil
    var imageDatas: [Any] = Array()
    var imagePHAssets: [AnyObject] = Array()
    /// 是否开启设置付费
    var shoudSetPayInfo: Bool = false
    
    var imageShare: [PostPhotoExtension] = Array()
    var fromShare: Bool = false

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        self.dataSource = self
        self.register(TSReleasePulseCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width - 40 - spacing * 3
        let cellSize = width / cellCount
        layout.itemSize = CGSize(width: cellSize, height: cellSize)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing

        self.collectionViewLayout = layout
        self.reloadData()
    }

    // MARK: - CollectionViewMethod
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TSReleasePulseCollectionViewCell
        if let image =  imageDatas[indexPath.row] as? UIImage {
            cell?.image = image
        }
        
        if let imageURLString = imageDatas[indexPath.row] as? String {
            cell?.imageView.sd_setImage(with: URL(string: imageURLString))
        }
        

        cell?.deleteImageBtn.tag = indexPath.row
        cell?.deleteImageBtn.makeVisible()
        cell?.deleteImageBtnBlock = {[weak self] (btn) in
            self?.didselectCellDelegate?.didTapDeleteImageBtn(btn: btn)
        }
        
        cell?.payinfoSetBtn.isHidden = true
        // 如果不是最大张数，最后一个item显示的是+按钮
        var isLast = false
        if let lastImage = imageDatas.last as? UIImage, lastImage == UIImage.set_image(named: "img_edit_photo_frame") {
            // 在这里可以执行针对最后一个元素为指定图像的操作
            isLast = true
        }
        if fromShare {
            if indexPath.row == (imageDatas.count - 1) && isLast {
                cell?.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
                cell?.layer.borderWidth = frameWidth
                cell?.deleteImageBtn.makeHidden()
            }
        }else{
            if indexPath.row == (imageDatas.count - 1) && isLast {
                cell?.layer.borderColor = TSColor.inconspicuous.highlight.cgColor
                cell?.layer.borderWidth = frameWidth
                cell?.deleteImageBtn.makeHidden()
            }
        }
        
        
       
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 点击进入相册
        self.didselectCellDelegate?.didSelectCell(index: indexPath.row)
    }
}
