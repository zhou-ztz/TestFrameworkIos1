//
//  EditPostViewController.swift
//  Yippi
//
//  Created by ChuenWai on 15/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import KMPlaceholderTextView
import SwiftLinkPreview
import IQKeyboardManagerSwift
//import NIMPrivate

class EditPostViewController: TSViewController{
    private var headerView: UIView = UIView()
    private var avatar: AvatarView = AvatarView(type: .width38(showBorderLine: false))
    private var nameLabel: UILabel = UILabel()
    private var headerBottomLine: UIView = UIView()
    private var contentStackView: UIStackView = {
        let view = UIStackView()
        view.distribution = .fill
        view.alignment = .fill
        view.axis = .vertical
        view.spacing = 8
        
        return view
    }()
    private var scrollView: UIScrollView = UIScrollView()
    private var repostViewBgView = UIView()
    private var postCaptionView: KMPlaceholderTextView = KMPlaceholderTextView()
    private var pictureView: PicturesTrellisView = PicturesTrellisView()
    private var repostView = TSRepostView()
    private var sharedView = TSRepostView()
    private var feedSharedView = TSFeedRePostView()
    private var locationView = UIView()
    private var isImageVideoPost: Bool = false
    private var cancelButton = UIButton()
    private var doneButton = TSTextButton.initWith(putAreaType: .top)
    private var feedId: Int
    private var name: String
    private var avatarInfo: AvatarInfo
    private var postContent: String
    private var pictures: [PaidPictureModel]
    private var videoUrl: String
    private var localVideoFileUrl: String?
    private var liveModel: LiveEntityModel?
    private var liveIcon : UIButton = UIButton(type: .custom)
    private var repostID: Int
    private var repostType: String?
    private var repostModel: TSRepostModel?
    private var sharedModel: SharedViewModel?
    private var locationModel: TSPostLocationModel?
    private var topicList: [TopicListModel]
    private var isHotFeed: Bool
    private var privacy: String
    private var lastTextViewHeight: CGFloat = 0
    private var resignKeyboardGesture = UITapGestureRecognizer()
    private var keyboardHeight: CGFloat = 0
    private var feedType: FeedContentType = .normalText
    var onSucessEdit: ((Int?, _ repostModel: TSRepostModel?, _ sharedModel: SharedViewModel?, _ content: String) -> Void)?
    var userIdList: [String] = []
    var htmlAttributedText: NSMutableAttributedString?
    var releasePulseContent: String {
        return postCaptionView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var tagVoucher: TagVoucherModel?
    
    init(feedId: Int, name: String, avatarInfo: AvatarInfo, postContent: String, pictures: [PaidPictureModel], videoUrl: String, localVideoFileUrl: String?, liveModel: LiveEntityModel?, repostID: Int, repostType: String?, repostModel: TSRepostModel?, sharedModel: SharedViewModel?, locationModel: TSPostLocationModel?, topicList: [TopicListModel], isHotFeed: Bool, privacy: String, feedType: FeedContentType, tagVoucher: TagVoucherModel?) {
        self.feedId = feedId
        self.name = name
        self.avatarInfo = avatarInfo
        self.postContent = postContent
        self.pictures = pictures
        self.videoUrl = videoUrl
        self.localVideoFileUrl = localVideoFileUrl
        self.liveModel = liveModel
        self.repostID = repostID
        self.repostType = repostType
        self.repostModel = repostModel
        self.sharedModel = sharedModel
        self.locationModel = locationModel
        self.topicList = topicList
        self.isHotFeed = isHotFeed
        self.privacy = privacy
        self.feedType = feedType
        self.tagVoucher = tagVoucher
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSubviews()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.title = "title_edit_moment".localized
        
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        
        postCaptionView.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func cancelButtonClicked() {
        self.textViewResignResponder()
        let actionsheetView = TSCustomActionsheetView(titles: ["warning_cancel_post_status".localized, "confirm".localized])
        actionsheetView.delegate = self
        actionsheetView.tag = 2
        actionsheetView.notClickIndexs = [0]
        actionsheetView.show()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: contentStackView.frame.maxY)
    }
    
    @objc private func doneEdit() {
        self.textViewResignResponder()
        doneButton.isEnabled = false
        var topics: [TopicCommonModel] = []
        var pulseContent = self.releasePulseContent
        
        if let attributedString = self.postCaptionView.attributedText {
            pulseContent = HTMLManager.shared.formHtmlString(attributedString)
        }
        let topIndicator = TSIndicatorWindowTop(state: .loading, title: "processing".localized)
        topIndicator.show()
        for topic in topicList {
            topics.append(TopicCommonModel(topicListModel: topic))
        }
        let postPulseContent = pulseContent
        
        TSMomentNetworkManager().update(feedContent: postPulseContent, feedId: feedId, privacy: privacy, images: nil, feedFrom: 3, topics: topics, repostType: repostType, repostId: repostID, customAttachment: sharedModel, location: locationModel, isHotFeed: isHotFeed, tagVoucher: tagVoucher) { [weak self] (feedId, error) in
            
            topIndicator.dismiss()
            self?.doneButton.isEnabled = true
            
            if let error = error {
                self?.showError(message: error.localizedDescription)
            } else {
                self?.navigationController?.popViewController(animated: true)
                self?.onSucessEdit?(feedId, self?.repostModel, self?.sharedModel, postPulseContent)
            }
        }
    }
    
    private func loadSubviews() {
        self.view.addSubview(headerView)
        self.headerView.addSubview(avatar)
        self.headerView.addSubview(nameLabel)
        self.view.addSubview(headerBottomLine)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentStackView)
        loadPictureView()
        loadRepostView()
        loadLocation()
        loadTopics()
        self.contentStackView.addArrangedSubview(postCaptionView)
    }
    
    private func setUI() {
        self.view.backgroundColor = UIColor.white
        let cancelButton = TSTextButton.initWith(putAreaType: .top)
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        doneButton.setTitle("publish".localized, for: .normal)
        doneButton.addTarget(self, action: #selector(doneEdit), for: .touchUpInside)
        doneButton.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        doneButton.isEnabled = false
        
        headerView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        avatar.avatarInfo = avatarInfo
        avatar.buttonForAvatar.removeAllTargets()
        avatar.snp.makeConstraints { (make) in
            make.width.height.equalTo(38)
            make.left.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        nameLabel.text = self.name
        nameLabel.setFontSize(with: 13, weight: .norm)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(avatar.snp.centerY)
            make.left.equalTo(avatar.snp.right).offset(5)
            make.right.greaterThanOrEqualToSuperview().offset(-15)
        }
        
        headerBottomLine.backgroundColor = TSColor.inconspicuous.disabled
        headerBottomLine.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.width.equalToSuperview()
            make.height.equalTo(0.7)
        }
        
        scrollView.alwaysBounceHorizontal = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInset = .zero
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.snp.makeConstraints { (make) in
            make.top.equalTo(headerBottomLine.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().inset(TSBottomSafeAreaHeight)
        }
        
        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        postCaptionView.placeholder = "placeholder_post_status".localized
        postCaptionView.returnKeyType = .default
        postCaptionView.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        postCaptionView.placeholderColor = TSColor.normal.disabled
        postCaptionView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        postCaptionView.delegate = self
        postCaptionView.textAlignment = .left
                
        //postCaptionView.insertText(postContent + "")
        postCaptionView.isScrollEnabled = false
        postCaptionView.showsVerticalScrollIndicator = false
        postCaptionView.showsHorizontalScrollIndicator = false
        let newSize = postCaptionView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        postCaptionView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().inset(5)
            make.right.equalToSuperview().offset(-5)
            make.height.equalTo(newSize.height)
        }
        
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonClicked), for: .touchUpInside)
        
        doneButton.setTitle("done".localized, for: .normal)
        doneButton.setTitleColor(.systemBlue, for: .normal)
        
        liveIcon.applyStyle(.custom(text: "text_live".localized.uppercased(), textColor: .white, backgroundColor: .red, cornerRadius: 0))
        liveIcon.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        liveIcon.frame = CGRect(origin: .zero, size: CGSize(width: 10, height: 0))
        liveIcon.sizeToFit()
        liveIcon.frame = CGRect(origin: .zero, size: liveIcon.size)
        
        HTMLManager.shared.removeHtmlTag(htmlString: postContent, completion: { [weak self] (content, userIdList) in
            guard let self = self else { return }
            self.userIdList = userIdList
            self.htmlAttributedText = content.attributonString().setTextFont(14).setlineSpacing(0)
            if let attributedText = self.htmlAttributedText {
                self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, self.userIdList)
            }
            self.postCaptionView.attributedText = self.htmlAttributedText
            self.postCaptionView.delegate?.textViewDidChange!(self.postCaptionView)
            self.adjustTextViewHeight(textView: self.postCaptionView)
        })
    }
    
    private func loadTopics() {
        guard topicList.count > 0 else { return }
        let paddingContainer = UIView()
        let stackView = UIStackView().configure {
            $0.axis = .horizontal
            $0.alignment = .leading
        }
        stackView.translatesAutoresizingMaskIntoConstraints = false
        for  topic in topicList {
            let tagLabel: UIButton = UIButton(type: .custom)
            tagLabel.backgroundColor = TSColor.main.theme.withAlphaComponent(0.15)
            tagLabel.setTitleColor(TSColor.main.theme, for: .normal)
            tagLabel.layer.cornerRadius = 3
            tagLabel.titleLabel?.font = UIFont.systemFont(ofSize: 10)
            tagLabel.contentEdgeInsets = UIEdgeInsets(top: 2, left: 5, bottom: 2, right: 5)
            tagLabel.setTitle(topic.topicTitle, for: .normal)
            tagLabel.isUserInteractionEnabled = true
            stackView.addArrangedSubview(tagLabel)
        }
        guard stackView.subviews.count > 0 else { return }
        stackView.addArrangedSubview(UIView())
        contentStackView.addArrangedSubview(paddingContainer)
        
        paddingContainer.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.top.centerX.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.height.equalTo(25)
        }
    }
    
    private func loadLocation() {
        guard let model = locationModel else {
            locationView.isHidden = true
            return
        }
        let paddingView = UIView()
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
        label.applyStyle(.regular(size: 12, color: .gray))
        
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
        locationView.isUserInteractionEnabled = false
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
    
    private func loadPictureView() {
        if videoUrl.count > 0 || localVideoFileUrl != nil {
            pictureView.isUseVideoFrameRule = true
        } else {
            pictureView.isUseVideoFrameRule = false
        }
        
        pictureView.models = pictures // 内部计算 size
        let playIcon = UIImageView(image: UIImage.set_image(named:"ico_video_play_list"))
        
        if videoUrl.count > 0 || localVideoFileUrl != nil {
            playIcon.isHidden = false
        } else {
            playIcon.isHidden = true
        }
        playIcon.center = CGPoint(x: pictureView.width / 2, y: pictureView.height / 2)
        pictureView.insertSubview(playIcon, at: pictureView.subviews.count)
        liveIcon.isHidden = true
        if videoUrl.count > 0 || localVideoFileUrl != nil {
            playIcon.isHidden = false
        } else {
            playIcon.isHidden = true
        }
        
        contentStackView.addArrangedSubview(pictureView)
        
        pictureView.snp.remakeConstraints {
            $0.width.equalToSuperview()
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(pictureView.frame.height)
        }
    }
    
    private func loadRepostView() {
        let paddingView = UIView()
        repostViewBgView.removeAllSubViews()
        contentStackView.addArrangedSubview(paddingView)
        paddingView.addSubview(repostViewBgView)
        repostViewBgView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(10)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        if repostID > 0, let type = repostType, type.isEmpty == false, let repostModel = repostModel {
            /// 如果有转发的内容，转发的卡片在文本下边
            let contentWidth = UIScreen.main.bounds.width - 58 - 13
            repostViewBgView.isHidden = false
            repostViewBgView.frame = CGRect(x: 58, y: 0, width: contentWidth, height: 0)
            repostViewBgView.snp.remakeConstraints {
                $0.centerX.centerY.equalToSuperview()
                $0.left.equalToSuperview().offset(10)
                $0.top.equalToSuperview()
                $0.height.equalTo(repostView.getSuperViewHeight(model: repostModel, superviewWidth: repostViewBgView.width))
            }
            repostModel.updataModelType()
            repostViewBgView.addSubview(repostView)
            repostView.cancelImageButton.addTap { [weak self] (_) in
                guard let self = self else { return }
                self.repostViewBgView.isHidden = true
                paddingView.isHidden = true
                self.repostModel = nil
            }
            repostView.updateUI(model: repostModel)
            repostView.bindToEdges()
        }
        else if let sharedModel = sharedModel {
            
            switch sharedModel.type {
            case .sticker:
                repostViewBgView.removeFromSuperview()
                paddingView.addSubview(feedSharedView)
                feedSharedView.translatesAutoresizingMaskIntoConstraints = false
                feedSharedView.updateUI(model: sharedModel)
                
                feedSharedView.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.right.equalToSuperview().inset(10)
                    $0.height.equalTo(100)
                }
                
            case .metadata:
                repostViewBgView.isHidden = false
                repostViewBgView.snp.remakeConstraints {
                    $0.centerX.centerY.equalToSuperview()
                    $0.left.right.equalToSuperview().inset(10)
                    $0.top.equalToSuperview()
                    $0.height.equalTo(100)
                }
                repostViewBgView.addSubview(repostView)
                repostView.cardShowType = .postView
                repostView.cancelImageButton.addTap { [weak self] (_) in
                    guard let self = self else { return }
                    self.repostViewBgView.isHidden = true
                    paddingView.isHidden = true
                    self.sharedModel = nil
                }
                repostView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                repostView.bindToEdges()
                
            default:
                repostViewBgView.removeFromSuperview()
                paddingView.addSubview(sharedView)
                contentStackView.addArrangedSubview(paddingView)
                sharedView.updateUI(model: sharedModel)
                
                sharedView.snp.remakeConstraints {
                    $0.top.bottom.equalToSuperview()
                    $0.left.right.equalToSuperview().inset(10)
                    $0.height.equalTo(100)
                }
            }
        } else {
            repostViewBgView.makeHidden()
            paddingView.makeHidden()
        }
    }
    
    @objc private func textViewResignResponder() {
        postCaptionView.resignFirstResponder()
    }
    
    /// 跳转到可选at人的列表
    private func pushAtSelectedList() {
        let atselectedListVC = TSAtPeopleAndMechantListVC()
        atselectedListVC.selectedBlock = { [weak self] (userInfo, userInfoModelType) in
            guard let self = self else { return }
            atselectedListVC.dismiss(animated: true, completion: nil)
            if let userInfo = userInfo {
                /// 先移除光标所在前一个at
                self.insertTagTextIntoContent(userId: userInfo.userIdentity, userName: userInfo.name)
                return
            }
        }
        self.present(TSNavigationController(rootViewController: atselectedListVC).fullScreenRepresentation, animated: true, completion: nil)
    }
    
    private func insertTagTextIntoContent(userId: Int? = nil, userName: String) {
//        self.postCaptionView = TSCommonTool.atMeTextViewEdit(self.postCaptionView) as! KMPlaceholderTextView
//        
//        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
//        let newMutableString = self.postCaptionView.attributedText.mutableCopy() as! NSMutableAttributedString
//        newMutableString.append(temp)
//        
//        self.postCaptionView.attributedText = newMutableString
//        //self.contentTextView.insertText(insertStr)
//        self.postCaptionView.delegate?.textViewDidChange!(postCaptionView)
//        self.postCaptionView.becomeFirstResponder()
    }
}

extension EditPostViewController {
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if keyboardHeight > 0 {
            return
        }
        
        if let userInfo = notification.userInfo, let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            self.keyboardHeight = endFrame.height
            UIView.animate(withDuration: 1, delay: duration, options: .showHideTransitionViews, animations: {
                self.scrollView.snp.updateConstraints { (make) in
                    make.bottom.equalToSuperview().inset(self.keyboardHeight)
                }
            }, completion: nil)
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        self.scrollView.snp.updateConstraints { (make) in
            make.bottom.equalToSuperview().inset(TSBottomSafeAreaHeight)
        }
        self.keyboardHeight = 0
    }
}

// MARK: - TextView Delegate
extension EditPostViewController: UITextViewDelegate {
    private func adjustTextViewHeight(textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: UIScreen.main.bounds.width - 10, height: CGFloat.greatestFiniteMagnitude))
        textView.frame.size.height = newSize.height
        
        // only update the textview height when newline is detected
        if newSize.height > lastTextViewHeight || newSize.height < lastTextViewHeight {
            postCaptionView.translatesAutoresizingMaskIntoConstraints = false
            postCaptionView.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().inset(5)
                make.right.equalToSuperview().offset(-5)
                make.height.equalTo(newSize.height)
            }
            postCaptionView.sizeToFit()
            postCaptionView.setNeedsLayout()
            postCaptionView.layoutIfNeeded()
            self.viewDidLayoutSubviews()
            self.scrollView.layoutIfNeeded()
            self.scrollView.layoutSubviews()
            lastTextViewHeight = newSize.height
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.adjustTextViewHeight(textView: textView)
        guard textView.text.isEmpty == false else {
            self.doneButton.isEnabled = false
            return
        }
        self.doneButton.isEnabled = true
        //self.postContent = textView.text
        
        if feedType == .normalText || (sharedModel != nil && sharedModel?.type == .metadata)  {
            checkLinkPreview(withText: textView.text)
        }
        
        // For format the tag people text
        let selectedRange = textView.markedTextRange
        if selectedRange == nil {
            HTMLManager.shared.formatTextViewAttributeText(textView, completion: {
                self.adjustTextViewHeight(textView: textView)
            })
            return
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
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
                HTMLManager.shared.formatTextViewAttributeText(textView, completion: {
                    self.adjustTextViewHeight(textView: textView)
                })
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        resignKeyboardGesture = UITapGestureRecognizer(target: self, action: #selector(textViewResignResponder))
        self.headerView.addGestureRecognizer(resignKeyboardGesture)
        self.contentStackView.addGestureRecognizer(resignKeyboardGesture)
        self.view.addGestureRecognizer(resignKeyboardGesture)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.headerView.removeGestureRecognizer(resignKeyboardGesture)
        self.contentStackView.removeGestureRecognizer(resignKeyboardGesture)
        self.view.removeGestureRecognizer(resignKeyboardGesture)
    }
    
    private func checkLinkPreview(withText: String?) {
        self.repostViewBgView.removeAllSubViews()
        let slp = SwiftLinkPreview()
        guard slp.extractURL(text: withText.orEmpty) != nil && ((self.repostViewBgView.isHidden == true) || (self.repostViewBgView.subviews.count == 0)) else {
            self.sharedModel = nil
            self.repostViewBgView.makeHidden()
            self.repostViewBgView.superview?.makeHidden()
            return
        }
        self.sharedModel = SharedViewModel.getModel(title: nil, description: nil, thumbnail: nil, url: nil, type: .metadata)
        guard let sharedModel = self.sharedModel else { return }
        let sharedView = TSRepostView(frame: .zero)
        repostViewBgView.makeVisible()
        repostViewBgView.superview?.makeVisible()
        repostViewBgView.addSubview(sharedView)
        sharedView.cardShowType = .postView
        sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
        sharedView.cancelImageButton.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.repostViewBgView.makeHidden()
            self.repostViewBgView.superview?.makeHidden()
            self.sharedModel = nil
        }
        sharedView.bindToEdges()
        sharedView.startShimmering(background: false)
        slp.preview(withText.orEmpty,
                    onSuccess: { [weak self] (result) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.repostViewBgView.removeAllSubViews()
                let sharedView = TSRepostView(frame: .zero)
                self.repostViewBgView.addSubview(sharedView)
                sharedView.cardShowType = .postView
                
                if var repostModel = self.repostModel {
                    repostModel.content = result.url?.absoluteString
                    repostModel.title = result.title
                    repostModel.coverImage = result.image
                    self.repostModel = repostModel
                    sharedView.updateUI(model: repostModel, shouldShowCancelButton: true)
                } else if var sharedModel = self.sharedModel {
                    sharedModel = SharedViewModel.getModel(title: result.title, description: result.description, thumbnail: result.image, url: result.url?.absoluteString, type: .metadata)
                    self.sharedModel = sharedModel
                    sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                }
                
                sharedView.cancelImageButton.addTap { [weak self] (_) in
                    guard let self = self else { return }
                    self.repostViewBgView.makeHidden()
                    self.repostViewBgView.superview?.makeHidden()
                    self.sharedModel = nil
                }
                
                sharedView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                    $0.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight + 15)
                }
                
                self.view.layoutIfNeeded()
            }
        }, onError: { [weak self] error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                defer {
                    self.view.layoutIfNeeded()
                }
                switch error {
                case .cannotBeOpened(let error):
                    self.repostViewBgView.removeAllSubViews()
                    let imageUrl = error?.description
                    guard let url = URL(string: imageUrl.orEmpty) else {
                        self.sharedModel = nil
                        return
                    }
                    self.sharedModel = SharedViewModel.getModel(title: "", description: url.host, thumbnail:imageUrl, url: imageUrl, type: .metadata)
                    guard let sharedModel = self.sharedModel else { return }
                    let sharedView = TSRepostView(frame: .zero)
                    self.repostViewBgView.addSubview(sharedView)
                    sharedView.cardShowType = .postView
                    sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                    sharedView.snp.makeConstraints {
                        $0.edges.equalToSuperview()
                        $0.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight + 15)
                    }
                    sharedView.cancelImageButton.addTap { [weak self] (_) in
                        guard let self = self else { return }
                        self.repostViewBgView.makeHidden()
                        self.repostViewBgView.superview?.makeHidden()
                        self.sharedModel = nil
                    }
                default:
                    self.sharedModel = nil
                    self.repostViewBgView.makeHidden()
                    self.repostViewBgView.superview?.makeHidden()
                    return
                }
                
            }
        })
    }
}

// MARK: - Custom Action Sheet Delegate
extension EditPostViewController: TSCustomAcionSheetDelegate {
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
