//
//  ShareListView.swift
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/7.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit


protocol ShareListViewDelegate: AnyObject {
    func didClickMessageButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, model: TSmessagePopModel)
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickRepostButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?)
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 设置置顶
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 撤销置顶
    func didClickCancelTopButon(_ sharesetUIView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 设为精华帖
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // 取消精华帖
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    // share external
    func didClickShareExternal(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any])
    // share only Image
    func didClickShareQr(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?, items: [Any])
    // disable comment
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    
    func didClickAliasButton(_ shareView: ShareListView, fatherViewTag: Int)
    
    func didClickShareOptionsButton(_ shareView: ShareListView, fatherViewTag: Int)
    
    func didClickBlackListButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?)
    
    func didClickRemoveFromBlackListButton(_ shareView: ShareListView, fatherViewTag: Int)
    
    func didClickReportUserButton(_ shareView: ShareListView, fatherViewTag: Int)
    
    func didClickHideAdsButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?)
    
    // edit post
    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    
    func didClickPinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
    func didClickUnpinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath)
}

/// Optional
extension ShareListViewDelegate {
    func didClickReportButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickCollectionButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickDeleteButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickApplyTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickSetTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickCancelTopButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickSetExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickCancelExcellentButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickDisableCommentButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickAliasButton(_ shareView: ShareListView, fatherViewTag: Int) {}
    func didClickShareOptionsButton(_ shareView: ShareListView, fatherViewTag: Int) {}
    func didClickBlackListButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {}
    func didClickRemoveFromBlackListButton(_ shareView: ShareListView, fatherViewTag: Int) {}
    func didClickReportUserButton(_ shareView: ShareListView, fatherViewTag: Int) {}
    func didClickEditButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickHideAdsButton(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath?) {}
    
    func didClickPinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
    func didClickUnpinButon(_ shareView: ShareListView, fatherViewTag: Int, feedIndex: IndexPath) {}
}

enum ShareListURL: String {
    /// 动态分享+feedid
    case feed = "/feeds/"
    /// 用户分享+userid
    case user = "/users/"
    /// 问答 - 问题，拼接问题id
    case question = "/questions/"
    /// 问答 - 答案，{question} 替换为问题id 拼接答案id
    case answswer = "/questions/replacequestion/answers/"
    /// 资讯分享 拼接资讯id
    case news = "/news/"
    /// 圈子详情
    case groupsList = "/groups/replacegroup?type=replacefetch"
    /// 话题分享
    case topics = "/question-topics/replacetopic"
}

enum ShareListType {
    case liveMoment
    case momentList
    case momenDetail
    case newDetail
    case groupMomentDetail
    case questionDetail
    case questionAnswerDetail
    case topicFeedList
    case officialPage
    case sticker
    case custom(items: [ShareItem])
}

enum ShareItem: Equatable {
    case edit(isEdited: Bool)
    case forward
    case save(isSaved: Bool)
    case message
    case report
    case delete
    case pinTop(isPinned: Bool)
    case shareExternal
    case essence(isEssence: Bool)
    case applyTop
    case comment(isCommentDisabled: Bool)
    case shareOptions
    case alias
    case blackList(isBlackListed: Bool)
    case reportUser
    case block
    case resubscribe
    case unsubscribe
    case deleteSubscription
    case hideAds
    case pinned(isPinned: Bool)
    case shareInviteLink
    case shareQr
    case download
    
    var title: String {
        switch self {
        case .edit(let isEdited):
            return isEdited ? "text_edited".localized : "edit".localized
        case .forward:
            return "share_moments".localized
        case .save(let isSaved):
            return isSaved ? "unsave".localized : "save".localized
        case .message:
            return "message".localized
        case .report:
            return "report".localized
        case .delete:
            return "delete".localized
        case .pinTop(let isPinned):
            return isPinned ? "pintop".localized : "unpin".localized
        case .shareExternal:
            return "share".localized
        case .essence(let isEssence):
            return isEssence ? "remove_essence_post".localized:"set_essence_post".localized
        case .applyTop:
            return "set_to_top".localized
        case .comment(let isCommentDisabled):
            return isCommentDisabled ? "enable_comment".localized : "disable_comment".localized
        case .shareOptions:
            return "share".localized
        case .alias:
            return "alias".localized
        case .blackList(let isBlackListed):
            return isBlackListed ? "remove_black_list".localized : "add_to_black_list".localized
        case .reportUser:
            return "report".localized
        case .block:
            return "text_block".localized
        case .resubscribe:
            return "subs_status_more_option_resubscribe".localized
        case .unsubscribe:
            return "subs_status_more_option_unsubscribe".localized
        case .deleteSubscription:
            return "subs_status_more_option_delete".localized
        case .hideAds:
            return "hide_ads".localized
        case .pinned(let isPinned):
            return isPinned ? "detail_share_unpin".localized : "detail_share_pin".localized
        case .shareInviteLink:
            return "text_share_invite_link".localized
        case .shareQr:
            return "text_share_qr".localized
        case .download:
            return "download".localized
        }
    }
    
    var image: String {
        switch self {
        case .edit(let isEdited):
            return isEdited ? "icEditedPost" : "icEditPost"
        case .forward:
            return "detail_share_forwarding"
        case .save(let isSaved):
            return isSaved ? "detail_share_clt_hl" : "detail_share_clt"
        case .message:
            return "detail_share_sent"
        case .report:
            return "detail_share_report"
        case .delete:
            return "detail_share_det"
        case .pinTop, .applyTop:
            return "detail_share_top"
        case .shareExternal:
            return "ic_share_external"
        case .essence(let isEssence):
            return isEssence ? "ico_cancel" : "ico_essence"
        case .comment(let isCommentDisabled):
            return isCommentDisabled ? "detail_share_disable_comment" : "detail_share_comment"
        case .shareOptions:
            return "ic_share_external"
        case .alias:
            return "ic_alias"
        case .blackList(let isBlackListed):
            return isBlackListed ? "ic_blacklisted" : "ic_blacklist" //todo cc change BLACKLISTED icon
        case .reportUser:
            return "detail_share_report"
        case .block:
            return "ic_blacklist"
        case .resubscribe:
            return "subscribe"
        case .unsubscribe:
            return "unsubscribe"
        case .deleteSubscription:
            return "delete"
        case .hideAds:
            return "ic_hide_ads"
        case .pinned(let isPinned):
            return isPinned ? "detail_share_unpin" : "detail_share_pin"
        case .shareInviteLink:
            return "icShareLink"
        case .shareQr:
            return "icShareQr"
        case .download:
            return "icDownload"
        }
    }

    var darkThemeImage: String {
        switch self {
            case .edit(let isEdited):
                return isEdited ? "icMoreEditedDark" : "icMoreEditDark"
            case .forward:
                return "icMoreMomentDark"
            case .save(let isSaved):
                return isSaved ? "icMoreSavedDark" : "icMoreSaveDark"
            case .message:
                return "icMoreMessageDark"
            case .report:
                return "icMoreReportWhite"
            case .delete:
                return "icMoreDeleteDark"
            case .pinTop, .applyTop:
                return "detail_share_top"
            case .shareExternal:
                return "icMoreShareDark"
            case .essence(let isEssence):
                return isEssence ? "ico_cancel" : "ico_essence"
            case .comment(let isCommentDisabled):
                return isCommentDisabled ? "icMoreEnableDark" : "icMoreDisableDark"
            case .shareOptions:
                return "icMoreShareDark"
            case .alias:
                return "ic_alias"
            case .blackList(let isBlackListed):
                return isBlackListed ? "ic_blacklisted" : "ic_blacklist" //todo cc change BLACKLISTED icon
            case .reportUser:
                return "detail_share_report"
            case .block:
                return "icMoreBlockWhite"
            case .resubscribe:
                return "subscribe"
            case .unsubscribe:
                return "unsubscribe"
            case .deleteSubscription:
                return "delete"
            case .hideAds:
                return "ic_hide_ads" // dark theme
            case .pinned(let isPinned):
                return isPinned ? "detail_share_unpin_dark" : "detail_share_pin_dark"
            case .shareInviteLink:
                return "icShareLink"
            case .shareQr:
                return "icShareQr"
            case .download:
                return "icDownload"
        }
    }
    
    var isSaved: Bool {
        switch self {
        case .save(let isSaved):
            return isSaved == true
        default:
            return false
        }
    }
    
    var isCommentDisabled: Bool {
        switch self {
        case .comment(let isCommentDisabled):
            return isCommentDisabled == true
        default:
            return false
        }
    }

    var isEdited: Bool {
        switch self {
            case .edit(let isEdited):
                return isEdited == true
            default:
                return false
        }
    }
}

class ShareListView: UIView {

    weak var delegate: ShareListViewDelegate?
    /// 点击取消的回调
    var dismissAction: (() -> Void)?
    /// 按钮间距
    let buttonSpace: CGFloat = 45.0
    /// 按钮尺寸
    let buttonSize: CGSize = CGSize(width: 33.0, height: 60)
    /// 按钮 tag
    let tagForShareButton = 200
    /// 按钮背景滚动视图
    var scrollow = UIScrollView()
    /// 分享按钮组
    var shareViewArray = [UIView]()
    /// 分享链接
    var shareUrlString: String? = nil
    /// 分享图片
    var shareImage: UIImage? = nil
    /// 分享描述
    var shareDescription: String? = nil
    /// 分享标题
    var shareTitle: String? = nil
    /// 是自己的还是他人的
    var isMine = false
    // 是否是管理员
    var isManager = false
    // 是否是圈主
    var isOwner = false
    
    var isPinned = false
    var isPinEnabled = false
    // 是否是精华
    var isExcellent = false
    // 是否是置顶
    var isTop = false
    // 是否置顶
    var isCollect = false
    var isCommentDisabled = false
    var isEdited = false
    var isShowBlock = TSAppConfig.share.moduleFlags.hideFeedBlockButton
    private var isSponsored = false
    
    var cancelButton = UIButton(type: .custom)
    var oneLineheight: CGFloat = 117.0
    var twoLineheight: CGFloat = 333.0 / 2.0
    var messageModel: TSmessagePopModel? = nil
    var feedIndex: IndexPath? = nil
    var shareType = ShareListType.momentList
    var theme: Theme = .white
    /// Powerful array ever
    var itemArray: [ShareItem] = [.forward, .message, .shareExternal]
    
    // MARK: Lifecycle
    init(isMineSend: Bool, isCollection: Bool, isDisabledCommentFeed: Bool, isEdited: Bool = false, isSponsored: Bool = false, isPinned: Bool = false, isPinEnabled: Bool = false, shareType: ShareListType, theme: Theme = .white) {
        super.init(frame: UIScreen.main.bounds)
        if let ismanager = TSCurrentUserInfo.share.accountManagerInfo?.getData() {
            self.isManager = ismanager
        } else {
            self.isManager = false
        }
        self.isMine = isMineSend
        self.isCollect = isCollection
        self.isCommentDisabled = isDisabledCommentFeed
        self.isEdited = isEdited
        self.theme = theme
        self.shareType = shareType
        self.isSponsored = isSponsored
        self.isPinned = isPinned
        self.isPinEnabled = isPinEnabled
        setUI()
    }

    init(shareType: ShareListType, theme: Theme = .white) {
        super.init(frame: UIScreen.main.bounds)
        self.shareType = shareType
        self.theme = theme
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.frame = UIScreen.main.bounds
    }

    // MARK: - Custom user interface
    func setUI() {

        backgroundColor = UIColor(white: 0, alpha: 0.2)
        switch theme {
            case .white:
                scrollow.backgroundColor = UIColor(hex: 0xf6f6f6)
                cancelButton.backgroundColor = UIColor.white
                cancelButton.setTitleColor(.black, for: .normal)

            case .dark:
                scrollow.backgroundColor = UIColor(red: 23, green: 23, blue: 23)
                cancelButton.backgroundColor = UIColor(red: 37, green: 37, blue: 37)
                cancelButton.setTitleColor(.white, for: .normal)
        }
        
        if !TSCurrentUserInfo.share.isLogin {
            itemArray.removeAll()
            itemArray.append(.shareExternal)
        } else {
            switch shareType {
            case .liveMoment:
                // do nothing
            break
            
            case .momentList:
                
                if isPinEnabled {
                    itemArray.append(.pinned(isPinned: isPinned))
                }
                itemArray.append(.save(isSaved: isCollect))
                
                if isMine {
                    itemArray.insert(.edit(isEdited: isEdited), at: 0)
                    itemArray.append(contentsOf: [.comment(isCommentDisabled: isCommentDisabled), .delete])
                } else if isManager {
                    itemArray.append(contentsOf: [.comment(isCommentDisabled: isCommentDisabled), .delete])
                } else if isShowBlock == false {
                    itemArray.append(contentsOf: [.block, .report])
                } else {
                    itemArray.append(.report)
                }
                
                if isSponsored {
                    itemArray.insert(.hideAds, at: 0)
                }
                
            case .topicFeedList:
                /// 话题没有置顶，没有置顶
                itemArray.append(.save(isSaved: isCollect))

                if isMine || isManager {
                    itemArray.insert(.edit(isEdited: isEdited), at: 0)
                    itemArray.append(contentsOf: [.comment(isCommentDisabled: isCommentDisabled), .delete])
                } else {
                    itemArray.append(contentsOf: [.report])
                }
        
            case .custom(let items):
                itemArray = items
                
            default:
                break
            }
        }
        
        let topOffset = 50 + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight()

        //scroll view
        addSubview(scrollow)
        scrollow.translatesAutoresizingMaskIntoConstraints = false
        scrollow.snp.makeConstraints({ (make) in
            make.leading.trailing.bottom.equalTo(self)
            make.height.equalTo(115 + topOffset)
        })
        
        // gesture
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(50+TSBottomSafeAreaHeight)
        }
        cancelButton.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)

        //stack view
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fill
        scrollow.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.snp.makeConstraints({ (make) in
            make.trailing.top.bottom.equalTo(scrollow)
            make.left.equalTo(scrollow).offset(15)
            make.height.equalTo(scrollow)
        })

        for index in 0..<itemArray.count {
            //shareview content
            let shareView = UIView()
            shareView.backgroundColor = theme == .white ? UIColor(hex: 0xf6f6f6) : UIColor(red: 23, green: 23, blue: 23)
            shareView.tag = tagForShareButton + index
            shareView.isUserInteractionEnabled = true

            let imageView = theme == .white ? UIImageView(image: UIImage.set_image(named: itemArray[index].image)) : UIImageView(image: UIImage.set_image(named: itemArray[index].darkThemeImage))
            imageView.isUserInteractionEnabled = true
            shareView.addSubview(imageView)
            imageView.snp.makeConstraints({ (make) in
                make.top.equalTo(shareView.snp.top).offset(20)
                make.centerX.equalTo(shareView.snp.centerX)
                make.size.equalTo(CGSize(width: 50, height: 50))
            })

            let label = UILabel()
            label.text = itemArray[index].title
            label.textColor = theme == .white ? .black : .white
            label.font = UIFont.systemFont(ofSize: TSFont.SubInfo.mini.rawValue)
//            if itemArray[index].isSaved || itemArray[index].isCommentDisabled{
//                label.textColor = TSColor.main.theme
//            }
            label.textAlignment = .center
            label.numberOfLines = 0
            shareView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.top.equalTo(imageView.snp.bottom).offset(12)
                make.width.equalTo(80)
                make.centerX.equalTo(imageView.snp.centerX)

            })

            stackView.addArrangedSubview(shareView)
            shareView.translatesAutoresizingMaskIntoConstraints = false
            shareView.snp.makeConstraints({ (make) in
                make.width.equalTo(80)
            })
            shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(buttonTaped(_:))))
        }
    }

    // MARK: - Button click
    @objc internal func buttonTaped(_ sender: UIGestureRecognizer) {
        
        defer {
            dismiss()
        }
        
        let view = sender.view
        let index = view!.tag - 200
        let shareName = itemArray[index]

        if TSCurrentUserInfo.share.isLogin == false && shareName != .shareExternal {
            TSRootViewController.share.guestJoinLandingVC()
            return
        }
        
        switch shareName {
        case .edit:
            guard let feedIndex = feedIndex else {
                return
            }
            delegate?.didClickEditButton(self, fatherViewTag: index, feedIndex: feedIndex)

        case .forward:
            delegate?.didClickRepostButon(self, fatherViewTag: index, feedIndex: feedIndex)
            
        case .save:
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickCollectionButon(self, fatherViewTag: index, feedIndex: feedindex)
            
        case .message:
            guard let model = messageModel else {
                return
            }
            delegate?.didClickMessageButon(self, fatherViewTag: index, feedIndex: feedIndex, model: model)
            
        case .applyTop:
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickApplyTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            
        case .pinTop(let isPinned):
            guard let feedindex = feedIndex else {
                return
            }
            if isPinned {
                delegate?.didClickCancelTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            } else {
                delegate?.didClickSetTopButon(self, fatherViewTag: index, feedIndex: feedindex)
            }
            
        case .essence(let isEssence):
            guard let feedindex = feedIndex else {
                return
            }
            if isEssence {
                delegate?.didClickCancelExcellentButon(self, fatherViewTag: index, feedIndex: feedindex)
            } else {
                delegate?.didClickSetExcellentButon(self, fatherViewTag: index, feedIndex: feedindex)
            }
            
        case .delete:
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickDeleteButon(self, fatherViewTag: index, feedIndex: feedindex)
            
        case .report:
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickReportButon(self, fatherViewTag: index, feedIndex: feedindex)
            
        case .shareExternal:
            let items: [Any] = [URL(string: shareUrlString.orEmpty), shareTitle, shareImage, ShareExtensionBlockerItem()]
            delegate?.didClickShareExternal(self, fatherViewTag: index, feedIndex: feedIndex, items: items)
            
        case .comment:
            guard let feedindex = feedIndex else {
                return
            }
            delegate?.didClickDisableCommentButton(self, fatherViewTag: index, feedIndex: feedindex)
            
        case .shareOptions:
            delegate?.didClickShareOptionsButton(self, fatherViewTag: index)
            
        case .alias:
            delegate?.didClickAliasButton(self, fatherViewTag: index)

        case .blackList(let isBlackListed):
            if isBlackListed == true {
                delegate?.didClickRemoveFromBlackListButton(self, fatherViewTag: index)
            } else {
                delegate?.didClickBlackListButton(self, fatherViewTag: index, feedIndex: feedIndex)
            }
            
        case .reportUser:
            delegate?.didClickReportUserButton(self, fatherViewTag: index)
            
        case .block:
            delegate?.didClickBlackListButton(self, fatherViewTag: index, feedIndex: feedIndex)
            
        case .unsubscribe:
//            delegate?.didClickUnsubscribeButton(self, fatherViewTag: index, subscriptionModel: subscriptionModel)
            break
        case .resubscribe:
//            delegate?.didClickResubscribeButton(self, fatherViewTag: index, subscriptionModel: subscriptionModel)
            break
        case .deleteSubscription:
//            delegate?.didClickDeleteSubscriptionButton(self, fatherViewTag: index, subscriptionModel: subscriptionModel)
            break
        case .hideAds:
            delegate?.didClickHideAdsButton(self, fatherViewTag: index, feedIndex: feedIndex)
            
        case .pinned(let isPinned):
            guard let feedindex = feedIndex else {
                return
            }
            if isPinned {
                delegate?.didClickUnpinButon(self, fatherViewTag: index, feedIndex: feedindex)
            } else {
                delegate?.didClickPinButon(self, fatherViewTag: index, feedIndex: feedindex)
            }
        case .shareInviteLink:
            let items: [Any] = [URL(string: shareUrlString.orEmpty), shareTitle, shareImage, ShareExtensionBlockerItem()]
            delegate?.didClickShareExternal(self, fatherViewTag: index, feedIndex: feedIndex, items: items)
        case .shareQr:
            let items: [Any] = [URL(string: shareUrlString.orEmpty), shareTitle, shareImage, ShareExtensionBlockerItem()]
            delegate?.didClickShareQr(self, fatherViewTag: index, feedIndex: feedIndex, items: items)
        case .download:
            delegate?.didClickShareOptionsButton(self, fatherViewTag: index)
        default:
            break
        }
    }
    
    /// 取消按钮点击
    @objc func cancelBtnClick() {
        dismiss()
        dismissAction?()
    }
    
    /// 设置完成后的回调方法
    func setFinishBlock() -> ((Bool) -> Void) {
        func finishBlock(success: Bool) -> Void {
            if success {
            }
        }
        return finishBlock
    }

    // MARK: Public
    /// 显示分享视图
    ///
    /// - Parameters:
    ///   - URLString: 分享的链接
    ///   - image: 分享的图片
    ///   - description: 分享的'对链接的描述'
    ///   - title: 分享的'链接标题'
    public func show(URLString: String?, image: UIImage?, description: String?, title: String?, shouldUsePrefix: Bool = true) {
        if shouldUsePrefix {
            if let url = URLString, let hostUrl = URL(string: FeedIMSDKManager.shared.param.apiBaseURL) {
                shareUrlString = (hostUrl.absoluteString + url)
            }
        } else {
            if let url = URL(string: URLString.orEmpty) {
                shareUrlString = url.absoluteString
            }
        }
        shareImage = image
        shareDescription = description
        shareTitle = title
        if self.superview != nil {
            return
        }
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(self)
    }

    /// 隐藏分享视图
   @objc public func dismiss() {
        if self.superview == nil {
            return
        }
        self.removeFromSuperview()
        dismissAction?()
    }

    func updateView(tag: Int, iscollect: Bool) {
        let bgView = self.scrollow.viewWithTag(tag + 200)
        for view in (bgView?.subviews)! {
            if view is UILabel {
                let titleLabel = view as! UILabel
                titleLabel.text = iscollect ? "mine_collect".localized : "collect".localized
                if titleLabel.text == "mine_collect".localized {
                    titleLabel.textColor = TSColor.main.theme
                } else {
                    titleLabel.textColor = TSColor.normal.content
                }
            }
            if view is UIImageView {
                let imageIcon = view as! UIImageView
                imageIcon.image = iscollect ? UIImage.set_image(named: "detail_share_clt_hl") : UIImage.set_image(named: "detail_share_clt")
            }
        }
    }
}
