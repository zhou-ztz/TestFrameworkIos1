//
//  MomentListBasicCell.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/10/31.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  动态列表 cell

import UIKit
import ActiveLabel
import AliyunVideoSDKPro
import AliyunPlayer
import Lottie
import SnapKit

/// 动态列表 cell
class FeedListCell: UITableViewCell, AVPDelegate, BaseCellProtocol {

    var reactionHandler: ReactionHandler?
    var onPictureDidSelect: ((PictureViewer, Int, _ transitionId: String) -> Void)?
    var onToolbarItemDidSelect: ((Int) -> Void)?
    var onReactionSuccess: EmptyClosure?
    var onUpdateTranslateText: ((String, Bool, Int) -> Void)?
    var onUpdateCellLayout: EmptyClosure?
    
    /// 是否在个人主页
    let feedContentView = FeedContentView(frame: CGRect.zero)
    var isAtHomepage: Bool = false
    var isNeedShowPostExcellent = true
    
    /// 数据
    var model = FeedListCellModel() {
        didSet {
            updateContentView()
        }
    }
    
    // MARK: - 生命周期
    override func prepareForReuse() {
        super.prepareForReuse()
        self.feedContentView.contentstackView.removeAllArrangedSubviews()
        self.feedContentView.clearResendButton()
        self.feedContentView.videoPlayer.prepareForReuse()
    }
    
    class func cell(for tableView: UITableView, at indexPath: IndexPath) -> FeedListCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FeedListCell.cellIdentifier, for: indexPath) as! FeedListCell
        return cell
    }

    func willDisplay(for view: UIView) -> ReactionHandler {
        let likeItem = feedContentView.toolbar.getItemAt(0)
        self.reactionHandler = ReactionHandler(reactionView: likeItem, toAppearIn: view, currentReaction: model.reactionType, feedId: model.idindex, feedItem: model, reactions: [.heart,.awesome,.wow,.cry,.angry])

        likeItem.addGestureRecognizer(reactionHandler!.longPressGesture)

        reactionHandler?.onSelect = { [weak self] reaction in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.animate(for: reaction)
            }
        }

        reactionHandler?.onSuccess = { [weak self] message in
            // do nothing
            self?.onReactionSuccess?()
        }
        
        return self.reactionHandler!
    }
    
    private func animate(for reaction: ReactionTypes?) {
        let toolbaritem = feedContentView.toolbar.getItemAt(0)
        
        if let reaction = reaction {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = reaction.image
                toolbaritem.titleLabel.text = reaction.title
                toolbaritem.titleLabel.textColor = AppTheme.softBlue
            }
        } else {
            UIView.transition(with: toolbaritem.imageView, duration: 0.3) {
                toolbaritem.imageView.image = UIImage.set_image(named: "IMG_home_ico_love")
                toolbaritem.titleLabel.text = "love_reaction".localized
                toolbaritem.titleLabel.textColor = .black
            }
        }
    }

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    /// 设置视图
    private func setUI() {
        contentView.addSubview(feedContentView)
        contentView.backgroundColor = .white
        feedContentView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
    
    private func updateContentView() {
        let usrName = model.userInfo?.username
        let usrDisplayName = model.userInfo?.name
        
        let name = LocalRemarkName.getRemarkName(userId: "\(model.userId)", username: usrName, originalName: usrDisplayName, label: nil)
        let type: FeedContentType = model.feedType
        let timeStamp = (model.time?.timeAgoDisplay()).orEmpty
        let canAcceptReward = model.canAcceptReward == 1 ? true : false
        
        let basicFeed: NormalFeed = (name: name, userModel: model.userInfo, content: model.content, timeStamp: timeStamp, avatar: model.avatarInfo, topicList: model.topics, locationModel: model.location, toolbarModel: model.toolModel, canAcceptReward: canAcceptReward, reactionList: model.topReactionList, reactionType: model.reactionType, feedId: model.idindex, isSponsored: model.isSponsored, translateOn: model.isTranslateOn, translateText: model.translateText)
        
        switch type {
            case .normalText:
                feedContentView.configureBasicFeed(with: basicFeed)
                feedContentView.sizeToFit()
                feedContentView.layoutIfNeeded()

            case .picture, .video, .live, .miniVideo:
                feedContentView.configureAttachmentFeed(with: basicFeed, feedContentType: type, pictures: model.pictures, videoUrl: model.videoURL, localVideoFileURL: model.localVideoFileURL, liveModel: model.liveModel)
                feedContentView.sizeToFit()
                feedContentView.layoutIfNeeded()

            case .repost:
                feedContentView.configureRepostFeed(with: basicFeed, repostId: model.repostId, repostType: model.repostType, repostModel: model.repostModel)
                feedContentView.sizeToFit()
                feedContentView.layoutIfNeeded()

            case .share:
                feedContentView.configureSharedFeed(with: basicFeed, sharedModel: model.sharedModel)
                feedContentView.sizeToFit()
                feedContentView.layoutIfNeeded()
        }
        
        feedContentView.onUpdateTranslateText = { [weak self] text, isOn, feedId in
            self?.onUpdateTranslateText?(text, isOn, feedId)
        }
        
        feedContentView.pictureView.onTapPictureView = { [weak self] (view, tappedIndex, transitionId) in
            self?.onPictureDidSelect?(view, tappedIndex, transitionId)
        }
        feedContentView.updateCellLayout = { [weak self] in
            self?.onUpdateCellLayout?()
        }
        feedContentView.onTapToolbarItemAtIndex = { [weak self] index in
            guard let self = self else { return }
            
            guard index > 0 else {
                guard TSCurrentUserInfo.share.isLogin == true else {
                    TSRootViewController.share.guestJoinLandingVC()
                    return
                }
                self.reactionHandler?.onTapReactionView()
                self.model.reactionType = self.reactionHandler?.currentReaction
                return
            }
            self.onToolbarItemDidSelect?(index)
        }
    }

    func onReturnToTrellis(index: Int, transitionId: String) {
        guard index < feedContentView.pictureView.pictureViews.count else { return }
        feedContentView.pictureView.pictureViews[index].hero.id = transitionId
    }
    
    //    @objc func didClickAdvertToolBtn(_ btn: UIButton) {
    //        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didClickAdvertToolBtn"), object: nil, userInfo: ["FeedListCell": self])
    //    }
    //
    //    @objc func videoDidClick(_ button: UIButton) {
    //        print("video did click")
    //        delegate?.feedCell(self, didSelectedPictures: picturesView, at: 0)
    //    }
    //
    //    @objc func followDidClick(_ button: UIButton) {
    //        // 1.如果是游客模式，触发登录注册操作
    //          if TSCurrentUserInfo.share.isLogin == false {
    //              TSRootViewController.share.guestJoinLandingVC()
    //              return
    //          }
    //
    //        followButton.makeHidden()
    //        followView.makeVisible()
    //        followView.play { finished in
    //            if finished == true {
    //                self.delegate?.feedCell(self, didClickFollow: self.model.userId)
    //            }
    //        }
    //    }
    /// 加载内容 label
    
    //    internal func loadContentLabel(topRecord: inout CGFloat) {
    //        // 1.如果 content 为空，则不显示 content label
    //        contentLabel.isHidden = model.content.isEmpty
    //        guard !model.content.isEmpty else {
    
    
    
    // MARK: - 用户交互事件
    /// 点击了重发按钮
//    @objc func resendButtonTaped() {
//        delegate?.feedCellDidSelectedResendButton(self)
//    }
//    /// 点击了来自Lab
//    @objc func didTapFromLab(tap: UITapGestureRecognizer) {
//        delegate?.feedCellDidTapFromLab!(self)
//    }
//
//    @objc func goToLocationViewController () {
//        guard let location = model.location else {
//            return
//        }
//        delegate?.feedCellDidSelectLocation(self, locationID: location.locationID, locationName: location.locationName)
//    }

//    func liveChecker(_ feedId: Int) {
//        self.parentViewController?.navigationController?.loadingOverlay()
//        TSMomentNetworkManager.getOneMoment(feedId: feedId, complete: { [unowned self] (object, error, _, status) in
//            DispatchQueue.main.async {
//                self.parentViewController?.navigationController?.endLoading()
//                if let object = object, let live = object.liveModel, live.status != YPLiveStatus.finishProcess.rawValue {
//                    let player = YippiLivePlayerViewController(feedId: feedId, entry: .moment(object: object)).fullScreenRepresentation
//                    self.parentViewController?.navigationController?.present(player, animated: true, completion: nil)
//                } else {
//                    let detail = TSCommetDetailTableView(feedId: feedId)
//                    self.parentViewController?.navigationController?.pushViewController(detail, animated: true)
//                }
//            }
//        })
//    }
    
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
        let attribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.paragraphStyle: paragraphStyle.copy(), NSAttributedString.Key.strokeColor: UIColor.black]
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
    
    func WidthOfAttributeString(contentHeight: CGFloat, attributeString: NSAttributedString, font: UIFont, paragraphstyle: NSMutableParagraphStyle) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: font, NSAttributedString.Key.paragraphStyle: paragraphstyle.copy()]
        let att: NSString = NSString(string: attributeString.string)
        let rectToFit1 = att.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: contentHeight), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if attributeString.length == 0 {
            return 0
        }
        return rectToFit1.size.width
    }
    
    // MARK: - 点击话题板块儿的某个话题标签 跳转到话题详情页
//    @objc func jumpToTopicDetailVC(sender: UIButton) {
//        if model.topics.isEmpty {
//            return
//        }
//        let modelTopic = model.topics[sender.tag - 666]
//        delegate?.feedCellDidClickTopic!(self, topicId: modelTopic.topicId)
//    }
    
}

//// MARK: - TSMomentPicturePreviewDelegate: 九宫格图片代理
//exten,
//
//// MARK: - TSToolbarViewDelegate: 工具栏代理
//extension FeedListCell: TSToolbarViewDelegate {
//
//    /// 工具栏的 item 被点击
//    func toolbar(_ toolbar: TSToolbarView, DidSelectedItemAt index: Int) {
//        delegate?.feedCell(self, didSelectedToolbar: toolbar, at: index)
//    }
//}
//
//// MARK: - FeedCommentListViewDelegate: 评论视图代理事件
//extension FeedListCell: FeedCommentListViewDelegate {
//
//    /// 长按了评论视图的评论行
//    func feedCommentListView(_ view: FeedCommentListView, didLongPressComment data: FeedCommentListCellModel, at indexPath: IndexPath) {
//        delegate?.feedCell(self, didLongPressComment: view, at: indexPath)
//    }
//
//    /// 点击了查看全部按钮
//    func feedCommentListViewDidSelectedSeeAllButton(_ view: FeedCommentListView) {
//        delegate?.feedCellDidSelectedSeeAllButton(self)
//    }
//
//    /// 点击了评论行
//    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment data: FeedCommentListCellModel, at indexPath: IndexPath) {
//        delegate?.feedCell(self, didSelectedComment: view, at: indexPath)
//    }
//
//    /// 点击了评论内容中的用户名
//    func feedCommentListView(_ view: FeedCommentListView, didSelectedComment cell: FeedCommentListCell, onUser userId: Int) {
//        delegate?.feedCell(self, didSelectedComment: cell, onUser: userId)
//    }
//}
