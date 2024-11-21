//
//  TSReleaseDynamicViewController.swift
//  Thinksns Plus
//
//  Created by LeonFa on 2017/2/21.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  发布动态界面
// 图片付费的信息绑定思路:
//

import UIKit
import KMPlaceholderTextView
import Photos
import CoreLocation
import SDWebImage
import TZImagePickerController

import MobileCoreServices
import SwiftLinkPreview
import iOSPhotoEditor
//import NIMPrivate

typealias FoursquareLocation = TSPostLocationObject

// TODO: Handle file posting for selectedModelImages

class TSReleasePulseViewController: TSViewController, UITextViewDelegate, didselectCellDelegate, TSCustomAcionSheetDelegate, UIGestureRecognizerDelegate, TSSettingImgPriceVCDelegate, TZImagePickerControllerDelegate {
    /// 主承载视图
    @IBOutlet weak var postTokenView: PostTokenView!
    @IBOutlet weak var mainView: UIView!
    // 滚动视图高度
    @IBOutlet weak var scrollContentSizeHeight: NSLayoutConstraint!
    
    // 图片查看器的高度
    @IBOutlet weak var releaseDynamicCollectionViewHeight: NSLayoutConstraint!
    // 发布内容
    @IBOutlet weak var contentTextView: KMPlaceholderTextView!
    @IBOutlet weak var atView: UIView!
    /// 修饰后的发布内容
    var releasePulseContent: String {
        return contentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    var apiPulseContent: String = ""
    // 展示图片CollectionView
    @IBOutlet weak var showImageCollectionView: TSReleasePulseCollectionView!
    // 滚动视图
    @IBOutlet weak var mainScrollView: UIScrollView!
    // 展示文本字数
    @IBOutlet weak var showWordsCountLabel: UILabel!
    @IBOutlet weak var switchPayInfoView: TSSwitchPayInfoView!
    @IBOutlet weak var topicView: UIView!
    @IBOutlet weak var topicViewHeight: NSLayoutConstraint!
    @IBOutlet weak var repostBgView: UIView!
    @IBOutlet weak var repostBgViewHeight: NSLayoutConstraint!
    /// Permission
    @IBOutlet weak var privacyView: UIView!
    @IBOutlet weak var privacyValueLabel: UILabel!
    @IBOutlet weak var privacyTitleLabel: UILabel!
    @IBOutlet weak var privacyArrowImageView: UIImageView!
    @IBOutlet weak var tagTitleLabel: UILabel!
    @IBOutlet weak var tagArrowImageView: UIImageView!
    @IBOutlet weak var checkInView: UIView!
    @IBOutlet weak var checkInLabel: UILabel!
    @IBOutlet weak var checkInLocationLabel: UILabel!
    @IBOutlet weak var checkInArrowImageView: UIImageView!
    @IBOutlet weak var contentStackView: UIStackView!
    //文本内容展开/收起 按钮
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var voucherView: UIView!
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var voucherLabel: UILabel!
    @IBOutlet weak var addVoucher: UILabel!
    @IBOutlet weak var contentTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var voucherConstantH: NSLayoutConstraint!
    @IBOutlet weak var voucherInfoView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    var privacyType: PrivacyType = .everyone {
        didSet {
            self.privacyValueLabel.text = privacyType.localizedString
        }
    }
    // cell个数
    let cellCount: CGFloat = 4.0
    // cell行间距
    let spacing: CGFloat = 5.0
    // 最大标题字数
    let maxtitleCount: Int = 30
    // 最大内容字数
    let maxContentCount: Int = 255
    // 显示字数时机
    let showWordsCount: Int = 200
    // contentTextView是否滚动的行数
    let contentTextViewScrollNumberLine = 7
    // 发布按钮（还没判断有无图片时的点击逻辑）
    // 最大图片张叔
    let maxPhotoCount: Int = 9
    private let slp = SwiftLinkPreview()
    
    var releaseButton = TSTextButton.initWith(putAreaType: .top)
    // 记录collection高度
    var releaseDynamicCollectionViewSourceHeight: CGFloat = 0.0
    /// 选择图片数据对应数据
    var selectedPHAssets: [PHAsset] = []
    /// 选择图片数据对应数据
    //    var selectedModelImages: [UIImage] = []
    /// 选择图片数据对应数据
    var selectedModelImages: [Any] = []
    
    var selectedText: String = ""
    
    /// 支付信息
    //    var imagesPayInfo: [TSImgPrice] = [TSImgPrice]()
    // 是否隐藏CollectionView
    var isHiddenshowImageCollectionView = false
    // 是否开启图片支付
    var isOpenImgsPay = false
    // 键盘高度
    var currentKbH: CGFloat = 0
    
    ///从话题进入的发布页面自带一个不能删除的话题
    var chooseModel: TopicCommonModel?
    
    /// 话题信息
    var topics: [TopicCommonModel] = []
    /// 转发信息
    var repostModel: TSRepostModel?
    
    var sharedModel: SharedViewModel?
    
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
    
    // By Kit Foong (Check is it mini program)
    var isMiniProgram: Bool = false
    var isFromShareExtension: Bool = false
    var postPhotoExtension =  [PostPhotoExtension]()
    //动态ID
    var feedId: String?
    //是否从(驳回动态/编辑)页面来
    var isFromEditFeed: Bool = false
    
    var isPost: Bool = false
    
    private let beanErrorLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 12, color: UIColor(red: 209, green: 77, blue: 77)))
        label.text = "socialtoken_post_hot_feed_alert".localized
        label.textAlignment = .right
        
        return label
    }()
    
    var isTapOtherView = false
    var isPriceTextFiledTap = false
    var isReposting = false
    var isText = false
    var currentIndex = 0
    private var taggedLocation: FoursquareLocation? {
        willSet  {
            guard let checkedIn = newValue else {
                checkInLocationLabel.text = ""
                return
            }
            checkInLocationLabel.text = checkedIn.locationName
        }
    }
    var preText: String? = nil
    var voucherId: Int?
    var voucherName: String?
    var tagVoucher: TagVoucherModel?
    var isVoucherRemoved: Bool = false
    
    init(isHiddenshowImageCollectionView: Bool,isText:Bool = false, isReposting:Bool = false) {
        super.init(nibName: "TSReleasePulseViewController", bundle: nil)
        self.isText = isText
        self.isReposting = isReposting
        self.isHiddenshowImageCollectionView = isHiddenshowImageCollectionView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShowNotificationProcess(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHideNotificationProcess(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldBeginEditingNotificationProcess(_:)), name: UITextField.textDidBeginEditingNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fieldEndEditingNotificationProcess(_:)), name: UITextField.textDidEndEditingNotification, object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
        
        if selectedText != "" {
            self.contentTextView.insertText(selectedText)
            contentTextView.delegate?.textViewDidChange!(contentTextView)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
        //        NotificationCenter.default.addObserver(self, selector: #selector(topicChooseNotice(notice:)), name: NSNotification.Name(rawValue: "passPublishTopicData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateContentTextViewTag(_:)), name: NSNotification.Name(rawValue: "isTaggingPost"), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - setUI
    fileprivate func setUI() {
        
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
        
        switchPayInfoView.isHidden = true //!TSAppConfig.share.localInfo.isFeedPay
        /// 限制输入文本框字数
        contentTextView.placeholder = "placeholder_post_status".localized
        contentTextView.returnKeyType = .default    // 键盘的return键为换行样式
        contentTextView.font = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        //允许非焦点状态下仍然可以滚动
        contentTextView.isScrollEnabled = true
        //显示垂直滚动条
        contentTextView.showsVerticalScrollIndicator = true
        contentTextView.placeholderColor = TSColor.normal.disabled
        contentTextView.placeholderFont = UIFont.systemFont(ofSize: TSFont.ContentText.text.rawValue)
        contentTextView.delegate = self
        contentTextView.textAlignment = .left
        showImageCollectionView.didselectCellDelegate = self
        releaseDynamicCollectionViewSourceHeight = (UIScreen.main.bounds.size.width - 40 - spacing * 3) / cellCount + 1
        releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
        
        showImageCollectionView.isHidden = isHiddenshowImageCollectionView
        
        expandCollapseButton.setBackgroundImage(UIImage.set_image(named: "ic_rl_expand"), for: .normal)
        expandCollapseButton.setBackgroundImage(UIImage.set_image(named: "ic_rl_collapse"), for: .selected)
        expandCollapseButton.roundCorner(14)
        expandCollapseButton.backgroundColor = .lightGray.withAlphaComponent(0.4)
        expandCollapseButton.addTarget(self, action: #selector(expandCollapseButtonTapped(_:)), for: .touchUpInside)
        
        // set btns
        let cancelButton = TSTextButton.initWith(putAreaType: .top)
        cancelButton.setTitle("cancel".localized, for: .normal)
        cancelButton.contentHorizontalAlignment = .left
        cancelButton.addTarget(self, action: #selector(tapCancelButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        releaseButton.setTitle("publish".localized, for: .normal)
        releaseButton.addTarget(self, action: #selector(releasePulse), for: .touchUpInside)
        releaseButton.contentHorizontalAlignment = .right
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: releaseButton)
        releaseButton.isEnabled = false
        showImageCollectionView.maxImageCount = (maxPhotoCount - selectedModelImages.count)
        self.topicView.isHidden = true
        setTopicViewUI(showTopic: true, topicData: topics)
        let atViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapAtView))
        atView.addGestureRecognizer(atViewTap)
        
        tagTitleLabel.text = "tag_title_ppl_merchant".localized
        
        privacyArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        tagArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        arrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        checkInArrowImageView.image = UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
        
        /// Privacy view setup
        setPrivacyView()
        
        setCheckInView()
        
        setVoucherView()
        
        // 有转发内容
        if let model = self.repostModel {
            
            let repostView = TSRepostView(frame: CGRect.zero)
            repostBgView.addSubview(repostView)
            repostView.cardShowType = .postView
            repostView.bindToEdges()
            
            repostView.updateUI(model: model, shouldShowCancelButton: true)
            repostBgViewHeight.constant = 100
            // 隐藏付费选择器
            switchPayInfoView.isHidden = true
            // 增加底部分割线
            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
            topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topicBottomline)
            topicBottomline.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
            
        } else if let model = self.sharedModel {
            
            let sharedView = TSRepostView(frame: .zero)
            repostBgView.addSubview(sharedView)
            sharedView.cardShowType = .postView
            sharedView.updateUI(model: model)
            repostBgViewHeight.constant = 100
            sharedView.bindToEdges()
            // 隐藏付费选择器
            switchPayInfoView.isHidden = true
            // 增加底部分割线
            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
            topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topicBottomline)
            topicBottomline.snp.makeConstraints { (make) in
                make.top.left.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
            
        } else {
            // 普通发布
            repostBgView.makeHidden()
        }
        
        view.layoutIfNeeded()
    }
    
    @IBAction func tapScrollView(_ sender: UITapGestureRecognizer) {
        textViewResignFirstResponder()
    }
    
    // By Kit Foong (Check is valid url)
    private func isReachable(url: URL, completion: @escaping (Bool) -> ()) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        URLSession.shared.dataTask(with: request) { _, response, _ in
            completion((response as? HTTPURLResponse)?.statusCode == 200)
        }.resume()
    }
    
    private func checkLinkPreview(withText: String?) {
        self.repostBgView.removeAllSubViews()
        guard slp.extractURL(text: withText.orEmpty) != nil && (self.repostBgView.subviews.count == 0) else {
            self.sharedModel = nil
            return
        }
        
        var isValidUrl: Bool = false
        var url = slp.extractURL(text: withText.orEmpty)!
        
        let group = DispatchGroup()
        group.enter()
        
        if url != nil {
            self.isReachable(url: url, completion:  { success in
                isValidUrl = success
                
                group.leave()
            })
        } else {
            group.leave()
        }
        
        group.notify(queue: .global(), execute: {
            if isValidUrl == false {
                return
            }
            
            if TSUtil.checkIsDeepLink(urlString: withText ?? "") {
                return
            }
            
            DispatchQueue.main.async {
                self.sharedModel = SharedViewModel.getModel(title: nil, description: nil, thumbnail: nil, url: nil, type: .metadata)
                guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView, let switchPayInfoView = self.switchPayInfoView , let topicView = self.topicView else { return }
                let sharedView = TSRepostView(frame: .zero)
                repostBgView.makeVisible()
                repostBgView.addSubview(sharedView)
                sharedView.cardShowType = .postView
                sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                self.repostBgViewHeight.constant = 100
                sharedView.bindToEdges()
                repostBgView.startShimmering(background: false)
                
                // 隐藏付费选择器
                switchPayInfoView.isHidden = true
                // 增加底部分割线
                let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
                topicView.addSubview(topicBottomline)
                self.slp.preview(withText.orEmpty,
                                 onSuccess: { [weak self] (result) in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.repostBgView.stopShimmering()
                        self.repostBgView.removeAllSubViews()
                        self.sharedModel = SharedViewModel.getModel(title: result.title, description: result.description, thumbnail: result.image, url: result.url?.absoluteString, type: .metadata)
                        guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView, let switchPayInfoView = self.switchPayInfoView , let topicView = self.topicView else { return }
                        let sharedView = TSRepostView(frame: .zero)
                        repostBgView.addSubview(sharedView)
                        sharedView.cardShowType = .postView
                        sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                        self.repostBgViewHeight.constant = 100
                        sharedView.snp.makeConstraints {
                            $0.edges.equalToSuperview()
                            $0.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight + 15)
                        }
                        
                        
                        // 隐藏付费选择器
                        switchPayInfoView.isHidden = true
                        // 增加底部分割线
                        let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                        topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
                        topicView.addSubview(topicBottomline)
                        topicBottomline.snp.makeConstraints { (make) in
                            make.top.left.right.equalToSuperview()
                            make.height.equalTo(0.5)
                        }
                        
                        self.view.layoutIfNeeded()
                    }
                },
                                 onError: { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        defer {
                            self.view.layoutIfNeeded()
                        }
                        switch error {
                        case .cannotBeOpened(let error):
                            self.repostBgView.stopShimmering()
                            self.repostBgView.removeAllSubViews()
                            let imageUrl = error?.description
                            guard let url = URL(string: imageUrl.orEmpty) else {
                                self.sharedModel = nil
                                return
                            }
                            
                            self.sharedModel = SharedViewModel.getModel(title: "", description: url.host, thumbnail:imageUrl , url: imageUrl, type: .metadata)
                            guard let sharedModel = self.sharedModel, let repostBgView = self.repostBgView, let switchPayInfoView = self.switchPayInfoView , let topicView = self.topicView else { return }
                            let sharedView = TSRepostView(frame: .zero)
                            repostBgView.addSubview(sharedView)
                            sharedView.cardShowType = .postView
                            sharedView.updateUI(model: sharedModel, shouldShowCancelButton: true)
                            self.repostBgViewHeight.constant = 100
                            sharedView.snp.makeConstraints {
                                $0.edges.equalToSuperview()
                                $0.height.equalTo(TSRepostViewUX.postUIPostVideoCardHeight + 15)
                            }
                            
                            
                            // 隐藏付费选择器
                            switchPayInfoView.isHidden = true
                            // 增加底部分割线
                            let topicBottomline = UIView(frame: CGRect(x: 0, y: 50, width: ScreenWidth, height: 0.5))
                            topicBottomline.backgroundColor = TSColor.inconspicuous.disabled
                            topicView.addSubview(topicBottomline)
                            topicBottomline.snp.makeConstraints { (make) in
                                make.top.left.right.equalToSuperview()
                                make.height.equalTo(0.5)
                            }
                        default:
                            self.sharedModel = nil
                            return
                        }
                    }
                })
            }
        })
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        isTapOtherView = true
        if !contentTextView.isFirstResponder && !toolView.isHidden {
            toolView.isHidden = true
        }
        if touch.view == mainScrollView || touch.view == showImageCollectionView {
            return true
        }
        return false
    }
    
    fileprivate func calculationCollectionViewHeight() {
        if isFromShareExtension {
            switch postPhotoExtension.count {
            case 0...3:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
            case 4...7:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
            case 8...9:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
            default:
                break
            }
        } else {
            switch selectedPHAssets.count + selectedModelImages.count {
            case 0...3:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight
            case 4...7:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 2 + spacing
            case 8...9:
                releaseDynamicCollectionViewHeight.constant = releaseDynamicCollectionViewSourceHeight * 3 + 2 * spacing
            default:
                break
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
            let searchVC = LocationPOISearchViewController()
            searchVC.onLocationSelected = setLocationBlock
            
            let presentingVC = TSNavigationController(rootViewController: searchVC).fullScreenRepresentation
            self?.navigationController?.present(presentingVC, animated: true, completion: nil)
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
    
    /// 发布按钮是否可点击
    fileprivate func setReleaseButtonIsEnabled() {
        if self.isReposting {
            releaseButton.isEnabled = true
        } else {
            if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty || !selectedModelImages.isEmpty{
                releaseButton.isEnabled = true
            } else {
                releaseButton.isEnabled = false
            }
        }
    }
    
    // MARK: - tapButton
    @objc fileprivate func tapCancelButton() {
        textViewResignFirstResponder()
        if !releasePulseContent.isEmpty || !selectedPHAssets.isEmpty || !postPhotoExtension.isEmpty {
            let actionsheetView = TSCustomActionsheetView(titles: ["warning_cancel_post_status".localized, "confirm".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 2
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
        } else {
            if self.isMiniProgram {
                self.navigationController?.popViewController(animated: true)
            } else {
                let _ = self.navigationController?.dismiss(animated: true, completion: {})
            }
        }
    }
    
    func returnSelectTitle(view: TSCustomActionsheetView, title: String, index: Int) {
        if view.tag == 2 {
            let _ = self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - tapSend
    fileprivate  func textViewResignFirstResponder() {
        contentTextView.resignFirstResponder()
        packUpKey()
        switchPayInfoView.priceTextFieldResignFirstResponder()
    }
    
    fileprivate  func setShowImages() {
        self.showImageCollectionView.imageDatas.removeAll()
        var payinfos: [TSImgPrice] = []
        if isFromShareExtension {
            for item in postPhotoExtension {
                var image: UIImage!
                if item.type == kUTTypeGIF as String {
                    image = UIImage.gif(data: item.data!)
                } else {
                    image = UIImage(data: item.data!)
                }
                image.TSImageMIMEType = item.type!
                self.showImageCollectionView.imageDatas.append(image)
                // payinfos.append(item.payInfo)
                
            }
            
            let pi: UIImage? = postPhotoExtension.count < maxPhotoCount ? UIImage.set_image(named: "img_edit_photo_frame") : nil
            if let pi = pi {
                self.showImageCollectionView.imageDatas.append(pi)
            }
            self.showImageCollectionView.imageShare = self.postPhotoExtension
            self.showImageCollectionView.fromShare = true
            self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
            self.showImageCollectionView.reloadData()
            self.calculationCollectionViewHeight()
            
        }else {
            for item in selectedModelImages {
                if let imageItem = item as? RejectDetailModelImages {
                    self.showImageCollectionView.imageDatas.append(imageItem.imagePath ?? "")
                }
                if let image = item as? UIImage {
                    self.showImageCollectionView.imageDatas.append(image)
                }
            }
            for item in selectedPHAssets {
                
                let option = PHImageRequestOptions()
                option.isSynchronous = true
                PHCachingImageManager.default().requestImageData(for: item, options: option) { [weak self] (data, type, orientation, info) in
                    guard let data = data, let type = type, let self = self else { return }
                    var image: UIImage!
                    if type == kUTTypeGIF as String {
                        image = UIImage.gif(data: data)
                    } else {
                        image = UIImage(data: data)
                    }
                    image.TSImageMIMEType = type
                    self.showImageCollectionView.imageDatas.append(image)
                    payinfos.append(item.payInfo)
                }
            }
            
            let pi: UIImage? = (selectedPHAssets.count + selectedModelImages.count) < maxPhotoCount ? UIImage.set_image(named: "img_edit_photo_frame") : nil
            if let pi = pi {
                self.showImageCollectionView.imageDatas.append(pi)
            }
            self.showImageCollectionView.imagePHAssets = self.selectedPHAssets
            self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
            self.showImageCollectionView.reloadData()
            self.calculationCollectionViewHeight()
        }
    }
    
    // MARK: - 点击了相册按钮
    func didSelectCell(index: Int) {
        textViewResignFirstResponder()
        
        TSUtil.checkAuthorizeStatusByType(type: .cameraAlbum, viewController: self, completion: {
            DispatchQueue.main.async {
                self.currentIndex = index
                if self.isOpenImgsPay == false {
                    self.clearImgPayInfo()
                }
                if self.isFromShareExtension {
                    if index + 1 > self.postPhotoExtension.count { // 点击了相册选择器,进入图片查看器
                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets) { [weak self] (assets, _, _, _, _) in
                            for asset in assets {
                                let manager = PHImageManager.default()
                                let options = PHImageRequestOptions()
                                
                                options.version = .original
                                options.isSynchronous = true
                                manager.requestImageData(for: asset, options: options) { data, uti, _, _ in
                                    if let data = data {
                                        self?.postPhotoExtension.append(PostPhotoExtension(data: data as Data, type: uti))
                                    }
                                }
                            }
                            self?.setShowImages()
                        }
                    } else {
                        if self.isOpenImgsPay == true {
                            self.editPhotoVC(asset: nil, photo: self.postPhotoExtension[index])
                            //openImgsPayEnterPreViewVC(index: index)
                        } else {
                            self.editPhotoVC(asset: nil, photo: self.postPhotoExtension[index])
                            //closeImgsPayEnterPreViewVC(index: index)
                        }
                    }
                } else {
                    if index + 1 > (self.selectedPHAssets.count + self.selectedModelImages.count) { // 点击了相册选择器,进入图片查看器
                        self.showCameraVC(true, selectedAssets: self.selectedPHAssets, selectedImages: self.selectedModelImages) { [weak self] (assets, _, _, _, _) in
                            self?.selectedPHAssets = assets
                            self?.setShowImages()
                        }
                    } else {
                        if index < self.selectedModelImages.count {
                            if let imageModel = self.selectedModelImages[index] as? RejectDetailModelImages {
                                self.editPhotoVC(imageURL: imageModel.imagePath ?? "", photo: nil)
                            }
                            if let image = self.selectedModelImages[index] as? UIImage {
                                self.editPhotoVC(image: image, photo: nil)
                            }
                        } else {
                            if self.isOpenImgsPay == true {
                                self.editPhotoVC(asset: self.selectedPHAssets[index - self.selectedModelImages.count], photo: nil)
                                //openImgsPayEnterPreViewVC(index: index)
                            } else {
                                self.editPhotoVC(asset: self.selectedPHAssets[index - self.selectedModelImages.count], photo: nil)
                                //closeImgsPayEnterPreViewVC(index: index)
                            }
                        }
                        //                if self.isOpenImgsPay == true {
                        //                    editPhotoVC(asset: self.selectedPHAssets[index], photo: nil)
                        //                    //openImgsPayEnterPreViewVC(index: index)
                        //                } else {
                        //                    editPhotoVC(asset: self.selectedPHAssets[index], photo: nil)
                        //                    //closeImgsPayEnterPreViewVC(index: index)
                        //                }
                    }
                }
            }
        })
    }
    
    func didSelectedPayInfoBtn(btn: UIButton) {
        let index = btn.tag
        let payInfo = selectedPHAssets[index].payInfo
        pushToPaySetting(imagePrice: payInfo, index: index)
    }
    
    func didTapDeleteImageBtn(btn: UIButton) {
        let index = btn.tag
        releaseButton.isEnabled = true
        if isFromShareExtension {
            if postPhotoExtension.count > index {
                postPhotoExtension.remove(at: index)
            }
            
            if postPhotoExtension.count == 0 {
                textViewResignFirstResponder()
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
        } else {
            if index < selectedModelImages.count {
                self.selectedModelImages.remove(at: index)
            } else {
                if selectedPHAssets.count > index - selectedModelImages.count {
                    selectedPHAssets.remove(at: index - selectedModelImages.count)
                }
            }
            if selectedPHAssets.count == 0 && !self.isFromEditFeed {
                textViewResignFirstResponder()
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
        }
        if (selectedPHAssets.count + selectedModelImages.count) == 0 && self.isFromEditFeed {
            releaseButton.isEnabled = false
        }
        
        self.setShowImages()
    }
    
    func closeImgsPayEnterPreViewVC(index: Int) {
//        var imagesPayInfo: [TSImgPrice] = []
//        for item in selectedPHAssets {
//            imagesPayInfo.append(item.payInfo)
//        }
//        let previewController = CustomPHPreViewVC(currentIndex: index, assets: selectedPHAssets, isShowSettingPay: isOpenImgsPay, payInfo: imagesPayInfo)
//        previewController.setFinish { [unowned self] in
//            self.selectedPHAssets = previewController.selectedAssets
//            self.setShowImages()
//            let _ = self.navigationController?.popViewController(animated: true)
//        }
//        previewController.setDismiss {
//            // 根据旧的支付信息显示旧的支付配置和图片
//        }
//        navigationController?.pushViewController(previewController, animated: true)
    }
    
    func openImgsPayEnterPreViewVC(index: Int) {
//        var imagesPayInfo: [TSImgPrice] = []
//        for item in selectedPHAssets {
//            imagesPayInfo.append(item.payInfo)
//        }
//        let previewController = CustomPHPreViewVC(currentIndex: index, assets: selectedPHAssets, isShowSettingPay: isOpenImgsPay, payInfo: imagesPayInfo)
//        previewController.setFinish { [unowned self] in
//            self.selectedPHAssets = previewController.selectedAssets
//            for (index, item) in previewController.payInfo.enumerated() {
//                let imageAsset = self.selectedPHAssets[index]
//                imageAsset.payInfo = item
//            }
//            // 有图 显示图
//            if self.selectedPHAssets.isEmpty == false {
//                self.setShowImages()
//            } else {
//                // 没图 关闭支付模式
//                self.isOpenImgsPay = false
//                self.switchPayInfoView.paySwitch.isOn = false
//                self.selectedPHAssets = []
//                self.setShowImages()
//            }
//            let _ = self.navigationController?.popViewController(animated: true)
//        }
//        previewController.setDismiss {
//            // 根据旧的支付信息显示旧的支付配置和图片
//        }
//        navigationController?.pushViewController(previewController, animated: true)
    }
    
    // MARK: - packageImagesPayInfo
    fileprivate func imagesPayInfoConvert(shouldPay: Bool) {
        var payInfoArray = [TSImgPrice?]()
        for _ in selectedPHAssets {
            if shouldPay == true {
                payInfoArray.append(TSImgPrice(paymentType: .not, sellingPrice: 0))
            } else {
                payInfoArray.append(nil)
            }
        }
        let pi: UIImage? = selectedPHAssets.count < (maxPhotoCount - selectedModelImages.count) ? UIImage.set_image(named: "img_edit_photo_frame") : nil
        if pi != nil {
            payInfoArray.append(nil)
        }
        self.showImageCollectionView.shoudSetPayInfo = self.isOpenImgsPay
    }

    // MARK: - 图片支付信息相关
    func clearImgPayInfo() {
        for item in selectedPHAssets {
            let imgPrice = TSImgPrice(paymentType: .not, sellingPrice: 0)
            item.payInfo = imgPrice
        }
    }
    // MARK: - 设置了付费信息
    func setsPrice(price: TSImgPrice, index: Int) {
        let imageAssets = selectedPHAssets[index]
        imageAssets.payInfo = price
        self.setShowImages()
    }
    
    @objc func emojiBtnClick() {
        smileButton.isSelected = !smileButton.isSelected
        if smileButton.isSelected {
            isTapOtherView = false
            contentTextView.resignFirstResponder()
        } else {
            contentTextView.becomeFirstResponder()
        }
    }
    @objc func packUpKey() {
        smileButton.isSelected = false
        contentTextView.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.toolView.isHidden = true
        }
    }
    
    func editPhotoVC(asset: PHAsset?, photo: PostPhotoExtension?){
        var image: UIImage!
        
        if isFromShareExtension {
            guard let data = photo?.data, let type = photo?.type else { return }
            if type == kUTTypeGIF as String {
                image = UIImage.gif(data: data)
            } else {
                image = UIImage(data: data)
            }
        } else {
            guard let asset = asset else { return }
            let option = PHImageRequestOptions()
            option.isSynchronous = true
            PHCachingImageManager.default().requestImageData(for: asset, options: option) { [weak self] (data, type, orientation, info) in
                guard let data = data, let type = type, let self = self else { return }
                if type == kUTTypeGIF as String {
                    image = UIImage.gif(data: data)
                } else {
                    image = UIImage(data: data)
                }
                
            }
        }
        DispatchQueue.main.async{
            if let photoEditor = AppUtil.shared.createPhotoEditor(for: image) {
                photoEditor.photoEditorDelegate = self
                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
            }
        }
    }
    func editPhotoVC(image: UIImage?, photo: PostPhotoExtension?){
        
        DispatchQueue.main.async{
            if let photoEditor = AppUtil.shared.createPhotoEditor(for: image) {
                photoEditor.photoEditorDelegate = self
                self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
            }
        }
    }
    func editPhotoVC(imageURL: String?, photo: PostPhotoExtension?){
        
        guard let imageURL = URL(string: imageURL ?? "") else {
            printIfDebug("Failed to load image data from URL")
            return
        }
        
        DispatchQueue.global().async {
            guard let imageData = try? Data(contentsOf: imageURL) else {
                printIfDebug("Failed to load image data from URL")
                return
            }
            
            guard let image = UIImage(data: imageData) else {
                printIfDebug("Failed to create UIImage from image data")
                return
            }
            
            DispatchQueue.main.async {
                if let photoEditor = AppUtil.shared.createPhotoEditor(for: image) {
                    photoEditor.photoEditorDelegate = self
                    self.present(photoEditor.fullScreenRepresentation, animated: true, completion: nil)
                }
            }
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
             self.contentTextView.becomeFirstResponder() // 打开键盘
         } else {
             self.contentTextViewHeight.constant = 150 // 收起时的高度
             self.contentTextView.resignFirstResponder() // 关闭键盘
         }
    }
}

// MARK: - TSSwitchPayInfoViewDelegate
extension TSReleasePulseViewController: TSSwitchPayInfoViewDelegate {
    func paySwitchValueChanged(_ paySwitch: UISwitch) {
        if isHiddenshowImageCollectionView {
            if paySwitch.isOn {
                view.endEditing(true)
            }
            return
        }
        isOpenImgsPay = paySwitch.isOn
        if paySwitch.isOn {
            imagesPayInfoConvert(shouldPay: true)
            // 切换到支付模式时，设置支付为空
            clearImgPayInfo()
        } else {
            imagesPayInfoConvert(shouldPay: false)
        }
        setShowImages()
    }
    
    // 点击了收费配置按钮
    func pushToPaySetting(imagePrice: TSImgPrice, index: Int) {
        // 读取旧的支付信息，然后传递给支付页面
        let settingPriceVC = TSSettimgPriceViewController(imagePrice: imagePrice)
        settingPriceVC.delegate = self
        settingPriceVC.enterIndex = index
        self.navigationController?.pushViewController(settingPriceVC, animated: true)
    }
}

// MARK: - Release btn tap
extension TSReleasePulseViewController {
    @objc fileprivate func releasePulse() {
        textViewResignFirstResponder()
        guard TSReachability.share.isReachable() != false else {
            self.showError(message: "connect_lost_check".localized)
            return
        }
        var pulseContent = self.releasePulseContent
        
        if let attributedString = self.contentTextView.attributedText {
            pulseContent = HTMLManager.shared.formHtmlString(attributedString)
        }
                
        if switchPayInfoView.paySwitchIsOn && selectedPHAssets.isEmpty { // 文字付费
            if switchPayInfoView.payPrice > 0 {
                if pulseContent.count <= TSAppConfig.share.localInfo.feedLimit {
                    let str = "warning_exceed".localized + "\(TSAppConfig.share.localInfo.feedLimit)" + "exceed_word_limit_need_pay".localized
                    let actionsheetView = TSCustomActionsheetView(titles: [str])
                    actionsheetView.delegate = self
                    actionsheetView.tag = 99
                    actionsheetView.notClickIndexs = [0]
                    actionsheetView.show()
                    return
                }
                releaseButton.isEnabled = false
                return
            }
            // 提示输入支付金额
            let actionsheetView = TSCustomActionsheetView(titles: ["please_set_limit_money"])
            actionsheetView.delegate = self
            actionsheetView.tag = 99
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            return
        }
        if switchPayInfoView.paySwitchIsOn && !selectedPHAssets.isEmpty { // 图片付费
            var setPayPrice = false
            for item in selectedPHAssets {
                let payInfo = item.payInfo
                if payInfo.paymentType != .not {
                    setPayPrice = true
                }
            }
            if setPayPrice == true {
                releaseButton.isEnabled = false
                return
            }
            // 提示输入支付金额
            let actionsheetView = TSCustomActionsheetView(titles: ["setting_at_least_one_pic_payment".localized])
            actionsheetView.delegate = self
            actionsheetView.tag = 99
            actionsheetView.notClickIndexs = [0]
            actionsheetView.show()
            return
        }
        releaseButton.isEnabled = false
        let postPHAssets = selectedPHAssets
        let postPulseContent = pulseContent
        if self.sharedModel?.url == nil {
            self.sharedModel = nil
        }
        
        if isVoucherRemoved {
            tagVoucher = nil
        } else {
            if let voucherId = self.voucherId, let voucherName = self.voucherName {
                tagVoucher = TagVoucherModel(taggedVoucherId: voucherId, taggedVoucherTitle: voucherName)
            } else {
                tagVoucher = nil
            }
        }
        
        let post = PostModel(feedMark: TSCurrentUserInfo.share.createResourceID(), isHotFeed: postTokenView.isEnabled == true, feedContent: postPulseContent, privacy: privacyType.rawValue, repostModel: repostModel, shareModel: sharedModel, topics: topics, taggedLocation: taggedLocation, phAssets: postPHAssets, postPhoto: postPhotoExtension, video: nil, soundId: nil, videoType: nil, postVideo: nil, isEditFeed: isFromEditFeed, feedId: feedId, images: selectedModelImages, rejectNeedsUploadVideo: nil, videoCoverId: nil, videoDataId: nil, tagUsers: selectedUsers, tagMerchants: selectedMerchants, tagVoucher: tagVoucher)
        
        PostTaskManager.shared.addTask(post)
        //        if isFromEditFeed == true {
        //            TSRootViewController.share.presentFeedHome(atIndex: 1)
        //        }else{
        //            self.navigationController?.dismiss(animated: true, completion: nil)
        //        }
        DispatchQueue.main.async {
            if self.isFromEditFeed == true {
                TSRootViewController.share.presentFeedHome(atIndex: 1, isEditPost: true)
            } else {
                self.isPost = true
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

// MARK: - TextViewDelegate
extension TSReleasePulseViewController {
    func textViewDidChange(_ textView: UITextView) {
        //only enable when post type = text
        if self.isText {
            checkLinkPreview(withText: textView.text)
        }
        
        setReleaseButtonIsEnabled()
        
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

// MARK: - Lifecycle
extension TSReleasePulseViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // 初始化时创建配置信息都为空
        imagesPayInfoConvert(shouldPay: false)
        if !selectedModelImages.isEmpty {
            
        }
        if !selectedPHAssets.isEmpty {
            setShowImages()
        }
        if !selectedModelImages.isEmpty {
            setShowImages()
        }
        if !postPhotoExtension.isEmpty {
            setShowImages()
        }
        if let privacy = self.rejectPrivacyType {
            self.privacyType = privacy
            self.privacyValueLabel.text = privacy.localizedString
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if let location = self.rejectLocation {
                self.taggedLocation = location
            }
        }
        
        switchPayInfoView.delegate = self
        switchPayInfoView.isHiddenMoreInfo = !isHiddenshowImageCollectionView
        
        setReleaseButtonIsEnabled()
        
        beanErrorLabel.sizeToFit()
        self.contentStackView.addArrangedSubview(beanErrorLabel)
        beanErrorLabel.isHidden = true
        
        postTokenView.isEnabled = false
        postTokenView.allowBean = selectedPHAssets.count > 0
        postTokenView.allowBean = postPhotoExtension.count > 0
        
        if let currentUser = CurrentUserSessionInfo {
            postTokenView.isHidden = !((currentUser.freeHotPost > 0) && (!currentUser.verificationType.orEmpty.isEmpty) && (TSAppConfig.share.launchInfo?.isSocialTokenEnabled == true))
        } else {
            postTokenView.isHidden = true
        }
        
        // Yellow Bean Removal
        postTokenView.isHidden = true
        
        postTokenView.onDisallow = { [weak self] in
            guard let self = self else { return }
            self.beanErrorLabel.makeVisible()
            self.postTokenView.isUserInteractionEnabled = self.beanErrorLabel.isHidden
        }
        if let text = self.preText, text.count > 0 {
            HTMLManager.shared.removeHtmlTag(htmlString: "\(text) ", completion: { [weak self] (content, userIdList) in
                guard let self = self else { return }
                var htmlAttributedText = content.attributonString()
                htmlAttributedText = HTMLManager.shared.formAttributeText(htmlAttributedText, userIdList)
                self.contentTextView.attributedText = htmlAttributedText
                self.contentTextView.delegate?.textViewDidChange!(contentTextView)
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.title = "title_post_status".localized
        setReleaseButtonIsEnabled()
        if mainView.frame.size.height > mainScrollView.bounds.height {
        } else {
            scrollContentSizeHeight.constant = mainScrollView.bounds.size.height - mainView.bounds.size.height + 1
        }
        self.updateViewConstraints()
        
        guard UserDefaults.socialTokenToolTipShouldHide == false else {
            // By Kit Foong (Added flag for checking isText)
            postTokenView.fetchHotBalances(shouldToggle: false, isText: self.isText)
            return
        }
        //showSocialTooltip()
        
        postTokenView.onError = { [weak self] (msg) in
            self?.showError(message: msg)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
}

// MARK: - Notification
extension TSReleasePulseViewController {
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
        self.kbProcessReset()
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
    
    @objc fileprivate func fieldBeginEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = true
        if !self.switchPayInfoView.paySwitch.isOn || !self.switchPayInfoView.priceTextField.isFirstResponder {
            return
        }
        let kbH: CGFloat = self.currentKbH
        let bottomH: CGFloat = ScreenHeight - self.mainView.bounds.size.height - 64.0
        if kbH > bottomH {
            UIView.animate(withDuration: 0.25) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -(kbH - bottomH) - 20.0)
            }
        }
    }
    @objc fileprivate func fieldEndEditingNotificationProcess(_ notification: Notification) -> Void {
        isPriceTextFiledTap = false
        self.kbProcessReset()
    }
    
    /// 键盘相关的复原
    fileprivate func kbProcessReset() -> Void {
        UIView.animate(withDuration: 0.25) {
            self.view.transform = CGAffineTransform.identity
        }
    }
    
}

// MARK: - 话题板块儿
extension TSReleasePulseViewController {
    /// 布局话题板块儿
    func setTopicViewUI(showTopic: Bool, topicData: [TopicCommonModel]) {
        topicView.removeAllSubViews()
        if showTopic {
            let topLine = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 0.5))
            topLine.backgroundColor = TSColor.inconspicuous.disabled
            topicView.addSubview(topLine)
            
            if topicData.isEmpty {
                let addTopicLabel = UILabel(frame: CGRect(x: 25, y: 0.5, width: 100, height: 49))
                addTopicLabel.text = "post_add_topic".localized
                addTopicLabel.textColor = UIColor(hex: 0x333333)
                addTopicLabel.font = UIFont.systemFont(ofSize: 15)
                topicView.addSubview(addTopicLabel)
                
                let rightIcon = UIImageView(frame: CGRect(x: ScreenWidth - 15 - 10, y: 0, width: 10, height: 20))
                rightIcon.clipsToBounds = true
                rightIcon.contentMode = .scaleAspectFill
                rightIcon.image =  UIImage.set_image(named: "IMG_ic_arrow_smallgrey")
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
                    bgView.image =  UIImage.set_image(named: "ico_topic_close")
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
                            addImage.image =  UIImage.set_image(named: "ico_add_topic")
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
            }
        } else {
            topicViewHeight.constant = 0
            topicView.updateConstraints()
        }
    }
    
    // MARK: - 搜索话题页面选择话题之后发通知处理话题板块儿
    @objc func topicChooseNotice(notice: Notification) {
        let dict: NSDictionary = notice.userInfo! as NSDictionary
        let model: TopicListModel = dict["topic"] as! TopicListModel
        let changeModel: TopicCommonModel = TopicCommonModel(topicListModel: model)
        /// 先检测已选的话题里面是不是已经有了当前选择的那个话题，如果有，不作处理（不添加到 topics数组里面），如果没有，直接添加进去
        var hasTopic = false
        if !topics.isEmpty {
            for (_, item) in topics.enumerated() {
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
    
    // MARK: - 话题板块儿选择话题跳转到搜索话题页面
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
    
    // MARK: - 话题板块儿删除话题按钮点击事件
    @objc func deleteTopic(tap: UIGestureRecognizer) {
        if !topics.isEmpty {
            topics.remove(at: (tap.view?.tag)! - 999)
            setTopicViewUI(showTopic: true, topicData: topics)
        }
    }
    
    // MARK: - 话题板块儿点击话题按钮删除话题
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
    
    // MARK: - 话题板块儿获取当前已选择的话题 id 然后组装成一个 id 数组（用于发布接口传值）
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
extension TSReleasePulseViewController {
    /// 点击了atView
    @objc func didTapAtView() {
        self.pushAtSelectedList()
    }
    /// 跳转到可选at人的列表
    func pushAtSelectedList() {
        let atselectedListVC = TSAtPeopleAndMechantListVC()
        self.present(TSNavigationController(rootViewController: atselectedListVC).fullScreenRepresentation, animated: true, completion: nil)
        atselectedListVC.selectedBlock = { [weak self] (userInfo, userInfoModelType) in
            guard let self = self else { return }
            atselectedListVC.dismiss(animated: true, completion: nil)
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
    }
    
    @objc func updateContentTextViewTag (_ noti: NSNotification) {
        
        if let userInfo = noti.userInfo as? Dictionary<String, Any>, userInfo["username"] != nil {
            let username = userInfo["username"] as! String
            /// 先移除光标所在前一个at
            insertTagTextIntoContent(userName: username)
        }
    }
    
    func insertTagTextIntoContent (userId: Int? = nil, userName: String) {
//        self.contentTextView = TSCommonTool.atMeTextViewEdit(self.contentTextView) as! KMPlaceholderTextView
        
        let temp = HTMLManager.shared.addUserIdToTagContent(userId: userId, userName: userName)
        let newMutableString = self.contentTextView.attributedText.mutableCopy() as! NSMutableAttributedString
        newMutableString.append(temp)
        
        self.contentTextView.attributedText = newMutableString
        //self.contentTextView.insertText(insertStr)
        self.contentTextView.delegate?.textViewDidChange!(contentTextView)
        self.contentTextView.becomeFirstResponder()
        self.contentTextView.insertText("")
    }
}

extension TSReleasePulseViewController: TSSystemEmojiSelectorViewDelegate {
    func emojiViewDidSelected(emoji: String) {
        self.contentTextView.insertText(emoji)
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
}

//// MARK: - permission
extension TSReleasePulseViewController {
    
    func setPrivacyView() {
        privacyTitleLabel.text = "post_privacy".localized
        privacyValueLabel.text = privacyType.localizedString
        
        privacyView.addAction {
            
            self.textViewResignFirstResponder()
            
            let sheet = TSCustomActionsheetView(titles: PrivacyType.allCases.map { $0.localizedString }, cancelText: "cancel".localized)
            sheet.finishBlock = { _, _, index in
                self.privacyType = PrivacyType.getType(for: index)
            }
            sheet.show()
        }
    }
}

extension TSReleasePulseViewController: PhotoEditorDelegate{
    func doneEditing(image: UIImage) {
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { [weak self] (saved, error) in
                guard let self = self else { return }
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions).lastObject
                    
                    if self.isFromShareExtension {
                        if let result = result, self.postPhotoExtension.count > self.currentIndex {
                            let options = PHImageRequestOptions()
                            let manager = PHImageManager.default()
                            manager.requestImageData(for: result, options: options) { data, type, _, _ in
                                
                                if let data = data, let type = type {
                                    self.postPhotoExtension[self.currentIndex].data = data
                                    self.postPhotoExtension[self.currentIndex].type = type
                                }
                                DispatchQueue.main.async {
                                    self.setShowImages()
                                }
                            }
                        }
                    }else{
                        if self.selectedModelImages.count > 0 && self.currentIndex < self.selectedModelImages.count {
                            //编辑完的图片传回的时候 应该要怎么替换
                            self.selectedModelImages[self.currentIndex] = image
                        }else{
                            let index = self.currentIndex - self.selectedModelImages.count
                            if let result = result, self.selectedPHAssets.count > index {
                                let asset = self.selectedPHAssets[index]
                                result.payInfo = asset.payInfo
                                self.selectedPHAssets[index] = result
                            }
                        }
                        
                        DispatchQueue.main.async {
                            self.setShowImages()
                        }
                    }
                }
            }
        })
        
    }
    
    func canceledEditing() {
        
    }
}

enum PrivacyType: String, CaseIterable {
    case everyone
    case friends
    case `self`
    
    static func getType(for index: Int) -> PrivacyType {
        switch index {
        case 0:
            return .everyone
        case 1:
            return .friends
        default:
            return .`self`
        }
    }
    
    var localizedString: String {
        switch self {
        case .everyone:
            return "everyone".localized
        case .friends:
            return "friends_only".localized
        case .`self`:
            return "me_only".localized
        }
    }
}

extension TSReleasePulseViewController: SuggestVoucherDelegate {
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
