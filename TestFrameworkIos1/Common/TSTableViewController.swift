//
//  TSTableViewController.swift
//  Thinksns Plus
//
//  Created by lip on 2016/12/30.
//  Copyright © 2016年 ZhiYiCX. All rights reserved.
//
//  抽象类

import UIKit
import MJRefresh

class TSTableViewController: UITableViewController {
    let shimmerView = RewardDealsShimmerView()
    /// 占位图
    lazy var placeholder = Placeholder()
    
    let edgeInsets = UIEdgeInsets.zero
    /// 导航栏右边按钮的区域
    var rightButtonCunstomView: UIView? = nil
    /// 导航栏右边的按钮
    var rightButton: UIButton? = nil
    
    var shimmerDidHide: Bool = false
    
    public var customScrollViewDelegate:TSScrollDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addNotic()
        //self.hidesBottomBarWhenPushed = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeNotic()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        if !shimmerDidHide {
//            customUISetup()
//        }
        customSeparator()
        setupRefresh()
    }

    deinit {
        removeNotic()
    }

    // MARK: - Custom user interface

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        customScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        customScrollViewDelegate?.scrollViewDidScroll(scrollView)
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        customScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

// MARK: - 指示器A的处理逻辑
extension TSTableViewController {
    // 需要显示指示器A
    func show(indicatorA title: String) {
        guard let nav = self.navigationController as? TSNavigationController else { return }
        nav.show(indicatorA: title)
    }

    func show(indicatorA title: String, timeInterval: Int) {
        guard let nav = self.navigationController as? TSNavigationController else { return }
        nav.show(indicatorA: title, timeInterval: timeInterval)
    }

    func dismissIndicatorA() {
        guard let nav = self.navigationController as? TSNavigationController else { return }
        nav.dismissIndicatorA()
    }
}

// MARK: - 占位图
extension TSTableViewController {

    /// 显示占位图
    func show(placeholderView type: PlaceholderViewType, margin: CGFloat = 0.0, height: CGFloat? = nil) {
        
        if placeholder.superview == nil {
            tableView.addSubview(placeholder)
            placeholder.snp.makeConstraints {
                $0.bottom.left.right.equalToSuperview()
                $0.top.equalToSuperview().offset(margin)
                $0.width.equalToSuperview()
                if let height = height {
                    $0.height.equalTo(height)
                } else {
                    $0.height.equalToSuperview()
                }
            }
            placeholder.onTapActionButton = {
                self.placeholderButtonDidTapped()
            }
        }
        placeholder.set(type)
    }
    
    @objc func placeholderButtonDidTapped() { }

    /// 移除占位图
    func removePlaceholderViews() {
        if placeholder.superview != nil {
            placeholder.removeFromSuperview()
        }
    }

}

extension TSTableViewController {
    func setCloseButton(backImage: Bool = false, titleStr: String? = nil, customView: UIView? = nil, completion: (() -> Void)? = nil, needPop: Bool = true) {
        let image: UIImage
        if backImage == false {
            image = UIImage.set_image(named: "IMG_topbar_close")!
        } else {
            image = UIImage.set_image(named: "iconsArrowCaretleftBlack")!
        }
        let barButton = UIBarButtonItem(image: image, action: { [weak self] in
            if needPop {
                let _ = self?.navigationController?.popViewController(animated: true, completion: {
                    completion?()
                })
            } else {
                completion?()
            }
        })
        barButton.tintColor = .black
        
        if let titleStr = titleStr {
            let btn = UIButton(type: .custom)
            btn.set(title: titleStr, titleColor: .black, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
            let titleButton = UIBarButtonItem(customView: btn)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        if let customView = customView {
            let titleButton = UIBarButtonItem(customView: customView)
            self.navigationItem.leftBarButtonItems = [barButton, titleButton]
            return
        }
        self.navigationItem.leftBarButtonItem = barButton
    }
}

extension TSTableViewController {

    /// 自定义设置
    fileprivate func customUISetup() {
        self.view.backgroundColor = .white
        self.view.addSubview(shimmerView)
        shimmerView.bindToEdges()
        shimmerView.startShimmering(background: false)
    }
    
    func hideShimmer(hide: Bool?) {
        if let hide = hide {
            shimmerDidHide = hide
        }
    }

    @objc func setupRefresh() {
        tableView.mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }

    // MARK: - Delegete
    // MARK: GTMRefreshHeaderDelegate
    @objc func refresh() {

        fatalError("必须重写该方法,执行下拉刷新后的逻辑")
    }

    // MARK: GTMLoadMoreFooterDelegate
    @objc func loadMore() {
        fatalError("必须重写该方法,执行上拉加载后的逻辑")
    }
}

/// 设置分割线 布满Cell 底部
extension TSTableViewController {

    func customSeparator() {
        self.tableView.separatorColor = TSColor.inconspicuous.disabled
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.separatorInset = edgeInsets
        tableView.layoutMargins = edgeInsets
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutMargins = edgeInsets
        cell.separatorInset = edgeInsets
    }
}

/// 添加音乐入口点击的监听
extension TSTableViewController {

    func addNotic() {
        /// 音乐暂停后等待一段时间 视图自动消失的通知
       // NotificationCenter.default.addObserver(self, selector: #selector(setRightCustomViewWidthMin), name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }

    func removeNotic() {
       // NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: TSMusicStatusViewAutoHidenName), object: nil)
    }
}

/// 导航栏右边按钮相关
extension TSTableViewController {

    /// 设置右边按钮
    /// 增加导航栏右边按钮
    ///
    /// - Note: 在 viewWillAppear 和 viewDidLoad 各写一次，一共写两次
    ///
    /// - Parameters:
    ///   - title: 标题
    ///   - img: 图片
    func setRightButton(title: String?, img: UIImage?) {

        if self.navigationController == nil {
            return
        }

        if rightButtonCunstomView == nil {
            initRightCustom()
        }

        rightButton?.setImage(img, for: UIControl.State.normal)
        rightButton?.setTitle(title, for: UIControl.State.normal)

       // setRightCustomViewWidth(Max: TSMusicPlayStatusView.shareView.isShow)
    }

    /// 初始化右边的按钮区域
    func initRightCustom() {
        self.rightButtonCunstomView = UIView()
        self.rightButton = UIButton(frame: CGRect(x: 0, y: 0, width: TSViewRightCustomViewUX.MinWidth, height: 44))
        self.rightButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        self.rightButton?.addTarget(self, action: #selector(rightButtonClicked), for: UIControl.Event.touchUpInside)
        self.rightButton?.setTitleColor(TSColor.main.theme, for: UIControl.State.normal)
        self.rightButton?.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Button.navigation.rawValue)
        self.rightButtonCunstomView?.addSubview(self.rightButton!)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.rightButtonCunstomView!)
    }

    /// 设置按钮标题颜色
    ///
    /// - Parameter color: 颜色
    func setRightButtonTextColor(color: UIColor) {
        self.rightButton?.setTitleColor(color, for: UIControl.State.normal)
    }

    /// 设置按钮是否可以点击
    ///
    /// - Parameter enable: 是否可以点击
    func rightButtonEnable(enable: Bool) {
        self.rightButton?.isEnabled = enable
        self.rightButton?.setTitleColor(enable ? TSColor.main.theme : TSColor.normal.disabled, for: UIControl.State.normal)
    }

    /// 设置按钮区域的宽度
    ///
    /// - Parameter Max: 是否是最大宽度
    func setRightCustomViewWidth(Max: Bool) {
        if self.rightButtonCunstomView == nil {
            return
        }

        let width = Max ? TSViewRightCustomViewUX.MaxWidth: TSViewRightCustomViewUX.MinWidth

        if self.rightButtonCunstomView?.frame.width == width {
            return
        }

        self.rightButtonCunstomView!.frame = CGRect(x: 0, y: 0, width: width, height: TSViewRightCustomViewUX.Height)
    }

    /// 设置为最小宽度 （用于音乐图标自动消失时重置宽度）
    @objc func setRightCustomViewWidthMin() {
        setRightCustomViewWidth(Max: false)
    }

    /// 按钮点击方法
    @objc func rightButtonClicked() {
        fatalError("请重写此方法实现右边按钮的点击事件")
    }
}
@objcMembers
class Placeholder: UIView {
    
    private lazy var container: UIView = UIView().configure {
        $0.backgroundColor = .clear
    }
    
    private lazy var stackView = UIStackView().configure {
        $0.axis = .vertical
        $0.alignment = .center
        $0.distribution = .fill
        $0.spacing = 16
    }
    
    private lazy var placeholderImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var placeholderLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.142, alpha: 1)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    private lazy var contentLabel = UILabel().configure {
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.textColor = UIColor(red: 0.141, green: 0.141, blue: 0.142, alpha: 1)
        $0.font = UIFont.systemRegularFont(ofSize: 12)
    }
    
    private lazy var button = UIButton(font: UIFont.boldSystemFont(ofSize: 14))
    
    var onTapActionButton: EmptyClosure?
    var theme: Theme = .white {
        didSet {
            if let customColor = customBackgroundColor {
                backgroundColor = customColor
                return
            }
            switch theme {
            case .dark:
                backgroundColor = AppTheme.materialBlack
            default:
                backgroundColor = .white
            }
        }
    }
    
    var customBackgroundColor: UIColor? = nil
    var type: PlaceholderViewType?
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .white
        
        self.addSubview(container)
        container.addSubview(stackView)
        container.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        stackView.addArrangedSubview(placeholderImageView)
        stackView.addArrangedSubview(placeholderLabel)
        stackView.addArrangedSubview(contentLabel)
        
        stackView.bindToEdges()
        
        placeholderImageView.snp.makeConstraints {
            $0.height.equalTo(240)
            $0.width.equalTo(200)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(_ type: PlaceholderViewType) {
        self.type = type
        placeholderImageView.image = type.content.image
        placeholderLabel.text = type.content.text
        contentLabel.text = type.content.content
        
        switch type {
        case .needLocationAccess, .networkWithRetry, .customWithButton, .serverError, .network, .teenMode:
            if button.superview == nil {
                var buttonTitle : String = type.buttonText ?? ""
                
                var buttonHeight = Int(round(buttonTitle.heightOfString(usingFont: UIFont.boldSystemFont(ofSize: 14)))) + 10
                var buttonWidth = Int(round(buttonTitle.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 14)))) + 10
                      
                stackView.addArrangedSubview(button)
                button.snp.makeConstraints {
                    $0.height.equalTo(buttonHeight)
                    $0.width.equalTo(buttonWidth)
                    //$0.width.equalToSuperview().dividedBy(2)
                }
                button.addAction {
                    self.onTapActionButton?()
                }
                button.setTitle(type.buttonText, for: .normal)

                switch type {
                case .customWithButton:
                    button.setBackgroundColor(AppTheme.dodgerBlue, for: .normal)
                    button.setTitleColor(.white, for: .normal)
                    button.roundCorner(20)
                default:
                    button.setTitleColor(UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1), for: .normal)
                    button.set(font: UIFont.boldSystemFont(ofSize: 14), cornerRadius: 8, borderWidth: 1, borderColor: UIColor(red: 0.929, green: 0.102, blue: 0.231, alpha: 1))
                }
            }
        case .imEmpty:
            placeholderLabel.font =  UIFont.systemFont(ofSize: 16, weight: .regular)
        default:
            button.removeFromSuperview()
            break
        }
    }
}
