//
//  FeedContentView.swift
//  Yippi
//
//  Created by francis on 01/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import ActiveLabel
import Lottie
import Toast

import FLAnimatedImage
import SDWebImage
import SwiftyJSON
import UIKit
import AVFoundation


class FeedContentView: UIView {
    
    weak var navigator: UIViewController?
    private weak var locationInfo : TSPostLocationModel?
    let toolbar = TSToolbarView(type: .left)
    var onTapToolbarItemAtIndex: ((_ index: Int) -> Void)?
    /// 是否需要隐藏发布时间
    var isNeedHideTime: Bool = false {
        didSet{
            if isNeedHideTime == true{
                //隐藏列表页面的时间
                timepaddingView.isHidden = true
            }else{
                timepaddingView.isHidden = false
            }
        }
    }
    
    @IBOutlet weak var toolbarTopLine: UIView!
    @IBOutlet var bottomLine: UIView!
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak private var avatarView: UIView!
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak var followButton: FollowButton!
    private var primaryLabel: ActiveLabel! = ActiveLabel()
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var sponsorLabel: UILabel!
    
    
    private var originalTexts: String = ""
    private var translatedTexts: String? = nil
    
    private lazy var timeWrapperView: UIView = {
        let wrapper = UIView()
        wrapper.addSubview(timeStackView)
        timeStackView.snp.makeConstraints { (v) in
            v.top.bottom.equalToSuperview()
            v.left.equalToSuperview().inset(10)
            v.right.lessThanOrEqualToSuperview()
        }
        
        return wrapper
    }()
    private lazy var timeStackView: UIStackView = {
        let stackview = UIStackView().build { (v) in
            v.spacing = 5
            v.distribution = .fill
            v.alignment = .fill
            v.axis = .horizontal
        }
        return stackview
    }()
    
    let timepaddingView = UIView()
    private var translateButton: LoadableButton = LoadableButton(frame: .zero, icon: nil,
                                                                 text: "text_translate".localized, textColor: AppTheme.primaryBlueColor,
                                                                 font: UIFont.systemMediumFont(ofSize: 12), bgColor: .clear, cornerRadius: 0,
                                                                 withShadow: false)
    
    private var timestampLabel: UILabel = UILabel().configure {
        $0.setContentHuggingPriority(.required, for: .horizontal)
        $0.applyStyle(.regular(size: 12, color: UIColor.lightGray))
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    @IBOutlet weak var contentstackView: UIStackView!
    private var resendButton = FeedResendButton()
    private var avatar = AvatarView(origin: .zero, type: AvatarType.width38(showBorderLine: false), animation: true)
    private let topIcon = UIImageView()
    private let liveIcon = FLAnimatedImageView()
    var pictureView = PicturesTrellisView()
    var multiplePictureView = MultiplePictureViewController(currentIndex: 0, pictureModel: PaidPictureModel())
    var multiplePicturePageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private var multiplePicturePageControl = UIPageControl()
    private var isTrasitioningBetweenPage = false
    
    lazy var videoPlayer = FeedPlayerView()
    private var parentFeedListCell: FeedListCell?
    private var locationView = UIView()
    private var repostViewBgView = UIView()
    private var repostView = TSRepostView()
    private var sharedView = TSRepostView()
    private var feedSharedView = TSFeedRePostView()
    private var pictureModels: [PaidPictureModel] = []
    private lazy var reactionView = UserReactionView()
    
    var onUpdateTranslateText: ((String, Bool, Int) -> Void)?
    var updateCellLayout: EmptyClosure?
    
    var parentVC: UIViewController?
    private var _parentViewController: UIViewController? {
        get {
            return self.parentVC ?? self.parentViewController
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func clearResendButton () {
        resendButton.isHidden = true
    }
    
    func remakeAvatarViewContraint() {
        self.avatarView.snp.remakeConstraints { (make) in
            make.top.left.equalToSuperview().inset(16)
            make.width.height.equalTo(38)
        }
        self.layoutIfNeeded()
    }
    
    // By Kit Foong (Adjust primary label constraint)
    func remakePrimaryLabelViewContraint(isTranslate: Bool = false) {
        self.primaryLabel.snp.remakeConstraints { (make) in
            if isTranslate {
                make.top.equalToSuperview().inset(2)
                make.bottom.equalToSuperview().inset(8)
            } else {
                make.top.bottom.equalToSuperview().inset(8)
            }
            make.left.right.equalToSuperview().inset(10)
        }
        
        self.timeStackView.snp.makeConstraints { (v) in
            if isTranslate {
                v.top.equalToSuperview()
                v.bottom.equalToSuperview().inset(2)
            } else {
                v.top.bottom.equalToSuperview()
            }
            v.left.equalToSuperview().inset(10)
            v.right.lessThanOrEqualToSuperview()
        }
        self.layoutIfNeeded()
    }
    
    private func updateMultiplePictureView(pictures: [PaidPictureModel]) {
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
        
        if !isTrasitioningBetweenPage {
            multiplePicturePageController.setViewControllers([multiplePictureView], direction: .forward, animated: true, completion: nil)
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
        
        contentstackView.addArrangedSubview(containerView)
        containerView.snp.makeConstraints {
            $0.width.height.equalTo(frame.width)
        }
    }
    
    private func updatePictureView(pictures: [PaidPictureModel], videoURL: String, localVideoFileURL: String?, liveModel: LiveEntityModel?, status: Int, isMiniVideo: Bool) {
        
        if liveModel != nil && status == 1 {
            pictureView.isUseVideoFrameRule = false
            
            pictureView.models = pictures // 内部计算 size
            
            contentstackView.addArrangedSubview(pictureView)
            
            pictureView.snp.updateConstraints {
                $0.height.equalTo(pictureView.frame.height)
            }
            
            liveIcon.sd_setImage(with: Bundle.main.url(forResource: "white-animation", withExtension: ".gif"), completed: nil)
            liveIcon.makeVisible()
            pictureView.addSubview(liveIcon)
            liveIcon.snp.makeConstraints { (make) in
                make.top.right.equalToSuperview().inset(10)
                make.width.height.equalTo(25)
            }
        } else {
            pictureView.isUseVideoFrameRule = true
            
            liveIcon.makeHidden()
            var url: URL?
            url = URL(string: videoURL)
            if let fileURL = localVideoFileURL {
                let filePath = TSUtil.getWholeFilePath(name: fileURL)
                url = URL(fileURLWithPath: filePath)
            }
            guard let url = url, let thumbnail = pictures.first else {
                pictureView.isUseVideoFrameRule = false
                pictureView.models = pictures // 内部计算 size
                contentstackView.addArrangedSubview(pictureView)
                pictureView.snp.updateConstraints {
                    $0.height.equalTo(pictureView.frame.height)
                }
                return
            }
            
            let avPlayer = AVPlayer(url: url)
            videoPlayer.backgroundColor = .black
            videoPlayer.videoView.player = avPlayer
            
            videoPlayer.thumbnail.sd_setImage(with: URL(string: thumbnail.url.orEmpty), completed: nil)
            
            var height = UIScreen.main.bounds.width * 5 / 4
            if !isMiniVideo {
                let ratioHeight = thumbnail.originalSize.height * UIScreen.main.bounds.width / thumbnail.originalSize.width
                height = min(height, ratioHeight)
            }
            
            videoPlayer.thumbnail.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: height))
            videoPlayer.videoView.playerLayer?.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: height))
            contentstackView.addArrangedSubview(videoPlayer)
            videoPlayer.snp.updateConstraints {
                $0.height.equalTo(height)
            }
            videoPlayer.showMiniVideoIcon(isMiniVideo)
            videoPlayer.layoutIfNeeded()
        }
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FeedContentView", owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(contentView)
        // By Kit Foong (Added this for content stack view to manage subview space)
        contentstackView.distribution = .fill
        avatarView.addSubview(avatar)
        avatar.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        primaryLabel.wordWrapped()
        primaryLabel.enabledTypes = [.mention, .hashtag, .url]
        primaryLabel.mentionColor = AppTheme.primaryBlueColor
        primaryLabel.hashtagColor = AppTheme.primaryBlueColor
        primaryLabel.URLColor = UIColor(hex: 0x66A8F0)
        primaryLabel.URLSelectedColor = AppTheme.red
        primaryLabel.textColor = .black
        primaryLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        primaryLabel.textAlignment = .left
        primaryLabel.handleURLTap { [weak self] (url) in
            self?.deeplink(urlString: url.absoluteString)
            //            TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
            //                guard let _url = URL(string: finalUrl) else { return }
            //                DispatchQueue.main.async {
            //                    self?._parentViewController?.navigation(navigateType: .pushURL(url: _url))
            //                }
            //
            //            }
        }
        
        primaryLabel.handleMentionTap { (name) in
            let uname = String(name[..<name.index(name.startIndex, offsetBy: name.count - 1)])
            TSUtil.pushUserHomeName(name: uname)
        }
        
        primaryLabel.handleHashtagTap { [weak self] (hashtagString) in
//            let vc = GlobalSearchResultViewController()
//            vc.searchText.text = hashtagString.withHashtagPrefix()
//            vc.initialSearchType = .momments
//            vc.canCloseView = true
//            self?._parentViewController?.navigation(navigateType: .presentView(viewController: TSNavigationController(rootViewController: vc).fullScreenRepresentation))
        }
        
        sponsorLabel.text = "sponsored".localized
        
        let toolbarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 20, height: 45)
        
        toolbar.set(items: [TSToolbarItemModel(image: "", title: "", index: 0, titleShouldHide: true), TSToolbarItemModel(image: "IMG_home_ico_comment_normal", title: "", index: 1), TSToolbarItemModel(image: "", title: "", index: 2), TSToolbarItemModel(image: "IMG_home_ico_more", title: "", index: 3)], frame: toolbarFrame)
        
        bottomLine.backgroundColor = TSColor.inconspicuous.background
        toolbarTopLine.backgroundColor = TSColor.inconspicuous.background
        
        resendButton.setTitleColor(TSColor.normal.minor, for: .normal)
        resendButton.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.keyboardRight.rawValue)
        let image = UIImage.set_image(named: "IMG_msg_box_remind")
        resendButton.setImage(image, for: .normal)
        resendButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0 )
        resendButton.titleEdgeInsets = UIEdgeInsets(top: 0, left :0, bottom: 0 , right :0)
        resendButton.backgroundColor = TSColor.inconspicuous.background
        resendButton.titleLabel?.numberOfLines = 0
        resendButton.titleLabel?.lineBreakMode = .byWordWrapping
        resendButton.isHidden = true
        resendButton.layer.cornerRadius = 10
        resendButton.clipsToBounds = true
        
        let flippedTopIconImage = UIImage.set_image(named: "ic_home_pintotop")?.withHorizontallyFlippedOrientation()
        topIcon.image = flippedTopIconImage
        contentView.addSubview(topIcon)
        topIcon.isHidden = true
        
        bottomStackView.addArrangedSubview(toolbar)
        bottomStackView.addArrangedSubview(resendButton)
        
        repostView.cardShowType = .listView
        toolbar.snp.updateConstraints {
            $0.height.equalTo(toolbar.height)
        }
        
        bottomLine.snp.updateConstraints {
            $0.height.equalTo(10)
        }
        
        toolbarTopLine.snp.updateConstraints {
            $0.height.equalTo(1)
        }
        toolbarTopLine.makeHidden()
        
        resendButton.snp.makeConstraints {
            $0.leading.equalToSuperview()
        }
        
        topIcon.snp.makeConstraints {
            $0.top.equalTo(followButton)
            $0.trailing.equalTo(followButton.snp.leading).offset(-10)
        }
    }
    
    func showToast(_ message: String) {
        DispatchQueue.main.async {
            self.makeToast(message, duration: 2.0, position: CSToastPositionCenter)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.primaryLabel.width > 0 else { return }
        updateTexts()
        didLayoutSubview = true
    }
    
    var didLayoutSubview = false
    
    func updateTranslateText(_ isTranslate: Bool, _ feedId: Int) {
        if isTranslate {
            FeedListNetworkManager.translateFeed(feedId: feedId.stringValue) { [weak self] (translates) in
                guard let self = self else { return }
                self.translatedTexts = translates
                self.onUpdateTranslateText?(translates, true, feedId)
                DispatchQueue.main.async {
                    self.translateButton.isSelected = true
                    self.updateTexts()
                    self.onUpdateTranslateText?(self.translatedTexts.orEmpty, true, feedId)
                }
            } failure: { (message) in
                UIViewController.showBottomFloatingToast(with: "", desc: message)
            }
        } else {
            self.translateButton.isSelected = false
            self.updateTexts()
            self.onUpdateTranslateText?(self.translatedTexts.orEmpty, false, feedId)
        }
    }
    
    private func updateTexts() {
        if translateButton.isSelected {
            self.primaryLabel.shortenedText(with: translatedTexts.orEmpty, maxlines: 5)
        } else {
            self.primaryLabel.shortenedText(with: originalTexts, maxlines: 5)
        }
    }
    
    private func loadStrings(with name: String) {
        nameLabel.text = name
        
        if originalTexts.isURL() {
            self.primaryLabel.text = originalTexts
        }
        
        let paddingContainer = UIView()
        paddingContainer.addSubview(primaryLabel)
        primaryLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.left.right.equalToSuperview().inset(10)
        }
        primaryLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        contentstackView.addArrangedSubview(paddingContainer)
        if originalTexts.isEmpty == true {
            paddingContainer.makeHidden()
        } else {
            paddingContainer.makeVisible()
        }
    }
    
    private func loadTopIcon(shouldShowTopIcon: Bool) {
        topIcon.isHidden = !shouldShowTopIcon
    }
    
    private func loadFollowButton(userModel: UserInfoModel?) {
        guard let userModel = userModel else {
            followButton.isHidden = true
            return
        }
        
        followButton.backgroundColor = AppTheme.UIColorFromRGB(red: 59, green: 179, blue: 255)
        followButton.roundCorner(followButton.frame.height/2)
        let followStatus = userModel.follower
        if let relation = userModel.relationshipWithCurrentUser {
            switch relation.status {
            case .oneself:
                followButton.isHidden = true
            default:
                if followStatus == false {
                    followButton.isHidden = false
                } else {
                    followButton.isHidden = true
                }
            }
        }
        else {
            followButton.isHidden = false
        }
    }
    
    func updateFollowButton(_ status: FollowStatus) {
        followButton.isHidden = status != .unfollow
    }
    
    private func loadAvatar(with info: AvatarInfo?) {
        guard let info = info else { return }
        avatar.avatarInfo = info
        guard let userId = info.type.userId else { return }
        topView.addTap { (_) in
            NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userId])
        }
    }
    
    private func loadAttachment(feedContentType: FeedContentType, pictures: [PaidPictureModel], videoURL: String, localVideoFileURL: String?, liveModel: LiveEntityModel?, status: Int) {
        
        switch feedContentType {
        case .picture:
            if pictures.count < 2 {
                fallthrough
            } else {
                self.pictureModels = pictures
                updateMultiplePictureView(pictures: pictures)
            }
        case .video:
            fallthrough
        case .live:
            guard  pictures.count > 0 else { return }
            updatePictureView(pictures: pictures, videoURL: videoURL, localVideoFileURL: localVideoFileURL, liveModel: liveModel, status: status, isMiniVideo: false)
        case .miniVideo:
            guard  pictures.count > 0 else { return }
            updatePictureView(pictures: pictures, videoURL: videoURL, localVideoFileURL: localVideoFileURL, liveModel: liveModel, status: status, isMiniVideo: true)
            
        default:
            break
        }
    }
    
    func loadToolbar(model: FeedListToolModel?, canAcceptReward: Bool, reactionType: ReactionTypes?) {
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
    
    func updateRewardItem(_ model: FeedListToolModel?) {
        guard let model = model else { return }
        toolbar.setTitle(model.rewardCount.abbreviated, At: 2)
        toolbar.setImage(model.isRewarded ? "ic_reward" : "ic_tip", At: 2)
    }
    
    private func loadLocation(model: TSPostLocationModel?) {
        guard let model = model else {
            locationView.isHidden = true
            return
        }
        let paddingView = UIView()
        self.locationInfo = model
        locationView.removeAllSubViews()
        locationView.isHidden = false
        
        locationView.frame = CGRect(x: 58, y: 0, width: ScreenWidth - 58 - 10, height: 25)
        
        let icon = UIImageView().configure {
            $0.image = UIImage.set_image(named: "ic_location")
            $0.size = CGSize(width: 25, height: 14)
        }
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(14)
        }
        
        let label = UILabel()
        label.text = model.locationName
        label.applyStyle(.regular(size: 12, color: AppTheme.warmGrey))
        
        label.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
        
        let stackView = UIStackView().configure {
            $0.frame = CGRect(x: 0, y: 0, width: ScreenWidth - 58 - 10, height: 14)
            $0.axis = .horizontal
            $0.spacing = 5.0
            $0.center.y = locationView.height/2
        }
        
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(label)
        locationView.isUserInteractionEnabled = true
        locationView.addTap(action: { [weak self] (_) in
            guard let locationInfo = self?.locationInfo else { return }
            let locationVC = TSLocationDetailVC(locationID: locationInfo.locationID, locationName: locationInfo.locationName)
            let nav = TSNavigationController(rootViewController: locationVC).fullScreenRepresentation
            locationVC.setCloseButton(backImage: true)
            self?._parentViewController?.navigation(navigateType: .presentView(viewController: nav))
        })
        locationView.addSubview(stackView)
        
        
        contentstackView.addArrangedSubview(paddingView)
        
        paddingView.addSubview(locationView)
        let height = locationView.frame.height
        locationView.snp.makeConstraints {
            $0.height.equalTo(height)
            $0.left.equalToSuperview().offset(10)
            $0.top.centerY.centerX.equalToSuperview()
        }
    }
    
    private func loadRepostView(repostId: Int, repostType: String?, repostModel: TSRepostModel?) {
        guard let repostModel = repostModel, repostId > 0 else { return }
        
        let paddingView = UIView()
        repostViewBgView.removeAllSubViews()
        
        contentstackView.addArrangedSubview(paddingView)
        repostViewBgView.makeVisible()
        let contentWidth = UIScreen.main.bounds.width - 71
        paddingView.addSubview(repostViewBgView)
        repostViewBgView.snp.makeConstraints {
            $0.center.top.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.height.equalTo(repostView.getSuperViewHeight(model: repostModel, superviewWidth: contentWidth))
        }
        repostModel.updataModelType()
        repostViewBgView.addSubview(repostView)
        repostView.updateUI(model: repostModel)
        
        repostView.didTapCardBlock = { [weak self] in
            guard let self = self else { return }
            
            let updateToolbarHandler = (self.parentViewController as? BaseFeedController)?.onToolbarUpdate
            switch repostModel.type {
            case .postURL:
                guard let content = repostModel.content, let url = URL(string: content) else { return }
                self._parentViewController?.navigation(navigateType: .pushURL(url: url))
                
            case .postLive, .postVideo:
                self.liveChecker(repostModel.id)
                
            case .postMiniVideo:
                self._parentViewController?.navigation(navigateType: .miniVideo(feedListType: .detail(feedId: repostModel.id), currentVideo: nil, onToolbarUpdated: updateToolbarHandler))
                
            case .postMiniProgram:
                let extra = repostModel.extra?.toDictionary
                if let appId = extra?["appId"] as? String, let path = extra?["path"] as? String, let parentVC = self._parentViewController {
                   // miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: parentVC)
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: path)
                } else {
                    self._parentViewController?.showTopFloatingToast(with: "please_retry_option".localized, desc: "")
                }
                break
                
            case .postImage:
                self._parentViewController?.navigation(navigateType: .innerFeedSingle(feedId: repostModel.id, placeholderImage: self.repostView.coverImageView.image, transitionId: UUID().uuidString, imageId: 0))
                
            default:
                let detailVC = FeedInfoDetailViewController(feedId: repostModel.id, onToolbarUpdated: updateToolbarHandler )
                self._parentViewController?.navigation(navigateType: .pushView(viewController: detailVC))
            }
            
        }
        
        //             设置短链接点击事件
        repostView.contentLab.handleURLTap { [weak self] (url) in
            TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                guard let _url = URL(string: finalUrl) else { return }
                DispatchQueue.main.async {
                    self?._parentViewController?.navigation(navigateType: .pushURL(url: _url))
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
    
    private func loadSharedView(sharedModel: SharedViewModel?) {
        guard let sharedModel = sharedModel else { return }
        
        let paddingView = UIView()
        
        switch sharedModel.type {
        case .sticker:
            paddingView.addSubview(feedSharedView)
            feedSharedView.translatesAutoresizingMaskIntoConstraints = false
            contentstackView.addArrangedSubview(paddingView)
            contentstackView.layoutSubviews()
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
                stickerDetail.setCloseButton(backImage: true)
                self._parentViewController?.navigation(navigateType: .pushView(viewController: stickerDetail))
            }
            // 设置短链接点击事件
            feedSharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?._parentViewController?.navigation(navigateType: .pushURL(url: _url))
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
                $0.top.bottom.equalToSuperview()
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(100)
            }
            
        case .metadata:
            guard let link = sharedModel.url else { return }
            // By Kit Foong (Hide Metadata for deeplink)
            var isDeepLink = TSUtil.checkIsDeepLink(urlString: link)
            if isDeepLink { return }
            
            paddingView.addSubview(feedSharedView)
            contentstackView.addArrangedSubview(paddingView)
            feedSharedView.updateUI(model: sharedModel)
            feedSharedView.layoutSubviews()
            feedSharedView.didTapCardBlock = { [weak self] in
                guard let self = self else { return }
                guard let url = URL(string: link) else { return }
                self._parentViewController?.navigation(navigateType: .pushURL(url: url))
            }
            // 设置短链接点击事件
            feedSharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?._parentViewController?.navigation(navigateType: .pushURL(url: _url))
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
                $0.top.bottom.equalToSuperview()
                $0.left.right.equalToSuperview().inset(12)
                $0.height.equalTo(feedSharedView.snp.width).multipliedBy(0.6)
            }
            
        default:
            paddingView.addSubview(sharedView)
            contentstackView.addArrangedSubview(paddingView)
            sharedView.updateUI(model: sharedModel)
            sharedView.didTapCardBlock = { [unowned self] in
                guard let attachment = sharedModel.customAttachment else { return }
                let feedId = attachment.attachId
                switch sharedModel.type {
                case .live:
                    self.liveChecker(feedId)
                case .user:
                    FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: feedId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
//                    let vc = HomePageViewController(userId: feedId)
//                    self._parentViewController?.navigation(navigateType: .pushView(viewController: vc))
                case .miniProgram:
                    guard TSCurrentUserInfo.share.isLogin else {
                        TSRootViewController.share.guestJoinLandingVC()
                        return
                    }
                    let extra = sharedModel.extra?.toDictionary
                    let appId = extra?["appId"] as? String ?? ""
                    let path = extra?["path"] as? String ?? ""
                    guard let parentVC = self._parentViewController else { return }
                    FeedIMSDKManager.shared.delegate?.didOpenMiniProgram(appId: appId, path: path)
//                    miniProgramExecutor.startApplet(type: .normal(appId: appId), param: ["path": path], parentVC: parentVC)
                case .miniVideo:
                    self._parentViewController?.navigation(navigateType: .miniVideo(feedListType: .detail(feedId: feedId), currentVideo: nil, onToolbarUpdated: (self.parentViewController as? BaseFeedController)?.onToolbarUpdate))
                default:
                    break
                }
            }
            // 设置短链接点击事件
            sharedView.contentLab.handleURLTap { [weak self] (url) in
                TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
                    guard let _url = URL(string: finalUrl) else { return }
                    DispatchQueue.main.async {
                        self?._parentViewController?.navigation(navigateType: .pushURL(url: _url))
                    }
                    
                }
            }
            // 点击at某人
            sharedView.contentLab.handleMentionTap { (name) in
                /// 获取到的是name+一个看不见的分隔符号，所以需要把尾部的分隔符号移除
                let index = name.endIndex
                let uname = String(name[..<index])
                TSUtil.pushUserHomeName(name: uname)
            }
            
            sharedView.snp.remakeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.left.right.equalToSuperview().inset(10)
                $0.height.equalTo(100)
            }
            
        }
    }
    
    private func loadTopics(with list: [TopicListModel]) {
        
        guard list.count > 0 else { return }
        let paddingContainer = UIView()
        let stackView = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .leading
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for topic in list {
            let tagLabel: UIButton = UIButton(type: .custom)
            tagLabel.backgroundColor = UIColor(hexString: "#BAE6FF")
            tagLabel.setTitleColor(UIColor(hexString: "#19AAFE"), for: .normal)
            tagLabel.layer.cornerRadius = 8.5
            tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            tagLabel.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            tagLabel.setTitle(" " + topic.topicTitle + " ", for: .normal)
            tagLabel.isUserInteractionEnabled = true
            tagLabel.addTap { [weak self] (_) in
                //                guard let self = self, let feedListCell = self.parentFeedListCell, let feedListCellDelegate = self.feedListCellDelegate else { return }
                //                feedListCellDelegate.feedCellDidClickTopic?(feedListCell, topicId: topic.topicId)
                self?.videoPlayer.pause()
                let topicVC = TopicPostListVC(groupId: topic.topicId)
                if #available(iOS 11, *) {
                    self?._parentViewController?.navigation(navigateType: .pushView(viewController: topicVC))
                } else {
                    let nav = TSNavigationController(rootViewController: topicVC).fullScreenRepresentation
                    self?._parentViewController?.navigation(navigateType: .presentView(viewController: nav))
                }
            }
            stackView.addArrangedSubview(tagLabel)
        }
        guard stackView.subviews.count > 0 else { return }
        stackView.addArrangedSubview(UIView())
        contentstackView.addArrangedSubview(paddingContainer)
        
        paddingContainer.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.centerX.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
        }
    }
    
    func loadTranslateButton(feedId: Int, isTranslateOn: Bool, translateText: String?) {
        //        // By Kit Foong (Added checking when no text or only emoji will hide translate button)
        //        guard (originalTexts.count > 0 || TSCurrentUserInfo.share.isLogin) else {
        //            translateButton.isHidden = true
        //            return
        //        }
        guard originalTexts.count > 0  else {
            translateButton.isHidden = true
            return
        }
        translatedTexts = translateText
        translateButton.isHidden = !TSCurrentUserInfo.share.isLogin || self.originalTexts.isEmpty || self.originalTexts.containsOnlyEmoji
        timeStackView.addArrangedSubview(translateButton)
        translateButton.setTitle("button_original".localized, for: .selected)
        translateButton.setTitle("text_translate".localized, for: .normal)
        
        translateButton.isSelected = isTranslateOn
        
        updateTexts()
        
        translateButton.addTap { [weak self] (button) in
            print("feed content view")
            
            guard let self = self, let button = button as? LoadableButton else { return }
            guard button.isSelected == false else {
                button.isSelected = false
                self.updateTexts()
                // By Kit Foong (call this to update view layout if needed)
                //self.remakePrimaryLabelViewContraint(isTranslate: false)
                self.onUpdateTranslateText?(self.translatedTexts.orEmpty, false, feedId)
                return
            }
            
            button.showLoader(userInteraction: false)
            
            FeedListNetworkManager.translateFeed(feedId: feedId.stringValue) { [weak self] (translates) in
                guard let self = self else { return }
                defer { button.hideLoader() }
                self.translatedTexts = translates
                DispatchQueue.main.async {
                    button.isSelected = true
                    self.updateTexts()
                    // By Kit Foong (call this to update view layout if needed)
                    //self.remakePrimaryLabelViewContraint(isTranslate: true)
                    self.onUpdateTranslateText?(self.translatedTexts.orEmpty, true, feedId)
                }
            } failure: { (message) in
                defer { button.hideLoader() }
                UIViewController.showBottomFloatingToast(with: "", desc: message)
            }
            
        }
    }
    
    func loadTimeStamp(timeStamp: String) {
        timestampLabel.text = timeStamp
        timepaddingView.addSubview(timestampLabel)
        timestampLabel.snp.makeConstraints {
            $0.left.top.right.bottom.equalToSuperview()
        }
        
        timeStackView.setContentHuggingPriority(.required, for: .horizontal)
        timeStackView.addArrangedSubview(timepaddingView)
        
        contentstackView.addArrangedSubview(timeWrapperView)
        
    }
    
    private func loadReactionView(reactionList: [ReactionTypes?], totalReactions: Int, feedId: Int) {
        guard reactionList.count > 0 else { return }
        let paddingView = UIView()
        paddingView.addSubview(reactionView)
        reactionView.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.left.equalToSuperview().inset(10)
        }
        
        reactionView.setData(reactionIcon: reactionList, totalReactionCount: totalReactions)
        reactionView.addTap { [weak self] _ in
            let vc = ReactionController(feedId: feedId)
            vc.setCloseButton(image: UIImage.set_image(named: "iconsArrowCaretleftBlack"))
            let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
            self?._parentViewController?.present(nav, animated: true, completion: nil)
        }
        contentstackView.addArrangedSubview(paddingView)
    }
    
    func updateReactionView(_ list: [ReactionTypes?], total: Int, feedId: Int) {
        guard reactionView.superview != nil else {
            loadReactionView(reactionList: list, totalReactions: total, feedId: feedId)
            self.updateCellLayout?()
            return
        }
        reactionView.setData(reactionIcon: list, totalReactionCount: total)
    }
    
    func liveChecker(_ feedId: Int) {
//        FeedListNetworkManager.getMomentFeed(id: feedId) { [weak self] (feedListModel, errorMessage, status, networkResult) in
//            guard let self = self else { return }
//            guard let listModel = feedListModel else {
//                switch networkResult {
//                case .failure(let failure):
//                    if failure.statusCode == 404 {
//                        let vc = TSViewController()
//                        vc.setCloseButton(backImage: true)
//                        let nav = TSNavigationController(rootViewController: vc).fullScreenRepresentation
//                        self._parentViewController?.present(nav, animated: true, completion: {
//                            vc.show(placeholder: .contentRemoved)
//                        })
//                    }
//                default:
//                    break
//                }
//                return
//            }
//            
//            let cellModel = FeedListCellModel(feedListModel: listModel)
//            if let live = cellModel.liveModel, live.status != YPLiveStatus.finishProcess.rawValue {
//                let player = YippiLivePlayerViewController(feedId: feedId, entry: .moment(object: cellModel)).fullScreenRepresentation
//                self._parentViewController?.navigation(navigateType: .presentView(viewController: player))
//            } else {
//                let detail = FeedInfoDetailViewController(feedId: feedId, onToolbarUpdated: (self.parentViewController as? BaseFeedController)?.onToolbarUpdate)
//                self._parentViewController?.navigation(navigateType: .pushView(viewController: detail))
//            }
//        }
    }
    
    func loadSponsored(_ isShow: Bool) {
        sponsorLabel.isHidden = !isShow
    }
}

typealias NormalFeed = (name: String, userModel: UserInfoModel?, content: String, timeStamp: String, avatar: AvatarInfo?, topicList: [TopicListModel], locationModel: TSPostLocationModel?, toolbarModel: FeedListToolModel?, canAcceptReward: Bool, reactionList: [ReactionTypes?], reactionType: ReactionTypes?, feedId: Int, isSponsored: Bool, translateOn: Bool, translateText: String?)

// 不同view的配置方法
extension FeedContentView {
    func configureBasicFeed(with feed: NormalFeed) {
        originalTexts = feed.content
        loadFollowButton(userModel: feed.userModel)
        loadAvatar(with: feed.avatar)
        loadToolbar(model: feed.toolbarModel, canAcceptReward: feed.canAcceptReward, reactionType: feed.reactionType)
        loadStrings(with: feed.name)
        loadLocation(model: feed.locationModel)
        loadTopics(with: feed.topicList)
        loadTimeStamp(timeStamp: feed.timeStamp)
        loadTranslateButton(feedId: feed.feedId, isTranslateOn: feed.translateOn, translateText: feed.translateText)
        loadReactionView(reactionList: feed.reactionList, totalReactions: (feed.toolbarModel?.diggCount).orZero, feedId: feed.feedId)
        loadSponsored(feed.isSponsored)
        
    }
    
    //照片，直播，视频类帖子的配置方法
    func configureAttachmentFeed(with feed: NormalFeed, feedContentType: FeedContentType, pictures: [PaidPictureModel], videoUrl: String, localVideoFileURL: String?, liveModel: LiveEntityModel?) {
        loadAttachment(feedContentType: feedContentType, pictures: pictures, videoURL: videoUrl, localVideoFileURL: localVideoFileURL, liveModel: liveModel, status: liveModel?.status ?? 0)
        configureBasicFeed(with: feed)
        
    }
    
    //转发类帖子的配置方法
    func configureRepostFeed(with feed: NormalFeed, repostId: Int, repostType: String?, repostModel: TSRepostModel?) {
        loadRepostView(repostId: repostId, repostType: repostType, repostModel: repostModel)
        configureBasicFeed(with: feed)
    }
    
    //分享类帖子的配置方法
    func configureSharedFeed(with feed: NormalFeed, sharedModel: SharedViewModel?) {
        loadSharedView(sharedModel: sharedModel)
        configureBasicFeed(with: feed)
    }
    
}

// MARK: - Multi Picture Page View Delegate
extension FeedContentView: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
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


extension FeedContentView: TSToolbarViewDelegate {
    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
        self.onTapToolbarItemAtIndex?(index)
    }
}

