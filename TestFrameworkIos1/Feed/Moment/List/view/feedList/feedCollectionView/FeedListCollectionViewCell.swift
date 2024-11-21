//
//  FeedListCollectionViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/8.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import ActiveLabel

import Lottie
import SnapKit
import SDWebImage

class FeedListCollectionViewCell: UICollectionViewCell, BaseCellProtocol {
    
    private let pictureView = UIView()
    
    private let sponsorView = UIView().configure {
        $0.backgroundColor = UIColor(hex: 0x00B998)
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
    }
    
    private let sponsorLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .white))
        $0.numberOfLines = 1
        $0.text = "sponsored".localized
    }
    
    private let pictureImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
        $0.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        $0.clipsToBounds = true
    }
    private let feedVideoIcon = UIImageView().configure {
        $0.image = UIImage.set_image(named: "ic_feed_video_icon")
    }
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    private let avatarNameStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 5
        return stack
    }()
    
    private let avatar = AvatarView(origin: .zero, type: AvatarType.width26(showBorderLine: false), animation: true)
    
    private var primaryLabel: ActiveLabel! = ActiveLabel()
    
    private let nameLabel = UILabel().configure {
        $0.applyStyle(.regular(size: 10, color: UIColor(hex: 0x737373)))
        $0.numberOfLines = 1
    }
    
    private lazy var likeBtn: FeedToolBarButton = {
        let button = FeedToolBarButton()
        button.imageView.image = UIImage.set_image(named: "ic_feed_like")
        button.imageView.contentMode = .scaleAspectFit
        button.addAction { [weak self] in
            guard TSCurrentUserInfo.share.isLogin else {
                TSRootViewController.share.guestJoinLandingVC()
                return
            }
            self?.reactionHandler?.onTapReactionView()
        }
        return button
    }()
    
    private var reactionHandler: ReactionHandler?
    var onReactionSuccess: EmptyClosure?
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    
    /// 数据
    var model = FeedListCellModel() {
        didSet {
            updateContentView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    /// 设置视图
    private func setUI() {
        contentView.backgroundColor = TSColor.inconspicuous.background
        contentView.roundCorner(10)
        contentView.layer.borderColor = AppTheme.inputContainerGrey.cgColor
        contentView.layer.borderWidth = 1
        
        //封面图
        contentView.addSubview(pictureView)
        contentView.addSubview(sponsorView)
        pictureView.addSubview(pictureImageView)
        
        sponsorView.isHidden = true
        sponsorView.addSubview(sponsorLabel)
        
        //视频标识
        feedVideoIcon.isHidden = true
        contentView.addSubview(feedVideoIcon)
        //动态内容
        contentView.addSubview(primaryLabel)
        
        //用户头像、用户昵称
        contentView.addSubview(bottomStackView)
        avatarNameStackView.addArrangedSubview(avatar)
        avatarNameStackView.addArrangedSubview(nameLabel)
        bottomStackView.addArrangedSubview(avatarNameStackView)
        //点赞
        bottomStackView.addArrangedSubview(likeBtn)
        
        primaryLabel.wordWrapped()
        primaryLabel.enabledTypes = [.mention, .hashtag, .url]
        primaryLabel.mentionColor = AppTheme.primaryBlueColor
        primaryLabel.hashtagColor = AppTheme.primaryBlueColor
        primaryLabel.URLColor = UIColor(hex: 0x66A8F0)
        primaryLabel.URLSelectedColor = TSColor.main.theme
        primaryLabel.textColor = .black
        primaryLabel.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
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
            HTMLManager.shared.handleMentionTap(name: name, attributedText: self.htmlAttributedText)
        }
        
        primaryLabel.handleHashtagTap { [weak self] (hashtagString) in
//            let vc = GlobalSearchResultViewController()
//            vc.searchText.text = hashtagString.withHashtagPrefix()
//            vc.initialSearchType = .momments
//            vc.canCloseView = true
        }
        
        bottomStackView.snp.makeConstraints {
            $0.bottom.equalTo(-10)
            $0.left.equalToSuperview().offset(5)
            $0.right.equalToSuperview().inset(5)
            $0.height.equalTo(27)
        }
        
        primaryLabel.snp.makeConstraints {
            $0.bottom.equalTo(bottomStackView.snp.top)
            $0.left.right.equalToSuperview().inset(5)
            $0.height.equalTo(40)
        }
        
        pictureView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(primaryLabel.snp.top).offset(0)
        }
                
        pictureImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sponsorView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(6)
            $0.left.equalToSuperview()
        }
        
        sponsorLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(3)
        }
        
        feedVideoIcon.snp.makeConstraints {
            $0.top.equalTo(pictureView.snp.top).offset(5)
            $0.right.equalTo(pictureView.snp.right).offset(-5)
        }
        
        likeBtn.snp.makeConstraints {
            $0.width.equalTo(35)
        }
//        nameLabel.snp.makeConstraints {
//            $0.left.equalTo(avatar.snp.right).offset(5)
//            $0.right.equalToSuperview()
//            $0.centerY.equalToSuperview()
//        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateSponsorStatus(model.isSponsored)
    }
    
    private func updateContentView() {
        loadAvatar(with: model.avatarInfo)
        setupReactions(model)
        
        let usrName = model.userInfo?.username
        let usrDisplayName = model.userInfo?.name
        
        let name = LocalRemarkName.getRemarkName(userId: "\(model.userId)", username: usrName, originalName: usrDisplayName, label: nil)
        let type: FeedContentType = model.feedType
        let timeStamp = (model.time?.timeAgoDisplay()).orEmpty
        let canAcceptReward = model.canAcceptReward == 1 ? true : false
        if model.pictures.count > 0 {
            self.pictureImageView.sd_setImage(with: URL(string: model.pictures[0].url.orEmpty), placeholderImage: UIImage.set_image(named: "icFeedPlaceholder"), options: [SDWebImageOptions.lowPriority, .refreshCached], completed: nil)
        }
        self.pictureView.isHidden = model.pictures.count <= 0
        self.nameLabel.text = name
        
        HTMLManager.shared.removeHtmlTag(htmlString: model.content, completion: { [weak self] (content, userIdList) in
            guard let self = self else { return }
            
            self.userIdList = userIdList
            self.primaryLabel.text = content
            
            self.htmlAttributedText = content.attributonString().setTextFont(14).setlineSpacing(0)
            if let attributedText = self.htmlAttributedText {
                self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList)
            }
            
            self.primaryLabel.attributedText = self.htmlAttributedText
        })
        
        let basicFeed: NormalFeed = (name: name, userModel: model.userInfo, content: model.content, timeStamp: timeStamp, avatar: model.avatarInfo, topicList: model.topics, locationModel: model.location, toolbarModel: model.toolModel, canAcceptReward: canAcceptReward, reactionList: model.topReactionList, reactionType: model.reactionType, feedId: model.idindex, isSponsored: model.isSponsored, translateOn: model.isTranslateOn, translateText: model.translateText)

        if model.feedType == .miniVideo && model.pictures.count > 0 {
            self.feedVideoIcon.isHidden = false
        } else {
            self.feedVideoIcon.isHidden = true
        }
                
        self.updateSponsorStatus(model.isSponsored)
    }
    
    private func updateSponsorStatus(_ isShow: Bool) {
        if UserDefaults.sponsoredEnabled {
            sponsorView.isHidden = !isShow
            sponsorView.roundCorners([.topRight, .bottomRight], radius: 5)
        } else {
            sponsorView.isHidden = true
        }
        
        sponsorView.setNeedsLayout()
        UIView.animate(withDuration: 0.3) {
            self.sponsorView.layoutIfNeeded()
        }
    }
    
    private func loadAvatar(with info: AvatarInfo?) {
        guard let info = info else { return }
        avatar.avatarInfo = info
    }
    
    private func setupReactions(_ model: FeedListCellModel) {
        self.reactionHandler = ReactionHandler(reactionView: likeBtn, toAppearIn: self.parentViewController?.view ?? UIView(), currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry], isForCollectionCell: true)
        
        likeBtn.addGestureRecognizer(reactionHandler!.longPressGesture)
        
        if let toolModel = model.toolModel {
            //添加点赞数
            likeBtn.titleLabel.text = toolModel.diggCount.stringValue
            if let reaction = model.reactionType {
                likeBtn.imageView.image = reaction.image
            } else {
                likeBtn.imageView.image = toolModel.isDigg ? UIImage.set_image(named: "red_heart") : UIImage.set_image(named: "ic_feed_like")
            }
        }
        
        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.updateReactionList(reaction: reaction)
                self.animate(for: reaction)
            }
        }
        
        reactionHandler?.onSuccess = { [weak self] message in
            // do nothing
            guard let self = self else { return }
            self.onReactionSuccess?()
        }
    }
    
    private func animate(for reaction: ReactionTypes?) {
        if let reaction = reaction {
            likeBtn.imageView.image = reaction.image
//            likeBtn.titleLabel.text = reaction.title
//            likeBtn.titleLabel.textColor = AppTheme.softBlue
        } else {
            likeBtn.imageView.image = UIImage.set_image(named: "ic_feed_like")
//            likeBtn.titleLabel.text = ReactionTypes.heart.title
//            likeBtn.titleLabel.textColor = .white
        }
    }
    
    func updateReactionList(reaction: ReactionTypes?) {
        if let reaction = reaction {
            if self.model.topReactionList.contains(reaction) == false {
                self.model.topReactionList.append(reaction)
            }
        
            if self.model.reactionType == nil {
                self.model.toolModel?.diggCount += 1
            }
        } else {
            self.model.toolModel?.diggCount -= 1
        }
        if let count = self.model.toolModel?.diggCount, count >= 0 {
            likeBtn.titleLabel.text = count.stringValue
        }
        
        self.model.reactionType = reaction
    }
    
    func resetReactHandler() {
        self.reactionHandler?.reset()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FeedToolBarButton: UIView {
    let imageView: UIImageView = UIImageView(frame: .zero).configure {
        $0.contentMode = .scaleAspectFit
    }
    
    let titleLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 10, color: UIColor(hex: 0x737373)))
    }
    
    private let stackview = UIStackView().configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 3
    }
    
    init() {
        super.init(frame: .zero)
        addSubview(stackview)
        stackview.bindToEdges()
        
        stackview.addArrangedSubview(imageView)
        stackview.addArrangedSubview(titleLabel)
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
