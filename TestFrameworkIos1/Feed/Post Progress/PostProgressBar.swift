//
//  PostProgressBar.swift
//  Yippi
//
//  Created by Yong Tze Ling on 03/06/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import TZImagePickerController

public enum PostProgressStatus {
    case posting
    case finishingUp
    case complete
    case fail
    case rejectPostFail
    
    var text: String {
        switch self {
        case .complete: return "feed_upload_verify_title".localized
        case .posting: return  "feed_upload_posting".localized
        case .finishingUp : return "feed_upload_post_done".localized
        case .fail: return "feed_upload_fail".localized
        case .rejectPostFail: return "posting_sensitive_message".localized
        }
    }
}

class PostProgressBar: UIView {
    
    private lazy var progressBar: UIProgressView = {
        let progress = UIProgressView()
        progress.trackTintColor = AppTheme.red.withAlphaComponent(0.35)
        progress.progressTintColor = AppTheme.red
        return progress
    }()
    
    private lazy var thumbnailView: UIImageView = {
        let imageView = UIImageView()
        imageView.roundCorner(4)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.numberOfLines = 2
        textLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        textLabel.textColor = .darkGray
        return textLabel
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.alignment = .center
        stackview.axis = .horizontal
        stackview.distribution = .fillProportionally
        stackview.spacing = 10
        return stackview
    }()
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "ic_reload_post_task"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage.set_image(named: "ic_cancel_post_task"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    private var status: PostProgressStatus = .posting {
        didSet {
            self.textLabel.text = status.text
            switch status {
            case .posting:
                progressBar.trackTintColor = AppTheme.red.withAlphaComponent(0.35)
                progressBar.progressTintColor = AppTheme.red
                progressBar.setProgress(0, animated: false)
            case .finishingUp:
                self.progressBar.setProgress(1, animated: true)
            case .complete:
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.removeFromSuperview()
                    self.onRemoveTask?()
                }
            case .fail:
                progressBar.progressTintColor = .red
                progressBar.trackTintColor = .red.withAlphaComponent(0.35)
                progressBar.setProgress(1, animated: true)
                
            case .rejectPostFail:
                progressBar.progressTintColor = AppTheme.red
                progressBar.trackTintColor = AppTheme.red.withAlphaComponent(0.35)
                progressBar.setProgress(1, animated: true)
            }
            
            if status == .finishingUp {
                loadingIndicator.startAnimating()
            } else {
                loadingIndicator.stopAnimating()
            }
            
            switch status {
            case .fail:
                retryButton.isHidden = false
                cancelButton.isHidden = false
            case .rejectPostFail:
                retryButton.isHidden = true
                cancelButton.isHidden = false
            default:
                retryButton.isHidden = true
                cancelButton.isHidden = true
            }
          
            FeedIMSDKManager.shared.delegate?.didChangeCreateFeedProgressStatus(status: status)
        }
    }
    
    private var thumbnail: UIImage?
    var onRemoveTask: EmptyClosure?
    var isComplete: Bool {
        return status == .complete
    }
    var isRejectFail: Bool {
        return status == .rejectPostFail
    }
    private var convertedVideoURL: String = ""
    
    var singleImg: Float = 0
    var arrProgress = [Progress]()
    
    func add(post: PostModel) {
        
        self.addSubview(stackview)
        self.addSubview(progressBar)
        stackview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(14)
            $0.top.bottom.equalToSuperview()
        }
        progressBar.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(2)
        }
        if post.hasCover {
            stackview.addArrangedSubview(thumbnailView)
            thumbnailView.snp.makeConstraints {
                $0.width.height.equalTo(37)
            }
            self.addSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints {
                $0.center.width.height.equalTo(thumbnailView)
            }
        } else {
            stackview.addArrangedSubview(loadingIndicator)
            loadingIndicator.snp.makeConstraints {
                $0.width.height.equalTo(37)
            }
        }
        stackview.addArrangedSubview(textLabel)
        stackview.addArrangedSubview(retryButton)
        stackview.addArrangedSubview(cancelButton)
        
        retryButton.snp.makeConstraints {
            $0.width.height.equalTo(25)
        }
        cancelButton.snp.makeConstraints {
            $0.width.height.equalTo(25)
        }
        
        textLabel.text = status.text
        retryButton.addAction { [weak self] in
            guard let self = self else { return }
            self.status = .posting
            self.releaseStart(object: post)
            self.layoutIfNeeded()
        }
        cancelButton.addAction { [weak self] in
            guard let self = self else {
                return
            }
            self.removeFromSuperview()
            if let videoURL = URL(string: self.convertedVideoURL), FileManager.default.fileExists(atPath: videoURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: videoURL.path)
                } catch {
                    print(error.localizedDescription)
                }
            }
            self.onRemoveTask?()
        }
        
        releaseStart(object: post)
    }
    
    private func setThumbnail(_ image: UIImage?) {
        guard thumbnail == nil else {
            return
        }
        thumbnail = image
        thumbnailView.image = image
    }
    private func setThumbnail(_ imageUrl: String?) {
        guard let imageUrl = imageUrl else {
            return
        }
        thumbnailView.sd_setImage(with: URL(string: imageUrl))
    }
    private func releaseStart(object: PostModel) {
        
        if object.phAssets?.count ?? 0 > 0 || object.images?.count ?? 0 > 0 {
            if object.isEditFeed == true {
                self.postPhotosWithRejectFeed(object: object)
            } else {
                self.postPhotos(object: object)
            }
        } else if object.postPhoto?.isEmpty == false && object.phAssets?.isEmpty == true {
            self.postPhotosWithData(object: object)
        } else if object.rejectNeedsUploadVideo == false {
            self.postVideoLocally(object: object)
        }
//        else if object.rejectNeedsUploadVideo != nil && object.videoCoverId != nil && object.videoDataId != nil {
//            self.postVideoLocally(object: object)
//        }
        else if object.video != nil && object.postVideo == nil {
            self.postVideo(object: object)
        } else if object.postVideo != nil {
            self.postVideoWithData(object: object)
        } else {
            if object.isEditFeed == true {
                self.postPhotosWithRejectFeed(object: object)
            } else {
                TSMomentNetworkManager().release(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: nil, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .finishingUp
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                self?.status = .complete
                            }
                        }
                    }
                }
            }
        }
    }
    
   private func deleteFile(atPath filePath: String) {
        let fileManager = FileManager.default
        
        // 判断文件是否存在
        if fileManager.fileExists(atPath: filePath) {
            do {
                // 尝试删除文件
                try fileManager.removeItem(atPath: filePath)
                print("文件删除成功")
            } catch {
                print("文件删除失败: \(error.localizedDescription)")
            }
        } else {
            print("文件不存在")
        }
    }
    
}

// Image
extension PostProgressBar {
    private func postPhotos(object: PostModel) {
 
        guard let assets = object.phAssets else {
            self.status = .fail
            return
        }
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        for asset in assets {
            
            PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { [weak self] imageData, type, orientation, info in
                guard let data = imageData, let image = UIImage(data: data) else {
                    return
                }
                
                self?.setThumbnail(image)
                
                switch type {
                case String(kUTTypeGIF):
                    imageMimeType.append("image/gif")
                    let compressedData = ImageCompress.compressImageData(data, limitDataSize: 500 * 1024) ?? Data()
                    uploadDatas.append(compressedData)
                case "public.heic":
                    imageMimeType.append("image/jpeg")
                    if #available(iOS 10.0, *) {
                        guard let ciImage = CIImage(data: data), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                            return
                        }
                        let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                        uploadDatas.append(compressedData)
                    }
                default:
                    imageMimeType.append("image/jpeg")
                    let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
            }
        }
        TSUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
            guard let self = self else { return }
            if progress.fractionCompleted == 1 {
                self.arrProgress.append(progress)
            }
            DispatchQueue.main.async {
                if uploadDatas.count > 1 {
                    
                    var currentProg: Float = 0.1
                    let max: Float = 0.8
                    
                    self.singleImg = max / Float(uploadDatas.count)
                    currentProg += self.singleImg * Float(self.arrProgress.count)
                    self.progressBar.setProgress(currentProg, animated: true)
                } else {
                    self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                }
            }
        } complete: { [weak self] imageFileds in
            if imageFileds.isEmpty == false && imageFileds.count > 0 {
                self?.status = .finishingUp
                TSMomentNetworkManager().release(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .complete
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.status = .fail
                }
            }
        
        }

    }
    
    private func postPhotosWithData(object: PostModel) {
    
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        
        for postPhoto in object.postPhoto ?? [] {
            let image = UIImage(data: postPhoto.data!)
            self.setThumbnail(image)
            
            switch postPhoto.type {
            case String(kUTTypeGIF):
                imageMimeType.append("image/gif")
                let compressedData = ImageCompress.compressImageData(postPhoto.data!, limitDataSize: 500 * 1024) ?? Data()
                uploadDatas.append(compressedData)
            case "public.heic":
                imageMimeType.append("image/jpeg")
                if #available(iOS 10.0, *) {
                    guard let ciImage = CIImage(data: postPhoto.data!), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                        return
                    }
                    let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
            default:
                imageMimeType.append("image/jpeg")
                let compressedData = image?.jpegData(compressionQuality: 1.0) ?? Data()
                uploadDatas.append(compressedData)
            }
        }
        TSUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
            guard let self = self else { return }
            if progress.fractionCompleted == 1 {
                self.arrProgress.append(progress)
            }
            DispatchQueue.main.async {
                if uploadDatas.count > 1 {
                    
                    var currentProg: Float = 0.1
                    let max: Float = 0.8
                    
                    self.singleImg = max / Float(uploadDatas.count)
                    currentProg += self.singleImg * Float(self.arrProgress.count)
                    self.progressBar.setProgress(currentProg, animated: true)
                } else {
                    self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                }
            }
        } complete: { [weak self] imageFileds in
            if imageFileds.isEmpty == false && imageFileds.count > 0 {
                self?.status = .finishingUp
                TSMomentNetworkManager().release(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                    DispatchQueue.main.async {
                        if error != nil {
                            self?.status = .fail
                        } else {
                            self?.status = .complete
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self?.status = .fail
                }
            }
        
        }
    
    }
    
    private func postPhotosWithRejectFeed(object: PostModel) {
       
        if (object.phAssets?.count == 0 && object.images?.count == 0) || (object.phAssets == nil && object.images == nil) {
            
            TSMomentNetworkManager().editRejectFeed(feedID: object.feedId ?? "", feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: nil, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.status = .rejectPostFail
                    } else {
                        self?.status = .finishingUp
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.status = .complete
                        }
                    }
                }
            }
            return
        }

        // Continue with the rest of the code if phAssetsCount == 0 && imagesCount == 0
        
        let option = PHImageRequestOptions()
        var imageMimeType: [String] = []
        var uploadDatas: [Data] = []
        option.isSynchronous = true
        if let assets = object.phAssets {
            for asset in assets {
                
                PHImageManager.default().requestImageDataAndOrientation(for: asset, options: option) { [weak self] imageData, type, orientation, info in
                    guard let data = imageData, let image = UIImage(data: data) else {
                        return
                    }
                    
                    self?.setThumbnail(image)
                    
                    switch type {
                    case String(kUTTypeGIF):
                        imageMimeType.append("image/gif")
                        let compressedData = ImageCompress.compressImageData(data, limitDataSize: 500 * 1024) ?? Data()
                        uploadDatas.append(compressedData)
                    case "public.heic":
                        imageMimeType.append("image/jpeg")
                        if #available(iOS 10.0, *) {
                            guard let ciImage = CIImage(data: data), let imageData = CIContext().jpegRepresentation(of: ciImage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [:]), let image = UIImage(data: imageData) else {
                                return
                            }
                            let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                            uploadDatas.append(compressedData)
                        }
                    default:
                        imageMimeType.append("image/jpeg")
                        let compressedData = image.jpegData(compressionQuality: 1.0) ?? Data()
                        uploadDatas.append(compressedData)
                    }
                }
            }
            
        }
        //这里上传需要注意判断originalImageIds 已有的图片ID
        var originalImageIds: [Int] = []
        if let images = object.images {
            var thumbnailSet = false // 用于跟踪是否已经设置了缩略图
            for (index, image) in images.enumerated() {
                if let imageItem = image as? UIImage {
                    // 只在第一个元素上设置缩略图
                    if index == 0 && !thumbnailSet {
                        self.setThumbnail(imageItem)
                        thumbnailSet = true // 设置为true，表示已经设置了缩略图
                    }
                    imageMimeType.append("image/jpeg")
                    let compressedData = imageItem.jpegData(compressionQuality: 1.0) ?? Data()
                    uploadDatas.append(compressedData)
                }
                if let imageModel = image as? RejectDetailModelImages {
                    // 只在第一个元素上设置缩略图
                    if index == 0 && !thumbnailSet {
                        self.setThumbnail(imageModel.imagePath)
                        thumbnailSet = true // 设置为true，表示已经设置了缩略图
                    }
                    originalImageIds.append(imageModel.fileId)
                }
            }
        }
        //如果用户不需要上传任何图片
        if uploadDatas.count == 0 && originalImageIds.count > 0 {
            TSMomentNetworkManager().editRejectFeed(feedID: object.feedId ?? "", feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: originalImageIds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                DispatchQueue.main.async {
                    if error != nil {
                        self?.status = .rejectPostFail
                    } else {
                        self?.status = .finishingUp
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self?.status = .complete
                        }
                    }
                }
            }
        }else {
            TSUploadNetworkManager().uploadFileToOBS(fileDatas: uploadDatas) {[weak self] progress in
                guard let self = self else { return }
                if progress.fractionCompleted == 1 {
                    self.arrProgress.append(progress)
                }
                DispatchQueue.main.async {
                    if uploadDatas.count > 1 {
                        
                        var currentProg: Float = 0.1
                        let max: Float = 0.8
                        
                        self.singleImg = max / Float(uploadDatas.count)
                        currentProg += self.singleImg * Float(self.arrProgress.count)
                        self.progressBar.setProgress(currentProg, animated: true)
                    } else {
                        self.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5, animated: true)
                    }
                }
            } complete: { [weak self] imageFileds in
                if imageFileds.isEmpty == false && imageFileds.count > 0 {
                    self?.status = .finishingUp
                    TSMomentNetworkManager().release(feedContent: object.feedContent, feedId: object.feedMark, privacy: object.privacy, images: imageFileds, feedFrom: 3, topics: object.topics, repostType: object.repostType, repostId: object.repostModel?.id, customAttachment: object.shareModel, location: object.taggedLocation, isHotFeed: object.isHotFeed, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (feedId, error) in
                        DispatchQueue.main.async {
                            self?.status = .complete
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.status = .fail
                    }
                }
            
            }

        }
  
    }
    
}

// Video
extension PostProgressBar {
    
    private func postVideo(object: PostModel) {
        self.setThumbnail(object.video?.coverImage)
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        if let asset = object.video?.asset {
            convertShortVideoAssetToMP4(asset: asset) { [weak self] url in
                if let url = url {
                    self?.convertedVideoURL = url.relativeString
                }
                dispatchGroup.leave()
            }
        } else if let recorderSession = object.video?.recorderSession?.outputUrl {
            convertedVideoURL = recorderSession.absoluteString
            dispatchGroup.leave()
        } else if let url = object.video?.videoFileURL {
            convertedVideoURL = url.relativeString
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            guard let url = URL(string: self.convertedVideoURL), let coverImage = object.video?.coverImage else {
                self.status = .fail
                return
            }
            
            let session = URLSession.shared
            let task = session.dataTask(with: url) { (data, response, error) in
                // 处理网络请求的响应
                if let error = error {
                    // 处理错误
                    DispatchQueue.main.async {
                        self.status = .fail
                    }
                    print("Error: \(error)")
                    return
                }
                if let videoData = data {
                    // 成功获取到视频数据，可以在这里进行后续操作
                    print("upload video size: \(videoData.count)")
                    
                    let coverData: Data = coverImage.jpegData(compressionQuality: 1.0) ?? Data()
                    
                    let videoSize = CGSize(width: coverImage.size.width, height: coverImage.size.height)
                    
                    DispatchQueue.global(qos: .background).async {
                        var videoFileID: Int? = nil
                        var imageFildID: Int? = nil
                        let requestGroup = DispatchGroup()
                        requestGroup.enter()
                       
                        TSUploadNetworkManager().uploadFileToOBS(fileDatas: [videoData], isImage: false, videoSize: videoSize, progressHandler: {[weak self] progress in
                            DispatchQueue.main.async {
                                self?.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5 + 0.5, animated: true)
                            }
                        }) { fileIDs in
                            defer {
                                requestGroup.leave()
                            }
                            guard  let fileID =  fileIDs.first else {
                                return
                            }
                            videoFileID = fileID
                        }
                       
                        requestGroup.enter()
                        TSUploadNetworkManager().uploadFileToOBS(fileDatas: [coverData], isImage: true) { fileIDs in
                            defer {
                                requestGroup.leave()
                            }
                            guard  let fileID =  fileIDs.first else {
                                return
                            }
                            imageFildID = fileID
                        }

                        requestGroup.notify(queue: DispatchQueue.main) {
                            
                            if let videoFileID = videoFileID, let imageFildID = imageFildID {
                                self.status = .finishingUp
                                if object.isEditFeed == true {
                                    TSMomentNetworkManager().editRejectShortVideo(feedID: object.feedId ?? "" , shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                                        DispatchQueue.main.async {
                                            if myFeedId == nil {
                                                self?.status = .rejectPostFail
                                            } else {
                                                self?.status = .finishingUp
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                    self?.status = .complete
                                                }
                                            }
                                        }
                                    }
                                }else{
                                    TSMomentNetworkManager().postShortVideo(shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                                        //if myFeedId != nil {
                                        self?.status = .complete
                                        if FileManager.default.fileExists(atPath: url.path) {
                                            do {
                                                try FileManager.default.removeItem(at: url)
                                            } catch {
                                                print(error.localizedDescription)
                                            }
                                        }
                                        // } else {
                                        //     self?.status = .fail
                                        // }
                                    }
                                }
                                
                            } else {
                                self.status = .fail
                            }
                        }
                    }
                }
            }.resume()
            
            
        }
        
    }
    
    private func postVideoLocally(object: PostModel) {
        //处理视频本地操作，而不进行上传
        self.setThumbnail(object.video?.coverImage)
        TSMomentNetworkManager().editRejectShortVideo(feedID: object.feedId ?? "" , shortVideoID: object.videoDataId ?? 0, coverImageID: object.videoCoverId ?? 0, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
            DispatchQueue.main.async {
                if myFeedId == nil {
                    self?.status = .rejectPostFail
                } else {
                    self?.status = .finishingUp
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self?.status = .complete
                    }
                }
            }
        }
        
    }
    
    private func postVideoWithData(object: PostModel){
        self.setThumbnail(object.video?.coverImage)
        
        guard let coverImage = object.video?.coverImage else {
            self.status = .fail
            return
        }
        
        var videoData = Data()
        if let postVideo = object.postVideo {
            for item in postVideo {
                videoData = item.data!
            }
        }
        
        let coverData: Data = coverImage.jpegData(compressionQuality: 1.0) ?? Data()
        
        let videoSize = CGSize(width: coverImage.size.width, height: coverImage.size.height)
            
        DispatchQueue.global(qos: .background).async {
            var videoFileID: Int? = nil
            var imageFildID: Int? = nil
            let requestGroup = DispatchGroup()
            requestGroup.enter()
            TSUploadNetworkManager().uploadFileToOBS(fileDatas: [videoData], isImage: false, progressHandler: {[weak self] progress in
                DispatchQueue.main.async {
                    self?.progressBar.setProgress(Float(progress.fractionCompleted) * 0.5 + 0.5, animated: true)
                }
            }) { fileIDs in
                defer {
                    requestGroup.leave()
                }
                guard  let fileID =  fileIDs.first else {
                    return
                }
                videoFileID = fileID
            }
            
            requestGroup.enter()
            TSUploadNetworkManager().uploadFileToOBS(fileDatas: [coverData], isImage: true, videoSize: videoSize) { fileIDs in
                defer {
                    requestGroup.leave()
                }
                guard  let fileID =  fileIDs.first else {
                    return
                }
                imageFildID = fileID
            }
            
            
            requestGroup.notify(queue: DispatchQueue.main) {
                //本地视频存在就删除
                if let url = object.video?.videoFileURL {
                    let path = url.relativeString.replacingOccurrences(of: "file:///", with: "")
                    self.deleteFile(atPath: path)
                }
                
                if let videoFileID = videoFileID, let imageFildID = imageFildID {
                    self.status = .finishingUp
                    TSMomentNetworkManager().postShortVideo(shortVideoID: videoFileID, coverImageID: imageFildID, feedMark: object.feedMark, feedContent: object.feedContent, privacy: object.privacy, feedFrom: 3, topics: object.topics, location: object.taggedLocation, isHotFeed: object.isHotFeed, soundId: object.soundId, videoType: object.videoType ?? .normalVideo, tagUsers: object.tagUsers, tagMerchants: object.tagMerchants, tagVoucher: object.tagVoucher) { [weak self] (myFeedId, myErrMsg) in
                        if myFeedId != nil {
                            self?.status = .complete
                        } else {
                            self?.status = .fail
                        }
                    }
                } else {
                    self.status = .fail
                }
            }
        }
    }
    
    private func convertShortVideoAssetToMP4(asset:PHAsset, completion: @escaping (URL?) -> Void) {
        guard let manager = TZImageManager.default() else {
            return
        }
        guard let config = TZImagePickerConfig.sharedInstance() else {
            return
        }
        config.needFixComposition = true
        
        //When export 5mins video, AVAssetExportPreset1280x720: 569mb, AVAssetExportPresetMediumQuality: 28.7mb
        //Server video size limitation Production: 200mb, preprod: 150mb
        let exportQuality: String = AVAssetExportPresetMediumQuality
        
        manager.getVideoOutputPath(with: asset, presetName: exportQuality, success: { (outputPath) in
            guard let outputPath = outputPath else {
                completion(nil)
                return
            }
            completion(URL(fileURLWithPath: outputPath))
        }, failure: { (_, _) in
            completion(nil)
        }, progressUpdate: #selector(PostProgressBar.updateProgress(timer:)), inClass: self)
    }
    
    @objc private func updateProgress(timer: Timer) {
        guard let exportSession = timer.userInfo as? AVAssetExportSession else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.progressBar.setProgress(exportSession.progress * 0.5, animated: true)
        }
    }
}

struct PostModel {
    let feedMark: Int
    let isHotFeed: Bool
    let feedContent: String
    let privacy: String
    let repostModel: TSRepostModel?
    let shareModel: SharedViewModel?
    let topics: [TopicCommonModel]?
    let taggedLocation: TSPostLocationObject?
    
    // photo
    let phAssets: [PHAsset]?
    let postPhoto: [PostPhotoExtension]?

    // video
    let video: ShortVideoAsset?
    let soundId: String?
    let videoType: VideoType?
    let postVideo: [PostVideoExtension]?
    
    var repostType: String? {
        return repostModel == nil ? nil : "feeds"
    }
    
    var hasCover: Bool {
        if let assets = phAssets, assets.count > 0 {
            return true
        }else if let imgs = images, imgs.count > 0 {
            return true
        }
        else if video?.coverImage != nil {
            return true
        }
        return false
    }
    //是否提交被驳回的动态
    let isEditFeed: Bool
    //动态id
    let feedId: String?
    //图片资源
    let images: [Any]?
    //是否需要重新上传视频资源
    let rejectNeedsUploadVideo: Bool?
    //视频封面Id
    let videoCoverId: Int?
    //视频Id
    let videoDataId: Int?
    //记录发布动态时标记的用户IDs
    let tagUsers: [UserInfoModel]?
    //记录发布动态时标记的商家IDs
    let tagMerchants: [UserInfoModel]?
    //记录发布动态时标记的代金券ID
    let tagVoucher: TagVoucherModel?
}

class PostTaskManager {
    
    let taskProgressView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 0
        $0.distribution = .fillEqually
        $0.alignment = .fill
    }

    
    static let UpdateViewNotification = Notification.Name("UpdateViewNotification")

    static let shared = PostTaskManager()
    
    var onUpdateView: EmptyClosure?
//    {
//        didSet {
//            taskProgressView.isHidden = taskProgressView.arrangedSubviews.count == 0
//        }
//    }
    
    
    var updateColor: Bool? = false
    var progressIsHidden: Bool = true
    var arrProgressView = [PostProgressBar]()
    
    init() {}
    
    func addTask(_ task: PostModel) {
        self.progressIsHidden = false
        let postView = PostProgressBar()
        postView.add(post: task)
        arrProgressView.append(postView)
        self.taskProgressView.addArrangedSubview(postView)
        postView.snp.makeConstraints {
            $0.height.equalTo(46)
        }
        postView.onRemoveTask = {
            self.taskProgressView.layoutIfNeeded()
            self.progressIsHidden = self.arrProgressView.count == 0
            self.onUpdateView?()
            NotificationCenter.default.post(name: PostTaskManager.UpdateViewNotification, object: nil)
        }
        postView.addAction {
            if postView.isComplete {
                NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": TSCurrentUserInfo.share.userInfo?.userIdentity ?? 0])
            }
            if postView.isRejectFail {
                DispatchQueue.main.async {
                    postView.removeFromSuperview()
                }
                NotificationCenter.default.post(name: NSNotification.Name.CommentChange.editModel, object: nil, userInfo: ["post_model": task])
                
            }
        }
        if self.updateColor! {
            updateColor = false
            postView.textLabel.textColor = .white
            postView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
        }
        self.taskProgressView.layoutIfNeeded()
        self.onUpdateView?()
        NotificationCenter.default.post(name: PostTaskManager.UpdateViewNotification, object: nil)

    }
    
    func updateTextColor() {
        for view in arrProgressView {
            if updateColor! {
                view.textLabel.textColor = .white
                view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.15)
            } else {
                view.textLabel.textColor = .darkGray
                view.backgroundColor = .white
            }
            self.taskProgressView.layoutIfNeeded()
        }
    }
    
    func isAbleToPost() -> Bool {
        return self.taskProgressView.arrangedSubviews.count < 3
    }
    
    func clear() {
        for subview in taskProgressView.arrangedSubviews {
               taskProgressView.removeArrangedSubview(subview)
               subview.removeFromSuperview()
           }
    }
}
