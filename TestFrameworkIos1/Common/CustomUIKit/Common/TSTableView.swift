//
//  TSTableView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/8/22.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//

import UIKit
import SnapKit

class TSTableView: UITableView {
    
    let placeholder = Placeholder()
    var needDynamic: Bool = false

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setSuperUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setSuperUI()
    }

    // MARK: - Custom user interface
    func setSuperUI() {
        tableFooterView = UIView()
        // 添加刷新控件
        sectionIndexColor = .black
        sectionIndexBackgroundColor = .clear
        mj_header = TSRefreshHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        mj_footer = TSRefreshFooter(refreshingTarget: self, refreshingAction: #selector(loadMore))
    }

    override var intrinsicContentSize: CGSize {
        if needDynamic {
            return contentSize
        }

        return super.intrinsicContentSize
    }

    override var contentSize: CGSize {
        didSet {
            if needDynamic {
                self.invalidateIntrinsicContentSize()
            }
        }
    }

    override func reloadData() {
        super.reloadData()
        if needDynamic {
            self.invalidateIntrinsicContentSize()
        }
    }
}

// MARK: - 显示指示器
extension TSTableView {
    func show(indicatorA title: String) {
        let noti = Notification(name: Notification.Name.NavigationController.showIndicatorA, object: nil, userInfo: ["content": title])
        NotificationCenter.default.post(noti)
    }

    func show(indicatorA title: String, timeInterval: Int) {
        // 兼容旧的接口,修改的该视图显示的A指示器不能设置时间自动会消失,所有该方法的时间参数未被使用
        let noti = Notification(name: Notification.Name.NavigationController.showIndicatorA, object: nil, userInfo: ["content": title])
        NotificationCenter.default.post(noti)
    }

    func dismissIndicatorA() {
       // 兼容旧的接口,修改的该视图显示的A指示器不能设置时间自动会消失,所有该方法无效.
    }
}

// MARK: - 占位图
extension TSTableView {
    
    func show(placeholderView type: PlaceholderViewType, theme: Theme = .white, margin: CGFloat = 0.0, height: CGFloat? = nil) {
        if placeholder.superview == nil {
            self.addSubview(placeholder)
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
        }
        
        placeholder.set(type)
        placeholder.theme = theme
        placeholder.onTapActionButton = { [weak self] in
            guard let self = self, self.mj_header != nil else { return }
            self.mj_header.beginRefreshing()
        }
    }
    
    /// 移除占位图
    func removePlaceholderViews() {
        placeholder.removeFromSuperview()
    }
    
    func setGreyBackgroundColor() {
        placeholder.customBackgroundColor = TSColor.inconspicuous.background // UIColor(hex: 0xF9FAFB)
    }
}

/// 刷新逻辑
extension TSTableView {

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
