//
//  NoticePendingCell.swift
//  ThinkSNS +
//
//  Created by lip on 2017/9/12.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  待操作的cell
//  注：该Cell的头像响应是使用的tag为250进行的判断处理。更简单的方式是取消自定义的头像响应，再数据赋值时传入用户id，当前的模型中没有用户id，之后可考虑优化。

import UIKit
import YYText
import SnapKit
import ActiveLabel
import TYAttributedLabel
import SDWebImage
//import NIMPrivate

/// 通知待操作cell点击区域
///
/// - avatar: 头像
/// - title: 标题
/// - subTitle: 小标题
/// - pending: 待操作
/// - content: 内容
/// - exten: 扩展区域
enum NoticePendingCellClickRegion: Int {
    case avatar = 0
    case title
    case subTitle
    case pending
    case content
    case exten
}

/// 通知待操作协议
protocol NoticePendingProtocol: class {
    /// 待操作按钮点击了某些区域
    func notice(pendingCell: NoticePendingCell, didClickRegion: NoticePendingCellClickRegion)
}

/// 通知操作区域状态
///
/// - isHidden: 隐藏
/// - hightLight: 高亮
/// - warning: 警告
/// - normal: 普通
/// - heart: 桃心
enum NoticePendingCellPendingReginStatus {
    case isHidden
    case hightLight
    case warning
    case normal
    case heart
    case report
}

struct NoticePendingCellLayoutConfig {
    /// 待操作区的状态
    let pendingReginStatus: NoticePendingCellPendingReginStatus
    /// 是否隐藏扩展区域
    let isHiddenExtenRegin: Bool
    /// 是否隐藏正文
    let isHiddenContent: Bool
    /// 头像
    let avatarUrl: String?
    /// 头像认证类型
    let verifyType: String?
    /// 头像认证标识
    let verifyIcon: String?
    /// 头像用户id
    let userId: Int?
    /// 标题
    let title: String
    /// 标题信息
    var titleInfo: String?
    /// 副标题
    let subTitle: String?
    /// 时间
    let date: Date?
    /// 内容
    let content: String?
    /// 高亮内容
    let hightLightInContent: String?
    /// 扩展内容
    let extenContent: String?
    /// 扩展封面
    let extenCover: URL?
    /// 是否是视频(只有动态才有视频)
    let isVideo: Bool?
    /// 操作区内容
    let pendingContent: String?
    /// 申请置顶积分
    let amount: Int?
    /// 申请置顶天数
    let day: Int?
}

class NoticePendingExtenView: UIControl {
    let content = ActiveLabel(frame: CGRect.zero)
    let cover: UIImageView = UIImageView(frame: CGRect.zero)
    let coverVideoIcon: UIImageView = UIImageView(frame: CGRect.zero)
    var tapBlock: (() -> Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.content.numberOfLines = 2
        self.content.textAlignment = .left
        self.content.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
        self.content.textColor = UIColor(hex: 0x999999)
        self.content.mentionColor = UIColor(hex: 0x999999)
        self.content.URLColor = TSColor.main.theme
        self.content.URLSelectedColor = TSColor.main.theme
        self.backgroundColor = TSColor.inconspicuous.background
        self.cover.contentMode = UIView.ContentMode.scaleAspectFill
        self.cover.clipsToBounds = true
        self.coverVideoIcon.contentMode = UIView.ContentMode.scaleAspectFill
        self.coverVideoIcon.clipsToBounds = true
        self.coverVideoIcon.image = UIImage.set_image(named: "ico_notice_video")
        self.addSubview(self.content)
        self.addSubview(self.cover)
        self.addSubview(self.coverVideoIcon)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.isHidden == false {
            cover.snp.remakeConstraints { (mark) in
                mark.top.equalToSuperview().offset(5)
                mark.left.equalToSuperview().offset(5)
                mark.bottom.equalToSuperview().offset(-5)
                if cover.isHidden == true {
                    mark.width.equalTo(0)
                } else {
                    mark.width.equalTo(27)
                }
            }
            coverVideoIcon.snp.remakeConstraints { (mark) in
                mark.width.height.equalTo(17)
                mark.center.equalTo(cover.snp.center)
            }
            content.snp.remakeConstraints { (mark) in
                mark.top.equalToSuperview().offset(-6).priorityLow()
                mark.right.equalToSuperview().offset(-5)
                mark.bottom.equalToSuperview().offset(6).priorityLow()
                if cover.isHidden {
                    mark.left.equalToSuperview().offset(5)
                } else {
                    mark.left.equalTo(cover.snp.right).offset(5)
                }
                mark.centerY.equalToSuperview()
            }
        }
    }
    /// 这个地方需要处理从ActiveLabel穿透过来的点击事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let tapBlock = self.tapBlock {
            tapBlock()
        }
    }
}

class NoticeContentCell: NoticePendingCell {
    let contentLabel: TYAttributedLabel = TYAttributedLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 1)).configure {
        $0.numberOfLines = 0
        $0.lineBreakMode = .byWordWrapping
    }
    let tyContentLabel: TYAttributedLabel = TYAttributedLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
    let extenView: NoticePendingExtenView = NoticePendingExtenView(frame: CGRect.zero)
    /// 置顶信息
    let topInfoLabel: UILabel = UILabel(frame: CGRect.zero)

    @objc override func didClickRegion(_ region: UIControl) {
        if region is NoticePendingExtenView {
            self.delegate?.notice(pendingCell: self, didClickRegion: .exten)
        } else {
            super.didClickRegion(region)
        }
    }
    
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    
    override func loadConfig() {
        super.loadConfig()
        guard let config = config  else {
            return
        }
        // 内容
        contentLabel.isHidden = config.isHiddenContent
        contentLabel.text = nil
        
        if !contentLabel.isHidden {
            if let content = config.content {
                let highlight = YYTextHighlight()
                highlight.tapAction = { (containerView, text, range, rect) in
                    self.delegate?.notice(pendingCell: self, didClickRegion: .content)
                }
            
                if let url = URL(string: content), ["png", "gif", "jpeg"].contains(url.pathExtension.lowercased()) {
                    let imageView = contentImage(url)
                    contentLabel.append(imageView)
                } else {
                    /// 按照这样的顺序去赋值富文本属性应该就是对的（整体颜色用yylabel去设置，其他的用tscommonTool去设置，最后如果有艾特的 就放到最后去设置艾特内容的颜色）
//                    HTMLManager.shared.removeHtmlTag(htmlString: content, completion: { [weak self] (content, _) in
//                        guard let self = self else { return }
//                                            
//                        var attributedText  = content.attributonString().setTextFont(14).setlineSpacing(0)
//                        attributedText.yy_setColor(TSColor.normal.blackTitle, range: NSRange(location: 0, length: content.count))
//                        attributedText = TSCommonTool.string(attributedText, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: TSColor.normal.blackTitle]], strings: [content])
//                        if let hightContent = config.hightLightInContent, let range = content.range(of: hightContent) {
//                            attributedText = TSCommonTool.string(attributedText, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x999999)]], strings: [hightContent])
//                        }
//                        contentLabel.setAttributedText(attributedText)
//                    })
                    
//                    contentAttStr.yy_setColor(TSColor.normal.blackTitle, range: NSRange(location: 0, length: content.count))
//                    contentAttStr = TSCommonTool.string(contentAttStr, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: TSColor.normal.blackTitle]], strings: [content])
//                    if let hightContent = config.hightLightInContent, let range = content.range(of: hightContent) {
//                        contentAttStr = TSCommonTool.string(contentAttStr, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x999999)]], strings: [hightContent])
//                    }
//                    if content.count > 0 {
//                        let matchs = TSUtil.findAllTSAt(inputStr: content)
//                        if matchs.count > 0 {
//                            // 找到了at
//                            for match in matchs {
//                                contentAttStr.yy_setTextHighlight(match.range, color: TSColor.main.theme, backgroundColor: UIColor.clear) { (aTapView, aString, aRang, aRect) in
//                                    let selectedString = aString.string.subString(with: aRang)
//                                    var uname = selectedString.substring(to: selectedString.index(selectedString.startIndex, offsetBy: selectedString.count - 1))
//                                    uname = uname.substring(from: uname.index(after: uname.index(uname.startIndex, offsetBy: 1)))
//                                    TSUtil.pushUserHomeName(name: uname)
//                                }
//                            }
//                        }
//                    }
//                    contentLabel.setAttributedText(contentAttStr)
                }
            } else {
                assert(false, "配置显示正文时,传入正文为空")
            }
        }

        // 置顶积分/时间
        if config.day != nil && config.day! > 0 && config.pendingContent?.contains("delete".localized) == false {
            topInfoLabel.isHidden = false
            topInfoLabel.text = "\(config.amount!)" + TSAppConfig.share.localInfo.goldName + " / " + "\(config.day!)天"
        } else {
            topInfoLabel.isHidden = true
            topInfoLabel.text = ""
        }

        if config.pendingReginStatus == .normal {
            topInfoLabel.textColor = UIColor(red: 252.0 / 255.0, green: 163.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        } else if config.pendingReginStatus == .hightLight {
            topInfoLabel.textColor = TSColor.normal.disabled
        }

        extenView.coverVideoIcon.isHidden = true
        // 扩展
        if !config.isHiddenExtenRegin {
            HTMLManager.shared.removeHtmlTag(htmlString: config.extenContent ?? "", completion: { [weak self] (content, userIdList) in
                guard let self = self else { return }
                
                self.userIdList = userIdList
                self.htmlAttributedText = content.attributonString().setTextFont(14).setlineSpacing(0)
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList)
                    extenView.content.attributedText = attributedText
                }
            })
            
//            extenView.content.handleMentionTap { (name) in
//                HTMLManager.shared.handleMentionTap(name: name, attributedText: self.htmlAttributedText)
//            }
            
//            extenView.content.attributedText = config.extenContent?.attributonString().setTextFont(12).setlineSpacing(6)
//            extenView.content.handleMentionTap { (name) in
//                    /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
//                    let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
//                    TSUtil.pushUserHomeName(name: uname)
//            }
        } else {
            extenView.content.text = "moment_is_deleted".localized
        }
        let hiddenCover: Bool = (config.extenCover == nil)
        extenView.cover.isHidden = hiddenCover
        if let cover = config.extenCover {
            let placeholderImage = UIImage.colorImage(color: TSColor.inconspicuous.background)
            extenView.cover.sd_setImage(with: cover, placeholderImage: placeholderImage)
            // 是否是视频
            if config.isVideo == true {
                extenView.coverVideoIcon.isHidden = false
            } else {
                extenView.coverVideoIcon.isHidden = true
            }
        }
        
        pendingBtn.isHidden = (config.isHiddenExtenRegin && config.pendingReginStatus != .heart)
        
        extenView.setNeedsLayout()

        // 判断 内容, 扩展
        contentLabel.snp.removeConstraints()
        extenView.snp.removeConstraints()
        dateLabel.snp.removeConstraints()
//        这里代码注释，因为逻辑同Android端，如果动态被删除了，需要展示给用户 "内容已被删除"的提示内容
//        if config.isHiddenContent && config.isHiddenExtenRegin {
//            dateLabel.snp.remakeConstraints { (mark) in
//                mark.left.equalTo(avatarBtn.snp.right).offset(10)
//                mark.right.equalToSuperview().offset(-10)
//                mark.top.equalTo(titleLabel.snp.bottom).offset(5)
//                mark.bottom.equalToSuperview().offset(-15)
//            }
//            return
//        }
        if config.isHiddenContent {
            setupHiddenContentAndNotHiddenExtenReginLayout()
            return
        }
        if !config.isHiddenContent {
            setupNotHiddenContentAndNotHiddenExtenReginLayout()
            return
        }
    }

    private func setupNotHiddenContentAndHiddenExtenReginLayout() {
        dateLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.top.equalTo(titleLabel.snp.bottom).offset(5)
            mark.bottom.equalTo(contentLabel.snp.top).offset(-10)
            mark.height.equalTo(15)
        }
        contentLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.top.equalTo(dateLabel.snp.bottom).offset(10)
            mark.bottom.equalToSuperview().offset(-15)
        }
        topInfoLabel.snp.remakeConstraints { (mark) in
            mark.right.equalToSuperview().offset(-65)
            mark.centerY.equalTo(titleLabel.snp.centerY)
            mark.left.equalTo(titleLabel.snp.right).offset(10)
            mark.height.equalTo(12)
        }
    }

    private  func setupHiddenContentAndNotHiddenExtenReginLayout() {
        dateLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.top.equalTo(titleLabel.snp.bottom).offset(5)
            mark.bottom.equalTo(extenView.snp.top).offset(-10)
            mark.height.equalTo(15)
        }
        extenView.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.height.equalTo(37)
            mark.top.equalTo(dateLabel.snp.bottom).offset(10)
            mark.bottom.equalToSuperview().offset(-15)
        }
    }

    private func setupNotHiddenContentAndNotHiddenExtenReginLayout() {
        dateLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.top.equalTo(titleLabel.snp.bottom).offset(5)
            mark.bottom.equalTo(contentLabel.snp.top).offset(-10)
            mark.height.equalTo(15)
        }
        contentLabel.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.top.equalTo(dateLabel.snp.bottom).offset(10)
            mark.bottom.equalTo(extenView.snp.top).offset(-10)
        }
        topInfoLabel.snp.remakeConstraints { (mark) in
            mark.right.equalToSuperview().offset(-65)
            mark.centerY.equalTo(titleLabel.snp.centerY)
            mark.left.equalTo(titleLabel.snp.right).offset(10)
            mark.height.equalTo(12)
        }
        extenView.snp.remakeConstraints { (mark) in
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.right.equalToSuperview().offset(-10)
            mark.height.equalTo(37)
            mark.top.equalTo(contentLabel.snp.bottom).offset(10)
            mark.bottom.equalToSuperview().offset(-15)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentLabel.textAlignment = .left
        contentLabel.preferredMaxLayoutWidth = UIScreen.main.bounds.width - 48/*头像宽度 + 左右间距*/ - 10 /*屏幕右边距*/
        self.topInfoLabel.font = UIFont.systemFont(ofSize: 12)
        self.topInfoLabel.textColor = UIColor(red: 252.0 / 255.0, green: 163.0 / 255.0, blue: 8.0 / 255.0, alpha: 1.0)
        self.topInfoLabel.isHidden = true
        self.topInfoLabel.textAlignment = .right
        extenView.addTarget(self, action: #selector(didClickRegion(_:)), for: .touchUpInside)
        extenView.tapBlock = {
            self.didClickRegion(self.extenView)
        }
        self.contentView.addSubview(contentLabel)
        self.contentView.addSubview(extenView)
        self.addSubview(self.topInfoLabel)

        tyContentLabel.numberOfLines = 0;
        tyContentLabel.textAlignment = .left
        self.addSubview(self.tyContentLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }
}

class NoticePendingCell: TSTableViewCell {
    let avatarBtn = AvatarView(type: AvatarType.width26(showBorderLine: false))
    let titleLabel: YYLabel = YYLabel(frame: .zero)
    let dateLabel: TSLabel = TSLabel(frame: CGRect.zero)
    let pendingBtn: UIButton = UIButton(type: .custom)
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    weak var delegate: NoticePendingProtocol?
    var config: NoticePendingCellLayoutConfig? {
        didSet {
            loadConfig()
        }
    }

    @objc func didClickRegion(_ region: UIControl) {
        if region is AvatarView || region.tag == 250 {
            self.delegate?.notice(pendingCell: self, didClickRegion: .avatar)
        } else if region is UIButton {
            self.delegate?.notice(pendingCell: self, didClickRegion: .pending)
        }
    }

    func loadConfig() {
        guard let config = config  else {
            return
        }
        // 头像
        // TODO: 传递用户性别
        //        avatarBtn.avatarPlaceholderType = AvatarView.PlaceholderType(sexNumber: config.sex)
        let avatarInfo = AvatarInfo()
        avatarInfo.avatarURL = config.avatarUrl
        avatarInfo.verifiedType = config.verifyType ?? ""
        avatarInfo.verifiedIcon = config.verifyIcon ?? ""
        avatarInfo.type = .normal(userId: config.userId)
        avatarBtn.avatarInfo = avatarInfo
        avatarBtn.snp.remakeConstraints { (mark) in
            mark.top.equalToSuperview().offset(15)
            mark.left.equalToSuperview().offset(10)
            mark.size.equalTo(CGSize(width: 28, height: 28))
        }
        // 标题
        let attStr = convert(configToFullTitle: config)
        titleLabel.attributedText = attStr
        titleLabel.snp.remakeConstraints { (mark) in
            mark.top.equalToSuperview().offset(15)
            mark.left.equalTo(avatarBtn.snp.right).offset(10)
            mark.bottom.equalTo(dateLabel.snp.top).offset(-5)
            mark.height.equalTo(15)
        }
        // 时间
        if let date = config.date {
            dateLabel.text = TSDate().dateString(.normal, nDate: date)
        }
        setupPendingbtn(with: config)
    }

    private func setupPendingbtn(with config: NoticePendingCellLayoutConfig) {
        pendingBtn.isHidden = false
        pendingBtn.contentHorizontalAlignment = .right
        pendingBtn.layer.borderColor = UIColor.clear.cgColor

        switch config.pendingReginStatus {
        case .heart:
            pendingBtn.setTitle(nil, for: .disabled)
            pendingBtn.setImage(UIImage.set_image(named: "IMG_message_heart"), for: .disabled)
            pendingBtn.backgroundColor = UIColor.clear
            pendingBtn.layer.cornerRadius = 0
            pendingBtn.contentHorizontalAlignment = .right
            pendingBtn.isEnabled = false
        case .warning:
            assert(config.pendingContent != nil, "设置该状态时,必须设置该值")
            pendingBtn.setTitle(config.pendingContent!, for: .disabled)
            pendingBtn.setTitleColor(TSColor.main.warn, for: .disabled)
            pendingBtn.setImage(nil, for: .disabled)
            pendingBtn.backgroundColor = UIColor.clear
            pendingBtn.layer.cornerRadius = 0
            pendingBtn.contentHorizontalAlignment = .right
            pendingBtn.isEnabled = false
        case .hightLight:
            assert(config.pendingContent != nil, "设置该状态时,必须设置该值")
            pendingBtn.setTitle(config.pendingContent!, for: .disabled)
            pendingBtn.setTitleColor(TSColor.normal.disabled, for: .disabled)
            pendingBtn.setImage(nil, for: .disabled)
            pendingBtn.backgroundColor = UIColor.clear
            pendingBtn.layer.cornerRadius = 0
            pendingBtn.contentHorizontalAlignment = .right
            pendingBtn.isEnabled = false
        case .normal:
            assert(config.pendingContent != nil, "设置该状态时,必须设置该值")
            pendingBtn.setTitle(config.pendingContent!, for: .normal)
            pendingBtn.setTitleColor(TSColor.small.topLogo, for: .normal)
            pendingBtn.setImage(nil, for: .normal)
            pendingBtn.backgroundColor = UIColor.clear
            pendingBtn.layer.cornerRadius = 9
            pendingBtn.layer.borderColor = TSColor.small.topLogo.cgColor
            pendingBtn.layer.borderWidth = 0.5
            pendingBtn.contentHorizontalAlignment = .center
            pendingBtn.isEnabled = true
        case .report:
            pendingBtn.setTitle("longclick_msg_reply".localized, for: .disabled)
            pendingBtn.setTitleColor(UIColor(hex: 0x999999), for: .disabled)
            pendingBtn.backgroundColor = UIColor(hex: 0xf7f7f7)
            pendingBtn.layer.cornerRadius = 2
            pendingBtn.contentHorizontalAlignment = .center
            pendingBtn.isEnabled = false
        case .isHidden:
            pendingBtn.isHidden = true
        }

        switch config.pendingReginStatus {
        case .report:
            pendingBtn.snp.remakeConstraints { (mark) in
                mark.centerY.equalTo(titleLabel)
                mark.right.equalToSuperview().offset(-10)
                mark.height.equalTo(22)
                mark.width.equalTo(40)
            }
        case .normal:
            pendingBtn.snp.remakeConstraints { (mark) in
                mark.centerY.equalTo(titleLabel)
                mark.right.equalToSuperview().offset(-10)
                mark.height.equalTo(18)
                mark.width.equalTo(42)
            }
        default:
            pendingBtn.snp.remakeConstraints { (mark) in
                mark.centerY.equalTo(titleLabel)
                mark.right.equalToSuperview().offset(-10)
                mark.height.equalTo(12)
            }
        }
    }

    private func convert(configToFullTitle config: NoticePendingCellLayoutConfig) -> NSMutableAttributedString {
        let attributedText: NSMutableAttributedString
        let titleHighlight = YYTextHighlight()
        
        var configTitle = config.title
        
        // MARK: REMARK NAME
        configTitle = LocalRemarkName.getRemarkName(userId: "\(config.userId!)", username: nil, originalName: config.title, label: nil)
    
        titleHighlight.setFont(UIFont.systemFont(ofSize: TSFont.UserName.comment.rawValue))
        titleHighlight.tapAction = { (containerView, text, range, rect) in
            self.delegate?.notice(pendingCell: self, didClickRegion: .title)
        }
        let titleRange = NSRange(location: 0, length: configTitle.utf16.count)
        var titleInfoHigh: YYTextHighlight?
        var titleInfoRange: NSRange?
        var subTitleHigh: YYTextHighlight?
        var subTitleRange: NSRange?

        if let titleInfo = config.titleInfo {
            titleInfoHigh = YYTextHighlight()
            titleInfoHigh!.setFont(UIFont.systemFont(ofSize: TSFont.UserName.comment.rawValue))
            let fullTitle = configTitle + " " + titleInfo
            if let range = fullTitle.range(of: titleInfo) {
                titleInfoRange = fullTitle.nsRange(from: range)
            }
        }
        if let subTitle = config.subTitle {
            subTitleHigh = YYTextHighlight()
            subTitleHigh!.setColor(TSColor.normal.blackTitle)
            subTitleHigh!.setFont(UIFont.systemFont(ofSize: TSFont.UserName.comment.rawValue))
            subTitleHigh!.tapAction = { (containerView, text, range, rect) in
                self.delegate?.notice(pendingCell: self, didClickRegion: .subTitle)
            }
            var fullTitle = configTitle
            if let titleInfo = config.titleInfo {
                fullTitle.append(titleInfo)
            }
            fullTitle.append(subTitle)
            if let range = fullTitle.range(of: subTitle) {
                subTitleRange = fullTitle.nsRange(from: range)
            }
        }
        if config.titleInfo == nil && config.subTitle == nil {
            attributedText = NSMutableAttributedString(string: configTitle)
            attributedText.yy_setTextHighlight(titleHighlight, range: titleRange)
            attributedText.yy_setColor(TSColor.normal.blackTitle, range: titleRange)
            return attributedText
        }
        if config.titleInfo != nil && config.subTitle == nil && titleInfoRange != nil {
            attributedText = NSMutableAttributedString(string: configTitle + " " + config.titleInfo!)
            attributedText.yy_setTextHighlight(titleHighlight, range: titleRange)
            attributedText.yy_setTextHighlight(titleInfoHigh!, range: titleInfoRange!)
            attributedText.yy_setColor(TSColor.normal.blackTitle, range: titleRange)
            attributedText.yy_setColor(UIColor(hex: 0x999999), range: titleInfoRange!)
            return attributedText
        }
        if config.titleInfo != nil && config.subTitle != nil && titleInfoRange != nil{
            attributedText = NSMutableAttributedString(string: configTitle + " " + config.titleInfo! + " " + config.subTitle!)
            attributedText.yy_setTextHighlight(titleHighlight, range: titleRange)
            attributedText.yy_setTextHighlight(titleInfoHigh!, range: titleInfoRange!)
            attributedText.yy_setTextHighlight(subTitleHigh!, range: subTitleRange!)
            attributedText.yy_setColor(TSColor.normal.blackTitle, range: titleRange)
            attributedText.yy_setColor(UIColor(hex: 0x999999), range: titleInfoRange!)
            attributedText.yy_setColor(TSColor.normal.blackTitle, range: subTitleRange!)
            return attributedText
        }
        fatalError("数据解析成标题时出现了未配置的情况")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        avatarBtn.buttonForAvatar.isUserInteractionEnabled = true
        avatarBtn.buttonForAvatar.addTarget(self, action: #selector(didClickRegion(_:)), for: .touchUpInside)
        avatarBtn.buttonForAvatar.tag = 250

        titleLabel.textAlignment = .left
        
        dateLabel.textAlignment = .left
        dateLabel.font = UIFont.systemFont(ofSize: TSFont.Time.normal.rawValue)
        dateLabel.textColor = TSColor.normal.disabled

        pendingBtn.addTarget(self, action: #selector(didClickRegion(_:)), for: .touchUpInside)
        pendingBtn.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.toolbarLeft.rawValue)

        self.contentView.addSubview(avatarBtn)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(pendingBtn)
    }

    func contentImage(_ url: URL) -> UIImageView {
        let imageView = UIImageView()
        imageView.sd_setImage(with: url)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))
        return imageView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("不支持xib")
    }
}


