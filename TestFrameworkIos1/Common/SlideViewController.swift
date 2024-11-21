//
//  SlideViewController.swift
//  Yippi
//
//  Created by Jerry Ng on 25/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SnapKit

class SlideViewController: TSViewController, UIScrollViewDelegate {

    typealias IconNamePairs = (String, String)
    
    /// 滚动视图
    var scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    
    
    let labelHeight: CGFloat = 44
    let blueLineHeight: CGFloat = 2.0
    
    private var titleIconView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - TSNavigationBarHeight))
    /// 标签视图
    let pageSelectionStackview = UIStackView()
    /// 标签下方的蓝线
    let blueLine = UIView()
    /// 提示用的小红点
    var badges: [UIView] = []
    /// 蓝线的 leading
    var blueLineLeading: CGFloat = 0

    /// 标签标题数组
    var selectionIconArray: [IconNamePairs]? = nil

    /// 按钮基础 tag 值
    let tagBasicForButton = 200
    
    private let badgeSize: CGSize = CGSize(width: 6, height: 6)
    
    var customLeftButton: UIButton?
    var customRightButton: UIButton?

    // MARK: - Lifecycle

    /// 自定义初始化方法
    ///
    /// - Parameter iconArray: 导航栏上标签的 icon 的数组
    init(iconArray: [IconNamePairs], scrollViewFrame: CGRect?, leftButton: UIButton? = nil, rightButton:UIButton? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.customLeftButton = leftButton
        self.customRightButton = rightButton

        if let scrollViewFrame = scrollViewFrame {
            scrollView.frame = scrollViewFrame
        }
        selectionIconArray = iconArray
        for _ in iconArray {
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
        
        if let iconArray = selectionIconArray {
            pageSelectionStackview.distribution = .fillEqually
            pageSelectionStackview.axis = .horizontal
            pageSelectionStackview.alignment = .fill
            pageSelectionStackview.spacing = 30
            
            if iconArray.isEmpty {
                return
            }
            
            blueLine.backgroundColor = TSColor.main.theme

            
            
            if let leftButton = self.customLeftButton {
                pageSelectionStackview.addArrangedSubview(leftButton)
            }
            
            // labelView button
            for (index, iconNamePair) in iconArray.enumerated() {
                let selectedImage = UIImage.set_image(named: iconNamePair.0)
                let normalImage = UIImage.set_image(named: iconNamePair.1)
                let button = UIButton(type: .custom)
                button.setImage(selectedImage, for: .selected)
                button.setImage(normalImage, for: .normal)
                button.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
                button.tag = tagBasicForButton + index
                
                let badge = badges[index]
                let badgeX = button.frame.width + 5
                badge.frame = CGRect(x: badgeX, y: 10, width: badgeSize.width, height: badgeSize.height)
                button.addSubview(badge)
                
                pageSelectionStackview.addArrangedSubview(button)
            }
            
            if let rightButton = self.customRightButton {
                pageSelectionStackview.addArrangedSubview(rightButton)
            }
            updateButtonWidth()

            // labelView
            titleIconView.backgroundColor = UIColor.white
            titleIconView.addSubview(pageSelectionStackview)
            
            titleIconView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
            navigationItem.titleView = titleIconView
            
            pageSelectionStackview.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(6)
                make.bottom.left.right.equalToSuperview()
            }
            
            pageSelectionStackview.addSubview(blueLine)
            
            // set initial blueline position
            blueLine.snp.makeConstraints { (make) in
                make.height.equalTo(blueLineHeight)
                make.centerX.equalTo(pageSelectionStackview.arrangedSubviews[0])
                make.bottom.equalToSuperview().offset(6.0)
                make.width.equalTo(pageSelectionStackview.arrangedSubviews[0].snp.width).offset(8.0)
            }
            
            // scrollView
            scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(iconArray.count), height: scrollView.frame.size.height)
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
    
    private func updateButtonWidth() {
        let totalItem = pageSelectionStackview.arrangedSubviews.count
        let totalSpacing = 30 * CGFloat(totalItem)
        let buttonWidth = (UIScreen.main.bounds.width - totalSpacing) / CGFloat(totalItem)
        for view in pageSelectionStackview.arrangedSubviews {
            view.snp.remakeConstraints {
                $0.width.equalTo(buttonWidth)
            }
        }
    }

    // MARK: - Button click
    @objc func buttonTaped(sender: UIButton) {
        var index = sender.tag - tagBasicForButton
        scrollView.setContentOffset(CGPoint(x: UIScreen.main.bounds.size.width * CGFloat(index), y: 0), animated: true)
        selectedPageEndAt(index: index)
    }

    // MARK: - Public
    
    public func insertLeftButton(button:UIButton) {
        customLeftButton = button
        guard let newLeftButton = customLeftButton else { return }
        newLeftButton.tag = tagBasicForButton + 98
        pageSelectionStackview.insertArrangedSubview(newLeftButton, at: 0)
        updateButtonWidth()
        pageSelectionStackview.setNeedsDisplay()
        pageSelectionStackview.layoutIfNeeded()
    }
    public func insertRightButton(button:UIButton) {
        customRightButton = button
        guard let newRightButton = customRightButton else { return }
        newRightButton.tag = tagBasicForButton + 99
        pageSelectionStackview.addArrangedSubview(newRightButton)
        updateButtonWidth()
        pageSelectionStackview.setNeedsDisplay()
        pageSelectionStackview.layoutIfNeeded()
    }

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

    var oldIndex = -1
    /// 刷新按钮
    func updateButton(_ index: Int) {
        guard index < (selectionIconArray?.count ?? 0) else { return }
        guard oldIndex != index else { return }
        if let oldButton = (pageSelectionStackview.viewWithTag(tagBasicForButton + oldIndex) as? UIButton) {
            oldButton.isSelected = false
        }
        oldIndex = index
        if let button = (pageSelectionStackview.viewWithTag(tagBasicForButton + index) as? UIButton) {
            button.isSelected = true
        }
    }

    // MARK: - Delegate

    // MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > selectionIconArray!.count {
            index = CGFloat(selectionIconArray!.count)
        }
        
        if customLeftButton != nil { index+=1 }
        let i = round(index)
        blueLine.snp.remakeConstraints { (make) in
            make.height.equalTo(2.0)
            make.centerX.equalTo(pageSelectionStackview.arrangedSubviews[Int(i)])
            make.bottom.equalToSuperview().offset(6.0)
            make.width.equalTo(pageSelectionStackview.arrangedSubviews[Int(i)].snp.width).offset(8.0)
        }
        
        UIView.animate(withDuration: 0.15) {
            self.pageSelectionStackview.layoutIfNeeded()
        }
        TSKeyboardToolbar.share.keyboarddisappear()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var index = scrollView.contentOffset.x / scrollView.frame.width
        if index < 0 {
            index = CGFloat(0)
        }
        if Int(index) > selectionIconArray!.count {
            index = CGFloat(selectionIconArray!.count)
        }
        let i = round(index)
        updateButton(Int(i))
        selectedPageEndAt(index: Int(i))
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
         var index = scrollView.contentOffset.x / scrollView.frame.width
         if index < 0 {
             index = CGFloat(0)
         }
         if Int(index) > selectionIconArray!.count {
             index = CGFloat(selectionIconArray!.count)
         }
         let i = round(index)
         updateButton(Int(i))
    }
    
    func updateIndex(_ index: Int) {
        update(childViewsAt: index)
    }

}
