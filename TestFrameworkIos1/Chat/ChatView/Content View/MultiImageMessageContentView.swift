//
//  MultiImageMessageContentView.swift
//  Yippi
//
//  Created by Kit Foong on 19/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel
import SDWebImage
import UIKit

class MultiImageMessageContentView: BaseContentView {
    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        //view.image = UIImage.set_image(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        view.roundCorner(5)
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        return view
    }()
    
    lazy var displayImage2: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        //view.image = UIImage.set_image(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage3: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        //view.image = UIImage.set_image(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        view.backgroundColor = UIColor(hex: 0xF5F5F5)
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage4: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.image = UIImage.set_image(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        view.roundCorner(5)
        return view
    }()
    
    lazy var displayImage4OverlayView: UIView = {
        let view = UIView()
        view.roundCorner(5)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        return view
    }()
    
    lazy var extraCountLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.bold(20)
        label.textColor = UIColor.white
        return label
    }()
    
    var loadingView = IMCircularProgressView()
    var loadingView2 = IMCircularProgressView()
    var loadingView3 = IMCircularProgressView()
    
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
        backgroundView.addSubview(displayImage)
        backgroundView.addSubview(displayImage2)
        backgroundView.addSubview(displayImage3)
        backgroundView.addSubview(displayImage4)
        backgroundView.addSubview(displayImage4OverlayView)
        backgroundView.addSubview(timeTickStackView)
        self.addSubview(backgroundView)
        
        displayImage.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalToSuperview().inset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        displayImage2.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalToSuperview().inset(10)
            make.left.equalTo(displayImage.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage3.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        displayImage4.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage2.snp.bottom).offset(10)
            make.left.equalTo(displayImage3.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage4OverlayView.snp.makeConstraints { make in
            make.width.equalTo(90)
            make.height.equalTo(90)
            make.top.equalTo(displayImage2.snp.bottom).offset(10)
            make.left.equalTo(displayImage3.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        displayImage4OverlayView.addSubview(extraCountLabel)
        extraCountLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        extraCountLabel.text = "\(messageModel.messageList.count - 3)+"
        
        loadingView = IMCircularProgressView(frame: CGRect(x: displayImage.frame.x + 25, y: displayImage.frame.y + 25, width: 40, height: 40))
        loadingView.progressColor = AppTheme.red
        loadingView.trackColor = UIColor(hex: 0xD9D9D9)
        
        loadingView2 = IMCircularProgressView(frame: CGRect(x: displayImage2.frame.x + 25, y: displayImage2.frame.y + 25, width: 40, height: 40))
        loadingView2.progressColor = AppTheme.red
        loadingView2.trackColor = UIColor(hex: 0xD9D9D9)
        
        loadingView3 = IMCircularProgressView(frame: CGRect(x: displayImage3.frame.x + 25, y: displayImage3.frame.y + 25, width: 40, height: 40))
        loadingView3.progressColor = AppTheme.red
        loadingView3.trackColor = UIColor(hex: 0xD9D9D9)
        
        displayImage.addSubview(loadingView)
        displayImage2.addSubview(loadingView2)
        displayImage3.addSubview(loadingView3)
        
        timeTickStackView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(-10)
        }
        
        backgroundView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(230)
            make.edges.equalToSuperview()
        }
    }
    
    private func loadWebImage(imageView: UIImageView, loadingView: IMCircularProgressView?, url: String, placeholderImage: String?) {
        if loadingView != nil {
            if !loadingView!.isHidden {
                loadingView!.setProgressWithAnimation(duration: 0.2, value: 1.0)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if loadingView != nil {
                loadingView!.isHidden = true
            }
            
            imageView.sd_setImage(with: URL(string: url), placeholderImage: placeholderImage == nil ? UIImage.set_image(named: "IMG_icon") : UIImage(contentsOfFile: placeholderImage!))
        }
    }
    
    private func dataUpdate(messageModel: MessageData) {
        if let firstMessage = messageModel.messageList[0].nimMessageModel {
            loadingView.isHidden = firstMessage.isOutgoingMsg ? (firstMessage.deliveryState != NIMMessageDeliveryState.deliveried) : (firstMessage.attachmentDownloadState != NIMMessageAttachmentDownloadState.downloading)
            
            let imageObject = firstMessage.messageObject as! NIMImageObject
            
            self.loadWebImage(imageView: displayImage, loadingView: loadingView, url: imageObject.url.orEmpty, placeholderImage: imageObject.thumbPath)
        }
        
        
        if let secondMessage = messageModel.messageList[1].nimMessageModel {
            loadingView2.isHidden = secondMessage.isOutgoingMsg ? (secondMessage.deliveryState != NIMMessageDeliveryState.deliveried) : (secondMessage.attachmentDownloadState != NIMMessageAttachmentDownloadState.downloading)
            
            let imageObject = secondMessage.messageObject as! NIMImageObject
            
            self.loadWebImage(imageView: displayImage2, loadingView: loadingView2, url: imageObject.url.orEmpty, placeholderImage: imageObject.thumbPath)
        }
        
        if let thirdMessage = messageModel.messageList[2].nimMessageModel {
            loadingView3.isHidden = thirdMessage.isOutgoingMsg ? (thirdMessage.deliveryState != NIMMessageDeliveryState.deliveried) : (thirdMessage.attachmentDownloadState != NIMMessageAttachmentDownloadState.downloading)
            
            let imageObject = thirdMessage.messageObject as! NIMImageObject
            
            self.loadWebImage(imageView: displayImage3, loadingView: loadingView3, url: imageObject.url.orEmpty, placeholderImage: imageObject.thumbPath)
        }
        
        if let forthMessage = messageModel.messageList[3].nimMessageModel {
            let imageObject = forthMessage.messageObject as! NIMImageObject
            
            self.loadWebImage(imageView: displayImage4, loadingView: nil, url: imageObject.url.orEmpty, placeholderImage: imageObject.thumbPath)
        }
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        guard let message = self.model.nimMessageModel else { return }
        
        if message.messageObject is NIMImageObject {
            self.delegate?.imageTapped(model)
        }
    }
}

