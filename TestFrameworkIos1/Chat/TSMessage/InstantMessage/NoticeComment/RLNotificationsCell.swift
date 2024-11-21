//
//  RLNotificationsCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2023/10/13.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import ActiveLabel
import TYAttributedLabel
import SDWebImage
import YYText
//import NIMPrivate

enum RLNotificationsCellClickType: Int {
    case reply = 0 //回复
    case view  //查看
    case detail //查看详情
}
//消息总类型
enum ReceiveNotificationsType: String {
    case comment = "Comment"
    case reject = "FeedReject"
    case like = "Like" //点赞
    case follow = "Follow" //关注
    case system = "System" //system
    case tagged = "At" //at
    case forward = "Forward" // 转发
}

enum RLSystemNotificationType: String {
    case KYC = "user-certification"
    case rebate = "rebate"
    case purchase = "purchase"
    case userCash = "user-cash"
    case pinnedFeeds = "pinned:feeds"
    case userCurrencyCash = "user-currency:cash"
    case report = "report"
    case transfer = "transfer:yipps"
    
    case reward = "reward" //打赏
}

/// 通知待操作协议
protocol RLNotificationsCellDelegate: class {
    /// 待操作按钮点击了某些区域
    func noticeClick(notificationsCell: RLNotificationsCell, type: RLNotificationsCellClickType, indexPath: IndexPath)
    func followClick(notificationsCell: RLNotificationsCell, indexPath: IndexPath)
}

class RLNotificationsCell: UITableViewCell {
    
    static let identifier = "RLNotificationsCell"
    
    weak var  delegate: RLNotificationsCellDelegate?
    
    let avatarBtn = AvatarView(type: AvatarType.width33(showBorderLine: false))
    
    let allStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fill
        $0.alignment = .leading
    }
    
    let dayStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fill
        $0.alignment = .fill
    }
    
    private let iconImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let contentImageView = UIImageView().configure {
        $0.backgroundColor = .clear
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    private let labelForTitle = UILabel().configure {
        $0.setFontSize(with: 12, weight: .bold)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
        $0.numberOfLines = 2
    }
    
    private let labelForInfo = TYAttributedLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 1)).configure {
        $0.font = UIFont.systemRegularFont(ofSize: 12)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
        $0.lineBreakMode = .byTruncatingTail
        $0.numberOfLines = 1
    }
    
    private let labelForTime = UILabel().configure {
        $0.setFontSize(with: 10, weight: .norm)
        $0.textColor = UIColor(red: 128, green: 128, blue: 128)
    }
    private let detailButton = UIButton().configure {
        $0.applyStyle(.custom(text: "view".localized, textColor: UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1), backgroundColor: .white, cornerRadius: 0, fontWeight: .regular))
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 12)
    }
    
    private let followButton = UIButton().configure {
        $0.applyStyle(.custom(text: "rw_follow_back".localized, textColor: .white, backgroundColor: UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1), cornerRadius: 4, fontWeight: .regular))
        $0.titleLabel?.font = UIFont.systemRegularFont(ofSize: 10)
        $0.isHidden = true
    }
    
    let coverVideoIcon: UIImageView = UIImageView(frame: CGRect.zero)
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    var config: NoticePendingCellLayoutConfig?
    var data: ReceiveCommentModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.contentView.addSubview(avatarBtn)
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(allStackView)
        self.contentView.addSubview(contentImageView)
        self.contentView.addSubview(followButton)
        contentImageView.isUserInteractionEnabled = true
        avatarBtn.snp.makeConstraints { make in
            make.height.width.equalTo(33)
            make.left.equalTo(15)
            make.top.equalTo(11)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.height.width.equalTo(33)
            make.left.equalTo(15)
            make.top.equalTo(11)
        }
        
        contentImageView.snp.makeConstraints { make in
            make.height.width.equalTo(33)
            make.right.equalTo(-15)
            make.top.equalTo(11)
        }
        
        followButton.snp.makeConstraints { make in
            make.width.equalTo(82)
            make.height.equalTo(22)
            make.right.equalTo(-15)
            make.top.equalTo(11)
        }
        
        allStackView.snp.makeConstraints { make in
            make.left.equalTo(avatarBtn.snp.right).offset(8)
            make.right.equalTo(contentImageView.snp.left).inset(-12)
            make.top.equalTo(11)
            make.bottom.equalTo(-11)
        }
        
        allStackView.addArrangedSubview(labelForTitle)
        allStackView.addArrangedSubview(labelForInfo)
        allStackView.addArrangedSubview(dayStackView)
        
        labelForTitle.snp.makeConstraints { make in
            // make.height.equalTo(16)
            make.top.left.right.equalTo(0)
        }
        
        labelForInfo.snp.makeConstraints { make in
            make.left.right.equalTo(0)
        }
        
        dayStackView.snp.makeConstraints { make in
            make.height.equalTo(19)
            make.left.bottom.equalTo(0)
        }
        
        dayStackView.addArrangedSubview(labelForTime)
        dayStackView.addArrangedSubview(detailButton)
        labelForTime.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(0)
        }
        
        detailButton.snp.makeConstraints { make in
            make.bottom.top.equalToSuperview()
        }
        
        self.contentView.addSubview(coverVideoIcon)
        self.coverVideoIcon.contentMode = UIView.ContentMode.scaleAspectFill
        self.coverVideoIcon.clipsToBounds = true
        self.coverVideoIcon.image = UIImage.set_image(named: "ico_notice_video")
        coverVideoIcon.snp.makeConstraints { (mark) in
            mark.width.height.equalTo(17)
            mark.center.equalTo(contentImageView.snp.center)
        }
        coverVideoIcon.isHidden = true
        
        contentImageView.addTap { [weak self] _ in
            self?.delegate?.noticeClick(notificationsCell: self!, type: .detail, indexPath: self!.indexPath)
        }
        detailButton.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        followButton.addTarget(self, action: #selector(followAction), for: .touchUpInside)
    }
    
    public func setNoticeData(data: ReceiveCommentModel){
        self.data = data
        let config = data.convert()
        self.config = config
        
        followButton.isHidden = true
        allStackView.snp.removeConstraints()
        allStackView.snp.makeConstraints { make in
            make.left.equalTo(avatarBtn.snp.right).offset(8)
            make.right.equalTo(contentImageView.snp.left).inset(-12)
            make.top.equalTo(11)
            make.bottom.equalTo(-11)
        }
        switch data.sortType {
        case .reject:
            labelForInfo.isHidden = true
            avatarBtn.isHidden = true
            iconImageView.isHidden = false
            detailButton.isHidden = false
            // 时间
            labelForTitle.text = "rejected_string".localized
            labelForTitle.font = UIFont.systemRegularFont(ofSize: 12)
            labelForTime.text = TSDate().dateString(.normal, nDate: data.createDate ?? Date())
            iconImageView.image = UIImage.set_image(named: "post_reject")
            contentImageView.sd_setImage(with: URL(string: data.exten?.coverPath ?? ""), placeholderImage: UIImage.set_image(named: "post_placeholder"))
            labelForInfo.text = data.exten?.content ?? ""
            detailButton.setTitle("view".localized, for: .normal)
            if data.exten?.coverPath == "" {
                contentImageView.isHidden = true
            }else{
                contentImageView.isHidden = false
            }
            if (data.exten?.isVieo ?? false) == true {
                coverVideoIcon.isHidden = false
            } else {
                coverVideoIcon.isHidden = true
            }
        case .comment:
            
            iconImageView.isHidden = true
            avatarBtn.isHidden = false
            labelForInfo.isHidden = false
            detailButton.isHidden = false
            detailButton.setTitle("longclick_msg_reply".localized, for: .normal)
            
            
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = config.avatarUrl
            avatarInfo.verifiedType = config.verifyType ?? ""
            avatarInfo.verifiedIcon = config.verifyIcon ?? ""
            avatarInfo.type = .normal(userId: config.userId)
            avatarBtn.avatarInfo = avatarInfo
            // 标题
            configTitle(config: config)
            //内容
            configContent(config: config)
            // 时间
            if let date = config.date {
                labelForTime.text = TSDate().dateString(.normal, nDate: date)
            }
            labelForInfo.layoutIfNeeded()
            self.layoutIfNeeded()
            let size = labelForInfo.getSizeWithWidth(labelForInfo.width)
            labelForInfo.snp.removeConstraints()
            labelForInfo.snp.remakeConstraints { make in
                make.left.right.equalTo(0)
                make.height.equalTo(size.height)
            }
            
            let hiddenCover: Bool = (config.extenCover == nil)
            contentImageView.isHidden = hiddenCover
            if let cover = config.extenCover {
                let placeholderImage = UIImage.set_image(named: "rl_placeholder")
                contentImageView.sd_setImage(with: cover, placeholderImage: placeholderImage)
                // 是否是视频
                if config.isVideo == true {
                    coverVideoIcon.isHidden = false
                } else {
                    coverVideoIcon.isHidden = true
                }
            }
        case .follow:
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = config.avatarUrl
            avatarInfo.verifiedType = config.verifyType ?? ""
            avatarInfo.verifiedIcon = config.verifyIcon ?? ""
            avatarInfo.type = .normal(userId: config.userId)
            avatarBtn.avatarInfo = avatarInfo
            iconImageView.isHidden = true
            avatarBtn.isHidden = false
            labelForInfo.isHidden = true
            detailButton.isHidden = true
            contentImageView.isHidden = true
            coverVideoIcon.isHidden = true
            
            allStackView.snp.removeConstraints()
            allStackView.snp.makeConstraints { make in
                make.left.equalTo(avatarBtn.snp.right).offset(8)
                make.right.equalTo(followButton.snp.left).inset(-12)
                make.top.equalTo(11)
                make.bottom.equalTo(-11)
            }
            // 标题
            configTitle(config: config, type: .follow)
            // 时间
            if let date = config.date {
                labelForTime.text = TSDate().dateString(.normal, nDate: date)
            }
            
        case .like, .tagged, .forward:
            let avatarInfo = AvatarInfo()
            avatarInfo.avatarURL = config.avatarUrl
            avatarInfo.verifiedType = config.verifyType ?? ""
            avatarInfo.verifiedIcon = config.verifyIcon ?? ""
            avatarInfo.type = .normal(userId: config.userId)
            avatarBtn.avatarInfo = avatarInfo
            iconImageView.isHidden = true
            avatarBtn.isHidden = false
            labelForInfo.isHidden = true
            detailButton.isHidden = true
            let hiddenCover: Bool = (config.extenCover == nil)
            contentImageView.isHidden = hiddenCover
            if let cover = config.extenCover {
                let placeholderImage = UIImage.set_image(named: "rl_placeholder")
                contentImageView.sd_setImage(with: cover, placeholderImage: placeholderImage)
                // 是否是视频
                if config.isVideo == true {
                    coverVideoIcon.isHidden = false
                } else {
                    coverVideoIcon.isHidden = true
                }
            }
            // 时间
            if let date = config.date {
                labelForTime.text = TSDate().dateString(.normal, nDate: date)
            }
            // 标题
            configTitle(config: config, type: data.sortType)
        case .system:
            labelForInfo.isHidden = true
            avatarBtn.isHidden = true
            iconImageView.isHidden = false
            detailButton.isHidden = true
            contentImageView.isHidden = true
            coverVideoIcon.isHidden = true
            followButton.isHidden = true
            
            labelForTitle.font = UIFont.systemRegularFont(ofSize: 12)
            
            // 时间
            if let date = config.date {
                labelForTime.text = TSDate().dateString(.normal, nDate: date)
            }
            iconImageView.image = UIImage.set_image(named: "post_reject")
            
            let systemType = RLSystemNotificationType(rawValue: data.systemType) ?? .reward
            let nick = LocalRemarkName.getRemarkName(userId: "\(data.userId!)", username: nil, originalName: nil, label: nil)
            switch systemType {
            case .KYC:
                labelForTitle.text = data.systemContent.localized
                if data.systemState == "rejected" {
                    labelForTitle.text = "rw_noti_sys_request_authentication_rejected".localized
                } else if data.systemState == "bank_passed" {
                    labelForTitle.text = "noti_sys_request_bank_approved".localized
                } else if data.systemState == "bank_rejected" {
                    if data.systemContent.count > 0{
                        labelForTitle.text = String(format: "noti_sys_request_bank_rejected".localized , data.systemContent)
                    } else {
                        labelForTitle.text = "noti_sys_request_bank_rejected".localized
                    }
                } else {
                    labelForTitle.text = "rw_noti_sys_request_authentication_approved".localized
                }
                break
            case .rebate:
                labelForTitle.text = String(format: "noti_sys_rebate_success".localized, "\(data.rewardAmount)")
            case .report://举报
                var content = "noti_sys_report_action_took".localized
                let state = data.systemState
                let contentt = data.subject
                if state == "rejected" {
                    content = String(format: "noti_sys_report_on_user_action_rejected".localized, data.remark)
                    
                } else {
                    let typeS = data.sourceTypeNew
                    if typeS == "users" {
                        content = "noti_sys_report_on_user_action_took".localized
                    } else if typeS == "feed_topics" {
                        content = "noti_sys_report_moment".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                    } else if typeS == "comments" {
                        content = "noti_sys_report_on_user_action_took".localized
                    } else if typeS == "questions" {
                        content = "noti_sys_report_question".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                    } else if typeS == "feeds" {
                        content = "noti_sys_report_on_user_action_took".localized
                    } else if typeS == "news" {
                        content = "noti_sys_report_news".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                    } else if typeS == "answers" {
                        content = "noti_sys_report_answer".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                    } else if typeS == "posts" || typeS == "group-posts" {
                        content = "noti_sys_report_post_action_took".localized
                    } else if typeS == "groups" {
                        content = "noti_sys_report_group".localized + "「\(contentt)」" + "noti_sys_action_took_on_report".localized
                    }
                }
                labelForTitle.text = content
                break
            case .pinnedFeeds:
                if data.systemState == "rejected" {
                    labelForTitle.text = "noti_sys_request_pin_top_rejected".localized
                } else if data.systemState == "admin" {
                    labelForTitle.text = "noti_sys_admin_set_pin_top".localized
                } else {
                    labelForTitle.text = "noti_sys_request_pin_top_approved".localized
                }
                break
            case .transfer:
                
                let nick = LocalRemarkName.getRemarkName(userId: "\(data.userId!)", username: nil, originalName: nil, label: nil)
                
                labelForTitle.text = String(format: "noti_sys_transferred_you".localized ,"\(nick)")
                break
            case .userCash:
                if data.systemState == "rejected" {
                    labelForTitle.text = "noti_sys_fail_cash_out".localized
                } else {
                    labelForTitle.text = "noti_sys_success_cash_out".localized
                }
                break
            case .userCurrencyCash:
                labelForTitle.text = "userCurrencyCash".localized
                if data.systemState == "rejected" {
                    if data.systemContent.count > 0{
                        labelForTitle.text = "noti_sys_cash_out_fail_reason".localized + data.systemContent
                    } else {
                        labelForTitle.text = "noti_sys_cash_out_rejected".localized
                    }
                } else {
                    labelForTitle.text = "noti_sys_cash_out_approved".localized
                }
                break
            default:
                labelForTitle.text = "未知系统消息类型"
                break
            }
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = labelForInfo.getSizeWithWidth(labelForInfo.width)
        labelForInfo.snp.removeConstraints()
        labelForInfo.snp.remakeConstraints { make in
            make.left.right.equalTo(0)
            make.height.equalTo(size.height)
        }
        
        self.layoutIfNeeded()
    }
    
    @objc func clickAction() {
        guard let data1 = data else {
            return
        }
        self.delegate?.noticeClick(notificationsCell: self, type: data1.sourceType == .reject ? .view : .reply , indexPath: self.indexPath)
    }
    
    @objc func followAction() {
        guard let data = data else {
            return
        }
        self.delegate?.followClick(notificationsCell: self, indexPath: indexPath)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //标题
    func configTitle(config: NoticePendingCellLayoutConfig, type: ReceiveNotificationsType = .comment){
        labelForTitle.font = UIFont.boldSystemFont(ofSize: 12)
        var configTitle = config.title
        // MARK: REMARK NAME
        configTitle = LocalRemarkName.getRemarkName(userId: "\(config.userId!)", username: nil, originalName: config.title, label: nil)
        var titleInfo = config.titleInfo ?? ""
        switch type {
        case .follow:
            if let data = self.data, let user = data.user {
                titleInfo = "rw_notification_following".localized
                if user.followStatus == .unfollow {
                    followButton.isHidden = false
                } else if user.followStatus == .eachOther {
                    followButton.isHidden = true
                } else {
                    followButton.isHidden = true
                }
            } else {
                followButton.isHidden = true
            }
        case .like:
            titleInfo = "rw_notification_like".localized
        case .tagged:
            titleInfo = "rw_notification_tag".localized
        case .forward:
            titleInfo = "rw_notification_forward".localized
            
        default:
            titleInfo = config.titleInfo ?? ""
        }
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemRegularFont(ofSize: 12)
        ]
        let attStr = NSMutableAttributedString(string: configTitle + " " + titleInfo)
        attStr.addAttributes(attributes, range: NSRange(location: configTitle.utf16.count + 1, length: titleInfo.count))
        labelForTitle.attributedText = attStr
    }
    
    private func configContent(config: NoticePendingCellLayoutConfig){
        // 内容
        labelForInfo.isHidden = config.isHiddenContent
        labelForInfo.text = nil
        
        if !labelForInfo.isHidden {
            if let content = config.content {
                var contentAttStr = NSMutableAttributedString(string: content)
                let highlight = YYTextHighlight()
                highlight.tapAction = { (containerView, text, range, rect) in
                    //self.delegate?.notice(pendingCell: self, didClickRegion: .content)
                }
                
                if let url = URL(string: content), ["png", "gif", "jpeg", "jpg"].contains(url.pathExtension.lowercased()) {
                    let imageView = contentImage(url)
                    labelForInfo.append(imageView)
                } else {
                    /// 按照这样的顺序去赋值富文本属性应该就是对的（整体颜色用yylabel去设置，其他的用tscommonTool去设置，最后如果有艾特的 就放到最后去设置艾特内容的颜色）
                    HTMLManager.shared.removeHtmlTag(htmlString: content, completion: { [weak self] (content, _) in
                        guard let self = self else { return }
                        contentAttStr = content.attributonString()
                        contentAttStr.yy_setColor(TSColor.normal.blackTitle, range: NSRange(location: 0, length: content.count))
//                        contentAttStr = TSCommonTool.string(contentAttStr, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: TSColor.normal.blackTitle]], strings: [content])
//                        if let hightContent = config.hightLightInContent, let range = content.range(of: hightContent) {
//                            contentAttStr = TSCommonTool.string(contentAttStr, addpendAtrrs: [[NSAttributedString.Key.foregroundColor: UIColor(hex: 0x999999)]], strings: [hightContent])
//                        }

                        labelForInfo.setAttributedText(contentAttStr)
                    })
                    
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
//                    labelForInfo.setAttributedText(contentAttStr)
                }
            } else {
                assert(false, "配置显示正文时,传入正文为空")
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
            // self.delegate?.notice(pendingCell: self, didClickRegion: .title)
        }
        
        let titleRange = NSRange(location: 0, length: configTitle.utf16.count)
        var titleInfoHigh: YYTextHighlight?
        var titleInfoRange: NSRange?
        var subTitleHigh: YYTextHighlight?
        var subTitleRange: NSRange?
        
        if let titleInfo = config.titleInfo {
            titleInfoHigh = YYTextHighlight()
            titleInfoHigh!.setFont(UIFont.boldSystemFont(ofSize: TSFont.UserName.comment.rawValue))
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
                // self.delegate?.notice(pendingCell: self, didClickRegion: .subTitle)
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
    
    func contentImage(_ url: URL) -> UIImageView {
        let imageView = UIImageView()
        imageView.sd_setImage(with: url)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: .zero, size: CGSize(width: 60, height: 60))
        return imageView
    }
}
