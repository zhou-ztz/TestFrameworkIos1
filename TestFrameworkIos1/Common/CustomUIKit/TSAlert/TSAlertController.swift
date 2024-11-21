//
//  TSAlertController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 28/09/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  自定义的Alert弹窗，参考了UIAlertController
//  注1：该界面可以优化，将UI和数据加载分离开
//  注2：alert样式中的2个action时需要进一步判断，待完成
//  注3：一些极端情况的处理(title和message的存在、actions为空在各自style下)，待完成，
//  注4：关于动画的思考，待完成(1. 系统present没有问题；2.暂时使用present的false方式；3.自定义转场动画)

import Foundation
import UIKit

protocol AlertActionStyleProtocol {
    var titleColor: UIColor { get set }
    var titleFont: UIFont { get set }
    var backgroundColor: UIColor { get set }
}

/// 弹窗响应类型
struct TSAlertSheetActionStyle: AlertActionStyleProtocol {
    //
//    static var `default` = TSAlertActionStyle(titleColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: AppTheme.primaryColor)
//    static var theme = TSAlertActionStyle(titleColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: AppTheme.primaryColor)
    static var cancel = TSAlertActionStyle(titleColor: TSColor.button.greyBorder, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: .white)
    static var `default` = TSAlertActionStyle(titleColor: TSColor.main.content, titleFont: UIFont.boldSystemFont(ofSize: 16))
    static var theme = TSAlertActionStyle(titleColor: TSColor.button.warmBlue, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: TSColor.button.sunflowerYellow)
    // destructive 毁灭性的
    static var destructive = TSAlertActionStyle(titleColor: UIColor.red, titleFont: UIFont.boldSystemFont(ofSize: 16))

    var titleColor: UIColor
    var titleFont: UIFont
    var backgroundColor: UIColor
    
    init(titleColor: UIColor, titleFont: UIFont, backgroundColor: UIColor = .clear) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.backgroundColor = backgroundColor
    }
}

struct TSAlertActionStyle: AlertActionStyleProtocol {
    static var `default` = TSAlertActionStyle(titleColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: TSColor.main.theme)
    static var theme = TSAlertActionStyle(titleColor: .white, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: TSColor.main.theme)
    static var cancel = TSAlertActionStyle(titleColor: TSColor.button.greyBorder, titleFont: UIFont.boldSystemFont(ofSize: 16), backgroundColor: .white)
    // destructive 毁灭性的
    static var destructive = TSAlertActionStyle(titleColor: UIColor.red, titleFont: UIFont.boldSystemFont(ofSize: 16))

    var titleColor: UIColor
    var titleFont: UIFont
    var backgroundColor: UIColor
    
    init(titleColor: UIColor, titleFont: UIFont, backgroundColor: UIColor = .clear) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.backgroundColor = backgroundColor
    }
}
/// 弹窗响应
class TSAlertAction {

    var title: String
    /// titleStyle
    private(set) var style: AlertActionStyleProtocol
    private(set) var handler: ((_ action: TSAlertAction) -> Void)?

    init(title: String, style: AlertActionStyleProtocol, handler: ((_ action: TSAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

/// 弹窗类型
enum TSAlertStyle {
    case alert
    case popup(customview: UIView)
    case actionsheet
}

class TSAlertController: TSViewController {
    // MARK: - Internal Property
    private(set) var customTitle: String?
    private(set) var message: String?
    private(set) var style: TSAlertStyle
    private(set) var sheetCancelTitle: String  /// sheet-style下的默认取消选项的title
    
    private var hideCloseButton = false
    private var animateView = false
    //private var allowToRotate = true
    private(set) var isOffset: Bool?

    private var _textFields: [UITextField]?
    open var textFields: [UITextField]? {
        return _textFields
    }

    /// 标记
    var tag: Int = 0

    // MARK: - Class Function

    // 删除的确认弹窗(即二次弹窗)，格式为 "删除XXX" + "取消" 2个选项
    class func deleteConfirmAlert(deleteActionTitle: String, deleteAction: @escaping (() -> Void)) -> TSAlertController {
        let alertVC = TSAlertController(title: nil, message: nil, style: .actionsheet)
        alertVC.addAction(TSAlertAction(title: deleteActionTitle, style: TSAlertSheetActionStyle.destructive, handler: { (action) in
            deleteAction()
        }))
        return alertVC
    }

    // MARK: - Internal Function

    // 添加action
    func addAction(_ action: TSAlertAction) -> Void {
        self.actions.append(action)
    }

    // 添加 textField，目前仅支持 .alert 类型添加一个 textField，有其他需求请注意修改
    open func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        let _ = UIAlertController()
        if _textFields == nil {
            _textFields = []
        }
        let textField = UITextField()
        configurationHandler?(textField)
        _textFields?.append(textField)
    }

    // MARK: - Prvate Property
    fileprivate let alertView: UIView = UIView()
    fileprivate weak var sheetView: UIView!
    fileprivate weak var sheetTopView: UIView!
    fileprivate weak var sheetActionView: UIView!
    

    private(set) var actions: [TSAlertAction] = [TSAlertAction]()

    var actionsCount: Int {
        return actions.count
    }
    
    private var availableOrientations: UIInterfaceOrientationMask?
    private var attachmentBehaviour: UIAttachmentBehavior?
    private var allowBackgroundDismiss: Bool = true
    private var cancel: EmptyClosure? = nil

    private lazy var alertAnimator: UIDynamicAnimator = UIDynamicAnimator()
    
    fileprivate let actionTagBase: Int = 250

    // MARK: - Initialize Function

    /// sheetCancelTitle，在actionSheet样式下的取消选项标题
    init(title: String? = nil,
         message: String? = nil,
         style: TSAlertStyle,
         sheetCancelTitle: String = "cancel".localized,
         hideCloseButton: Bool = false,
         animateView: Bool = true,
         //allowToRotate: Bool = true,
         availableOrientations: UIInterfaceOrientationMask? = nil,
         allowBackgroundDismiss: Bool = true,
         cancel: EmptyClosure? = nil,
         isOffset: Bool? = nil) {
        self.style = style
        self.customTitle = title
        self.message = message
        self.allowBackgroundDismiss = allowBackgroundDismiss
        self.sheetCancelTitle = sheetCancelTitle
        self.hideCloseButton = hideCloseButton
        self.animateView = animateView
        //self.allowToRotate = allowToRotate
        self.availableOrientations = availableOrientations
        self.cancel = cancel
        self.isOffset = isOffset
        super.init(nibName: nil, bundle: nil)
        // present后的透明展示
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext

        alertAnimator = UIDynamicAnimator(referenceView: self.alertView)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("TSAlert deinit successfully, make sure no retain cycle")
    }

    // MARK: - LifeCircle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
        
        let translate = CGAffineTransform(translationX: 0, y: -500)
        let scale = CGAffineTransform(scaleX: 0.7, y: 0.7)
        
        self.alertView.transform = animateView ? translate.concatenating(scale) : .identity
        self.alertView.alpha = animateView ? 0 : 1;

        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(noti:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        if animateView {
            animateShowAlert()
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let textFields = textFields {
            for item in textFields {
                if item.isKind(of: UITextField.self) {
                    item.becomeFirstResponder()
                    return
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UI
    private func animateShowAlert() {
        switch style {
        case .alert, .popup:
            alertView.alpha = 0
            alertView.isHidden = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                self?.alertView.alpha = 1
                self?.alertView.transform = .identity
            }, completion: nil)
        default: break
        }
    }
    
    
    /// 页面布局
    fileprivate func initialUI() -> Void {
        self.view.backgroundColor = UIColor.clear
        // 1. cover
        let coverBtn = UIView()
        self.view.addSubview(coverBtn)
        coverBtn.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        coverBtn.addTap { [weak self] (_) in
            guard self?.allowBackgroundDismiss == true else { return }
            self?.coverBtnClick()
        }
        coverBtn.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        // 2. alertView
        // 3. actionsheetView
        switch self.style {
        case .alert:
            self.initAlertView()
        case .popup:
            self.initCustomAlert()
            
        case .actionsheet:
            self.initActionSheetView()
        }
        // 数据加载 与 UI 应分离出来，待完成

    }
    
    fileprivate func initCustomAlert() {
        guard case let TSAlertStyle.popup(customView) = self.style else { return }
        self.view.addSubview(alertView)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 10
        if isOffset ?? false {
            alertView.backgroundColor = .clear
        } else {
            alertView.backgroundColor = UIColor.white
        }
        
        alertView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.lessThanOrEqualTo(300).priority(.high)
            make.bottom.top.lessThanOrEqualToSuperview().inset(20).priority(.low)
            make.right.left.greaterThanOrEqualToSuperview().inset(10).priority(.low)
        }
        //ZTLevelView 重新设置宽度
        if customView.isKind(of: ZTLevelView.self){
            alertView.snp.makeConstraints { (make) in
                make.width.equalTo(300).priority(.high)
            }
        }
        
        if customView.isKind(of: CustomerStickerPopView.self){
            alertView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(330)
                make.height.equalTo(320)
            }
        }
        if customView.isKind(of: MeetingPasswordView.self){
            alertView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(322)
            }
        }
        if customView.isKind(of: MeetingPayView.self){
            alertView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(ScreenWidth - 48)
            }
        }
        
        if customView.isKind(of: CancelPopView.self){
            alertView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(350)
            }
        }
        
        let closeButton = UIButton().configure { button in
            button.setImage(UIImage.set_image(named: "IMG_topbar_close"), for: .normal)
            button.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            button.contentMode = .scaleAspectFit
            button.tintColor = .black
        }
        
        closeButton.addTap { [weak self] (_) in
            self?.dismiss()
            self?.cancel?()
        }
        
        alertView.addSubview(closeButton)
        closeButton.isHidden = hideCloseButton
        closeButton.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(16)
            $0.height.width.equalTo(32)
        }
        
        alertView.addSubview(customView)
        customView.snp.makeConstraints { (make) in
            make.top.equalTo(closeButton.snp.bottom)
            make.left.right.bottom.equalToSuperview().inset(16)
        }
        if self.hideCloseButton {
            customView.snp.makeConstraints { (make) in
                make.top.equalTo(0)
            }
        }
    }
    
    /// alert形式布局
    fileprivate func initAlertView() -> Void {
        let lrMargin: CGFloat = 24
        let tbMargin: CGFloat = 24
        self.view.addSubview(alertView)
        alertView.clipsToBounds = true
        alertView.layer.cornerRadius = 10
        alertView.backgroundColor = UIColor.white
        alertView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(availableOrientations != nil ? Device.isLandscape ? 112 : 36 : 36)
        }
        
        // 0. close button
        let closeButton = UIImageView(image: UIImage.set_image(named: "IMG_topbar_close")!)
        closeButton.tintColor = .black
        closeButton.addTap { [weak self] (_) in
            self?.dismiss()
            self?.cancel?()
        }
        

        // 1. topView - title
        let topView = UIView()
        alertView.addSubview(topView)
        alertView.addSubview(closeButton)
        closeButton.isHidden = hideCloseButton
        
        closeButton.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.top.right.equalToSuperview().inset(16)
        }
        
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(closeButton.snp.bottom)
            make.leading.trailing.equalTo(alertView)
        }
        
        // 1.1 titleLabel
        let titleLabel = UILabel().configure { (label) in
            label.setFontSize(with: 16, weight: .bold)
            label.textAlignment = .center
            label.textColor = TSColor.main.content
        }
        titleLabel.numberOfLines = 2
        alertView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
            make.bottom.equalTo(topView).offset(-16)
        }
        
        // 3. contentView - message
        let contentView = UIView()
        alertView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // 3.1 contentLabel
        let messageLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.content, alignment: .center)
        contentView.addSubview(messageLabel)
        //workaround, increase numberoflines to fit long text
        messageLabel.numberOfLines = 10
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-16)
            make.left.right.equalToSuperview()
        }
        
        // 3.2 textFilds view
        let textFiledsView = UIView()
        alertView.addSubview(textFiledsView)
        textFiledsView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(contentView)
            make.top.equalTo(contentView.snp.bottom)
        }
        
        // 3. bottom - action
        let bottomView = UIView()
        alertView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(alertView)
            make.top.equalTo(textFiledsView.snp.bottom)
        }

        // 加载数据
        titleLabel.text = self.customTitle
        messageLabel.text = self.message
        // 判断title 和 messge 没有时的情况处理(分别没有、都没有)，待完成
        if nil == self.customTitle || self.customTitle!.isEmpty {
            titleLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(topView).offset(tbMargin)
                make.bottom.equalTo(topView).offset(0)
            })
        }
        if nil == self.message || self.message!.isEmpty {
            messageLabel.snp.updateConstraints({ (make) in
                make.top.equalTo(contentView).offset(0)
                make.bottom.equalTo(contentView).offset(0)
            })
        }
        // 加载 textField
        if let textFields = textFields {
            for (index, textField) in textFields.enumerated() {
                textField.font = UIFont.systemFont(ofSize: 14)
                textField.textAlignment = .center
                textField.borderStyle = .roundedRect
                textFiledsView.addSubview(textField)
                textField.snp.makeConstraints({ (make) in
                    make.leading.equalTo(textFiledsView).offset(lrMargin)
                    make.trailing.equalTo(textFiledsView).offset(-lrMargin)
                    make.height.equalTo(35)
                    make.top.equalTo(textFiledsView).offset(CGFloat(index) * 35 + 30)
                    if index == textFields.count - 1 {
                        make.bottom.equalTo(textFiledsView).offset(-30)
                    }
                })
            }
        }
        // 加载action
        guard self.actions.isEmpty == false else {
            return
        }
        
        let stackview = UIStackView().configure {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 8
            $0.alignment = .fill
        }
        
        bottomView.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.right.equalToSuperview().inset(60)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        for (index, action) in actions.enumerated() {
            let button = UIButton(type: .custom)
            bottomView.addSubview(button)
            button.roundCorner(22.5)
            button.titleLabel?.font = action.style.titleFont
            button.setTitle(action.title, for: .normal)
            button.setTitleColor(action.style.titleColor, for: .normal)
            button.setBackgroundColor(action.style.backgroundColor, for: .normal)
            button.tag = actionTagBase + index
            button.addTarget(self, action: #selector(actionBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints { $0.height.equalTo(45) }
            stackview.addArrangedSubview(button)
        }
    }
    /// actionShee形式布局
    fileprivate func initActionSheetView() -> Void {

        let lrMargin: CGFloat = 16
        let tbMargin: CGFloat = 18
        let titleMsgMargin: CGFloat = 15

        let actionH: CGFloat = 45
        let verMargin: CGFloat = 5
        let sheetView = UIView()
        self.view.addSubview(sheetView)
        sheetView.backgroundColor = TSColor.inconspicuous.background
        sheetView.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(self.view)
        }
        self.sheetView = sheetView
        // 1. actionView，含追加的cancelAction
        let actionView = UIView()
        sheetView.addSubview(actionView)
        actionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(sheetView).offset(-TSBottomSafeAreaHeight)
        }
        self.sheetActionView = actionView
        // 2. topView
        let topView = UIView(bgColor: UIColor.white)
        sheetView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalTo(sheetView)
            make.bottom.equalTo(actionView.snp.top).offset(-verMargin)
        }
        self.sheetTopView = topView
        // 2.1 titleLabel
        let titleLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 16), textColor: TSColor.main.content, alignment: .center)
        titleLabel.numberOfLines = 2
        topView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(topView).offset(tbMargin)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
        }
        // 2.2 messageLabel
        let messageLabel = UILabel(text: "", font: UIFont.systemFont(ofSize: 14), textColor: TSColor.normal.minor, alignment: .center)
        topView.addSubview(messageLabel)
        messageLabel.numberOfLines = 3
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(titleMsgMargin)
            make.bottom.equalTo(topView).offset(-tbMargin)
            make.leading.equalTo(topView).offset(lrMargin)
            make.trailing.equalTo(topView).offset(-lrMargin)
        }

        // 数据加载 - 可考虑将数据加载分离出来
        titleLabel.text = self.customTitle
        messageLabel.text = self.message
        // 判断title和message是否存在，暂仅处理都不存在的情况
        var isShowTop: Bool = true
        if (nil == self.customTitle || self.customTitle!.isEmpty) && (nil == self.message || self.message!.isEmpty) {
            isShowTop = false
            topView.removeAllSubViews()
            topView.snp.remakeConstraints({ (make) in
                make.bottom.equalTo(actionView.snp.top).offset(0)
                make.top.leading.trailing.equalTo(sheetView)
            })
        }
        topView.isHidden = !isShowTop

        // cancel
        let cancelBtn = UIButton(type: .custom)
        actionView.addSubview(cancelBtn)
        cancelBtn.setTitle(self.sheetCancelTitle, for: .normal)
        cancelBtn.titleLabel?.font = TSAlertSheetActionStyle.default.titleFont
        cancelBtn.backgroundColor = UIColor.white
        cancelBtn.setTitleColor(AppTheme.headerTitleGrey, for: .normal)
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick(_:)), for: .touchUpInside)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.leading.trailing.equalTo(actionView)
            make.height.equalTo(actionH)
        }
        // actionsView，不含追加的cancelAction
        let actionsView = UIView(bgColor: UIColor.white)
        actionView.addSubview(actionsView)
        actionsView.snp.makeConstraints { (make) in
            make.leading.trailing.top.equalTo(actionView)
            if isShowTop {
                // 展示顶部，actions和追加的取消一起展示(无间隔)
                make.bottom.equalTo(cancelBtn.snp.top)
                cancelBtn.addLineWithSide(.inTop, color: TSColor.normal.background, thickness: 0.5, margin1: 0, margin2: 0)
            } else {
                // 不展示顶部，actions和追加的取消分开展示(有间隔)
                make.bottom.equalTo(cancelBtn.snp.top).offset(-verMargin)
            }
        }
        // 根据actions构造actionsView
        for (index, action) in self.actions.enumerated() {
            let button = UIButton(type: .custom)
            actionsView.addSubview(button)
            button.titleLabel?.font = action.style.titleFont
            button.setTitle(action.title, for: .normal)
            button.setTitleColor(action.style.titleColor, for: .normal)
            button.tag = actionTagBase + index
            button.addTarget(self, action: #selector(actionBtnClick(_:)), for: .touchUpInside)
            button.snp.makeConstraints({ (make) in
                make.leading.trailing.equalTo(actionsView)
                make.height.equalTo(actionH)
                make.top.equalTo(actionsView).offset(CGFloat(index) * actionH)
                if index == actions.count - 1 {
                    make.bottom.equalTo(actionsView)
                }
            })
            if index != actions.count - 1 {
                button.addLineWithSide(.inBottom, color: TSColor.normal.background, thickness: 0.5, margin1: 0, margin2: 0)
            }
        }
    }
    
    override var shouldAutorotate: Bool {
        guard availableOrientations == nil else { return true }
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard availableOrientations == nil else { return availableOrientations! }
        return [.portrait]
    }

    // MARK: - 数据处理与加载

    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {

    }
    
    func dismiss(completion: EmptyClosure? = nil) {
        switch self.style {
        case .alert, .popup:
            let translate = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height)
            let transform = translate.concatenating(CGAffineTransform(scaleX: 0.7, y: 0.7))
            if animateView {
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [.curveEaseIn], animations: { [weak self] in
                    self?.alertView.transform = transform
                }) { [weak self] (_) in
                    self?.dismiss(animated: false, completion: completion)
                }
            } else {
                self.dismiss(animated: false, completion: completion)
            }
            
        default: self.dismiss(animated: false, completion: completion)
        }
    }

    // MARK: - 事件响应

    /// 遮罩点击响应
    fileprivate func coverBtnClick() {
        /// 兼容直接加载到presentationController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParent()
        } else {
            self.dismiss()
        }
    }

    /// 按钮点击响应
    @objc fileprivate func actionBtnClick(_ button: UIButton) -> Void {
        let index = button.tag - self.actionTagBase
        let action = self.actions[index]
        /// 兼容直接加载到ParentViewController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParent()
            action.handler?(action)
        } else {
            action.handler?(action)

            let transition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.fade
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeIn)
            self.view.window!.layer.add(transition, forKey: kCATransition)
                        
            self.dismiss()
        }
    }
    @objc fileprivate func cancelBtnClick(_ button: UIButton) -> Void {
        /// 兼容直接加载到ParentViewController的情况
        if parent != nil {
            self.view.removeFromSuperview()
            self.removeFromParent()
        } else {
            self.dismiss()
        }
    }
    // 处理弹窗遮挡问题
    @objc func keyboardWillShow(noti: Notification) {
        if self.alertView.superview == nil { return }
        let userInfo = noti.userInfo! as NSDictionary
        let keyboardRect = userInfo["UIKeyboardFrameEndUserInfoKey"] as! CGRect
        let width = self.alertView.width
        let left = (ScreenWidth - width) / 2.0
        self.alertView.snp.remakeConstraints { (make) in
            // alertView底部距键盘顶部的间隔
            let bottomSpaceHeight = keyboardRect.height + 25
            let centerYOffset = (ScreenHeight / 2.0 - bottomSpaceHeight - self.alertView.height / 2.0)
            make.centerY.equalTo(self.view).offset(centerYOffset)
            make.leading.equalTo(self.view).offset(left)
            make.trailing.equalTo(self.view).offset(-left)
        }
    }
}

