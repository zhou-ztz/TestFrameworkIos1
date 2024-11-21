//
//  TSRePostView.swift
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
import YYWebImage
//import NIMPrivate

enum TSRepostViewType {
    /// 发布页面
    case postView
    /// 列表或者详情页
    case listView
}
struct TSRepostViewUX {
    /// 发布页面中
    static let postUINormalTitleFont: CGFloat = 14
    static let postUINormalContentFont: CGFloat = 12
    static let postUINewsTitleFont: CGFloat = 14
    static let postUINewsContentFont: CGFloat = 12
    // 视图的高度
    static let postUIPostWordCardHeight: CGFloat = 85
    static let postUIPostVideoCardHeight: CGFloat = 100
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
    static let listUIPostWordCardHeight: CGFloat = 100
    static let listUIPostVideoCardHeight: CGFloat = 100
    static let listUIPostStickerCardHeight: CGFloat = 100
    static let listUIPostURLCardHeight: CGFloat = 100
    static let listUIPostUserCardHeight: CGFloat = 100
    static let listUIPostImageCardHeight: CGFloat = 100
    static let listUIPostDefaultCardHeight: CGFloat = 100
    static let listUIGroupCardHeight: CGFloat = 80
    static let listUIGroupPostImageHeight: CGFloat = 220
    static let listUINewsCardHeight: CGFloat = 100
    static let listUIQuestionCardHeight: CGFloat = 75
    static let listUIQuestionAnswerCardHeight: CGFloat = 75
    static let listUIDeleteCardHeight: CGFloat = 40
    static let listUISharedCardHeight: CGFloat = 45
}

class TSRepostView: UIView {
    var cancelImageButton: UIButton!
    /// 卡片显示的位置类型
    var cardShowType: TSRepostViewType = .listView
    /// 图片
    var coverImageView: FadeImageView!
    /// 特殊标示,比如视频
    var iconImageView: FadeImageView!
    /// 标题,第一行文字就是标题，如果只有一行，那么它就是内容
    var titleLab: UILabel!
    /// 内容label
    /// 不要在外部赋值，允许访问该label的目的是允许处理Handel
    var contentLab: ActiveLabel!
    /// 点击了分享卡片
    var postDetailLab: ActiveLabel!
    
    var liveIcon = TSLabel().configure {
        $0.backgroundColor = UIColor(red: 230, green: 35, blue: 35)
        $0.textInsets = UIEdgeInsets(top: 1, left: 2, bottom: 1, right: 2)
        $0.textColor = .white
        $0.roundCorner(2)
        $0.setFontSize(with: 10, weight: .bold)
        $0.text = "text_live".localized
        $0.isHidden = true
    }
    
    var didTapCardBlock: (() -> Void)?
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func getSuperViewHeight(model: TSRepostModel, superviewWidth: CGFloat) -> CGFloat {
        var superViewHeight: CGFloat = 0
        if self.cardShowType == .listView {
            switch model.type {
            case .postWord:
                superViewHeight = TSRepostViewUX.listUIPostWordCardHeight
            case .postImage:
                superViewHeight = TSRepostViewUX.listUIPostImageCardHeight
            case .postVideo, .postLive, .postMiniVideo:
                superViewHeight = TSRepostViewUX.listUIPostVideoCardHeight
            case .postSticker:
                superViewHeight = TSRepostViewUX.listUIPostStickerCardHeight
            case .postURL:
                superViewHeight = TSRepostViewUX.listUIPostURLCardHeight
            case .postUser:
                superViewHeight = TSRepostViewUX.listUIPostUserCardHeight
            case .postMiniProgram:
                superViewHeight = TSRepostViewUX.listUIPostDefaultCardHeight
            case .news:
                superViewHeight = TSRepostViewUX.listUINewsCardHeight
            case .question:
                superViewHeight = TSRepostViewUX.listUIQuestionCardHeight
            case .questionAnswer:
                superViewHeight = TSRepostViewUX.listUIQuestionAnswerCardHeight
            case .delete:
                superViewHeight = TSRepostViewUX.listUIDeleteCardHeight
            }
        }
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
        backgroundColor = TSColor.small.repostBackground
        coverImageView = FadeImageView()
        coverImageView.backgroundColor = UIColor.white
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.clipsToBounds = true
        self.addSubview(coverImageView)
        iconImageView = FadeImageView()
        self.addSubview(iconImageView)
        self.addSubview(liveIcon)
        titleLab = UILabel()
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
        titleLab.textColor = TSColor.main.content
        titleLab.lineBreakMode = .byTruncatingTail
        titleLab.numberOfLines = 2
        self.addSubview(titleLab)
        contentLab = ActiveLabel()
        contentLab.mentionColor = TSColor.main.theme
        contentLab.URLColor = TSColor.normal.minor
        contentLab.URLSelectedColor = TSColor.normal.minor
        contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
        contentLab.textColor = TSColor.normal.minor
        contentLab.lineSpacing = 2
        contentLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
        contentLab.textAlignment = .left
        self.addSubview(contentLab)
        postDetailLab = ActiveLabel()
        postDetailLab.mentionColor = TSColor.main.theme
        postDetailLab.URLColor = TSColor.normal.minor
        postDetailLab.URLSelectedColor = TSColor.normal.minor
        postDetailLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
        postDetailLab.textColor = TSColor.normal.minor
        postDetailLab.lineSpacing = 2
        postDetailLab.lineBreakMode = NSLineBreakMode.byTruncatingTail
        postDetailLab.textAlignment = .left
        self.addSubview(postDetailLab)
        postDetailLab.isHidden = true
        self.layer.cornerRadius = 4
//        self.layer.borderColor = UIColor(red: 220/255.0, green: 220/255.0, blue: 220/255.0, alpha: 1.0).cgColor
//        self.layer.borderWidth = 1
        cancelImageButton = UIButton()
        cancelImageButton.setImage(UIImage.set_image(named: "cancel"), for: .normal)
        cancelImageButton.addTap(action: { [weak self] (_) in
            guard let self = self else { return }
            self.removeFromSuperview()
        })
        self.addSubview(cancelImageButton)
        cancelImageButton.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).inset(5.8)
            $0.right.equalTo(self.snp.right).inset(5.8)
            $0.width.height.equalTo(15)
        }
        cancelImageButton.isHidden = true
    }
    
    func updateUI(model: TSRepostModel, shouldShowCancelButton: Bool = false) {
        backgroundColor = TSColor.small.repostBackground
        if cardShowType == .postView {
            self.isUserInteractionEnabled = false
            contentLab.enabledTypes = []
        } else {
            self.isUserInteractionEnabled = true
        }
        
        switch model.type {
        case .delete:
            self.updataDeleteContentUI(model: model)
            
        case .questionAnswer:
            self.updateQuestionAnswerUI(model: model)
            
        case .question:
            self.updateQuestionUI(model: model)

        case .postURL:
            self.updatePostSharedUI(model: model, shouldShowCancelButton: shouldShowCancelButton)
            if shouldShowCancelButton {
                self.isUserInteractionEnabled = true
            }

        default:
            self.updatePostSharedUI(model: model)
        }
    }
    
    func updateUI(model: SharedViewModel, shouldShowCancelButton: Bool = false) {
        self.updatePostSharedUI(model: model,shouldShowCancelButton:shouldShowCancelButton)
    }
    
    // MARK: - 已经删除
    private func updataDeleteContentUI(model: TSRepostModel) {
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(TSRepostViewUX.listUIDeleteCardHeight)
        }
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
        coverImageView.isHidden = true
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = true
        postDetailLab.isHidden = true
        titleLab.numberOfLines = 1
        titleLab.text = "review_dynamic_deleted".localized
        titleLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(11)
            make.trailing.equalToSuperview().offset(-11)
            make.centerY.equalTo((superview?.snp.centerY)!)
        }
    }
    // MARK: - 动态
    private func updatePostTextUI(model: TSRepostModel, shouldShowCancelButton: Bool = false) {
//        if self.cardShowType == .postView {
//            self.snp.remakeConstraints { (make) in
//                make.top.equalToSuperview()
//                make.leading.equalToSuperview().offset(15)
//                make.trailing.equalToSuperview().offset(-15)
//                make.height.equalTo(TSRepostViewUX.postUIPostWordCardHeight)
//            }
//            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
//            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
//            coverImageView.isHidden = true
//            iconImageView.isHidden = true
//            titleLab.isHidden = false
//            contentLab.isHidden = false
//            titleLab.numberOfLines = 1
//            contentLab.numberOfLines = 2
//            titleLab.text = model.title
//            titleLab.snp.remakeConstraints { (make) in
//                make.leading.equalToSuperview().offset(11)
//                make.trailing.equalToSuperview().offset(-11)
//                make.top.equalToSuperview().offset(11)
//                make.height.equalTo(18)
//            }
//            contentLab.text = model.content
//            contentLab.snp.remakeConstraints { (make) in
//                make.leading.equalToSuperview().offset(11)
//                make.trailing.equalToSuperview().offset(-11)
//                make.top.equalTo(titleLab.snp.bottom).offset(5)
//                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
//                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
//                make.height.equalTo(38)
//            }
//        } else if cardShowType == .listView {
//            self.snp.remakeConstraints { (make) in
//                make.top.equalToSuperview()
//                make.leading.equalToSuperview()
//                make.trailing.equalToSuperview()
//                make.height.equalTo(TSRepostViewUX.listUIPostWordCardHeight)
//            }
//            contentLab.snp.remakeConstraints { (make) in
//                make.leading.equalToSuperview().offset(11)
//                make.trailing.equalToSuperview().offset(-11)
//                make.top.equalToSuperview().offset(5)
//                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
//                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
//                make.height.equalTo(44)
//            }
//            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
//            contentLab.textColor = TSColor.normal.minor
//            coverImageView.isHidden = true
//            iconImageView.isHidden = true
//            titleLab.isHidden = true
//            contentLab.isHidden = false
//            contentLab.numberOfLines = 2
//            var showStr = model.title! + "："
//            if let content = model.content {
//                showStr = showStr + content
//            } else {
//                showStr = showStr + " "
//            }
//            // 设置名字是黑色
//            contentLab.text = showStr
//            contentLab.attributedText = showStr.attributonString().setTextFont(TSRepostViewUX.listUINormalContentFont).setlineSpacing(0)
//
//            // 计算 frame
//            let contentWidth = UIScreen.main.bounds.width - 58 - 13
//            var contentLabelframe = CGRect(origin: .zero, size: CGSize(width: contentWidth, height: 0))
//            let paragraphStyle = NSMutableParagraphStyle()
//            paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
//            paragraphStyle.paragraphSpacing = 3
//            paragraphStyle.alignment = .left
//            paragraphStyle.headIndent = 0.000_1
//            paragraphStyle.tailIndent = -0.000_1
//            var labelHeight: CGFloat = 0
//            let heightLine = self.heightOfLines(line: 6, font: UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont))
//            let maxHeight = self.heightOfAttributeString(contentWidth: contentWidth, attributeString: contentLab.attributedText!, font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont), paragraphstyle: paragraphStyle)
//            if heightLine >= maxHeight {
//                labelHeight = maxHeight
//            } else {
//                labelHeight = heightLine
//            }
//            contentLabelframe = CGRect(x: 58, y: 0, width: contentWidth, height: labelHeight)
//
//            let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)]
//            let arr: NSArray = NSArray(array: LabelLineText.getSeparatedLines(fromLabelAddAttribute: contentLab.attributedText, frame: contentLabelframe, attribute: attribute))
//            let rangeArr: NSArray = NSArray(array: LabelLineText.getSeparatedLinesRange(fromLabelAddAttribute: contentLab.attributedText, frame: contentLabelframe, attribute: attribute))
//            var sixLineText: NSString = ""
//            var sixRange: NSRange?
//            let sixReplaceRange: NSRange?
//            var replaceLocation: NSInteger = 0
//            let replaceText: String = "sticker_see_all".localized
//            let replaceAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: replaceText)
//            let replacefirstAtttribute: NSMutableAttributedString = NSMutableAttributedString(string: "...")
//            replaceAtttribute.addAttributes(attribute, range: NSRange(location: 0, length: replaceAtttribute.length))
//            if arr.count > 2 {
//                sixLineText = NSString(string: "\(arr[1] )")
//                let modelSix: rangeModel = rangeArr[1] as! rangeModel
//                for (index, _) in rangeArr.enumerated() {
//                    if index > 0 {
//                        break
//                    }
//                    let model: rangeModel = rangeArr[index] as! rangeModel
//                    replaceLocation = replaceLocation + model.locations
//                }
//
//                // 计算出最合适的 range 范围来放置 "阅读全文  " ，让 UI 看起来就是刚好拼接在第六行最后面
//                sixReplaceRange = NSRange(location: replaceLocation + modelSix.locations - replaceText.count, length: replaceText.count)
//                sixRange = NSRange(location: replaceLocation, length: modelSix.locations)
//                let mutableReplace: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: sixRange!))!)
//
//                /// 这里要处理 第六行是换行的空白 或者 第六行未填满就换行 的情况
//                var lastRange: NSRange?
//                if modelSix.locations == 1 {
//                    /// 换行直接追加
//                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - 1)
//                } else {
//                    /// 如果第六行最后一个字符是 \n 换行符的话，需要将换行符扔掉，再 追加 “查看更多”字样
//                    let mutablepassLastString: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: modelSix.locations - 1, length: 1)))
//                    var originI: Int = 0
//                    if mutablepassLastString.string == "\n" {
//                        originI = 1
//                    }
//                    for i in originI..<modelSix.locations - 1 {
//                        /// 获取每一次替换后的属性文本
//                        let mutablepass: NSMutableAttributedString = NSMutableAttributedString(attributedString: mutableReplace.attributedSubstring(from: NSRange(location: 0, length: modelSix.locations - i)))
//                        mutablepass.append(replaceAtttribute)
//                        let mutablePassWidth = self.WidthOfAttributeString(contentHeight: 20, attributeString: mutablepass, font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont))
//                        /// 判断当前系统是不是 11.0 及以后的 是就不处理，11.0 以前要再细判断(有没有空格，有的情况下再判断宽度对比小的话要多留两个汉字距离来追加 阅读全文 字样)
//                        if #available(iOS 11.0, *) {
//                            if mutablePassWidth <= contentWidth * 2 / 3 {
//                                lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                                break
//                            }
//                        } else {
//                            if mutablePassWidth <= contentWidth * 2 / 3 {
//                                let mutableAll: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: NSRange(location: 0, length: replaceLocation + modelSix.locations - i)))!)
//                                if mutableAll.string.contains(" ") {
//                                    if mutablePassWidth <= (contentWidth * 2 / 3 - contentLab.font.pointSize * 2.0) {
//                                        lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                                        break
//                                    }
//                                } else {
//                                    lastRange = NSRange(location: 0, length: replaceLocation + modelSix.locations - i)
//                                    break
//                                }
//                            }
//                        }
//                    }
//                }
//                if lastRange == nil {
//                    lastRange = NSRange(location: 0, length: replaceLocation)
//                }
//
//                let mutable: NSMutableAttributedString = NSMutableAttributedString(attributedString: (contentLab.attributedText?.attributedSubstring(from: lastRange!))!)
//                mutable.append(replacefirstAtttribute)
//                mutable.append(replaceAtttribute)
//                contentLab.attributedText = NSAttributedString(attributedString: mutable)
//            }
//        }
    }
    
    private func updatePostURLUI(model: TSRepostModel) {
        self.cancelImageButton.isHidden = false
        self.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(TSRepostViewUX.listUIPostURLCardHeight)
        }
        titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
        contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
        coverImageView.isHidden = false
        iconImageView.isHidden = true
        titleLab.isHidden = false
        contentLab.isHidden = false
        postDetailLab.isHidden = true
        titleLab.numberOfLines = 2
        contentLab.numberOfLines = 2
        titleLab.text = model.title
        if let thumbnailImage = model.coverImage, thumbnailImage != "" {
            coverImageView.sd_setImage(with: URL(string: thumbnailImage), placeholderImage: UIImage.set_image(named: "post_placeholder"))
        }
        else {
            coverImageView.image = UIImage.set_image(named: "post_placeholder")
        }
        if let urlString = model.content, let url = URL(string: urlString), let domain = url.host {
            contentLab.text = domain
        }
        contentLab.textColor = UIColor(red: 109, green: 114, blue: 120)
        
        contentLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(14)
            make.bottom.equalToSuperview().offset(-8)
        }
        titleLab.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(14)
            make.trailing.equalToSuperview().offset(-18)
            make.height.equalTo(30)
            make.bottom.equalTo(contentLab.snp.top).offset(-5)
        }
        coverImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalTo(titleLab.snp.top).offset(-11)
        }
    }
    
    private func updatePostMediaUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(18)
                make.height.equalTo(18)
            }
            if model.type == .postVideo {
                iconImageView.image = UIImage.set_image(named: "ico_video_disabled")
                contentLab.text = "feed_click_video".localized
            } else  if model.type == .postImage {
                iconImageView.image = UIImage.set_image(named: "ico_pic_disabled")
                contentLab.text = "feed_click_picture".localized
            } else if model.type == .postLive {
                iconImageView.image = UIImage.set_image(named: "ico_pic_disabled")
                contentLab.text = "feed_click_live".localized
            } else if model.type == .postMiniVideo {
                iconImageView.image = UIImage.set_image(named: "ico_video_disabled")
                contentLab.text = "feed_click_mini_video".localized
            }

            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.top.equalTo(titleLab.snp.bottom).offset(10)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUIPostVideoCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            contentLab.textColor = TSColor.main.theme
            titleLab.textColor = TSColor.main.content
            coverImageView.isHidden = true
            iconImageView.isHidden = false
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            let showTitle = model.title! + "："
            titleLab.text = showTitle
            let showTitleSize = showTitle.size(maxSize: CGSize(width: ScreenWidth, height: 20), font: titleLab.font!)
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(17)
                make.top.equalToSuperview().offset(12)
                make.height.equalTo(15)
                make.width.equalTo(showTitleSize.width + 2)
            }
            titleLab.sizeToFit()
            if model.type == .postVideo {
                iconImageView.image = UIImage.set_image(named: "ico_video_highlight")
                contentLab.text = "feed_click_video".localized
            } else  if model.type == .postImage {
                iconImageView.image = UIImage.set_image(named: "ico_pic_highlight")
                contentLab.text = "feed_click_picture".localized
            } else if model.type == .postLive {
                iconImageView.image = UIImage.set_image(named: "ico_pic_disabled")
                contentLab.text = "feed_click_live".localized
            } else if model.type == .postMiniVideo {
                iconImageView.image = UIImage.set_image(named: "ico_video_highlight")
                contentLab.text = "feed_click_mini_video".localized
            }
            
            iconImageView.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.trailing).offset(2)
                make.centerY.equalTo(titleLab.snp.centerY)
                make.width.equalTo(15)
                make.height.equalTo(12)
            }
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(iconImageView.snp.trailing).offset(6)
                make.trailing.equalToSuperview().offset(-11)
                make.height.equalTo(15)
                make.centerY.equalTo(iconImageView.snp.centerY)
            }
        }
    }

    func heightOfLines(line: Int, font: UIFont) -> CGFloat {
        if line <= 0 {
            return 0
        }

        var mutStr = "*"
        for _ in 0..<line - 1 {
            mutStr = mutStr + "\n*"
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 3
        paragraphStyle.headIndent = 0.000_1
        paragraphStyle.tailIndent = -0.000_1
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont), NSAttributedString.Key.paragraphStyle: paragraphStyle.copy(), NSAttributedString.Key.strokeColor: UIColor.black]
        let tSize = mutStr.size(withAttributes: attribute)
        return tSize.height
    }

    func heightOfAttributeString(contentWidth: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: contentWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.height
    }

    // MARK: - 圈子
    private func updateGroupUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIGroupCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(15)
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.listUIGroupCardHeight)
            }
            self.superview?.backgroundColor = UIColor(hex: 0xF7F7F7)
            self.backgroundColor = UIColor(hex: 0xFFFFFF)
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(11)
                    make.top.equalToSuperview().offset(11)
                    make.height.width.equalTo(50)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(4)
                make.height.equalTo(38)
            }
        }
    }
    // MARK: - 帖子
    private func updateGroupPostUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIGroupPostCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.width.equalTo(TSRepostViewUX.postUIGroupPostCardHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(coverImageView.snp.trailing).offset(15)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(9)
                make.height.equalTo(38)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalToSuperview().offset(10)
                make.height.equalTo(18)
            }
            var contentHeight: CGFloat = 0
            if let content = model.content, content.count > 0 {
                contentLab.text = model.content
                contentHeight = content.size(maxSize: CGSize(width: (superview?.width)! - 16 * 2, height: 34), font: UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)).height
                contentHeight = contentHeight + 4
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.equalTo(titleLab.snp.bottom).offset(8)
                    make.height.equalTo(contentHeight)
                }
            } else {
                contentLab.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.trailing.equalToSuperview()
                    make.top.equalTo(titleLab.snp.bottom)
                    make.height.equalTo(contentHeight)
                }
            }

            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview().offset(23)
                    make.trailing.equalToSuperview().offset(-23)
                    make.top.equalTo(contentLab.snp.bottom).offset(8)
                    make.height.width.equalTo(TSRepostViewUX.listUIGroupPostImageHeight)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.leading.equalToSuperview()
                    make.top.equalToSuperview()
                    make.height.width.equalTo(0)
                }
            }
        }
    }
    // MARK: - 资讯
    private func updateNewsUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINewsContentFont)

            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2

            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(13)
                make.height.equalTo(35)
            }

            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUINewsCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = false
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            if let coverImage = model.coverImage {
                coverImageView.yy_setImage(with: URL(string: coverImage), placeholder: nil)
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(-5)
                    make.top.equalToSuperview().offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                    make.width.equalTo(95)
                }
            } else {
                coverImageView.snp.remakeConstraints { (make) in
                    make.trailing.equalToSuperview().offset(0)
                    make.height.width.equalTo(0)
                }
            }

            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(10)
                make.trailing.equalTo(coverImageView.snp.leading).offset(-23)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalTo(titleLab.snp.leading)
                make.trailing.equalTo(titleLab.snp.trailing)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(15)
            }
        }
    }
    // MARK: - 问题
    private func updateQuestionUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(40)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
//                make.height.equalTo(18)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.listUIQuestionCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINewsContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 2
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(36)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(16)
                make.trailing.equalToSuperview().offset(-16)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(18)
            }
        }
    }
    // MARK: - 回答
    private func updateQuestionAnswerUI(model: TSRepostModel) {
        if self.cardShowType == .postView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview().offset(15)
                make.trailing.equalToSuperview().offset(-15)
                make.height.equalTo(TSRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.postUINormalContentFont)
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(8)
                make.height.equalTo(15)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(8)
                make.height.equalTo(40)
            }
        } else if cardShowType == .listView {
            self.snp.remakeConstraints { (make) in
                make.top.equalToSuperview()
                make.leading.equalToSuperview()
                make.trailing.equalToSuperview()
                make.height.equalTo(TSRepostViewUX.postUIQuestionAnswerCardHeight)
            }
            titleLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalTitleFont)
            contentLab.font = UIFont.systemFont(ofSize: TSRepostViewUX.listUINormalContentFont)
            titleLab.textColor = TSColor.main.content
            contentLab.textColor = TSColor.normal.minor
            coverImageView.isHidden = true
            iconImageView.isHidden = true
            titleLab.isHidden = false
            contentLab.isHidden = false
            titleLab.numberOfLines = 1
            contentLab.numberOfLines = 2
            titleLab.text = model.title
            titleLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalToSuperview().offset(11)
                make.height.equalTo(18)
            }
            contentLab.text = model.content
            contentLab.snp.remakeConstraints { (make) in
                make.leading.equalToSuperview().offset(11)
                make.trailing.equalToSuperview().offset(-11)
                make.top.equalTo(titleLab.snp.bottom).offset(5)
                /// 设计图只需要30pt，但是这个富文本控件显示两行需要38
                /// 所以需要把整个控件上间距也调小4pt 使整个控件竖直居中
                make.height.equalTo(38)
            }
        }
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
    func WidthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.width
    }
}
