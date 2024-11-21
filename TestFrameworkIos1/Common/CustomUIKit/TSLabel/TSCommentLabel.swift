//
//  TSCommentLabel.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/3/7.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态页面评论富文本

import UIKit
import TYAttributedLabel
import SDWebImage

protocol TSCommentLabelDelegate: NSObjectProtocol {

    /// 点击
    ///
    /// - Parameter didSelectId: 点击用户名返回相应的Id
    func didSelect(didSelectId: Int)
    /// tap on sticker to reply comment owner
    func didTapToReply()
}

class TSCommentLabel: TYAttributedLabel, TYAttributedLabelDelegate {

    enum ShowType {
        case detail
        case simple
    }

    /// 回复固定字符串
    var replyTemplates = " " + "reply_str".localized + " "
    /// 固定的冒号
    var normalTemplates = ": "
    /// 显示类型
    var showType: ShowType = .simple
    /// 发表评论的名称
    var commentName = ""
    /// 回复发表评论的名称
    var replyCommentName: String?
    /// 评论内容
    var content = ""
    /// 当前评论的数据模型
    var commentModel: FeedCommentListCellModel? {
        didSet {
            if isXib {
                guard let model = commentModel else {
                    return
                }
                setSourceData(commentModel: model)
            }
        }
    }

    /// 点击名称的代理
    weak var labelDelegate: TSCommentLabelDelegate?

    var isXib = false
    
    var mode: Theme = .white
    
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    
    private var colors: (highlightColor: UIColor, normalColor: UIColor) {
        switch mode {
        case .white:
            return (TSColor.main.content, TSColor.normal.minor)
        default:
            return (UIColor.white, TSColor.normal.minor)
        }
    }
    
    /// Lifecycle
    ///
    /// - Parameter commentModel: 数据模型
    init(commentModel: FeedCommentListCellModel, type: ShowType) {
        super.init(frame: CGRect.zero)
        self.commentModel = commentModel
        self.showType = type
        setSourceData(commentModel: commentModel)
    }

    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        isXib = true
    }
    // MARK: - setDatas 
    func setSourceData (commentModel: FeedCommentListCellModel) {
        self.text = nil
        self.delegate = self
        HTMLManager.shared.removeHtmlTag(htmlString: commentModel.content, completion: { [weak self] (content, userIdList) in
            guard let self = self else { return }
            self.userIdList = userIdList
            self.content = content
            self.htmlAttributedText = content.attributonString()
            if let attributedText = self.htmlAttributedText {
                self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList)
            }
            
            if let replyUser = commentModel.replyUserInfo {
                self.replyCommentName = replyUser.name
                self.replyTemplates = self.showType == .simple ? " " + "reply_str".localized + " " : "reply_str".localized + " "
            } else {
                self.replyCommentName = nil
                self.replyTemplates = ""
            }
            
            switch self.showType {
            case .detail:
                self.commentName = (commentModel.userInfo?.name).orEmpty
                self.setDetailAttributedString(commentModel: commentModel)
            case .simple:
                self.commentName = ""
                self.setAttributedString(commentModel: commentModel)
            }
        })
    }

    /// 设置文本颜色字体以及可点击区域
    ///
    /// - Parameter commentModel: 数据模型
    private func setAttributedString(commentModel: FeedCommentListCellModel) {
        let normalFont = UIFont.systemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        let boldFont = UIFont.boldSystemFont(ofSize: TSFont.ContentText.sectionTitle.rawValue)
        
        if replyCommentName == nil || replyCommentName?.isEmpty == true {
            let attributedName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: commentName as NSString, firstColor: colors.highlightColor, font: normalFont), second: (secondString: "\(normalTemplates)\(content)" as NSString, secondColor: colors.normalColor, font: normalFont))
            self.setAttributedText(attributedName)
            let range = (attributedName.string as NSString).range(of: commentName)
            self.addLink(withLinkData: commentName, linkColor: colors.highlightColor, underLineStyle: .init(rawValue: 0), range: range)
            return
        }

        let replyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: commentName as NSString, firstColor: colors.highlightColor, font: normalFont), second: (secondString:  replyTemplates as NSString, secondColor: colors.normalColor, font: normalFont))
        let beReplyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: replyCommentName! as NSString, firstColor: colors.highlightColor, font: boldFont), second: (secondString: "\(normalTemplates)\(content)" as NSString, secondColor: colors.normalColor, font: normalFont))
        replyName.append( beReplyName)
        self.setAttributedText(replyName)
        let commentNameRange = (replyName.string as NSString).range(of: commentName)
        let replyNameRange = (replyName.string as NSString).range(of: replyCommentName!)
        self.addLink(withLinkData: commentName, linkColor: colors.highlightColor, underLineStyle: .init(rawValue: 0), range: commentNameRange)
        self.addLink(withLinkData: replyCommentName!, linkColor: colors.highlightColor, underLineStyle: .init(rawValue: 0), range: replyNameRange)
    }

    /// 设置动态详情里的评论
    ///
    /// - Parameter commentModel: 数据模型
    private func setDetailAttributedString(commentModel: FeedCommentListCellModel) {
        if replyCommentName == nil || replyCommentName?.isEmpty == true {
            if commentModel.contentType == .sticker {
                self.append(contentImage())
            } else {
                self.setAttributedText(NSAttributedString(string: content, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue), NSAttributedString.Key.foregroundColor: colors.normalColor]))
                // 匹配相关的at
                let matchs = TSUtil.findAllTSAt(inputStr: content)
                for match in matchs {
                    let matchContent = content.subString(with: match.range)
                    /// 按照上边的texts的拼接方式进行增加content前边的偏移量
                    addLink(withLinkData: matchContent, linkColor: AppTheme.blue, underLineStyle: .init(rawValue: 0), range: NSRange(location: match.range.location, length: match.range.length))
                }
            }
            return
        }

        let normalFont = UIFont.systemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        let boldFont = UIFont.boldSystemFont(ofSize: TSFont.SubInfo.footnote.rawValue)
        
        let reply = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: replyTemplates as NSString, firstColor: colors.normalColor, font: normalFont), second: (secondString: "" as NSString, secondColor: colors.normalColor, font: normalFont))
        
        let body = (commentModel.contentType == .sticker ? normalTemplates + "\n" : normalTemplates + content) as NSString
        
        let beReplyName = NSMutableAttributedString().differentColorAndSizeString(first: (firstString: (replyCommentName!) as NSString, firstColor: colors.highlightColor, font: boldFont), second: (secondString: body, secondColor: colors.normalColor, font: normalFont))
        reply.append(beReplyName)
        self.setAttributedText(reply)
        let commentNameRange = (reply.string as NSString).range(of: replyCommentName!)
        self.addLink(withLinkData: replyCommentName!, linkColor: colors.highlightColor, underLineStyle: .init(rawValue: 0), range: commentNameRange)
        
        if commentModel.contentType == .sticker {
            self.append(contentImage())
        } else {
            // 匹配相关的at
            let matchs = TSUtil.findAllTSAt(inputStr: content)
            for match in matchs {
                let matchContent = content.subString(with: match.range)
                /// 按照上边的texts的拼接方式进行增加content前边的偏移量
                addLink(withLinkData: matchContent, linkColor: AppTheme.blue, underLineStyle: .init(rawValue: 0), range: NSRange(location: 3 + (replyCommentName?.count)! + 2 + match.range.location, length: match.range.length))
            }
        }
    }
    
    func contentImage() -> SDAnimatedImageView {
        let imageView = SDAnimatedImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.sd_setImage(with: URL(string: content), placeholderImage: nil, options: [.lowPriority, .scaleDownLargeImages], completed: nil)
        imageView.shouldCustomLoopCount = true
        imageView.animationRepeatCount = 0
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))
        return imageView
    }
    
    /// 处理点击动作的代理
    ///
    /// - Parameters:
    ///   - attributedLabel: 当前的Label
    ///   - textStorage: textStorage description
    ///   - point: 位置
    func attributedLabel(_ attributedLabel: TYAttributedLabel!, textStorageClicked textStorage: TYTextStorageProtocol!, at point: CGPoint) {
        guard self.commentModel?.contentType == .text else {
            self.labelDelegate?.didTapToReply()
            return
        }
        // 1.获取点击文字内容
        let range = textStorage.realRange
        let selectedString = (attributedLabel.attributedText().string as NSString).substring(with: range)
        // 如果和评论者用户名的名字相同
        if commentName == selectedString {
            self.labelDelegate?.didSelect(didSelectId: (self.commentModel?.userInfo?.userIdentity)!)
        } else if replyCommentName == selectedString {
            self.labelDelegate?.didSelect(didSelectId: (self.commentModel?.replyUserInfo?.userIdentity)!)
        } else {
            HTMLManager.shared.handleMentionTap(name: selectedString, attributedText: self.htmlAttributedText)
        }
    }
}
