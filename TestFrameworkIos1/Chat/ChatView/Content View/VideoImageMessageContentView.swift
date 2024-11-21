//
//  VideoImageMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 01/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel
import SDWebImage
import UIKit

class VideoImageMessageContentView: BaseContentView {
    
    lazy var overlayImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "bubblecell_overlay")
        return view
    }()
    
    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        //view.image = UIImage.set_image(named: "IMG_icon")
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    lazy var playImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ico_video_play_list")
        return view
    }()
    
    var loadingView = IMCircularProgressView()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.roundCorner(10)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        let finalImageSize = imageSize(messageModel.nimMessageModel?.messageObject)
        
        timeLabel.textColor = .white
        displayImage.isHidden = false
        
        backgroundView.addSubview(displayImage)
        backgroundView.addSubview(playImage)
        backgroundView.addSubview(overlayImage)
        backgroundView.addSubview(timeTickStackView)
        self.addSubview(backgroundView)
        
        displayImage.snp.makeConstraints { make in
            make.width.equalTo(finalImageSize.width)
            make.height.equalTo(finalImageSize.height)
            make.edges.equalToSuperview()
        }
        
        overlayImage.snp.makeConstraints { make in
            make.width.equalTo(finalImageSize.width)
            make.height.equalTo(60)
            make.bottom.equalTo(displayImage.snp.bottom)
        }
        
        loadingView = IMCircularProgressView(frame: CGRect(x: (finalImageSize.width / 2) - 20, y: (finalImageSize.height / 2) - 20, width: 40, height: 40))
        loadingView.progressColor = AppTheme.red
        loadingView.trackColor = UIColor(hex: 0xD9D9D9)
        
        displayImage.addSubview(loadingView)
        
        playImage.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.center.equalTo(displayImage.snp.center)
        }
        
        timeTickStackView.snp.makeConstraints { make in
            make.bottom.equalTo(-3)
            make.right.equalTo(-2)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.left.top.equalToSuperview().offset(8)
            make.bottom.right.equalToSuperview().offset(-8)
        }
    }
    
    private func imageSize(_ messageObject: NIMMessageObject?) -> CGSize {
        var imageSize: CGSize = .zero
        
        guard let messageObject = messageObject else { return .zero }
        
        if messageObject is NIMImageObject {
            let imageObject = messageObject as! NIMImageObject
            if (!(imageObject.size.equalTo(.zero))) {
                imageSize = imageObject.size
            } else if let image = UIImage(contentsOfFile: imageObject.thumbPath ?? "") {
                imageSize = image.size
            }
        }
        else if messageObject is NIMVideoObject {
            let videoObject = messageObject as! NIMVideoObject
            imageSize = videoObject.coverSize
        }
        
        
        let attachmentImageMinWidth  = (ScreenWidth / 4.0);
        let attachmentImageMinHeight = (ScreenWidth / 4.0);
        let attachmemtImageMaxWidth  = (ScreenWidth - 184);
        let attachmentImageMaxHeight = (ScreenWidth - 184);
        
        let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
        let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)

        return CGSizeMake(0, 0)
    }
    
    private func loadWebImage(imageView: UIImageView, loadingView: IMCircularProgressView?, url: String, placeholderImage: String?, isVideo: Bool) {
        if loadingView != nil {
            if !loadingView!.isHidden {
                loadingView!.setProgressWithAnimation(duration: 0.3, value: 1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.4) {
            if loadingView != nil {
                loadingView!.isHidden = true
            }
            
            if isVideo  {
                self.playImage.isHidden = false
            }
            
            imageView.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage == nil ? UIImage.set_image(named: "IMG_icon") : UIImage(contentsOfFile: placeholderImage!))
        }
    }
    
    private func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        
        if message.messageObject is NIMImageObject {
            playImage.isHidden = true
            loadingView.isHidden = message.isOutgoingMsg ? (message.deliveryState != NIMMessageDeliveryState.deliveried) : (message.attachmentDownloadState != NIMMessageAttachmentDownloadState.downloading)
            
            let imageObject = message.messageObject as! NIMImageObject

            self.loadWebImage(imageView: displayImage, loadingView: loadingView, url: imageObject.url.orEmpty, placeholderImage: imageObject.thumbPath, isVideo: message.messageObject is NIMVideoObject)
        } else if message.messageObject is NIMVideoObject {
            loadingView.isHidden = (message.deliveryState != NIMMessageDeliveryState.deliveried)
            playImage.isHidden = true
            
            let videoObject = message.messageObject as! NIMVideoObject
            
            self.loadWebImage(imageView: displayImage, loadingView: loadingView, url: videoObject.coverUrl.orEmpty, placeholderImage: videoObject.coverPath, isVideo: message.messageObject is NIMVideoObject)
        }
    }
    
    func updateProgress(_ progress: Float) {
        if progress >= 1.0 {
            loadingView.isHidden = true
        }
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        guard let message = self.model.nimMessageModel else { return }
        
        if message.messageObject is NIMImageObject {
            self.delegate?.imageTapped(model)
        } else if message.messageObject is NIMVideoObject {
            self.delegate?.videoTapped(model)
        }
    }
}
