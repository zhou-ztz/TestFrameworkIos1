//
//  TSLabelViewController.swift
//  Thinksns Plus
//
//  Created by GorCat on 17/2/14.
//  Copyright © 2017年 LeonFa. All rights reserved.
//
//  分页视图控制器
//  超类
//  点击导航栏标签可切换下方 view 的视图控制器
//  例如：粉丝关注列表

import UIKit


class TSLabelViewController: TSViewController, UIScrollViewDelegate {

    /// 滚动视图
    var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    
    
    let labelHeight: CGFloat = 44
    let blueLineHeight: CGFloat = 2.0
    
    private var labelScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    /// 标签视图
    let labelView = UIStackView()
    /// 标签下方的蓝线
    let blueLine = UIView()
    /// 提示用的小红点
    var badges: [UIView] = []
    /// 蓝线的 leading
    var blueLineLeading: CGFloat = 0

    /// 标签标题数组
    var titleArray: [String]? = nil

    /// 按钮基础 tag 值
    let tagBasicForButton = 200
    
    private let badgeSize: CGSize = CGSize(width: 6, height: 6)

    // MARK: - Lifecycle

    /// 自定义初始化方法
    ///
    /// - Parameter labelTitleArray: 导航栏上标签的 title 的数组
    init(labelTitleArray: [String], scrollViewFrame: CGRect?, isChat: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        if isChat {
            let frame = scrollViewFrame ?? CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64)
            self.scrollView = ChatScrollView(frame: frame)
        }

        if let scrollViewFrame = scrollViewFrame {
            scrollView.frame = scrollViewFrame
        }
        titleArray = labelTitleArray
        for _ in labelTitleArray {
            let badge = UIView()
            badge.backgroundColor = TSColor.main.warn
            badge.clipsToBounds = true
            badge.layer.cornerRadius = badgeSize.height * 0.5
            badge.isHidden = true
            badges.append(badge)
        }

        setSuperUX()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(changeStatuBar), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }

    @objc func changeStatuBar() {
        if UIApplication.shared.statusBarFrame.size.height == 20 {
            scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64 - 49)
        }
    }

    // MARK: - Custom user interface

    /// 视图设置
    func setSuperUX() {
        defer { self.view.layoutIfNeeded() }
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        if let titleArray = titleArray {
            labelScrollView.showsHorizontalScrollIndicator = false
            labelScrollView.showsVerticalScrollIndicator = false
            labelView.distribution = .fill
            labelView.axis = .horizontal
            labelView.alignment = .fill
            labelView.spacing = 20.0
            
            if titleArray.isEmpty {
                return
            }
            
            blueLine.backgroundColor = TSColor.main.theme
            
            // labelView button
            for (index, title) in titleArray.enumerated() {
                let button = UIButton(type: .custom)
                button.titleLabel?.font = UIFont.systemFont(ofSize: TSFont.Title.pulse.rawValue)
                button.setTitle(title, for: .normal)
                button.setTitleColor( index == 0 ? TSColor.inconspicuous.navHighlightTitle : TSColor.normal.minor, for: .normal)
                button.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
                button.tag = tagBasicForButton + index
                button.sizeToFit()
                
                let badge = badges[index]
                let badgeX = button.frame.width + 5
                badge.frame = CGRect(x: badgeX, y: 10, width: badgeSize.width, height: badgeSize.height)
                button.addSubview(badge)
                
                labelView.addArrangedSubview(button)
            }

            // labelView
            labelScrollView.backgroundColor = UIColor.white
            
            labelScrollView.addSubview(labelView)
            let customTitleView = CustomScrollableTitleView(customScrollView: labelScrollView)
            
            customTitleView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
            navigationItem.titleView = customTitleView
            
            labelView.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.top.equalToSuperview().inset(6)
                make.left.greaterThanOrEqualToSuperview().inset(13)
                make.right.lessThanOrEqualToSuperview().inset(13)
            }
            
            labelView.addSubview(blueLine)
            
            // set initial blueline position
            blueLine.snp.makeConstraints { (make) in
                make.height.equalTo(blueLineHeight)
                make.centerX.equalTo(labelView.arrangedSubviews[0])
                make.bottom.equalToSuperview().offset(6.0)
                make.width.equalTo(labelView.arrangedSubviews[0].snp.width).offset(8.0)
            }
            
            // scrollView
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(titleArray.count), height: scrollView.frame.size.height)
            scrollView.backgroundColor = UIColor.white
            scrollView.isPagingEnabled = true
            scrollView.showsVerticalScrollIndicator = false
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.bounces = false
            scrollView.delegate = self
            view.addSubview(scrollView)

        }
        
        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    // MARK: - Button click
    @objc func buttonTaped(sender: UIButton) {
        let index = sender.tag - tagBasicForButton
        scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width * CGFloat(index), y: 0), animated: true)
        selectedPageEndAt(index: index)
    }

    // MARK: - Public

    /// 添加子视图
    public func add(childView: UIView, at index: Int) {
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        childView.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
        self.scrollView.addSubview(childView)
    }
    
    /// 添加Gallery子视图
    public func add(collectionView: UIView, at index: Int) {
        let width = self.scrollView.frame.width - 4
        let height = self.scrollView.frame.height - 5
        collectionView.frame = CGRect(x: CGFloat(index) * self.scrollView.frame.width + 2, y: 5, width: width, height: height)
        self.scrollView.addSubview(collectionView)
    }


    /// 添加子视图控制器的方法
    ///
    /// - Parameters:
    ///   - childViewController: 子视图控制器
    ///   - index: 索引下标，从 0 开始，请与 labelTitleArray 中的下标一一对应
    public func add(childViewController: Any, At index: Int) {
        let width = self.scrollView.frame.width
        let height = self.scrollView.frame.height
        if let childVC = childViewController as? UIViewController {
            self.addChild(childVC)
            childVC.view.frame = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: height)
            self.scrollView.addSubview(childVC.view)
        }
    }

    /// 切换选中的分页
    ///
    /// - Parameter index: 分页下标
    public func setSelectedAt(_ index: Int) {
        update(childViewsAt: index)
    }

    /// 切换了选中的页面
    func selectedPageChangedTo(index: Int) {
        /// [长期注释] 这个方法有子类实现，来获取页面切换的回调
    }
    func selectedPageEndAt(index: Int) {
        
    }
    // MARK: - Private
    /// 更新 scrollow 的偏移位置
    private func update(childViewsAt index: Int) {
        let width = self.scrollView.frame.width
        // scroll view
        scrollView.setContentOffset(CGPoint(x: CGFloat(index) * width, y: 0), animated: true)
        updateButton(index)
        selectedPageEndAt(index: index)
    }

    var oldIndex = 0
    /// 刷新按钮
    func updateButton(_ index: Int) {
        if oldIndex == index {
            return
        }
       
        let oldButton = (labelView.viewWithTag(tagBasicForButton + oldIndex) as? UIButton)!
        oldButton.setTitleColor(TSColor.normal.minor, for: .normal)
        oldIndex = index
        if let button = (labelView.viewWithTag(tagBasicForButton + index) as? UIButton) {
            button.setTitleColor(TSColor.inconspicuous.navHighlightTitle, for: .normal)
            labelScrollView.scrollRectToVisible(button.frame, animated: true)
        }
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > titleArray!.count {
            index = CGFloat(titleArray!.count)
        }
        let i = round(index)
        updateButton(Int(i))
       
        blueLine.snp.remakeConstraints { (make) in
            make.height.equalTo(2.0)
            make.centerX.equalTo(labelView.arrangedSubviews[Int(i)])
            make.bottom.equalToSuperview().offset(6.0)
            make.width.equalTo(labelView.arrangedSubviews[Int(i)].snp.width).offset(8.0)
        }
        
        self.labelView.layoutIfNeeded()
        
        TSKeyboardToolbar.share.keyboarddisappear()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > titleArray!.count {
            index = CGFloat(titleArray!.count)
        }
        let i = round(index)
        selectedPageEndAt(index: Int(i))
        
    }
    
    func updateIndex(_ index: Int) {
        update(childViewsAt: index)
    }

}


class CustomScrollableTitleView: UIView {
    let titleScrollView: UIScrollView
    init(customScrollView: UIScrollView) {
        titleScrollView = customScrollView
        super.init(frame: CGRect.zero)
        
        addSubview(titleScrollView)
    }
    
    override convenience init(frame: CGRect) {
        self.init(customScrollView: UIScrollView())
        self.frame = frame
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentWidth = titleScrollView.contentSize.width
        let titleViewWidth = UIScreen.main.bounds.width - 100

        if (contentWidth < titleViewWidth) {
            let scrollViewWidth = (contentWidth < titleViewWidth) ? contentWidth : UIScreen.main.bounds.width
            titleScrollView.snp.remakeConstraints { (make) in
                make.height.equalToSuperview()
                make.left.greaterThanOrEqualToSuperview()
                make.right.lessThanOrEqualToSuperview()
                
                if let parentView = self.superview {
                    make.centerX.equalTo(parentView).priorityHigh()
                }
                
                make.top.equalToSuperview()
                make.width.equalTo(scrollViewWidth)
            }
        } else {
            titleScrollView.frame = bounds
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
}
