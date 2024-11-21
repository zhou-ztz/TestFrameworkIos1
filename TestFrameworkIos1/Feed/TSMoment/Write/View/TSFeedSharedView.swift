//
//  TSFeedRePostView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/31.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
/*
 1、转发的卡片不同的内容样式的字体大小不同
 2、发布页面的字体大小和列表中的也不一样
 3、发布页面的布局和列表中的布局存在细微差别
 4、动态、圈子、帖子、问题、回答标题都是16pt，下面的文字就14pt；资讯：标题是14pt，下面的文字就12pt
 所以整体有两套布局配置，发布页面和列表页（详情页相同）
 */
import UIKit
import ActiveLabel
import SDWebImage

enum TSFeedRePostViewType {
    /// 发布页面
    case postView
    /// 列表或者详情页
    case listView
}
struct TSFeedRePostViewUX {
    /// 发布页面中
    static let postUINormalTitleFont: CGFloat = 14
    static let postUINormalContentFont: CGFloat = 13
    static let postUINewsTitleFont: CGFloat = 14
    static let postUINewsContentFont: CGFloat = 12
    // 视图的高度
    static let postUIPostWordCardHeight: CGFloat = 85
    static let postUIPostVideoCardHeight: CGFloat = 70
    static let postUIPostImageCardHeight: CGFloat = 70
    static let postUIGroupCardHeight: CGFloat = 72
    static let postUIGroupPostCardHeight: CGFloat = 85
    static let postUINewsCardHeight: CGFloat = 88
    static let postUIQuestionCardHeight: CGFloat = 88
    static let postUIQuestionAnswerCardHeight: CGFloat = 77
    
    /// 列表以及详情页
    static let listUINormalTitleFont: CGFloat = 14
    static let listUINormalContentFont: CGFloat = 12
    static let listUINewsTitleFont: CGFloat = 15
    static let listUINewsContentFont: CGFloat = 15
    static let listUIPostWordCardHeight: CGFloat = 64
    static let listUIPostVideoCardHeight: CGFloat = 45
    static let listUIPostImageCardHeight: CGFloat = 45
    static let listUIGroupCardHeight: CGFloat = 80
    static let listUIGroupPostImageHeight: CGFloat = 220
    static let listUINewsCardHeight: CGFloat = 88
    static let listUIQuestionCardHeight: CGFloat = 75
    static let listUIQuestionAnswerCardHeight: CGFloat = 75
    static let listUIDeleteCardHeight: CGFloat = 40
    static let listUISharedCardHeight: CGFloat = 45
}

class TSFeedRePostView: UIView {
    var compiledHeight :CGFloat = 0
    var cardShowType: TSFeedRePostViewType = .listView
    /// 图片
    private let coverImageView = SDAnimatedImageView()
    /// 标题,第一行文字就是标题，如果只有一行，那么它就是内容
    private let  titleLab = UILabel()
    /// 内容label
    /// 不要在外部赋值，允许访问该label的目的是允许处理Handel
    let  contentLab = ActiveLabel()
    let contentTypeLabel = ActiveLabel()

    /// 点击了分享卡片
    var didTapCardBlock: (() -> Void)?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getSuperViewHeight(model: SharedViewModel, superviewWidth: CGFloat) -> CGFloat {
        var superViewHeight: CGFloat = 0
        // 图片固定220pt搞定，需要加上10pt + 一行title 17pt + 18 pt + 两行正文 34pt + 10pt
        var contentHeight: CGFloat = 0
        var spHeight: CGFloat = 0
        var imageHeight: CGFloat = 0
        imageHeight = TSFeedRePostViewUX.listUIGroupPostImageHeight
        if let content = model.title, content.count > 0 {
            contentHeight = content.size(maxSize: CGSize(width: superviewWidth - 16 * 2, height: 34), font: UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)).height
            spHeight = 10 + 17 + 18 + (imageHeight > 0 ? 10 : 0)
        } else {
            spHeight = 10 + 17 + (imageHeight > 0 ? 10 : 0)
        }
        superViewHeight = imageHeight + spHeight + contentHeight + 15
        return superViewHeight
    }
    
    func creatUI() {
        /// 现在内容label和卡片点击冲突，暂保留卡片点击
        let control = UIControl(frame: self.bounds)
        addSubview(control)
        control.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.top.equalToSuperview()
        }
        let tapReg = UITapGestureRecognizer(target: self, action: #selector(didTapCard))
        control.addGestureRecognizer(tapReg)
        backgroundColor = UIColor(red: 245, green: 245, blue: 245)
        coverImageView.backgroundColor = UIColor.white
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        coverImageView.layer.cornerRadius = 4
//        coverImageView.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        coverImageView.layer.borderWidth = 1
        self.addSubview(coverImageView)

        titleLab.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalTitleFont)
        titleLab.textColor = TSColor.main.content
        titleLab.lineBreakMode = .byTruncatingTail
        titleLab.numberOfLines = 1
        self.addSubview(titleLab)
        contentLab.mentionColor = TSColor.main.theme
        contentLab.URLColor = TSColor.normal.minor
        contentLab.URLSelectedColor = TSColor.normal.minor
        contentLab.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)
        contentLab.textColor = TSColor.normal.minor
        contentLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
        contentLab.textAlignment = .left
        contentLab.lineSpacing = 1
        contentLab.numberOfLines = 2
        self.addSubview(contentLab)
        contentTypeLabel.mentionColor = TSColor.main.theme
        contentTypeLabel.URLColor = TSColor.main.theme
        contentTypeLabel.URLSelectedColor = TSColor.main.theme
        contentTypeLabel.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)
        contentTypeLabel.textColor = TSColor.main.theme
        contentTypeLabel.lineSpacing = 1
        contentTypeLabel.lineBreakMode = NSLineBreakMode.byTruncatingTail
        contentTypeLabel.textAlignment = .left
        contentTypeLabel.numberOfLines = 1
        self.addSubview(contentTypeLabel)
        self.layer.cornerRadius = 4
//        self.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        self.layer.borderWidth = 1
    }
    
    
    func updateUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        if model.type == .metadata {
            updateSharedViewURLUI(model: model,shouldShowCancelButton:shouldShowCancelButton)
        } else {
            updateSharedViewUI(model: model,shouldShowCancelButton:shouldShowCancelButton)
        }
    }
    
    // MARK: - 动态
    private func updateSharedViewURLUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        
        self.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        self.layoutSubviews()
        
        contentTypeLabel.text = "feed_click_article".localized
        let urlString = model.url.orEmpty
        let url = URL(string: urlString)
        let domain = url?.host
        contentLab.text = domain
        coverImageView.contentMode = .scaleAspectFill
        contentTypeLabel.isHidden = true
        
        coverImageView.sd_setImage(with: URL(string: model.thumbnail.orEmpty), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        
        titleLab.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)
        titleLab.numberOfLines = 2
        titleLab.text = model.title
        contentLab.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)
        contentLab.textColor = TSColor.normal.minor
        contentLab.numberOfLines = 2
        titleLab.sizeToFit()
        self.sizeToFit()
        compiledHeight = 240
        
        //constraint game
        contentLab.snp.makeConstraints {
            $0.height.equalTo(14)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-18)
            $0.bottom.equalToSuperview().offset(-8)
        }
        titleLab.snp.makeConstraints {
            $0.height.equalTo(32)
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().offset(-18)
            $0.bottom.equalTo(contentLab.snp.top).offset(-5)
        }
        coverImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalTo(titleLab.snp.top).offset(-11)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        setNeedsDisplay()
        layoutIfNeeded()
    }
    
    private func updateSharedViewUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        
        self.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        self.layoutSubviews()
        
        if model.type == .user {
            contentTypeLabel.text = "view_user".localized
            contentLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.desc?.removeNewLineChar()
        } else  if model.type == .sticker {
            contentTypeLabel.text = "sticker_view".localized
            contentLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.desc?.removeNewLineChar()
            coverImageView.contentMode = .scaleAspectFit
        } else if model.type == .live {
            contentTypeLabel.text = "feed_click_live".localized
            contentLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.desc?.removeNewLineChar()
        } else if model.type == .miniProgram {
            let mpIcon = NSTextAttachment()
            mpIcon.image = UIImage.set_image(named: "ic_miniProgram")
            mpIcon.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            let space: NSAttributedString = NSAttributedString(string: " ")
            let fullString: NSMutableAttributedString = NSMutableAttributedString(attachment: mpIcon)
            fullString.append(space)
            let text: NSAttributedString = NSAttributedString(string: "view_mini_program".localized)
            fullString.append(text)
            contentTypeLabel.attributedText = fullString
            contentLab.text = (model.desc?.removeNewLineChar() ?? "").isEmpty ? "feed_no_desc".localized : model.desc?.removeNewLineChar()
        } else if model.type == .metadata {
            contentTypeLabel.text = "feed_click_article".localized
            let urlString = model.url.orEmpty
            let url = URL(string: urlString)
            let domain = url?.host
            contentLab.text = domain
            
            coverImageView.contentMode = .scaleAspectFill
        }
        
        if let thumbnail = model.thumbnail {
            coverImageView.sd_setImage(with: URL(string: thumbnail), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        } else {
            coverImageView.image = UIImage.set_image(named: "post_placeholder")
        }

        titleLab.text = model.title
        contentLab.font = UIFont.systemFont(ofSize: TSFeedRePostViewUX.listUINormalContentFont)
        contentLab.textColor = TSColor.normal.minor
        contentLab.numberOfLines = 2
        titleLab.sizeToFit()
        self.sizeToFit()
        compiledHeight = 100
        
        //constraint game
        coverImageView.snp.makeConstraints {
//            $0.top.equalToSuperview()
//            $0.bottom.equalToSuperview()
//            $0.left.equalToSuperview()
            $0.top.bottom.left.equalToSuperview().inset(10)
            $0.width.equalTo(coverImageView.snp.height)
        }
        contentTypeLabel.snp.makeConstraints {
            $0.height.equalTo(15)
            $0.leading.equalTo(coverImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-11)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        if (contentLab.text ?? "").isEmpty {
            contentLab.removeConstraints(contentLab.constraints)
            contentLab.isHidden = true
            titleLab.snp.remakeConstraints {
                $0.top.equalToSuperview().offset(11)
                $0.leading.equalTo(coverImageView.snp.trailing).offset(12)
                $0.trailing.equalToSuperview().offset(-11)
                $0.bottom.equalTo(contentTypeLabel.snp.top)
            }
        } else {
            titleLab.snp.makeConstraints {
                $0.top.equalToSuperview().offset(11)
                $0.leading.equalTo(coverImageView.snp.trailing).offset(12)
                $0.trailing.equalToSuperview().offset(-11)
                $0.height.equalTo(18)
            }
            contentLab.snp.makeConstraints {
                $0.leading.equalTo(coverImageView.snp.trailing).offset(12)
                $0.top.equalTo(titleLab.snp.bottom).offset(2)
                $0.trailing.equalToSuperview().offset(-11)
                $0.height.equalTo(42)
            }
            contentLab.sizeToFit()
            contentLab.snp.updateConstraints {
                $0.height.equalTo(contentLab.frame.height)
            }
        }
        setNeedsDisplay()
        layoutIfNeeded()
    }

    /// 点击了卡片
    @objc func didTapCard() {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
    /// 这个地方需要处理从ActiveLabel穿透过来的点击事件，不然该事件会被tableview处理，导致cell被点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapBlock = didTapCardBlock {
            tapBlock()
        }
    }
}
