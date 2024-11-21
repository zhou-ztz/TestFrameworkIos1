//
//  PostShortVideoViewController.swift
//  ThinkSNSPlus
//
//  Created by lip on 2018/3/27.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//
//  【坑】视频发布成功后，充发成功后，预览页选择删除后都没有删除沙盒内导出的本地视频文件（文件分两种，相册导出和录制导出）
//  视频发送成功后，标记本地的视频备份数据为成功，每次启动APP的时候检查下本地标记为发送成功的视频备份 超过12小时的会被删除
//  用户手动点击清理缓存时，也需要主动删除一次已标记为成功的视频备份

import UIKit
import KMPlaceholderTextView
import TZImagePickerController
import AVKit
import SCRecorder
//import NIMPrivate

struct ShortVideoAsset {
    let coverImage: UIImage?
    let asset: PHAsset?
    let recorderSession: SCRecordSession?
    let videoFileURL: URL?
}

enum VideoType: Int {
    case normalVideo = 1
    case miniVideo = 2
    
    var path: String {
        switch self {
        case .normalVideo:
            return TSURLPathV2.path.rawValue + TSURLPathV2.Feed.feeds.rawValue
        case .miniVideo:
            return TSURLPathV2.path.rawValue + TSURLPathV2.Feed.miniVideo.rawValue
        }
    }
}


class PostShortVideoViewController: TSViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var postTokenView: PostTokenView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textView: KMPlaceholderTextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var previewImageLoadingOverlay: UILabel!
    @IBOutlet weak var insetCountLabel: UILabel!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
    var playerViewController: AVPlayerViewController?
    @IBOutlet weak var atView: UIView!
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var privacyTitleLabel: UILabel!
    @IBOutlet weak var privacyValueLabel: UILabel!
    @IBOutlet weak var privacyArrowImageView: UIImageView!
    @IBOutlet weak var tagTitleLabel: UILabel!
    @IBOutlet weak var tagArrowImageView: UIImageView!
    @IBOutlet weak var rerecordLabel: UILabel!
    
    @IBOutlet weak var checkInView: UIView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkInArrowImageView: UIImageView!
    @IBOutlet weak var checkInLocationLabel: UILabel!
    
    @IBOutlet weak var recordBtnView: UIView!
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    @IBOutlet weak var previewVideoIconImageView: UIImageView!
    @IBOutlet weak var selectCoverBtn: UIButton!
    @IBOutlet weak var videoPreviewView: UIView!
    @IBOutlet weak var contentStackView: UIStackView!
    //文本内容展开/收起 按钮
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var contentTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var voucherInfoView: UIView!
    @IBOutlet weak var addVoucher: UILabel!
    @IBOutlet weak var voucherView: UIView!
    @IBOutlet weak var voucherLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var voucherConstantH: NSLayoutConstraint!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var recordingImageView: UIImageView!
    private var taggedLocation: FoursquareLocation? {
        willSet  {
            guard let checkedIn = newValue else {
                checkInLocationLabel.text = ""
                return
            }
            
            checkInLocationLabel.text = checkedIn.locationName
        }
    }
    var releasePulseContent: String {
        return textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var preText: String? = nil
    // 发布按钮
    var postBtn = TSTextButton.initWith(putAreaType: .top)
    // 最大内容字数
    let maxContentCount: Int = 255
    // 显示字数时机
    let showWordsCount: Int = 200
    ///从话题进入的发布页面自带一个不能删除的话题
    var chooseModel: TopicCommonModel?
    /// 话题信息
    var topics: [TopicCommonModel] = []
    /// 从被拒绝动态传来的位置对象
    var rejectLocation: FoursquareLocation?
    /// 从被拒绝动态传来的隐私类型对象
    var rejectPrivacyType: PrivacyType?
    
    /// 选中的动态关联用户
    var selectedUsers: [UserInfoModel] = []
    /// 选中的动态关联商家
    var selectedMerchants: [UserInfoModel] = []
    /// 输入框顶部工具栏
    // 整个容器
    var toolView = UIView()
    // 下分割线
    var bottomLine = UIView()
    // 上分割线
    var topLine = UIView()
    /// 表情按钮
    var smileButton = UIButton(type: .custom)
    /// 收起按钮
    var packUpButton = UIButton(type: .custom)
    /// 选择Emoji的视图
    var emojiView: TSSystemEmojiSelectorView!
    var toolHeight: CGFloat = 145 + TSBottomSafeAreaHeight + 41
    // 键盘高度
    var currentKbH: CGFloat = 0
    private var beanErrorLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12, color: UIColor(red: 209, green: 77, blue: 77)))
        label.text = "socialtoken_post_hot_feed_alert".localized
        label.textAlignment = .right
        
        return label
    }()
    
    var isTapOtherView = false
    var isPriceTextFiledTap = false
    /// Privacy
    var privacyType: PrivacyType = .everyone {
        didSet {
            self.privacyValueLabel.text = privacyType.localizedString
        }
    }
    
    var soundId: String?
    var isMiniVideo: Bool = false
    private var isVideoDataChanged = false
    //动态ID
    var feedId: String?
    //封面ID
    var coverId: Int?
    //视频ID
    var videoId: Int?
    var voucherId: Int?
    var voucherName: String?
    var tagVoucher: TagVoucherModel?
    var isVoucherRemoved: Bool = false
    
    
    private var videoType: VideoType {
        return isMiniVideo ? .miniVideo : .normalVideo
    }
    /// 短视频资源
    ///
    /// - Note: 录制的视频 (outputURL 和 coverImage) 或者 相册选择的视频 (outputURL 和 coverImage)
    var shortVideoAsset: ShortVideoAsset? {
        didSet {
            reloadShortVideoAsset()
        }
    }
    var convertedVideoURL:URL?
    var convertedVideoData: Data?
    var postVideoExtension =  [PostVideoExtension]()
    var isFromShareVideo: Bool = false
    //是否从编辑动态页面来
    var isFromEditFeed: Bool = false
    /// TODO: 录制或者相册选择都用一个outputURL 重复覆盖 然后上传成功删除
    //
    // 进入视频预览页面 用 outputURL预览 如果撤销的话 那么就 删除outputURL 对应的文件
    
    func reloadShortVideoAsset() {
        guard let previewImageView = self.previewImageView else {
            return
        }
        guard let shortVideoAsset = shortVideoAsset else {
            videoPreviewView.makeHidden()
            self.postBtn.isEnabled = false
            if isFromEditFeed {
                recordBtnView.makeVisible()
            }
            return
        }
        
        videoPreviewView.makeVisible()
        self.postBtn.isEnabled = true
        if let coverImage = shortVideoAsset.coverImage {
            previewImageView.image = coverImage
        } else if let image = shortVideoAsset.recorderSession?.segments[0].thumbnail {
            previewImageView.image = image
        }
    }
    
    
    private func showSocialTooltip() {
        let preference = ToolTipPreferences()
        preference.drawing.bubble.color = UIColor(red: 37, green: 37, blue: 37).withAlphaComponent(0.78)
        preference.drawing.message.color = .white
        preference.drawing.background.color = .clear
        
        UserDefaults.socialTokenToolTipShouldHide = true
        
        postTokenView.debouncer.execute()
        
        let toolTip = postTokenView.showToolTip(identifier: "", title: "post_feed_hot_feed_guide_title".localized, message: "post_feed_hot_feed_guide_desc".localized, button: nil, arrowPosition: .bottom, preferences: preference)
        toolTip.controller.view.pauseInteraction(for: 1.5)
    }
    
    @objc func postShortVideo(_ btn: UIButton) {
        
        //        为了支持纯文本发布，注释这行判断代码
        //        guard let shortVideoAsset = shortVideoAsset else {
        //            assert(false)
        //            return
        //        }
        
        textView.resignFirstResponder()
        
        guard TSReachability.share.isReachable() != false else {
            self.showError(message: "connect_lost_check".localized)
            return
        }
        
        var pulseContent = self.releasePulseContent
        
        if let attributedString = self.textView.attributedText {
            pulseContent = HTMLManager.shared.formHtmlString(attributedString)
        }
        let postPulseContent = pulseContent
        
        //拿到关联的用户信息
        //        var atStrings = TSUtil.findTSAtStrings(inputStr: self.textView.text)
        //        atStrings = atStrings.map({$0.replacingOccurrences(of: "@", with: "")})
        //        var userIDs = TSUtil.generateMatchingUserIDs(tagUsers: selectedUsers, atStrings: atStrings)
        //        var merchantIDs = TSUtil.generateMatchingUserIDs(tagUsers: selectedMerchants, atStrings: atStrings)
        
        if isVoucherRemoved {
            tagVoucher = nil
        } else {
            if let voucherId = self.voucherId, let voucherName = self.voucherName {
                tagVoucher = TagVoucherModel(taggedVoucherId: voucherId, taggedVoucherTitle: voucherName)
            } else {
                tagVoucher = nil
            }
        }
        
        if isFromShareVideo {
            isFromShareVideo = false
            let postModel = PostModel(feedMark: TSCurrentUserInfo.share.createResourceID(), isHotFeed: self.postTokenView.isEnabled == true, feedContent: postPulseContent, privacy: self.privacyType.rawValue, repostModel: nil, shareModel: nil, topics: self.topics, taggedLocation: self.taggedLocation, phAssets: nil, postPhoto: nil, video: shortVideoAsset, soundId: self.soundId, videoType: self.videoType, postVideo: postVideoExtension, isEditFeed: isFromEditFeed, feedId: feedId, images: nil, rejectNeedsUploadVideo: isVideoDataChanged, videoCoverId: nil, videoDataId: nil, tagUsers: selectedUsers, tagMerchants: selectedMerchants, tagVoucher: tagVoucher)
            PostTaskManager.shared.addTask(postModel)
        } else {
            let postModel = PostModel(feedMark: TSCurrentUserInfo.share.createResourceID(), isHotFeed: self.postTokenView.isEnabled == true, feedContent: postPulseContent, privacy: self.privacyType.rawValue, repostModel: nil, shareModel: nil, topics: self.topics, taggedLocation: self.taggedLocation, phAssets: nil, postPhoto: nil, video: shortVideoAsset, soundId: self.soundId, videoType: self.videoType, postVideo: nil, isEditFeed: isFromEditFeed, feedId: feedId, images: nil, rejectNeedsUploadVideo: isVideoDataChanged, videoCoverId: coverId, videoDataId: videoId, tagUsers: selectedUsers, tagMerchants: selectedMerchants, tagVoucher: tagVoucher)
            PostTaskManager.shared.addTask(postModel)
        }
        
        DispatchQueue.main.async {
            if self.isFromEditFeed == true {
                
                TSRootViewController.share.presentFeedHome(atIndex: 1)
            } else{
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func setCheckInView() {
        checkInLocationLabel.text = String.empty
        checkInLabel.text = "check_in".localized
        
        let setLocationBlock = { [weak self] (location: TSPostLocationObject) -> Void in
            self?.taggedLocation = location
        }
        
        checkInView.addTap { [weak self] (_) in
//            let searchVC = LocationPOISearchViewController()
//            searchVC.onLocationSelected = setLocationBlock
//            
//            let presentingVC = TSNavigationController(rootViewController: searchVC).fullScreenRepresentation
//            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
        }
    }
    
    private func setVoucherView() {
        addVoucher.text = "rw_add_voucher".localized
        
        removeButton.addTap { [weak self] (_) in
            self?.voucherInfoView.isHidden = true
            self?.voucherConstantH.constant = 50
            self?.arrowImageView.isHidden = false
            self?.isVoucherRemoved = true
        }
        
        voucherView.addTap { [weak self] (_) in
            let suggestVC = SuggestVoucherViewController()
            suggestVC.delegate = self
           // searchVC.onLocationSelected = setLocationBlock
            
            let presentingVC = TSNavigationController(rootViewController: suggestVC).fullScreenRepresentation
            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
        }
        
        if let tagVoucher = tagVoucher, tagVoucher.taggedVoucherId > 0 {
            self.voucherInfoView.isHidden = false
            self.arrowImageView.isHidden = true
            self.voucherConstantH.constant = 100
            self.voucherLabel.text = tagVoucher.taggedVoucherTitle
            self.voucherId = tagVoucher.taggedVoucherId
            self.voucherName = tagVoucher.taggedVoucherTitle
        }
    }
    
    private func deleteShortVideoFile() {
        // 清理硬盘中缓存的视频
        // 导入新的过来 如果是视频 就删除掉上一个的文件
        //        let fileManager = FileManager.default
        //        guard let url = shortVideoAsset?.outputURL else {
        //            assert(false, "需要删除文件但是没有路径")
        //            return
        //        }
        //        if fileManager.fileExists(atPath: url.path) {
        //            try? fileManager.removeItem(at: url)
        //        }
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        setupUI()
        let tap = UITapGestureRecognizer { (_) in
            self.isTapOtherView = true
            if !self.textView.isFirstResponder && !self.toolView.isHidden {
                self.toolView.isHidden = true
            }
            self.textView.resignFirstResponder()
        }
        if let text = preText, text.count > 0 {
            HTMLManager.shared.removeHtmlTag(htmlString: "\(text) ", completion: { [weak self] (content, userIdList) in
                guard let self = self else { return }
                var htmlAttributedText = content.attributonString()
                htmlAttributedText = HTMLManager.shared.formAttributeText(htmlAttributedText, userIdList)
                self.textView.attributedText = htmlAttributedText
                self.textView.delegate?.textViewDidChange!(textView)
            })
        }
        if let privacy = self.rejectPrivacyType {
            self.privacyType = self.rejectPrivacyType ?? .everyone
            self.privacyValueLabel.text = privacy.localizedString
        }
        if let location = self.rejectLocation {
            taggedLocation = location
        }
        
        self.scrollView.addGestureRecognizer(tap)
        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
        atView.addGestureRecognizer(atViewTap)
        
        previewImageLoadingOverlay.isHidden = true
        previewImageLoadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        previewImageLoadingOverlay.numberOfLines = 2
        previewImageLoadingOverlay.applyStyle(.regular(size: 10, color: .white))
        
        beanErrorLabel.sizeToFit()
        self.contentStackView.addArrangedSubview(beanErrorLabel)
        beanErrorLabel.isHidden = true
        
        postTokenView.isEnabled = false
        postTokenView.allowBean = isMiniVideo
        if let currentUser = CurrentUserSessionInfo {
            postTokenView.isHidden = !((currentUser.freeHotPost > 0) &&
                                       (currentUser.verificationType != nil) &&
                                       (TSAppConfig.share.launchInfo?.isSocialTokenEnabled == true))
        } else {
            postTokenView.isHidden = true
        }
        
        // Yellow Bean Removal
        postTokenView.isHidden = true
        
        postTokenView.onDisallow = { [weak self]  in
            guard let self = self else { return }
            self.beanErrorLabel.makeVisible()
            self.postTokenView.isUserInteractionEnabled = self.beanErrorLabel.isHidden
        }
        
        expandCollapseButton.setBackgroundImage(UIImage.set_image(named: "ic_rl_expand"), for: .normal)
        expandCollapseButton.setBackgroundImage(UIImage.set_image(named: "ic_rl_collapse"), for: .selected)
        expandCollapseButton.roundCorner(14)
        expandCollapseButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseButtonTapped(_:)), for: .touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.isNavigationBarHidden = false
        reloadShortVideoAsset()
        if isFromEditFeed == false {
            isVideoDataChanged = true
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard UserDefaults.socialTokenToolTipShouldHide == false else {
            postTokenView.fetchHotBalances(shouldToggle: false)
            return
        }
        //showSocialTooltip()
        
        postTokenView.onError = { [weak self] (msg) in
            self?.showError(message: msg)
        }
    }
    
    func setupUI() {
        /// 初始化键盘顶部工具视图
        toolView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: toolHeight)
        toolView.backgroundColor = UIColor.white
        self.view.addSubview(toolView)
        toolView.isHidden = true
        
        topLine.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5)
        topLine.backgroundColor = TSColor.normal.keyboardTopCutLine
        toolView.addSubview(topLine)
        
        packUpButton.frame = CGRect(x: 25, y: 0, width: 22, height: 22)
        packUpButton.setImage(UIImage.set_image(named: "sec_nav_arrow"), for: .normal)
        packUpButton.centerY = 41 / 2.0
        toolView.addSubview(packUpButton)
        packUpButton.addTarget(self, action: #selector(packUpKey), for: UIControl.Event.touchUpInside)
        
        smileButton.frame = CGRect(x: ScreenWidth - 50, y: 0, width: 25, height: 25)
        smileButton.setImage(UIImage.set_image(named: "ico_chat_keyboard_expression"), for: .normal)
        smileButton.setImage(UIImage.set_image(named: "ico_chat_keyboard"), for: .selected)
        smileButton.centerY = packUpButton.centerY
        toolView.addSubview(smileButton)
        smileButton.addTarget(self, action: #selector(emojiBtnClick), for: UIControl.Event.touchUpInside)
        
        emojiView = TSSystemEmojiSelectorView(frame: CGRect(x: 0, y: 41, width: ScreenWidth, height: 0))
        emojiView.delegate = self
        toolView.addSubview(emojiView)
        emojiView.frame = CGRect(x: 0, y: 41, width: ScreenWidth, height: toolHeight - 41)
        
        bottomLine.frame = CGRect(x: 0, y: 40, width: ScreenWidth, height: 1)
        bottomLine.backgroundColor = UIColor(hex: 0x667487)
        toolView.addSubview(bottomLine)
        
        self.title = "title_post_status".localized
        textView.becomeFirstResponder()
        // 键盘的return键为换行样式
        textView.returnKeyType = .default
        textView.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        textView.placeholderColor = TSColor.normal.disabled
        textView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        textView.placeholder = "placeholder_post_status".localized
        //允许非焦点状态下仍然可以滚动
        textView.isScrollEnabled = true
        //显示垂直滚动条
        textView.showsVerticalScrollIndicator = true
        textView.delegate = self
        // 设置右边的发送 控制发送按钮的显示与否
        postBtn.setTitle("publish".localized, for: .normal)
        postBtn.addTarget(self, action: #selector(postShortVideo(_:)), for: .touchUpInside)
        postBtn.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: postBtn)
        postBtn.isEnabled = false
        
        rerecordLabel.text = "video_remake".localized
        
        let backBarItem = UIButton(type: .custom)
        backBarItem.setTitleColor(AppTheme.red)
        backBarItem.addTarget(self, action: #selector(backBtnAction(_:)), for: .touchUpInside)
        self.setupNavigationTitleItem(backBarItem, title: "cancel".localized)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backBarItem)
        
        previewImageView.contentScaleFactor = UIScreen.main.scale
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.autoresizingMask = UIView.AutoresizingMask.flexibleHeight
        previewImageView.clipsToBounds = true
        setTopicViewUI(showTopic: true, topicData: topics)
        
        tagTitleLabel.text = "tag_title_ppl_merchant".localized
        
        privacyTitleLabel.text = "post_privacy".localized
        privacyValueLabel.text = privacyType.localizedString
        privacyView.addAction {
            self.textView.resignFirstResponder()
            
            let sheet = TSCustomActionsheetView(titles: PrivacyType.allCases.map { $0.localizedString }, cancelText: "cancel".localized)
            sheet.finishBlock = { _, _, index in
                self.privacyType = PrivacyType.getType(for: index)
            }
            sheet.show()
        }
        
        setCheckInView()
        setVoucherView()
        
        selectCoverBtn.setTitle("mv_posting_select_cover".localized, for: .normal)
        if !isFromEditFeed {
            recordBtnView.isHidden = isMiniVideo
        }
        
        selectCoverBtn.isHidden = !isMiniVideo
        
        privacyArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        tagArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        arrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        checkInArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        
        recordingImageView.image = UIImage.set_image(named: "ico_video_recordings")
        previewVideoIconImageView.image = UIImage.set_image(named: "ico_video_recordings_white")
        
    }
    
    // MARK: action
    @objc func backBtnAction(_ btn: UIButton) {
        textView.resignFirstResponder()
        
        if self.textView.text.count > 0 || (shortVideoAsset != nil) {
            let actionsheetView = TSCustomActionsheetView(titles: ["warning_cancel_post_status".localized, "confirm".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
        } else {
            navigationController?.dismiss(animated: true)
        }
    }
    
    @IBAction func previewBtnAction(_ sender: Any) {
        guard let shortVideoAsset = shortVideoAsset else {
            return
        }
        if let asset = shortVideoAsset.asset {
            guard let manager = TZImageManager.default() else {
                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "export_video_fail".localized)
                return
            }
            
            manager.getVideoWith(asset) { [weak self] item, dictionary in
                guard let `self` = self, let item = item else {
                    return
                }
                DispatchQueue.main.async {
                    let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
                    vc.avasset = item.asset
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        } else if let asset = shortVideoAsset.recorderSession?.assetRepresentingSegments() {
            let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
            vc.avasset = asset
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        } else  if let url = shortVideoAsset.videoFileURL {
            let vc = PreviewVideoVC(nibName: "PreviewVideoVC", bundle: nil)
            vc.avasset = AVAsset(url: url)
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func reRecorderBtnAction(_ sender: Any) {
        showShortVideoPickerVC()
    }
    
    override func showShortVideoPickerVC() {
        let vc = MiniVideoRecorderViewController()
        vc.onSelectMiniVideo = { [weak self] (path) in
            guard let self = self else { return }
     
            let asset = AVURLAsset(url: path)
            let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: asset)
            
            self.isVideoDataChanged = true
            self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: path)
        }
        let nav = TSNavigationController(rootViewController: vc)
        self.present(nav.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    @objc func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            isTapOtherView = false
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    @objc func packUpKey() {
        smileButton.isSelected = false
        textView.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolView.isHidden = true
        }
    }
    
    @IBAction func selectCoverBtnTapped(_ sender: Any) {
        guard let shortVideoAsset = shortVideoAsset else {
            return
        }
        if let asset = shortVideoAsset.asset {
            guard let manager = TZImageManager.default() else {
                TSIndicatorWindowTop.showDefaultTime(state: .faild, title: "export_video_fail".localized)
                return
            }
            
            manager.getVideoWith(asset) { [weak self] item, dictionary in
                guard let `self` = self, let item = item else {
                    return
                }
                DispatchQueue.main.async {
                    let vc = MiniVideoCoverPickerViewController(asset: item.asset)
                    vc.delegate = self
                    self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
                }
            }
        } else if let asset = shortVideoAsset.recorderSession?.assetRepresentingSegments() {
            let vc = MiniVideoCoverPickerViewController(asset: asset)
            vc.delegate = self
            self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
        } else  if let url = shortVideoAsset.videoFileURL {
            let vc = MiniVideoCoverPickerViewController(asset: AVAsset(url: url))
            vc.delegate = self
            self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
        }
        
    }
    // 按钮点击事件处理
    @objc func expandCollapseButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            self.contentTextViewHeight.constant = self.currentKbH == 0 ? 300 : self.currentKbH // 高度设置为展开状态时的高度
            let newHeight = ScreenHeight - self.currentKbH - TSNavigationBarHeight - TSBottomSafeAreaHeight - 90
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = newHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
            self.textView.becomeFirstResponder() // 打开键盘
        } else {
            self.contentTextViewHeight.constant = 150 // 收起时的高度
            self.textView.resignFirstResponder() // 关闭键盘
            self.packUpKey()
        }
    }
}

// MARK: - TextViewDelegate
extension PostShortVideoViewController {
    func textViewDidChange(_ textView: UITextView) {
        // At
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            HTMLManager.shared.formatTextViewAttributeText(textView)
            return
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        /// 整体不可编辑
        // 联想文字则不修改
        let range = textView.selectedRange
        if range.length > 0 {
            return
        }
        let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
        for match in matchs {
            let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
            if NSLocationInRange(range.location, newRange) {
                textView.selectedRange = NSRange(location: match.range.location + match.range.length, length: 0)
                break
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "" {
            let selectRange = textView.selectedRange
            if selectRange.length > 0 {
                return true
            }
            // 整体删除at的关键词，修改为整体选中
            var isEditAt = false
            var atRange = selectRange
            let matchs = TSUtil.findAllTSAt(inputStr: textView.text)
            for match in matchs {
                let newRange = NSRange(location: match.range.location + 1, length: match.range.length - 1)
                if NSLocationInRange(range.location, newRange) {
                    isEditAt = true
                    atRange = match.range
                    break
                }
            }
            
            if isEditAt {
                HTMLManager.shared.formatTextViewAttributeText(textView)
                textView.selectedRange = atRange
                return false
            }
        } else if text == "@" {
            // 跳转到at列表
            self.pushAtSelectedList()
            // 手动输入的at在选择了用户的block中会先移除掉,如果跳转后不选择用户就不做处理
            return true
        }
        return true
    }
}

extension PostShortVideoViewController: PreviewVideoVCDelegate {
    func previewDeleteVideo() {
        self.shortVideoAsset = nil
        self.isVideoDataChanged = false
    }
}

extension PostShortVideoViewController: MiniVideoCoverPickerDelegate {
    func coverImageDidPicked(_ image: UIImage) {
        guard let asset = self.shortVideoAsset else {
            return
        }
        self.isVideoDataChanged = true
        self.shortVideoAsset = ShortVideoAsset(coverImage: image, asset: asset.asset, recorderSession: asset.recorderSession, videoFileURL: asset.videoFileURL)
    }
}

extension PostShortVideoViewController: TZImagePickerControllerDelegate {
    func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        self.isVideoDataChanged = true
        self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoURL as? URL)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo asset: PHAsset!) {
        self.isVideoDataChanged = true
        self.shortVideoAsset = ShortVideoAsset(coverImage: asset.coverImage, asset: asset, recorderSession: nil, videoFileURL: nil)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: PHAsset!) {
        let image = asset.coverImage
        self.isVideoDataChanged = true
        self.shortVideoAsset = ShortVideoAsset(coverImage: asset.coverImage, asset: asset, recorderSession: nil, videoFileURL: nil)
    }
    
    func imagePickerControllerDidClickRecordVideoBtn(_ picker: TZImagePickerController!) {
        // push 录制控制器
//        let vc = YippiCameraViewController.launch(cameraModes: [.video]) { (videoAsset, _, _, coverImage, _) in
//            self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage![0], asset: videoAsset, recorderSession: nil, videoFileURL: nil)
//        }
//        let nav = TSNavigationController(rootViewController: vc)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true, completion: nil)
    }
    
    // 视频长度超过5分钟少于4秒钟的都不显示
    func isAssetCanSelect(_ asset: PHAsset!) -> Bool {
        guard let asset = asset else {
            return false
        }
        if asset.mediaType == .video {
            return asset.duration < 5 * 60 && asset.duration > 3
        }
        return false
    }
}

extension PostShortVideoViewController: RecorderVCDelegate {
    func finishRecorder(recordSession: SCRecordSession, coverImage: UIImage) {
        self.isVideoDataChanged = true
        self.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: recordSession, videoFileURL: nil)
    }
}

extension PostShortVideoViewController: UIScrollViewDelegate {
    // 如果动了 撤销掉输入框焦点
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != textView {
            textView.resignFirstResponder()
        }
    }
}

// MARK: - 话题板块儿
extension PostShortVideoViewController {
    // 布局话题板块儿
    func setTopicViewUI(showTopic: Bool, topicData: [TopicCommonModel]) {
        topicView.isHidden = true
        topicView.removeAllSubViews()
        if showTopic {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
            topLine.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topLine)
            
            if topicData.isEmpty {
                let addTopicLabel = UILabel(frame: CGRect(x: 20, y: 1, width: 100, height: 49))
                addTopicLabel.text = "post_add_topic".localized
                addTopicLabel.textColor = UIColor(hex: 0x333333)
                addTopicLabel.font = UIFont.systemFont(ofSize: 15)
                topicView.addSubview(addTopicLabel)
                
                let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 20 - 10, y: 0, width: 10, height: 20))
                rightIcon.clipsToBounds = true
                rightIcon.contentMode = .scaleAspectFill
                rightIcon.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
                rightIcon.centerY = addTopicLabel.centerY
                topicView.addSubview(rightIcon)
                
                /// 外加一个点击事件button
                let addButton = UIButton(type: .custom)
                addButton.backgroundColor = UIColor.clear
                addButton.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 50)
                addButton.addTarget(self, action: #selector(jumpToTopicSearchVC), for: UIControl.Event.touchUpInside)
                topicView.addSubview(addButton)
                topicViewHeight.constant = 50
                topicView.updateConstraints()
                let bottomLine = UIView(frame: CGRect(x: 0, y: topicViewHeight.constant - 0.5, width: ScreenWidth, height: 0.5))
                bottomLine.backgroundColor = TSColor.inconspicuous.disabled
                topicView.addSubview(bottomLine)
            } else {
                var XX: CGFloat = 15
                var YY: CGFloat = 14
                let labelHeight: CGFloat = 24
                let inSpace: CGFloat = 8
                let outSpace: CGFloat = 20
                let maxWidth: CGFloat = ScreenWidth - 30
                var tagBgViewHeight: CGFloat = 0
                for (index, item) in topicData.enumerated() {
                    var labelWidth = item.name.sizeOfString(usingFont: UIFont.systemFont(ofSize: 10)).width
                    labelWidth = labelWidth + inSpace * 2
                    if labelWidth > maxWidth {
                        labelWidth = maxWidth
                    }
                    let tagLabel: UIButton = UIButton(type: .custom)
                    let bgView: UIImageView = UIImageView()
                    tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                    XX = tagLabel.right + outSpace
                    if tagLabel.right > maxWidth {
                        XX = 15
                        YY = tagLabel.bottom + outSpace
                        tagLabel.frame = CGRect(x: XX, y: YY, width: labelWidth, height: labelHeight)
                        XX = tagLabel.right + outSpace
                    }
                    tagLabel.backgroundColor = UIColor(hex: 0xe6e6e6)
                    tagLabel.setTitleColor(UIColor.white, for: .normal)
                    tagLabel.layer.cornerRadius = 3
                    tagLabel.setTitle(item.name, for: .normal)
                    tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
                    tagLabel.tag = 666 + index
                    tagLabel.addTarget(self, action: #selector(deleteTopicButton(sender:)), for: UIControl.Event.touchUpInside)
                    topicView.addSubview(tagLabel)
                    
                    bgView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 16, height: 16))
                    bgView.center = CGPoint(x: tagLabel.origin.x + 3, y: tagLabel.origin.y + 3)
                    bgView.layer.cornerRadius = 8
                    bgView.image = UIImage.set_image(named: "ico_topic_close")
                    bgView.tag = 999 + index
                    bgView.isUserInteractionEnabled = true
                    let deleteTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(deleteTopic(tap:)))
                    bgView.addGestureRecognizer(deleteTap)
                    topicView.addSubview(bgView)
                    bgView.isHidden = false
                    if chooseModel != nil {
                        if item.id == chooseModel?.id {
                            bgView.isHidden = true
                        }
                    }
                    
                    if topicData.count < 1 {
                        if index == (topicData.count - 1) {
                            // 需要增加一个添加话题按钮
                            let addImage = UIImageView()
                            addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                            if addImage.right > maxWidth {
                                XX = 15
                                YY = tagLabel.bottom + outSpace
                                addImage.frame = CGRect(x: XX, y: YY, width: 42, height: 24)
                                XX = addImage.right + outSpace
                            }
                            addImage.clipsToBounds = true
                            addImage.layer.cornerRadius = 3
                            addImage.contentMode = .scaleAspectFill
                            addImage.image = UIImage.set_image(named: "ico_add_topic")
                            addImage.tintColor = TSColor.inconspicuous.disabled
                            addImage.isUserInteractionEnabled = true
                            let addTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(jumpToTopicSearchVC))
                            addImage.addGestureRecognizer(addTap)
                            topicView.addSubview(addImage)
                            tagBgViewHeight = addImage.bottom + 14
                        }
                    } else {
                        if index == (topicData.count - 1) {
                            tagBgViewHeight = tagLabel.bottom + 14
                        }
                    }
                }
                topicViewHeight.constant = tagBgViewHeight
                topicView.updateConstraints()
                let bottomLine = UIView(frame: CGRect(x: 0, y: tagBgViewHeight - 0.5, width: ScreenWidth, height: 0.5))
                bottomLine.backgroundColor = TSColor.inconspicuous.disabled
                topicView.addSubview(topLine)
            }
        } else {
            topicViewHeight.constant = 0
            topicView.updateConstraints()
        }
    }
    
    /// 搜索话题页面选择话题之后发通知处理话题板块儿
    @objc func topicChooseNotice(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        let model: TopicListModel = dict["topic"] as! TopicListModel
        let changeModel: TopicCommonModel = TopicCommonModel(topicListModel: model)
        /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
        var hasTopic = false
        if !topics.isEmpty {
            for item in topics {
                if item.id == changeModel.id {
                    hasTopic = true
                    break
                }
            }
            if hasTopic {
                return
            } else {
                topics.append(changeModel)
                setTopicViewUI(showTopic: true, topicData: topics)
            }
        } else {
            topics.append(changeModel)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    /// 话题板块儿选择话题跳转到搜索话题页面
    @objc func jumpToTopicSearchVC() {
        let searchVC = TopicSearchVC.vc()
        searchVC.jumpType = "post"
        searchVC.onSelectTopic = { [weak self] model in
            guard let self = self else { return }
            let changeModel: TopicCommonModel = TopicCommonModel(topicListModel: model)
            /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
            var hasTopic = false
            if !self.topics.isEmpty {
                for (_, item) in self.topics.enumerated() {
                    if item.id == changeModel.id {
                        hasTopic = true
                        break
                    }
                }
                if hasTopic {
                    return
                } else {
                    self.topics.append(changeModel)
                    self.setTopicViewUI(showTopic: true, topicData: self.topics)
                }
            } else {
                self.topics.append(changeModel)
                self.setTopicViewUI(showTopic: true, topicData: self.topics)
            }
        }
        let nav = TSNavigationController(rootViewController: searchVC).fullScreenRepresentation
        self.present(nav, animated: true, completion: nil)
    }
    
    /// 话题板块儿删除话题按钮点击事件
    @objc func deleteTopic(tap: UIGestureRecognizer) {
        if !topics.isEmpty {
            topics.remove(at: (tap.view?.tag)! - 999)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    /// 话题板块儿点击话题按钮删除话题
    @objc func deleteTopicButton(sender: UIButton) {
        if !topics.isEmpty {
            if chooseModel != nil {
                let model = topics[sender.tag - 666]
                if model.id == chooseModel?.id {
                    return
                }
            }
            topics.remove(at: sender.tag - 666)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    /// 话题板块儿获取当前已选择的话题 id 然后组装成一个 id 数组（用于发布接口传值）
    /// 没选择话题的情况下发布接口对应的话题字段就不传，如果有就传话题 ID 数组
    func getCurrentTopicIdArray() -> NSArray {
        let pass = NSMutableArray()
        if !topics.isEmpty {
            for item in topics {
                pass.append(item.id)
            }
        }
        return pass
    }
}

// MARK: - at人
extension PostShortVideoViewController {
    /// 点击了atView
    @objc func didTapAtView() {
        self.pushAtSelectedList()
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList() {
        let atselectedListVC = TSAtPeopleAndMechantListVC()
        atselectedListVC.selectedBlock = {  [weak self] (userInfo, userInfoModelType) in
            guard let self = self else { return }
            if let userInfo = userInfo {
                /// 先移除光标所在前一个at
                self.insertTagTextIntoContent(userId: userInfo.userIdentity, userName: userInfo.name)
                if userInfoModelType == .merchant {
                    self.selectedMerchants.append(userInfo)
                } else {
                    self.selectedUsers.append(userInfo)
                }
                return
            }
        }
        //        self.navigationController?.pushViewController(atselectedListVC, animated: true)
        let nav = TSNavigationController(rootViewController: atselectedListVC)
        self.navigationController?.present(nav.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func insertTagTextIntoContent (userId: Int? = nil, userName: String) {
        
//        self.textView = TSCommonTool.atMeTextViewEdit(self.textView) as! KMPlaceholderTextView
        
        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
        let newMutableString = self.textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newMutableString.append(temp)
        self.textView.attributedText = newMutableString
        //self.contentTextView.insertText(insertStr)
        self.textView.delegate?.textViewDidChange!(textView)
        self.textView.becomeFirstResponder()
        self.textView.insertText("")

    }
}

// MARK: - TSCustomAcionSheetDelegate
extension PostShortVideoViewController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
}

extension PostShortVideoViewController {
    /// 键盘通知响应
    @objc fileprivate func kbWillShowNotificationProcess(_ notification: Notification) -> Void {
        guard let userInfo = notification.userInfo, let kbFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        self.currentKbH = kbFrame.size.height
        if isPriceTextFiledTap {
            self.toolView.isHidden = true
        } else {
            self.toolView.isHidden = false
            self.smileButton.isSelected = false
            self.toolView.top = kbFrame.origin.y - (TSBottomSafeAreaHeight + 41 + 64.0)
        }
        if expandCollapseButton.isSelected {
            let newHeight = ScreenHeight - self.currentKbH - TSNavigationBarHeight - TSBottomSafeAreaHeight - 90
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = newHeight
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    @objc fileprivate func kbWillHideNotificationProcess(_ notification: Notification) -> Void {
        self.toolView.top = ScreenHeight - toolHeight - 64.0 - TSBottomSafeAreaHeight
        self.smileButton.isSelected = true
        self.toolView.isHidden = isTapOtherView
        // 当键盘隐藏且按钮为选中状态，恢复原始高度
        if expandCollapseButton.isSelected {
            expandCollapseButton.isSelected = false
            UIView.animate(withDuration: 0.6,
                           delay: 0,
                           usingSpringWithDamping: 0.6,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.contentTextViewHeight.constant = 150
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension PostShortVideoViewController: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.textView.insertText(emoji)
        self.textView.scrollRangeToVisible(self.textView.selectedRange)
    }
}

extension PostShortVideoViewController: SuggestVoucherDelegate {
    func selectedVoucher(voucherId: Int, voucherName: String) {
        self.voucherInfoView.isHidden = false
        self.arrowImageView.isHidden = true
        self.voucherConstantH.constant = 100
        self.voucherLabel.text = voucherName
        self.voucherId = voucherId
        self.voucherName = voucherName
        self.isVoucherRemoved = false
    }
}
