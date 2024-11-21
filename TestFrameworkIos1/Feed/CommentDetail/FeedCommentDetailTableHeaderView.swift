//
//  FeedCommentDetailTableHeaderView.swift
//  Yippi
//
//  Created by ChuenWai on 18/01/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import CoreMedia
import ActiveLabel

class FeedCommentDetailTableHeaderView: UIView {
    
    // data model
    private var locationInfo: TSPostLocationModel?
    private var originalTexts: String = ""
    private var translatedTexts: String = ""
    private var model: FeedListCellModel = FeedListCellModel()
    var onTranslated: EmptyClosure?
    // views
    private var contentView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.backgroundColor = .white
        
        return stack
    }()
    
    private var locationView = UIView()
    private var repostViewBgView = UIView()
    private var repostView = TSRepostView()
    private var sharedView = TSRepostView()
    private var feedSharedView = TSFeedRePostView()
    //商家类目
    public  var feedShopView = FeedCommentDetailShopView(frame: .zero, shopSubViewType: .picture)
    
    private let timepaddingView = UIView()
    private var primaryLabel: ActiveLabel = ActiveLabel()
    let toolbar = TSToolbarView(type: .left)
    var videoPlayerView: VideoPlayerVODView = VideoPlayerVODView()
    var pictureView = PicturesTrellisView()
    var multiplePictureView = MultiplePictureViewController(currentIndex: 0, pictureModel: PaidPictureModel())
    var multiplePicturePageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var multiplePicturePageControl = UIPageControl()
    private var isTrasitioningBetweenPage = false
    private var pictureModels: [PaidPictureModel] = []
    
    private let reactionView = UserReactionView()
    private var playerStartTime: CMTime = .zero {
        didSet {
            videoPlayerView.startPlaytime = playerStartTime
        }
    }
    
    var contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 0
        stack.backgroundColor = .white
        return stack
    }()
    
    private lazy var viewAndTimeContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(viewsAndTimeView)
        viewsAndTimeView.snp.makeConstraints { (v) in
            v.top.bottom.equalToSuperview()
            v.left.equalToSuperview().inset(10)
            v.right.lessThanOrEqualToSuperview()
            v.height.equalTo(30)
        }
        return view
    }()
    
    private lazy var viewsAndTimeView: UIStackView = {
        let stackview = UIStackView(arrangedSubviews: [viewCountLabel, dateDotView, timestampLabel, translateDotView, translateButton])
        stackview.axis = .horizontal
        stackview.distribution = .fillProportionally
        stackview.alignment = .center
        stackview.spacing = 8.0
        return stackview
    }()
    
//    private lazy var timeWrapperView: UIView = {
//        let wrapper = UIView()
//        wrapper.addSubview(translateStackView)
//        translateStackView.snp.makeConstraints { (v) in
//            v.top.bottom.equalToSuperview()
//            v.left.equalToSuperview().inset(10)
//            v.right.lessThanOrEqualToSuperview()
//            v.height.equalTo(30)
//        }
//        
//        return wrapper
//    }()
//    
//    private lazy var translateStackView: UIStackView = {
//        let stackview = UIStackView().build { (v) in
//            v.spacing = 5
//            v.distribution = .fillProportionally
//            v.alignment = .center
//            v.axis = .horizontal
//        }
//        return stackview
//    }()
    
    private lazy var dateDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x808080)
        view.roundCorner(1)
        return view
    }()
    
    private lazy var translateDotView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0x808080)
        view.roundCorner(1)
        return view
    }()
    
    private var translateButton: LoadableButton = LoadableButton(frame: .zero, icon: nil,
                                                                 text: "text_translate".localized, textColor: AppTheme.primaryBlueColor,
                                                                 font: UIFont.systemMediumFont(ofSize: 12), bgColor: .clear, cornerRadius: 0,
                                                                 withShadow: false)
    
    private var timestampLabel: UILabel = UILabel().configure {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.applyStyle(.regular(size: 12, color: UIColor(hex: 0x808080)))
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    private let commentCountWrapperView: UIStackView = {
        let stack = UIStackView()
        stack.backgroundColor = .white
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .leading
        
        return stack
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12.0, color: AppTheme.warmGrey))
        
        return label
    }()
    
    private let viewCountLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12.0, color: UIColor(hex: 0x808080)))
//        label.textAlignment = .right
//        label.numberOfLines = 2
        return label
    }()
    
    // callback
    var onToolbarItemTapped: ((Int) -> Void)?
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        basicInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        basicInit()
    }
    
    private func basicInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { (m) in
            m.width.equalTo(UIScreen.main.bounds.width)
        }
        self.backgroundColor = .white
        addSubview(contentView)
        contentView.bindToEdges()
        
        primaryLabel.wordWrapped()
        primaryLabel.enabledTypes = [.mention, .hashtag, .url, .custom(pattern: "[@\\s]")]
        primaryLabel.mentionColor = AppTheme.primaryBlueColor
        primaryLabel.hashtagColor = AppTheme.primaryBlueColor
        primaryLabel.URLColor = UIColor(hex: 0x66A8F0)
        primaryLabel.URLSelectedColor = TSColor.main.theme
        primaryLabel.numberOfLines = 0
        primaryLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        primaryLabel.textColor = .black
        primaryLabel.lineSpacing = 6
        primaryLabel.lineBreakMode = .byWordWrapping
        primaryLabel.textAlignment = .left
        primaryLabel.handleURLTap { [weak self] (url) in
            DispatchQueue.main.async {
                self?.deeplink(urlString: url.absoluteString)
            }
            //            TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
            //                DispatchQueue.main.async {
            //                    self?.deeplink(urlString: finalUrl)
            //                }
            //
            //            }
        }
        
        primaryLabel.handleMentionTap { (name) in
            HTMLManager.shared.handleMentionTap(name: name, attributedText: self.htmlAttributedText)
        }
        
        primaryLabel.handleHashtagTap { [weak self] (hashtagString) in
            
//            let vc = RLSearchResultVC()
//            vc.initialSearchType = .feed
//            self?.parentViewController?.navigationController?.pushViewController(vc, animated: true)
//            vc.changeKeyword(keyword: hashtagString.withHashtagPrefix())
//            vc.searchComplete = { [weak self] text in
//    
//            }
            
        }
        
        let toolbarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 45)
        toolbar.leftPadding = 10
        toolbar.set(items: [TSToolbarItemModel(image: "", title: "", index: 0, titleShouldHide: true), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "", index: 1), TSToolbarItemModel(image: "", title: "", index: 2), TSToolbarItemModel(image: "IMG_home_ico_more", title: "", index: 3)], frame: toolbarFrame)
        
        repostView.cardShowType = .listView
        
        contentView.addArrangedSubview(contentStackView)
        //        contentView.addArrangedSubview(toolbar)
        contentView.addArrangedSubview(commentCountWrapperView)
        
        commentCountWrapperView.addArrangedSubview(commentLabel)
        commentCountWrapperView.makeHidden()
        
        
        contentStackView.snp.makeConstraints { (m) in
            m.width.equalTo(UIScreen.main.bounds.width)
        }
        
        //        toolbar.snp.makeConstraints { (m) in
        //            m.top.equalTo(contentStackView.snp.bottom).offset(8)
        //            m.left.equalToSuperview().offset(0)
        //            m.width.equalToSuperview()
        //            m.height.equalTo(45)
        //        }
        
        commentCountWrapperView.snp.makeConstraints { (m) in
            m.left.equalToSuperview().offset(0)
            m.width.equalToSuperview()
            m.height.equalTo(30)
        }
        
        dateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
        
        translateDotView.snp.makeConstraints {
            $0.width.height.equalTo(2)
        }
    }
}

// Open func to update data
extension FeedCommentDetailTableHeaderView {
    func setModel(model: FeedListCellModel) {
        contentStackView.removeAllSubviews()
        self.model = model
        switch model.feedType {
        case .picture:
            self.pictureModels = model.pictures
            loadPictureView(pictures: model.pictures)
        case .video:
            loadVideoView(pictures: model.pictures)
        case .repost:
            loadRepostView(repostId: model.repostId, repostType: model.repostType, repostModel: model.repostModel)
        case .share:
            loadSharedView(sharedModel: model.sharedModel)
        default:
            break
        }
        
        HTMLManager.shared.removeHtmlTag(htmlString: model.content, completion: { [weak self] (content, userIdList) in
            guard let self = self else { return }
            
            self.userIdList = userIdList
            self.originalTexts = content
            self.loadContent(content: content)
            self.loadToolbar(model: model.toolModel, canAcceptReward: model.canAcceptReward == 1 ? true : false, reactionType: model.reactionType)
            self.loadTimeAndLocation(model: model)
            self.contentStackView.addArrangedSubview(self.feedShopView)
            self.feedShopView.snp.makeConstraints { (m) in
                //            m.left.equalToSuperview().offset(10)
                //            m.trailing.equalToSuperview().offset(-10)
                m.height.equalTo(model.rewardsMerchantUsers.count > 1 ? 125 : 110)
            }
            
            //Rewardslink hidden topic view
            //        loadTopic(list: model.topics)
            self.loadViewCount(count: (model.toolModel?.viewCount).orZero)
            self.loadTranslateButton(feedId: model.idindex.stringValue)
            self.loadReactionView(reactionList: model.topReactionList, totalReactions: (model.toolModel?.diggCount).orZero, feedId: model.idindex)
            
            self.feedShopView.isHidden = !(model.rewardsMerchantUsers.count > 0)
            self.feedShopView.setData(merchantList: model.rewardsMerchantUsers)
        })
    }
    
    func setCommentLabel(count: Int?, isCommentDisabled: Bool) {
        if let count = count, count > 0 && isCommentDisabled == false {
            commentCountWrapperView.makeVisible()
            commentLabel.text = count.abbreviated + "comment_counts".localized
            commentLabel.sizeToFit()
            let commentSize = (commentLabel.text?.sizeOfString(usingFont: commentLabel.font))!
            commentLabel.snp.makeConstraints { (m) in
                m.height.equalTo(30)
                m.width.equalTo(commentSize.width + 5)
                m.left.equalToSuperview().offset(10)
            }
        } else {
            commentCountWrapperView.makeHidden()
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    func updateRewardView() {
        guard TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward == true else {
            return
        }
        
        self.toolbar.setTitle((self.model.toolModel?.rewardCount).orZero.abbreviated, At: 2)
        self.toolbar.setImage("ic_reward", At: 2)
    }
    
    func updateReactionView(reactionList: [ReactionTypes?], total: Int) {
        if reactionList.count > 0 {
            reactionView.superview?.makeVisible()
            reactionView.setData(reactionIcon: reactionList, totalReactionCount: total)
        } else {
            reactionView.superview?.makeHidden()
        }
        self.setNeedsLayout()
        self.layoutIfNeeded()
        contentStackView.setNeedsLayout()
        contentStackView.layoutIfNeeded()
    }
}

// UIConfig After Set Data
extension FeedCommentDetailTableHeaderView {
    private func loadViewCount(count: Int) {
        viewCountLabel.text = count.abbreviated + "number_of_browsed".localized
        //translateStackView.addArrangedSubview(viewCountLabel)
        //translateStackView.addArrangedSubview(dateDotView)
    }
    
    private func loadToolbar(model: FeedListToolModel?, canAcceptReward: Bool, reactionType: ReactionTypes?) {
        guard let model = model else { return }
        toolbar.backgroundColor = UIColor.white
        if let reaction = reactionType {
            toolbar.setImage(reaction.imageName, At: 0)
            toolbar.setTitle(reaction.title, At: 0)
            toolbar.setTitleColor(AppTheme.softBlue, At: 0)
        } else {
            toolbar.setImage("IMG_home_ico_love", At: 0)
            toolbar.setTitle("love_reaction".localized, At: 0)
            toolbar.setTitleColor(.black, At: 0)
        }
        // 设置评论按钮
        toolbar.setTitle(model.commentCount.abbreviated, At: 1)
        setCommentLabel(count: model.commentCount, isCommentDisabled: model.isCommentDisabled)
        // 设置打赏量按钮
        //        if canAcceptReward && TSAppConfig.share.localInfo.isOpenReward == true && TSAppConfig.share.localInfo.isFeedReward == true {
        //            toolbar.item(isHidden: false, at: 2)
        //            toolbar.setTitle(model.rewardCount.abbreviated, At: 2)
        //            toolbar.setImage(model.isRewarded ? "ic_reward" : "ic_tip", At: 2)
        //        } else {
        //            toolbar.item(isHidden: true, at: 2)
        //        }
        // Manually disable for Rewards Links
        toolbar.item(isHidden: true, at: 2)
        
        if model.isCommentDisabled == true {
            toolbar.item(isHidden: true, at: 1)
        } else {
            toolbar.item(isHidden: false, at: 1)
        }
        toolbar.delegate = self
    }
    
    private func loadReactionView(reactionList: [ReactionTypes?], totalReactions: Int, feedId: Int) {
        let reactionPaddingView = UIView()
        reactionPaddingView.addSubview(reactionView)
        reactionView.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
        }
        
        reactionView.setData(reactionIcon: reactionList, totalReactionCount: totalReactions)
        reactionView.addTap { [weak self] _ in
            let vc = ReactionController(feedId: feedId)
            self?.parentViewController?.navigationController?.pushViewController(vc, animated: true)
        }
        reactionPaddingView.isHidden = !(reactionList.count > 0)
        contentStackView.addArrangedSubview(reactionPaddingView)
    }
    private func loadTranslateButton(feedId: String) {
        //translateStackView.setContentHuggingPriority(.required, for: .horizontal)
        contentStackView.addArrangedSubview(viewAndTimeContainer)
        
//        translateStackView.addArrangedSubview(timestampLabel)
//        translateStackView.addArrangedSubview(translateDotView)
//        translateStackView.addArrangedSubview(translateButton)
        translateButton.setTitle("button_original".localized, for: .selected)
        translateButton.setTitle("text_translate".localized, for: .normal)
        
        // By Kit Foong (Added checking when no text or only emoji will hide translate button)
        translateButton.isHidden = !TSCurrentUserInfo.share.isLogin || self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
        translateDotView.isHidden = translateButton.isHidden
        //translateButton.isHidden = !TSCurrentUserInfo.share.isLogin
        
        translateButton.addTap { [weak self] (button) in
            guard let self = self, let button = button as? LoadableButton else { return }
            guard button.isSelected == false else {
                self.htmlAttributedText = self.originalTexts.attributonString().setTextFont(14).setlineSpacing(0)
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList)
                }
                self.primaryLabel.attributedText = self.htmlAttributedText
                //self.primaryLabel.text = self.originalTexts
                button.isSelected = false
                self.contentStackView.layoutSubviews()
                self.contentStackView.setNeedsLayout()
                self.contentStackView.layoutIfNeeded()
                self.onTranslated?()
                return
            }
            
            button.showLoader(userInteraction: false)
            
            FeedListNetworkManager.translateFeed(feedId: feedId) { [weak self] (translates) in
                guard let self = self else { return }
                defer { button.hideLoader() }
                button.isSelected = true
                self.translatedTexts = translates
                self.primaryLabel.text = translates
                self.contentStackView.layoutSubviews()
                self.contentStackView.setNeedsLayout()
                self.contentStackView.layoutIfNeeded()
                self.onTranslated?()
            } failure: { (message) in
                defer { button.hideLoader() }
                UIViewController.showBottomFloatingToast(with: "", desc: message)
            }
        }
    }
    
    private func loadTimeAndLocation(model: FeedListCellModel?) {
        // time
        if let timeModel = model?.time {
            let timeStamp = timeModel.timeAgoDisplay(dateFormat: "MMMM dd")
            timestampLabel.text = timeStamp
        }

        guard let locationModel = model?.location else {
            locationView.isHidden = true
            return
        }
        
        let paddingView = UIView()
        self.locationInfo = model?.location
        locationView.removeAllSubViews()
        locationView.isHidden = false
        
        locationView.frame = CGRect(x: 58, y: 0, width: ScreenWidth - 58 - 10, height: 25)
                
        let stackView = UIStackView().configure {
            $0.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 10, height: 20)
            $0.axis = .horizontal
            $0.spacing = 5.0
            $0.center.y = locationView.height / 2
        }
        
        let icon = UIImageView().configure {
            $0.image = UIImage.set_image(named: "ic_location")
            $0.size = CGSize(width: 18, height: 18)
        }
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(18)
        }
        
        let label = UILabel()
        label.text = model?.location?.locationName ?? ""
        label.applyStyle(.regular(size: 12, color: AppTheme.warmGrey))
        
        label.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
        
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(label)
        
        // 确保label的content compression resistance优先级低于timestampLabel
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
        locationView.isUserInteractionEnabled = true
        locationView.addTap(action: { [weak self] (_) in
            guard let locationInfo = self?.locationInfo else { return }
            let locationVC = TSLocationDetailVC(locationID: locationInfo.locationID, locationName: locationInfo.locationName)
            if #available(iOS 11, *) {
                self?.parentViewController?.navigation(navigateType: .pushView(viewController: locationVC))
            } else {
                let nav = TSNavigationController(rootViewController: locationVC).fullScreenRepresentation
                self?.parentViewController?.navigation(navigateType: .presentView(viewController: nav))
            }
        })
        
        locationView.addSubview(stackView)
        
        contentStackView.addArrangedSubview(paddingView)
        paddingView.addSubview(locationView)
        
        let height = locationView.frame.height
        locationView.snp.makeConstraints {
            $0.height.equalTo(height)
            $0.left.equalToSuperview().offset(10)
            $0.top.centerY.centerX.equalToSuperview()
        }
    }
    
    private func loadTopic(list: [TopicListModel]) {
        guard list.count > 0 else { return }
        let paddingContainer = UIView()
        let stackView = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .leading
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for topic in list {
            let tagLabel: UIButton = UIButton(type: .custom)
            tagLabel.backgroundColor = AppTheme.UIColorFromRGB(red: 0, green: 0, blue: 0).withAlphaComponent(0.25)
            tagLabel.setTitleColor(.white, for: .normal)
            tagLabel.layer.cornerRadius = 3
            tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            tagLabel.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            tagLabel.setTitle(topic.topicTitle, for: .normal)
            tagLabel.isUserInteractionEnabled = true
            tagLabel.addTap { [weak self] (_) in
                let topicVC = TopicPostListVC(groupId: topic.topicId)
                if #available(iOS 11, *) {
                    self?.parentViewController?.navigation(navigateType: .pushView(viewController: topicVC))
                } else {
                    let nav = TSNavigationController(rootViewController: topicVC).fullScreenRepresentation
                    self?.parentViewController?.navigation(navigateType: .presentView(viewController: nav))
                }
            }
            stackView.addArrangedSubview(tagLabel)
        }
        guard stackView.subviews.count > 0 else { return }
        stackView.addArrangedSubview(UIView())
        contentStackView.addArrangedSubview(paddingContainer)
        
        paddingContainer.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.centerX.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
        }
    }
    
    private func loadPictureView(pictures: [PaidPictureModel]) {
        multiplePicturePageController.delegate = self
        multiplePicturePageController.dataSource = self
        multiplePicturePageControl.numberOfPages = pictures.count
        multiplePicturePageControl.pageIndicatorTintColor = AppTheme.brownGrey
        multiplePicturePageControl.currentPageIndicatorTintColor = .white
        
        pictureView.models = [pictures[0]]
        let frame = pictureView.frame
        
        multiplePictureView = MultiplePictureViewController(currentIndex: 0, pictureModel: pictures[0])
        multiplePictureView.onPictureViewTapped = { [weak self] (trellis, tappedIndex, transitionID) in
            self?.pictureView.onTapPictureView?(trellis, tappedIndex, transitionID)
        }
        
        if let viewControllers = multiplePicturePageController.viewControllers, viewControllers.isEmpty {
            if !isTrasitioningBetweenPage {
                multiplePicturePageController.setViewControllers([multiplePictureView], direction: .forward, animated: true, completion: nil)
            }
        }
        
        let containerView = UIView()
        containerView.addSubview(multiplePicturePageController.view)
        multiplePicturePageController.view.didMoveToSuperview()
        multiplePicturePageController.view.bindToEdges()
        containerView.addSubview(multiplePicturePageControl)
        multiplePicturePageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().offset(-5)
        }
        
        contentStackView.addArrangedSubview(containerView)
        containerView.snp.makeConstraints {
            $0.width.height.equalTo(frame.width)
            
        }
        multiplePicturePageControl.isHidden = pictures.count < 2
    }
    private func loadVideoView(pictures: [PaidPictureModel]) {
        let imageObj = pictures.map({ $0.imageObject() })
        let images = imageObj.filter { (object) -> Bool in
            return object.width > 0 && object.height > 0
        }
        
        let image = images[0]
        
        contentStackView.addArrangedSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints { (m) in
            m.width.equalToSuperview()
            m.height.equalTo(videoPlayerView.snp.width)
        }
        
    }
    
    private func loadSharedView(sharedModel: SharedViewModel?) {
        guard let sharedModel = sharedModel else { return }
        
        let paddingView = UIView()
        
        switch sharedModel.type {
        case .sticker:
            paddingView.addSubview(feedSharedView)
            feedSharedView.translatesAutoresizingMaskIntoConstraints = false
            contentStackView.addArrangedSubview(paddingView)
            contentStackView.layoutSubviews()
            feedSharedView.updateUI(model: sharedModel)
            
            feedSharedView.didTapCardBlock = { [weak self] in
                guard let self = self else { return }
                guard let attachment = sharedModel.customAttachment else { return }
                let feedId = attachment.attachId
                
                // 如果是游客模式，触发登录注册操作
                if TSCurrentUserInfo.share.isLogin == false {
                    TSRootViewController.share.guestJoinLandingVC()
                    return
                }
                let stickerDetail = StickerDetailViewController(bundleId: feedId.stringValue)
                self.parentViewController?.navigation(navigateType: .pushView(viewController: stickerDetail))
            }
            // 设置短链接点击事件
            feedSharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?.parentViewController?.navigation(navigateType: .pushURL(url: _url))
                    }
                    
                }
            }
            // 点击at某人
            feedSharedView.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                let uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)])
                TSUtil.pushUserHomeName(name: uname)
            }
            
            feedSharedView.snp.remakeConstraints {
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(10)
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(100)
            }
            
        case .metadata:
            guard let link = sharedModel.url else { return }
            // By Kit Foong (Hide Metadata for deeplink)
            var isDeepLink = TSUtil.checkIsDeepLink(urlString: link)
            if isDeepLink { return }
            
            // feedSharedView.translatesAutoresizingMaskIntoConstraints = false
            paddingView.addSubview(feedSharedView)
            contentStackView.addArrangedSubview(paddingView)
            feedSharedView.updateUI(model: sharedModel)
            feedSharedView.layoutSubviews()
            feedSharedView.didTapCardBlock = { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: link) else { return }
                self.parentViewController?.navigation(navigateType: .pushURL(url: url))
            }
            // 设置短链接点击事件
            feedSharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?.parentViewController?.navigation(navigateType: .pushURL(url: _url))
                    }
                    
                }
            }
            // 点击at某人
            feedSharedView.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                let uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)])
                TSUtil.pushUserHomeName(name: uname)
            }
            
            feedSharedView.snp.remakeConstraints {
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(10)
                $0.left.right.equalToSuperview().inset(12)
                $0.height.equalTo(feedSharedView.snp.width).multipliedBy(0.6)
            }
            
        default:
            paddingView.addSubview(sharedView)
            contentStackView.addArrangedSubview(paddingView)
            sharedView.updateUI(model: sharedModel)
            sharedView.didTapCardBlock = { [unowned self] in
                guard let attachment = sharedModel.customAttachment else { return }
                let feedId = attachment.attachId
                switch sharedModel.type {
                case .live:
                    self.parentViewController?.navigateLive(feedId: feedId)
                case .user:
                    FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: feedId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//                    let vc = HomePageViewController(userId: feedId)
//                    self.parentViewController?.navigation(navigateType: .pushView(viewController: vc))
                case .miniProgram:
                    guard TSCurrentUserInfo.share.isLogin else {
                        TSRootViewController.share.guestJoinLandingVC()
                        return
                    }
                    let extra = sharedModel.extra?.toDictionary
                    let appId = extra?["appId"] as? String ?? ""
                    let path = extra?["path"] as? String ?? ""
                   // guard let parentVC = self.parentViewController else { return }
                  //  miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: parentVC)
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: path)
                case .miniVideo:
                    self.parentViewController?.navigation(navigateType: .miniVideo(feedListType: .detail(feedId: feedId), currentVideo: nil, onToolbarUpdated: (self.parentViewController as? BaseFeedController)?.onToolbarUpdate))
                default:
                    break
                }
            }
            // 设置短链接点击事件
            sharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?.parentViewController?.navigation(navigateType: .pushURL(url: _url))
                    }
                    
                }
            }
            // 点击at某人
            sharedView.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                //                    let uname = name.substring(to: name.index(name.startIndex, offsetBy: name.count - 1))
                let index = name.endIndex
                let uname = String(name[..<index])
                TSUtil.pushUserHomeName(name: uname)
            }
            
            sharedView.snp.remakeConstraints {
                $0.bottom.equalToSuperview()
                $0.top.equalToSuperview().offset(10)
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(100)
            }
            
        }
    }
    
    private func loadRepostView(repostId: Int, repostType: String?, repostModel: TSRepostModel?) {
        guard let repostModel = repostModel, repostId > 0 else { return }
        
        let paddingView = UIView()
        repostViewBgView.removeAllSubViews()
        
        contentStackView.addArrangedSubview(paddingView)
        repostViewBgView.makeVisible()
        let contentWidth = UIScreen.main.bounds.width - 71
        paddingView.addSubview(repostViewBgView)
        repostViewBgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(0)
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(repostView.getSuperViewHeight(model: repostModel, superviewWidth: contentWidth))
        }
        repostModel.updataModelType()
        repostViewBgView.addSubview(repostView)
        repostView.updateUI(model: repostModel)
        
        repostView.didTapCardBlock = { [weak self] in
            guard let self = self else { return }
            
            let toolbarUpdateHandler = (self.parentViewController as? FeedInfoDetailViewController)?.onToolbarUpdated
            switch repostModel.type {
            case .postURL:
                guard let content = repostModel.content, let url = URL(string: content) else { return }
                self.parentViewController?.navigation(navigateType: .pushURL(url: url))
                
            case .postLive, .postVideo:
                self.parentViewController?.navigateLive(feedId: repostModel.id)
                
            case .postMiniVideo:
                self.parentViewController?.navigation(navigateType: .miniVideo(feedListType: .detail(feedId: repostModel.id), currentVideo: nil, onToolbarUpdated: toolbarUpdateHandler))
                
            case .postMiniProgram:
                let extra = repostModel.extra?.toDictionary
                if let appId = extra?["appId"] as? String, let path = extra?["path"] as? String, let parentVC = self.parentViewController {
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: path)
                   // miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: parentVC)
                } else {
                    self.parentViewController?.showTopFloatingToast(with: "please_retry_option".localized, desc: "")
                }
                break
                
            case .postImage:
                self.parentViewController?.navigation(navigateType: .innerFeedSingle(feedId: repostModel.id, placeholderImage: self.repostView.coverImageView.image, transitionId: UUID().uuidString, imageId: 0))
                
            default:
                let detailVC = FeedInfoDetailViewController(feedId: repostModel.id, onToolbarUpdated: toolbarUpdateHandler )
                self.parentViewController?.navigation(navigateType: .pushView(viewController: detailVC))
            }
            
        }
        
        //             设置短链接点击事件
        repostView.contentLab.handleURLTap { [weak self] (url) in
            TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                guard let _url = URL(string: finalUrl) else { return }
                DispatchQueue.main.async {
                    self?.parentViewController?.navigation(navigateType: .pushURL(url: _url))
                }
                
            }
        }
        // 点击at某人
        repostView.contentLab.handleMentionTap { (name) in
            /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
            let uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)])
            TSUtil.pushUserHomeName(name: uname)
        }
    }
    
    private func loadContent(content: String) {
        if content.isURL() {
            primaryLabel.text = content.getUrlStringFromString()
        }
        
        htmlAttributedText = content.attributonString().setTextFont(14).setlineSpacing(0)
        if let attributedText = htmlAttributedText {
            htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList)
        }
        primaryLabel.attributedText = htmlAttributedText
        
        let paddingContainer = UIView()
        paddingContainer.addSubview(primaryLabel)
        primaryLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.right.equalToSuperview().inset(10)
        }
        primaryLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        contentStackView.addArrangedSubview(paddingContainer)
        if content.isEmpty == true {
            paddingContainer.makeHidden()
        } else {
            paddingContainer.makeVisible()
        }
    }
}

extension FeedCommentDetailTableHeaderView: TSToolbarViewDelegate {
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        self.onToolbarItemTapped?(index)
    }
}

// MARK: - Multi Picture Page View Delegate
extension FeedCommentDetailTableHeaderView: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let newIndex = ((viewController as? MultiplePictureViewController)?.index).orZero  - 1
        guard newIndex >= 0 && newIndex < pictureModels.count else { return nil}
        
        let newVC = MultiplePictureViewController(currentIndex: newIndex, pictureModel: pictureModels[newIndex])
        newVC.onPictureViewTapped = { [weak self] (trellis, _, transitionID) in
            self?.pictureView.onTapPictureView?(trellis, newIndex, transitionID)
        }
        
        return newVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let newIndex = ((viewController as? MultiplePictureViewController)?.index).orZero + 1
        guard newIndex >= 0, newIndex < self.pictureModels.count else { return nil }
        
        let newVC = MultiplePictureViewController(currentIndex: newIndex, pictureModel: pictureModels[newIndex])
        newVC.onPictureViewTapped = { [weak self] (trellis, _, transitionID) in
            self?.pictureView.onTapPictureView?(trellis, newIndex, transitionID)
        }
        
        return newVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let selectedVC = pageViewController.viewControllers?.first as? MultiplePictureViewController else { return }
        multiplePicturePageControl.currentPage = selectedVC.index
        if completed {
            isTrasitioningBetweenPage = false
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        isTrasitioningBetweenPage = true
    }
}

