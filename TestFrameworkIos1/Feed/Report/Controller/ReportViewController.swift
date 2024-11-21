//
//  ReportViewController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 14/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  举报界面(所有的举报都在这里)

import UIKit
import SVProgressHUD
import IQKeyboardManagerSwift
import TZImagePickerController

class ReportViewController: TSViewController {
    // MARK: - Internal Property
    
    let model: ReportTargetModel
    
    // MARK: - Internal Function
    // MARK: - Private Property
    
    //fileprivate weak var topView: UIView!
    fileprivate weak var reportBtn: UIButton!
    
    fileprivate let lrMargin: CGFloat = 10
    fileprivate let inputMargin: CGFloat = 10
    
    fileprivate weak var reportPromptLabel: UILabel!
    fileprivate weak var reportedUserNameBtn: UIButton!
    fileprivate weak var reportedTargetPromptLabel: UILabel!
    
    fileprivate weak var reportTargetView: ReportTargetControl!
    
    fileprivate weak var reportTextView: UITextView!
    fileprivate weak var reportInputNumLabel: UILabel!
    fileprivate weak var reportImagesNumLabel: UILabel!
    fileprivate weak var inputPlaceHolder: UILabel!
    
    /// 输入最大字数限制
    fileprivate let inputMaxNum: Int = 255
    fileprivate let imagesMaxNum: Int = 3
    
    var collectionView: UICollectionView?
    var reportAttachments: [UIImage?] = [nil]
    var filesId: [Int] = []
    var reportTypesModel : [ReportTypeEntity] = []
    
    public var onReportComplete: (()->())?
    
    private let reportSelectionField: DynamicTextField = DynamicTextField(minimumChar: 0, maximumChar: 100).configure {
        $0.placeholder = "report_bottom_sheet_title".localized
        $0.fieldKey = "report"
        $0.setForm(formType: .bottom, predefinedValue: "", options: [])
    }
    
    // MARK: - Initialize Function
    
    init(reportTarget: ReportTargetModel) {
        //        if reportTarget.type == ReportTargetType.Comment(commentType: commentType, sourceId: _, groupId: groupId) {
        //            if commentType == .post && groupId == nil {
        //                fatalError("帖子的评论举报需要传入圈子id")
        //            }
        //        }
        self.model = reportTarget
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCircle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        self.gerReportTypes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 输入控件内容变更的通知处理
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotificationProcess(notification:)), name: UITextView.textDidChangeNotification, object: nil)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 40.0
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        setCloseButton(backImage: true, titleStr: "title_report".localized)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
        IQKeyboardManager.shared.enable = false
    }
    
}

// MARK: - UI

extension ReportViewController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        
        // By Kit Foong (use navigation right button instead of button at bottom)
        //let reportBtnH: CGFloat = 45
        //let reportLrMargin: CGFloat = 15
        //let reportTopMargin: CGFloat = 30
        
        self.view.backgroundColor = .white
        
        // 1. navigationbar
        let reportBtn = UIButton()
        reportBtn.addTarget(self, action: #selector(reportBtnClick(_:)), for: .touchUpInside)
        reportBtn.setTitle("submit".localized, for: .normal)
        reportBtn.setTitleColor(TSColor.button.disabled, for: .normal)
        reportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportBtn)
        self.reportBtn = reportBtn
        
        // 2. topView
        //let topView = UIView(bgColor: UIColor.white)
        //self.view.addSubview(topView)
        self.initialTopView(self.view)
        //        topView.snp.makeConstraints { (make) in
        //            make.top.leading.trailing.equalTo(self.view)
        //        }
        //        self.view = topView
        // 3. retportBtn
        //        let reportBtn = UIButton(cornerRadius: 5)
        //        self.view.addSubview(reportBtn)
        //        reportBtn.addTarget(self, action: #selector(reportBtnClick(_:)), for: .touchUpInside)
        //        reportBtn.setTitle("report".localized, for: .normal)
        //        reportBtn.setTitleColor(UIColor.white, for: .normal)
        //        reportBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        //        reportBtn.setBackgroundImage(UIImage(color: TSColor.main.theme), for: .normal)
        //        reportBtn.setBackgroundImage(UIImage(color: TSColor.button.disabled), for: .disabled)
        //        reportBtn.snp.makeConstraints { (make) in
        //            make.height.equalTo(reportBtnH)
        //            make.leading.equalTo(self.view).offset(reportLrMargin)
        //            make.trailing.equalTo(self.view).offset(-reportLrMargin)
        //            make.top.equalTo(topView.snp.bottom).offset(reportTopMargin)
        //        }
        //        self.reportBtn = reportBtn
        if #available(iOS 11, *) {
            
        } else {
            let buttonAtLeft = TSButton(type: .custom)
            buttonAtLeft.frame = CGRect(x: 0, y:0, width: 44, height: 44)
            buttonAtLeft.setImage(UIImage.set_image(named: "iconsArrowCaretleftBlack"), for: .normal)
            buttonAtLeft.addTap { [unowned self] (_) in
                self.dismiss(animated: true, completion: nil    )
            }
            let leftBar = UIBarButtonItem(customView: buttonAtLeft)
            
            self.navigationItem.leftBarButtonItem = leftBar
        }
    }
    /// topView布局
    fileprivate func initialTopView(_ topView: UIView) -> Void {
        let promptTopMargin: CGFloat = 25
        let targetTopMargin: CGFloat = 15
        let inputTopMargin: CGFloat = 15
        let inputBottomMargin: CGFloat = 20
        let reportTargetH: CGFloat = 50
        //let reportInputH: CGFloat = 150
        // By Kit Foong (Change to use screen height percentage)
        let reportInputH: CGFloat = UIScreen.main.bounds.height * 0.3
        
        // 1. reportPromtView
        let promptView = UIView()
        topView.addSubview(promptView)
        self.initialReportPromptView(promptView)
        promptView.snp.makeConstraints { (make) in
            make.leading.equalTo(topView).offset(self.lrMargin)
            make.trailing.equalTo(topView).offset(-self.lrMargin)
            make.top.equalTo(topView).offset(promptTopMargin)
        }
        // 2. reportTargetView
        let targetView = ReportTargetControl()
        topView.addSubview(targetView)
        targetView.backgroundColor = TSColor.inconspicuous.background
        //targetView.addTarget(self, action: #selector(reportedTargetClick), for: .touchUpInside)
        targetView.isEnabled = false
        targetView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(promptView)
            make.top.equalTo(promptView.snp.bottom).offset(targetTopMargin)
            make.height.equalTo(reportTargetH)
        }
        self.reportTargetView = targetView
        
        // By Kit Foong (Added new report category, ios 15 above use bottom sheet, below use dropdown)
        // 3. report selection view
        topView.addSubview(reportSelectionField)
        reportSelectionField.onTapTextField = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self?.reportSelectionField.resignFirstResponder()
                self?.view.endEditing(true)
                
                let mainStoryboard = UIStoryboard(name: "ReportBottomSheetVC", bundle: nil)
                if let bottomSheet = mainStoryboard.instantiateViewController(withIdentifier: "reportBottomSheet") as? ReportBottomSheetVC {
                    bottomSheet.reportCategory = self?.reportTypesModel ?? []
                    bottomSheet.delegate = self
                    bottomSheet.modalPresentationStyle = .custom
                    let transitionDelegate = HalfScreenTransitionDelegate()
                    transitionDelegate.heightPercentage = 0.5
                    bottomSheet.transitioningDelegate = transitionDelegate
                    self?.present(bottomSheet, animated: true)
                }
            }
        }
        reportSelectionField.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(targetView)
            make.top.equalTo(targetView.snp.bottom).offset(targetTopMargin)
            make.height.equalTo(reportTargetH)
        }
        
        // 4. reportInputView
        let inputView = UIView(bgColor: TSColor.inconspicuous.background)
        topView.addSubview(inputView)
        self.initialReportInputView(inputView)
        inputView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(promptView)
            make.top.equalTo(reportSelectionField.snp.bottom).offset(inputTopMargin)
            //make.bottom.equalTo(topView).offset(-inputBottomMargin)
            make.height.equalTo(reportInputH)
        }
        
        // 5. Photo image evidence
        let imagesView = UIView()
        topView.addSubview(imagesView)
        self.initialImageEvidenceView(imagesView)
        imagesView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(inputView)
            make.top.equalTo(inputView.snp.bottom).offset(inputTopMargin)
            make.bottom.equalTo(topView).offset(-inputBottomMargin)
        }
    }
    /// 举报提示视图布局
    fileprivate func initialReportPromptView(_ promptView: UIView) -> Void {
        // 方案一：label + button + label
        // 方案二：yyLabel
        
        // 1. reportPromptLabel
        let reportPromptLabel = UILabel(text: "report".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        promptView.addSubview(reportPromptLabel)
        reportPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(promptView)
            make.leading.equalTo(promptView)
        }
        self.reportPromptLabel = reportPromptLabel
        // 2. reportedUserNameBtn
        let userNameBtn = UIButton(type: .custom)
        promptView.addSubview(userNameBtn)
        userNameBtn.setTitleColor(TSColor.main.theme, for: .normal)
        userNameBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        userNameBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        userNameBtn.addTarget(self, action: #selector(reportedUserNameClick), for: .touchUpInside)
        userNameBtn.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(promptView)
            make.leading.equalTo(reportPromptLabel.snp.trailing)
        }
        self.reportedUserNameBtn = userNameBtn
        // 3. reportTargetPromtLabel
        let targetPromptLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 15), textColor: TSColor.main.content)
        promptView.addSubview(targetPromptLabel)
        targetPromptLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(promptView)
            make.leading.equalTo(userNameBtn.snp.trailing)
            //make.trailing.equalTo(promptView)
        }
        self.reportedTargetPromptLabel = targetPromptLabel
    }
    fileprivate func initialReportInputView(_ inputView: UIView) -> Void {
        // 1. 提取输入框控件
        // 2. 输入框控件的间距设置问题
        // 3. 多上输入框placeHolder设置的间距问题
        
        let inputLrMargin: CGFloat = inputMargin - 5
        
        // 1. textView
        let textView = UITextView()
        inputView.addSubview(textView)
        textView.contentInset = UIEdgeInsets.zero
        textView.textContainerInset = UIEdgeInsets.zero
        //  textView.delegate = self
        textView.backgroundColor = UIColor.clear
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textColor = TSColor.main.content
        textView.snp.makeConstraints { (make) in
            make.leading.equalTo(inputView).offset(inputLrMargin)
            make.top.equalTo(inputView).offset(inputMargin)
            make.trailing.equalTo(inputView).offset(-inputLrMargin)
        }
        self.reportTextView = textView
        // 2. placeHolder
        let placeHolder = UILabel(text: "placeholder_report_reason".localized, font: UIFont.systemFont(ofSize: 15), textColor: TSColor.normal.secondary)
        textView.addSubview(placeHolder)
        placeHolder.snp.makeConstraints { (make) in
            make.leading.equalTo(textView).offset(inputMargin - inputLrMargin)
            make.top.equalTo(textView)
        }
        self.inputPlaceHolder = placeHolder
        // 3. inputNumLabel
        let inputNumLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.normal.minor)
        inputView.addSubview(inputNumLabel)
        inputNumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textView.snp.bottom).offset(inputMargin)
            make.bottom.equalTo(inputView).offset(-inputMargin)
            make.trailing.equalTo(inputView).offset(-inputMargin)
        }
        self.reportInputNumLabel = inputNumLabel
    }
    fileprivate func initialImageEvidenceView(_ inputView: UIView) -> Void {
        let inputLrMargin: CGFloat = inputMargin - 5
        let inputTopMargin: CGFloat = 15
        let inputBottomMargin: CGFloat = 20
        let titleImageH: CGFloat = 40
        let titlelabelW: CGFloat = UIScreen.main.bounds.width * 0.88
        
        // 1. Title Stack View
        let titleStackView = UIStackView()
        titleStackView.axis = .horizontal
        titleStackView.distribution = .fill
        titleStackView.alignment = .fill
        inputView.addSubview(titleStackView)
        
        titleStackView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(inputView)
            make.height.equalTo(titleImageH)
        }
        
        let titleLabel = UILabel(text: "report_image_evidence_title".localized, font: UIFont.systemFont(ofSize: 14), textColor: TSColor.main.content)
        titleStackView.addArrangedSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.width.equalTo(titlelabelW)
        }
        
        let inputNumLabel = UILabel(text: "0/\(self.imagesMaxNum)", font: UIFont.systemFont(ofSize: 10), textColor: TSColor.normal.minor)
        titleStackView.addArrangedSubview(inputNumLabel)
        
        self.reportImagesNumLabel = inputNumLabel
        
        // 2. Image Collection Cell
        let layout = UICollectionViewFlowLayout()
        self.collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        self.collectionView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        self.collectionView?.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleCollectionViewTap(_:)))
        self.collectionView?.addGestureRecognizer(tap)
        self.collectionView?.register(UINib(nibName:"ReportImageCollectionCell", bundle: nil), forCellWithReuseIdentifier: ReportImageCollectionCell.identifier)
        //self.collectionView?.register(ReportImageCollectionCell.self, forCellWithReuseIdentifier: ReportImageCollectionCell.identifier)
        inputView.addSubview(self.collectionView!)
        self.collectionView!.snp.makeConstraints { (make) in
            make.left.right.equalTo(inputView)
            make.top.equalTo(titleStackView.snp.bottom).offset(5)
            make.height.equalTo(100)
        }
    }
    
    @objc func handleCollectionViewTap(_ sender: UITapGestureRecognizer) {
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            let index = indexPath.row
            if self.reportAttachments[index] == nil {
                TSUtil.checkAuthorizeStatusByType(type: .album, viewController: self, completion: {
                    DispatchQueue.main.async {
                        self.showImagePickerVC()
                    }
                })
            }
        }
    }
    
    func checkAndResizeImage(image:UIImage) -> UIImage {
        let maxImageLenght = max(image.size.width, image.size.height)
        let maxViewLenght = max(self.view.frame.width, self.view.frame.height)
        
        guard maxImageLenght > (maxViewLenght * 1.5) else {
            return image
        }
        
        let ratio = (maxViewLenght * 1.5) / maxImageLenght
        let newImageWidth = image.size.width * ratio
        let newImageHeight = image.size.height * ratio
        let newSize = CGSize(width: newImageWidth, height: newImageHeight)
        let rect = CGRect(x:0, y:0, width:newImageWidth, height:newImageHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? image
    }
    
    func setReportAttachments(_ images: [UIImage]) {
        self.reportAttachments.removeAll(where: { $0 == nil })
        
        let dispatchGroup = DispatchGroup()
        
        for item in images {
            dispatchGroup.enter()
            
            SVProgressHUD.show()
            let editedImage = self.checkAndResizeImage(image: item)
            let compressedData = editedImage.jpegData(compressionQuality: 1.0) ?? Data()
            TSUploadNetworkManager().uploadFile(data: compressedData) { (fileID, msg, status, _) in
                SVProgressHUD.dismiss()
                guard status == true, let fileID = fileID else { return }
                self.filesId.append(fileID)
                self.reportAttachments.append(editedImage)
                
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            if self.reportAttachments.count < 3 {
                self.reportAttachments.append(nil)
            }
            
            DispatchQueue.main.async {
                var index = 0;
                self.reportAttachments.forEach { item in
                    if item != nil {
                        index += 1
                    }
                }
                self.reportImagesNumLabel.text = "\(index)/3"
                self.collectionView?.reloadData()
            }
        }
    }
}



// MARK: - 数据处理与加载

extension ReportViewController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        // 根据举报类型分别加载
        var reportPromptTitle: String = "report".localized
        var reportedUserName: String? = self.model.user?.name
        var reportedTargetPromptTitle: String = ""
        switch self.model.type {
        case .Comment(commentType: _):
            reportedTargetPromptTitle = "report_type_comment".localized
        case .Post:
            reportedTargetPromptTitle = "report_type_post".localized
        case .Moment:
            reportedTargetPromptTitle = "report_type_moment".localized
        case .Group:
            if reportedUserName == nil {
                reportPromptTitle = "report_circle".localized + ":"
            } else {
                reportedTargetPromptTitle = "report_type_group".localized
            }
        case .User:
            reportPromptTitle = "report_user".localized
            reportedUserName = nil
        case .Topic:
            reportedTargetPromptTitle = "report_type_topic".localized
        case .News:
            reportedTargetPromptTitle = "report_type_article".localized
        case .Live:
            reportedTargetPromptTitle = "report_type_live".localized
        }
        self.reportPromptLabel.text = reportPromptTitle
        self.reportedUserNameBtn.setTitle(reportedUserName, for: .normal)
        self.reportedTargetPromptLabel.text = reportedTargetPromptTitle
        self.reportTargetView.model = self.model
        self.reportInputNumLabel.text = "0/\(self.inputMaxNum)"
        self.reportBtn.isEnabled = false
    }
    
    func gerReportTypes() {
        let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "requesting".localized)
        loadingAlert.show()
        
        TSReportNetworkManager.getReportTypes() { (model, msg, status) in
            loadingAlert.dismiss()
            if status, let model = model {
                self.reportTypesModel = model.data
                
                if !self.reportTypesModel.isEmpty {
                    var firstReportType = self.reportTypesModel.first
                    self.reportSelectionField.text = firstReportType!.localiseKey.localized
                }
            } else {
                self.showError(message: msg ?? "")
            }
        }
    }
    
    @objc func dismissTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    /// report按钮是否可用的判断与处理
    fileprivate func couldReportProcess() -> Void {
        self.reportBtn.isEnabled = self.couldReport()
        reportBtn.setTitleColor(self.reportBtn.isEnabled ? TSColor.main.theme : TSColor.button.disabled, for: .normal)
    }
    /// report按钮是否可用/report操作是否可执行
    private func couldReport() -> Bool {
        var couldFlag: Bool = true
        // 输入内容判断
        guard let reportText = self.reportTextView.text else {
            return false
        }
        if self.reportSelectionField.text.isEmpty || reportText.isEmpty {
            couldFlag = false
        }
        return couldFlag
    }
    
    /// 举报
    fileprivate func report() -> Void {
        guard let reason = self.reportTextView.text else {
            return
        }
        
        var selectedReportType = self.reportTypesModel.first(where: { $0.localiseKey.localized == self.reportSelectionField.text })
        
        if selectedReportType != nil {
            let loadingAlert = TSIndicatorWindowTop(state: .loading, title: "requesting".localized)
            loadingAlert.show()
            
            TSReportNetworkManager.report(type: self.model.type, reportTargetId: self.model.targetId, reportType: selectedReportType!.reportTypeId, reason: reason, files: self.filesId) { (msg, status) in
                loadingAlert.dismiss()
                var tipMsg = msg ?? (status ? "report_success_tip".localized : "please_retry_option".localized)
                if tipMsg == "" {
                    tipMsg = status ? "report_success_tip".localized : "please_retry_option".localized
                }
                switch self.model.type {
                case .Moment:
                    //上报动态举报事件
                    EventTrackingManager.instance.trackEvent(
                        itemId: self.model.targetId.stringValue,
                        itemType: self.model.feedItem?.feedType == .miniVideo ? ItemType.shortvideo.rawValue   : ItemType.image.rawValue,
                        behaviorType: BehaviorType.dislike,
                        sceneId: "",
                        moduleId: ModuleId.feed.rawValue,
                        pageId: PageId.feed.rawValue)
                    
                default: break
                    
                }
                let resultAlert = TSIndicatorWindowTop(state: status ? .success : .faild, title: tipMsg )
                resultAlert.show(timeInterval: TSIndicatorWindowTop.defaultShowTimeInterval, complete: {
                    if status {
                        if self.onReportComplete != nil {
                            self.onReportComplete?()
                        } else {
                            _ = self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
            }
        }
    }
}

// MARK: - 事件响应

extension ReportViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    /// 举报按钮点击响应
    @objc fileprivate func reportBtnClick(_ button: UIButton) -> Void {
        self.view.endEditing(true)
        
        self.report()
    }
    
    /// 被举报的用户姓名点击响应
    @objc fileprivate func reportedUserNameClick() -> Void {
        self.view.endEditing(true)
        // 注：u serId==-1 表示问答中的匿名用户
        guard let userId = self.model.user?.userIdentity, userId != -1 else {
            return
        }
//        let userHomeVC = HomePageViewController(userId: userId)
//        self.navigationController?.pushViewController(userHomeVC, animated: true)
        FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: userId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
    }
    /// 被举报的对象点击响应
    @objc fileprivate func reportedTargetClick() -> Void {
        self.view.endEditing(true)
        let sourceId = self.model.targetId
        var detailVC = UIViewController()
        switch self.model.type {
        case .Comment(commentType: let commentType, sourceId: let sourceId, groupId: let groupId):
            switch commentType {
            case .momment: break
                detailVC = FeedInfoDetailViewController(feedId: sourceId, onToolbarUpdated: nil)
                self.navigationController?.pushViewController(detailVC, animated: true)
            case .album: break
              //  detailVC = TSMusicCommentVC(musicType: .album, sourceId: sourceId)
            case .song: break
               // detailVC = TSMusicCommentVC(musicType: .song, sourceId: sourceId)
            case .post: break
            case .news: break
            }
        case .Post(groupId: let groupId): break
        case .Moment, .Live: break
            detailVC = FeedInfoDetailViewController(feedId: sourceId, onToolbarUpdated: nil)
            self.navigationController?.pushViewController(detailVC, animated: true)
        case .Group: break
        case .User:
           // detailVC = HomePageViewController(userId: sourceId)
            FeedIMSDKManager.shared.delegate?.didClickHomePage(userId: sourceId, username: nil, nickname: nil, shouldShowTab: false, isFromReactionList: false, isTeam: false)
            break
        case .Topic: break
            detailVC = TopicPostListVC(groupId: sourceId)
            self.navigationController?.pushViewController(detailVC, animated: true)
        case .News: break
        }
        
    }
}

// MARK: - Notification

extension ReportViewController {
    /// UITextView输入的通知处理
    @objc fileprivate func textViewDidChangeNotificationProcess(notification: Notification) -> Void {
        // textView判断
        guard let textView = notification.object as? UITextView else {
            return
        }
        if textView != self.reportTextView {
            return
        }
        // 输入内容处理
        let maxLen = self.inputMaxNum
        if textView.text == nil || textView.text.isEmpty {
            self.inputPlaceHolder.isHidden = false
            self.reportInputNumLabel.text = "0/\(self.inputMaxNum)"
        } else {
            self.inputPlaceHolder.isHidden = true
            TSAccountRegex.checkAndUplodTextFieldText(textField: textView, stringCountLimit: maxLen)
            let currentNum = textView.text!.count
            self.reportInputNumLabel.text = "\(currentNum)/\(self.inputMaxNum)"
        }
        // 举报按钮的可用性判断
        self.couldReportProcess()
    }
}

//extension ReportViewController: UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        self.animateTextField(textField: textView, up: true)
//    }
//}

// MARK: - Delegate Function

extension ReportViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ReportItemTappedDelegate {
    func reportItemTapped(indexPath: IndexPath?) {
        if let ip = indexPath {
            self.reportAttachments.removeAll(where: { $0 == nil })
            self.reportAttachments.remove(at: ip.row)
            self.filesId.remove(at: ip.row)
            self.reportAttachments.append(nil)
            
            DispatchQueue.main.async {
                var index = 0;
                self.reportAttachments.forEach { item in
                    if item != nil {
                        index += 1
                    }
                }
                self.reportImagesNumLabel.text = "\(index)/3"
                self.collectionView?.reloadData()
                self.collectionView?.collectionViewLayout.invalidateLayout()
            }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reportAttachments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReportImageCollectionCell.identifier, for: indexPath) as! ReportImageCollectionCell
        cell.delegate = self
        cell.selectedAtIndex = indexPath
        cell.setData(iconName: reportAttachments[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension ReportViewController: TZImagePickerControllerDelegate {
    func showImagePickerVC() {
        let currentCount = self.reportAttachments.filter({ $0 != nil }).count
        let count = self.imagesMaxNum - currentCount
        let picker = TZImagePickerController(maxImagesCount: count, columnNumber: 4, delegate: self, mainColor: TSColor.main.theme)
        
        guard let imagePickerVC = picker else {
            return
        }
        imagePickerVC.topTitle = "title_report".localized
        imagePickerVC.maxImagesCount = count
        imagePickerVC.allowCrop = false
        imagePickerVC.isSelectOriginalPhoto = true
        imagePickerVC.allowTakePicture = false
        imagePickerVC.allowPickingImage = true
        imagePickerVC.allowPickingVideo = false
        imagePickerVC.allowPickingGif = false
        imagePickerVC.sortAscendingByModificationDate = false
        imagePickerVC.photoSelImage =  UIImage.set_image(named: "ic_rl_checkbox_selected")
        imagePickerVC.previewSelectBtnSelImage = UIImage.set_image(named: "ic_rl_checkbox_selected")
        imagePickerVC.navigationBar.barTintColor = UIColor.white
        var dic = [NSAttributedString.Key: Any]()
        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
        imagePickerVC.navigationBar.titleTextAttributes = dic
        imagePickerVC.modalPresentationStyle = .custom
        let transitionDelegate = HalfScreenTransitionDelegate()
        transitionDelegate.heightPercentage = 1
        imagePickerVC.transitioningDelegate = transitionDelegate
        self.present(imagePickerVC, animated: true)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        guard photos.count > 0 else {
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: true, completion: {
            self.setReportAttachments(photos)
        })
    }
}

extension ReportViewController: ReportBottomSheetDelegate {
    func sendData(data: String) {
        self.reportSelectionField.text = data.localized
        self.couldReportProcess()
    }
}

protocol ReportBottomSheetDelegate: class {
    func sendData(data: String)
}
