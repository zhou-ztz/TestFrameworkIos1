//
//  ImageCollectView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/4/13.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation

class ImageVideoCollectView: BaseCollectView {
    lazy var imageView: SDAnimatedImageView = {
        let image = SDAnimatedImageView()
        //image.image = UIImage.set_image(named: "IMG_icon")
        //image.backgroundColor = .lightGray
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    lazy var playImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage.set_image(named: "ico_video_play_list")
        return image
    }()
    
    override init(collectModel: FavoriteMsgModel, indexPath: IndexPath) {
        super.init(collectModel: collectModel, indexPath: indexPath)
        self.commitUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commitUI() {
        self.imageAttachmentForJson(josnStr: self.collectModel.data)
        
        guard let model = self.dictModel else {return}
        self.nameLable.text = model.fromAccount
        self.avatarView.avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.fromAccount)
        
        if self.collectModel.type == .image {
            self.imageView.sd_setImage(with: URL(string: self.imageAttachment?.url ?? ""), completed: nil)
            playImage.isHidden = true
        } else {
            if let url = URL(string: self.videoAttachment?.url ?? "") {
                DispatchQueue.global().async {
                    let image = self.generateThumnail(url: url)
                    DispatchQueue.main.async {
                        self.imageView.image = image
                    }
                }
            }
            
            //self.imageView.sd_setImage(with: URL(string: self.videoAttachment?.coverUrl ?? ""), completed: nil)
            playImage.isHidden = false
        }
        
        if model.sessionType == "Team" {
            contentStackView.addArrangedSubview(self.imageView)
            contentStackView.addArrangedSubview(self.groupView)
        } else {
            contentStackView.addArrangedSubview(self.imageView)
        }
        
        self.imageView.snp.makeConstraints { (make) in
            make.left.equalTo(0)
            make.height.width.equalTo(80)
        }
        
        self.imageView.addSubview(self.playImage)
        playImage.snp.makeConstraints { (make) in
            make.height.width.equalTo(20)
            make.center.equalToSuperview()
        }
        
        self.contentStackView.snp.makeConstraints { (make) in
            make.left.equalTo(12)
            make.top.equalTo(12)
            make.right.equalTo(-50)
            make.bottom.equalTo(-12)
        }
    }
    
    
    func generateThumnail(url : URL) -> UIImage? {
        let asset : AVAsset = AVAsset(url: url)
        let assetImgGenerate : AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        var frameImg: UIImage?
        let time: CMTime = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        do {
            let img: CGImage = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            frameImg = UIImage(cgImage: img)
        } catch  {
            
        }

        return frameImg
    }
    

}
