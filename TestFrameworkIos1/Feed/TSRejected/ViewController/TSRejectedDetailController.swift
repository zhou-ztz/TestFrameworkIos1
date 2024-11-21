//
//  TSRejectedDetailController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/21.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class TSRejectedDetailController: TSViewController {
    
    var onDelete: EmptyClosure?
    
    /// 动态id
    var feedId: String = ""
    
    var rejectDetailModel: RejectDetailModel?
    
    private let imgBgView: UIView = UIView()
    
    private let titleWarningContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private let paddingContainer = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private let titleView = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private lazy var readMoreLabel: TruncatableLabel = {
        return TruncatableLabel()
    }()
    
    private let labelForTitleIssue = UILabel().configure {
        $0.setFontSize(with: 14, weight: .norm)
        $0.textColor = UIColor(red: 0, green: 0, blue: 0)
        $0.numberOfLines = 0
    }
    
    private let titleIssueView: UIView = UIView().configure {
        $0.backgroundColor = UIColor(hex: 0xFCE1E1)
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 10
        $0.isHidden = true
    }
    
    private let ruleBtn: UIButton = UIButton().configure {
        $0.setTitle("what_is_community_guidelines".localized, for: .normal)
        $0.setTitleColor(AppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
        $0.isHidden = true
    }
    
    private let editBtn: StickerDownloadButton = StickerDownloadButton().configure {
        $0.setTitle("edit".localized, for: .normal)
        $0.setTitleColor(AppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
    }
    
    private let deleteBtn: UIButton = UIButton().configure {
        $0.setTitle("delete".localized, for: .normal)
        $0.setTitleColor(AppTheme.red, for: .normal)
        $0.set(font: .systemFont(ofSize: 14))
    }
    
    private let rightBarStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .horizontal
        $0.distribution = .fill
        $0.alignment = .center
        $0.spacing = 20
        $0.contentCompressionResistancePriority = .required
    }
    
    private let titleStackView: UIStackView = UIStackView(frame: .zero).configure {
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 8
    }
    
    private var scrollView: UIScrollView = UIScrollView().configure {
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = true
        $0.isHidden = true
    }
    
    private let imageSliderView: TSImageSliderView = TSImageSliderView.init(frame: CGRectMake(0, 0, ScreenWidth, 350))
    
    var htmlAttributedText: NSMutableAttributedString?
    
    // MARK: - Lifecycle
    init(feedId: String) {
        super.init(nibName: nil, bundle: nil)
        self.feedId = feedId
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        getData()
        // Do any additional setup after loading the view.
    }
    @objc func getData(){
        self.showLoading()
        RejectNetworkRequest().getRejectDetail(feedId: feedId) { [weak self] (responseModel) in
            defer {
                DispatchQueue.main.async {
                    self?.dismissLoading()
                    self?.scrollView.isHidden = false
                    self?.ruleBtn.isHidden = false
                }
            }
            self?.rejectDetailModel = responseModel
            self?.updateData(data: responseModel)
        } onFailure: { [weak self] (errorMessage) in
            defer {
                DispatchQueue.main.async {
                    self?.dismissLoading()
                    self?.scrollView.isHidden = false
                    self?.ruleBtn.isHidden = false
                }
            }
            if let errorMsg = errorMessage {
                self?.showError(message: errorMsg)
            } else {
                self?.showError(message: "network_is_not_available".localized)
            }
            self?.navigationController?.popViewController(animated: true)
        }
        
    }
    private func updateData(data: RejectDetailModel?) {
        guard let data = data else { return }
        
        if let feedContent = data.textModel?.feedContent {
            titleStackView.isHidden = false
            HTMLManager.shared.removeHtmlTag(htmlString: feedContent, completion: { [weak self] (content, userIdList) in
                guard let self = self else { return }
                self.htmlAttributedText = content.attributonString()
                if let attributedText = self.htmlAttributedText {
                    self.htmlAttributedText = HTMLManager.shared.formAttributeText(attributedText, userIdList)
                    if self.readMoreLabel != nil { self.readMoreLabel.setAttributeText(attString: attributedText, textColor: .black, allowTruncation: true) }
                } else {
                    if self.readMoreLabel != nil { self.readMoreLabel.setText(text: content, textColor: .black, allowTruncation: true) }
                }
            })
        }
        // 显示违规原因内容
        if let sensitiveContent = data.textModel?.sensitiveType {
            labelForTitleIssue.text = sensitiveContent
            titleIssueView.isHidden = false
        }
        guard let video = data.video, let coverPath = video.coverPath, !coverPath.isEmpty else {
            guard !data.images.isEmpty else {
                imageSliderView.isHidden = true
                imgBgView.isHidden = true
                return
            }
            let pictures = data.images
            imageSliderView.isHidden = pictures.isEmpty
            imgBgView.isHidden = pictures.isEmpty
            imageSliderView.imageModels = pictures
            imageSliderView.placeholder = "ic_rejected_default"
            return
        }
        imageSliderView.isHidden = false
        imgBgView.isHidden = false
        
        imageSliderView.imageModels = [RejectDetailModelImages(fileId: video.coverId, imagePath: coverPath, isSensitive: video.isSensitive, sensitiveType: video.sensitiveType)]

    }
    
    private func setupUI() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(-65)
        }
        //底部规则
        view.addSubview(ruleBtn)
        ruleBtn.addTap { [weak self] (v) in
            guard let self = self else { return }
            self.communityGuidelinesTapped()
        }
        ruleBtn.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(-23)
        }
        
        let mainStackView = UIStackView()
        mainStackView.axis = .vertical
        mainStackView.distribution = .fill
        mainStackView.spacing = 0
        scrollView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            // 设置高度约束，使其可以根据内容自动调整
            $0.bottom.equalToSuperview().offset(-8)
            $0.width.equalTo(scrollView.snp.width)
        }
        
        mainStackView.addArrangedSubview(imgBgView)
        mainStackView.addArrangedSubview(paddingContainer)
        mainStackView.addArrangedSubview(titleStackView)
        paddingContainer.snp.makeConstraints {
            $0.height.equalTo(11)
        }
        
        //======= cover =======
        imgBgView.snp.makeConstraints {
            $0.height.equalTo(350)
        }
        //Cover滑动视图
        imgBgView.addSubview(imageSliderView)
        imageSliderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        //======= content 文字内容 =======
        let titleIssueStackView = UIStackView()
        titleIssueStackView.axis = .horizontal
        titleIssueStackView.distribution = .fill
        titleIssueStackView.spacing = 8
        titleIssueView.addSubview(titleIssueStackView)
        
        titleIssueStackView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.trailing.bottom.equalToSuperview().offset(-10)
        }
        
        let warningImageView = UIImageView()
        warningImageView.image = UIImage.set_image(named: "ic_rejected_warning_icon")
        titleWarningContainer.addSubview(warningImageView)
        warningImageView.snp.makeConstraints {
            $0.size.equalTo(CGSizeMake(24, 24))
            $0.centerY.equalToSuperview()
        }
        
        titleIssueStackView.addArrangedSubview(titleWarningContainer)
        titleIssueStackView.addArrangedSubview(labelForTitleIssue)
        titleStackView.addArrangedSubview(titleView)
        
        if readMoreLabel != nil {
            titleView.addSubview(readMoreLabel)
            readMoreLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(5)
                $0.leading.equalToSuperview().offset(5)
                $0.trailing.equalToSuperview().offset(-5)
                $0.bottom.equalToSuperview().offset(-5)
            }
        }
        titleStackView.addArrangedSubview(titleIssueView)
        titleStackView.isHidden = true
        
        titleIssueView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }
        
        titleWarningContainer.snp.makeConstraints {
            $0.width.equalTo(30)
        }
        
        rightBarStackView.addArrangedSubview(editBtn)
        rightBarStackView.addArrangedSubview(deleteBtn)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarStackView)
        
        //设定一次高度
        scrollView.layoutIfNeeded()
        scrollView.contentSize = mainStackView.frame.size
        if readMoreLabel != nil {
            readMoreLabel.setText(text: "")
            readMoreLabel.numberOfLines = 0
            readMoreLabel.aliasColor = AppTheme.primaryBlueColor
            readMoreLabel.hashTagColor = AppTheme.primaryBlueColor
            readMoreLabel.httpTagColor = AppTheme.primaryBlueColor
        }
        labelForTitleIssue.text = ""
        
        deleteBtn.addTap { [weak self] (_) in
            let alert = TSAlertController(title: "delete".localized, message: "delete_confirmation".localized, style: .alert, hideCloseButton: true, animateView: true, allowBackgroundDismiss: false)
            alert.addAction(TSAlertAction(title: "delete".localized, style: TSAlertActionStyle.default, handler: { _ in
                guard let self = self else { return }
                TSMomentNetworkManager().deleteMoment( Int(self.feedId) ?? 0) { [weak self] (result) in
                    if result == true {
                        self?.navigationController?.popViewController(animated: true)
                        self?.onDelete?()
                    }
                }
            }))
            alert.addAction(TSAlertAction(title: "cancel".localized, style: TSAlertActionStyle.cancel, handler: { _ in
             
            }))
            self?.presentPopup(alert: alert)
        }
        
        editBtn.addTap { [weak self] (_) in
            guard let self = self, let rejectDetailModel = self.rejectDetailModel else { return }
            
            editBtn.showLoading()
            //被拒绝动态为视频动态
            if let video = rejectDetailModel.video, let videoPath = video.videoPath, let videoUrl = URL(string: videoPath) {
                // 创建一个表示网络视频文件的URL对象
                let asset = AVURLAsset(url: videoUrl)
                let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: asset)
                editBtn.hideLoading()
                var vc = PostShortVideoViewController(nibName: "PostShortVideoViewController", bundle: nil)
                vc.shortVideoAsset = ShortVideoAsset(coverImage: coverImage, asset: nil, recorderSession: nil, videoFileURL: videoUrl)
                vc.isMiniVideo = true
                vc.isFromEditFeed = true
                vc.feedId = self.feedId
                vc.coverId = video.coverId
                vc.videoId = video.videoId
                vc.tagVoucher = rejectDetailModel.tagVoucher
                if let extenVC = self.configureReleasePulseViewController(rejectDetailModel: rejectDetailModel, viewController: vc) as? PostShortVideoViewController{
                    vc = extenVC
                }
                if let feedContent = rejectDetailModel.textModel?.feedContent {
                    vc.preText = feedContent
                }
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            if rejectDetailModel.images.count > 0 {
                editBtn.hideLoading()
                var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: false)
                vc.selectedModelImages = rejectDetailModel.images ?? []
                if let feedContent = rejectDetailModel.textModel?.feedContent {
                    vc.preText = feedContent
                }
                vc.feedId = self.feedId
                vc.isFromEditFeed = true
                vc.tagVoucher = rejectDetailModel.tagVoucher
                if let extenVC = self.configureReleasePulseViewController(rejectDetailModel: rejectDetailModel, viewController: vc) as? TSReleasePulseViewController{
                    vc = extenVC
                }
                
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
                return
            }
            //被拒绝动态为纯文本
            if let feedContent = rejectDetailModel.textModel?.feedContent {
                self.editBtn.hideLoading()
                var vc = TSReleasePulseViewController(isHiddenshowImageCollectionView: true, isText: true)
                vc.preText = feedContent
                vc.feedId = self.feedId
                vc.isFromEditFeed = true
                if let extenVC = self.configureReleasePulseViewController(rejectDetailModel: rejectDetailModel, viewController: vc) as? TSReleasePulseViewController{
                    vc = extenVC
                }
                
                let navigation = TSNavigationController(rootViewController: vc).fullScreenRepresentation
                self.present(navigation, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func communityGuidelinesTapped() {
        guard let url = Foundation.URL(string: WebViewType.communityGuidelines.urlString) else { return }
        let webVC = TSWebViewController(url: url, type: .defaultType, title: "community_guidelines".localized)
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
