//
//  AnnouncementContentView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/5/18.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
import SDWebImage

class AnnouncementContentView: BaseContentView {

    var tapRecognizer: UITapGestureRecognizer!
    
    lazy var displayImage: SDAnimatedImageView = {
        let view = SDAnimatedImageView()
        view.image = UIImage.set_image(named: "IMG_icon")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.roundCorner(10)
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming

        backgroundView.addSubview(displayImage)
        self.addSubview(backgroundView)
        
        guard let message = messageModel.nimMessageModel else { return }
        if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMAnnouncementAttachment {
            
            self.displayImage.sd_setImage(with: URL(string: attachment.imageUrl), completed: nil)
            let finalImageSize = imageSize(attachment.showCoverImage)
            displayImage.snp.makeConstraints { make in
                make.width.equalTo(finalImageSize.width)
                make.height.equalTo(finalImageSize.height)
                make.edges.equalToSuperview()
            }
            backgroundView.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(2)
                make.bottom.equalToSuperview().offset(-2)
                make.left.equalToSuperview().offset(showLeft ? 9:0)
                make.right.equalToSuperview().offset(showLeft ? -0:-9)
            }
            
            
        }
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTouchUpInside))
        self.addGestureRecognizer(tapRecognizer)
        
        
    }
    
    private func imageSize(_ image: UIImage?) -> CGSize {
        if let image = image {
            let imageSize: CGSize = image.size
            let attachmentImageMinWidth  = (ScreenWidth / 4.0);
            let attachmentImageMinHeight = (ScreenWidth / 4.0);
            let attachmemtImageMaxWidth  = (ScreenWidth - 184);
            let attachmentImageMaxHeight = (ScreenWidth - 184);

            let minSize = CGSize(width: attachmentImageMinWidth, height: attachmentImageMinHeight)
            let maxSize = CGSize(width: attachmemtImageMaxWidth, height: attachmentImageMaxHeight)

            return CGSizeMake(0, 0)
        }
        
       
        let attachmemtImageMaxWidth  = (ScreenWidth - 184);
        return CGSize(width: attachmemtImageMaxWidth, height: ScreenWidth / 2.0)
    }
    
    
    @objc func onTouchUpInside(){
        guard let message = self.model.nimMessageModel else { return }
        if let object = message.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMAnnouncementAttachment {
            self.delegate?.AnnouncementTapped(attachment.linkUrl)
        }
 
    }
   

}
