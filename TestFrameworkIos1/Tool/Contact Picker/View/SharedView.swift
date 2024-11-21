//
//  SharedView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 30/05/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


extension TSRepostView {
    
    func getSuperViewHeight() -> CGFloat {
        return TSRepostViewUX.postUIPostVideoCardHeight
    }
    
    func updatePostSharedUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        if shouldShowCancelButton {
            cancelImageButton.isHidden = false
        } else {
            cancelImageButton.isHidden = true
            self.bringSubviewToFront(cancelImageButton)
        }
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight)
            }
        } else {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight)
            }
        }
        
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
        contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        coverImageView.roundCorner(2)
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = false
        titleLab.numberOfLines = 1
        postDetailLab.numberOfLines = 2
        contentLab.numberOfLines = 1
        titleLab.text = model.title
//        if model.sharedType == SharedType.live.rawValue, let postExtra = model.extra, let postId = Int(postExtra) {
//            do {
//                titleLab.text = LiveStoreManager().fetchById(id: postId.uint64)?.hostName
//            } catch let err {
//                LogManager.Log(err, loggingType: .exception)
//            }
//        }
        postDetailLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "" : model.desc?.removeNewLineChar()
        contentLab.textColor = TSColor.main.theme
        if model.type == .user {
            contentLab.text = "view_user".localized
        } else  if model.type == .sticker {
            contentLab.text = "sticker_view".localized
        } else if model.type == .live {
            contentLab.text = "feed_click_live".localized
        } else if model.type == .miniProgram {
            let mpIcon = NSTextAttachment()
            mpIcon.image = UIImage.set_image(named: "ic_miniProgram")
            mpIcon.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            let space: NSAttributedString = NSAttributedString(string: " ")
            let fullString: NSMutableAttributedString = NSMutableAttributedString(attachment: mpIcon)
            fullString.append(space)
            let text: NSAttributedString = NSAttributedString(string: "view_mini_program".localized)
            fullString.append(text)
            contentLab.attributedText = fullString
        } else if model.type == .miniVideo {
            contentLab.text = "feed_click_mini_video".localized
        } else if model.type == .metadata {
            titleLab.numberOfLines = 2
            let urlString = model.url.orEmpty
            let url = URL(string: urlString)
            let domain = url?.host
            contentLab.text = domain
        }
        coverImageView.snp.remakeConstraints { (make) in
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.top.left.bottom.equalToSuperview().inset(12)
            make.width.equalTo(coverImageView.snp.height)
            make.height.equalTo(coverImageView.snp.height)
        }
        coverImageView.layer.cornerRadius = 4
//        coverImageView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        coverImageView.layer.borderWidth = 1
        if let thumbnail = model.thumbnail {
            coverImageView.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        } else {
            coverImageView.image = UIImage.set_image(named: "post_placeholder")
        }

        if (postDetailLab.text ?? "").isEmpty {
            postDetailLab.isHidden = true
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.bottom.equalTo(contentLab.snp.top).offset(-5)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
        } else {
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
            postDetailLab.removeConstraints(postDetailLab.constraints)
            postDetailLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(2)
                make.height.equalTo(42)
            }
            setNeedsDisplay()
            layoutIfNeeded()
            postDetailLab.sizeToFit()
            postDetailLab.snp.updateConstraints {
                $0.height.equalTo(postDetailLab.frame.height)
            }
        }
    }
    
    func updatePostSharedUI(model: TSRepostModel, shouldShowCancelButton: Bool = false) {
        if shouldShowCancelButton {
            cancelImageButton.isHidden = false
        } else {
            cancelImageButton.isHidden = true
            self.bringSubviewToFront(cancelImageButton)
        }
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight)
        }
        
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
        contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
        postDetailLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        coverImageView.roundCorner(2)
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = false
        titleLab.numberOfLines = 1
        postDetailLab.numberOfLines = 2
        contentLab.numberOfLines = 1
        titleLab.text = model.title
//        if model.type == .postLive {
//            if let originalLive = LiveStoreManager().fetchById(id: model.id.uint64), let name = originalLive.hostName {
//                titleLab.text = name
//            }
//        }

        if let contentString = model.content, let urlString = contentString.getUrlStringFromString() {
            postDetailLab.text = urlString
        }
        postDetailLab.text = (model.content?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.content?.removeNewLineChar()
        contentLab.textColor = TSColor.main.theme
        liveIcon.isHidden = true
        iconImageView.isHidden = true
        if model.type == .postVideo {
            iconImageView.isHidden = false
            iconImageView.image = UIImage.set_image(named: "ico_video_play_list")
            contentLab.text = "feed_click_video".localized
        } else  if model.type == .postImage {
            contentLab.text = "feed_click_picture".localized
        } else if model.type == .postLive {
            liveIcon.isHidden = true
            contentLab.text = "feed_click_live".localized
        } else if model.type == .postWord {
            contentLab.text = "feed_click_text".localized
        } else if model.type == .postUser {
            contentLab.text = "view_user".localized
        } else if model.type == .postSticker {
            contentLab.text = "feed_click_sticker".localized
        } else if model.type == .news {
            contentLab.text = "feed_click_article".localized
        } else if model.type == .postMiniVideo {
            contentLab.text = "feed_click_mini_video".localized
        } else if model.type == .postMiniProgram {
            let mpIcon = NSTextAttachment()
            mpIcon.image = UIImage.set_image(named: "ic_miniProgram")
            mpIcon.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            let space: NSAttributedString = NSAttributedString(string: " ")
            let fullString: NSMutableAttributedString = NSMutableAttributedString(attachment: mpIcon)
            fullString.append(space)
            let text: NSAttributedString = NSAttributedString(string: "view_mini_program".localized)
            fullString.append(text)
            contentLab.attributedText = fullString
        } else if model.type == .postURL {
            titleLab.numberOfLines = 2
            if let urlString = model.content, let url = URL(string: urlString) {
                contentLab.text = url.host
                postDetailLab.text = nil
                contentLab.textColor = TSColor.normal.minor
            }
        }
        coverImageView.snp.remakeConstraints { (make) in
//            make.leading.equalToSuperview()
//            make.top.equalToSuperview()
//            make.bottom.equalToSuperview()
            make.top.left.bottom.equalToSuperview().inset(12)
            make.width.equalTo(coverImageView.snp.height)
            make.height.equalTo(coverImageView.snp.height)
        }
        coverImageView.layer.cornerRadius = 4
//        coverImageView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        coverImageView.layer.borderWidth = 1
        if let thumbnailImage = model.coverImage, thumbnailImage != "" {
            coverImageView.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        }
        else {
            coverImageView.image = UIImage.set_image(named: "post_placeholder")
        }
        
        if model.type == .postVideo {
            iconImageView.snp.remakeConstraints { (make) in
                make.height.equalTo(coverImageView.snp.height).multipliedBy(0.3)
                make.width.equalTo(coverImageView.snp.width).multipliedBy(0.3)
                make.centerX.equalTo(coverImageView.snp.centerX)
                make.centerY.equalTo(coverImageView.snp.centerY)
            }
        } else if model.type == .postLive {
            liveIcon.snp.remakeConstraints { (make) in
                make.top.equalTo(coverImageView.snp.top).offset(8)
                make.trailing.equalTo(coverImageView.snp.trailing).offset(-8)
            }
        }

        if (postDetailLab.text ?? "").isEmpty {
            postDetailLab.isHidden = true
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.bottom.equalTo(contentLab.snp.top).offset(-5)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
        } else {
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.bottom.equalToSuperview().offset(-12)
            }
            postDetailLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(12)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(2)
                make.height.equalTo(42)
            }
            setNeedsDisplay()
            layoutIfNeeded()
            postDetailLab.sizeToFit()
            postDetailLab.snp.updateConstraints {
                $0.height.equalTo(postDetailLab.frame.height)
            }
        }
    }
}
