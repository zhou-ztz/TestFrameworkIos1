//
//  TSPHAssetExtension.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/3/16.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import Photos

extension PHAsset {

    // 图片文件名
    var originalFilename: String? {
        var fname: String?
        if #available(iOS 9.0, *) {
            let resources = PHAssetResource.assetResources(for: self)
            if let resource = resources.first {
                fname = "\(arc4random() % 10_000)" + resource.originalFilename
            }
        }
        if fname == nil {
            // this is an undocumented workaround that works as of iOS 9.1
            fname = self.value(forKey: "filename") as? String
            guard let name = fname else {
                fname = "\(arc4random() % 10_000)"
                return fname
            }
            fname = "\(arc4random() % 10_000)" + name
        }
        return fname
    }
}

extension PHAsset {
    var coverImage : UIImage {
        get {
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var thumbnail = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: self, targetSize: CGSize(width: 300, height: 300), contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                if let result = result {
                    thumbnail = result
                }
            })
            return thumbnail
        }
    }
}

extension PHAsset {

    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

