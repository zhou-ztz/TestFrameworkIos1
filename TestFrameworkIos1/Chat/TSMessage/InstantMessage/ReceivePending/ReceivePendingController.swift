//
//  ReceivePendingController.swift
//  ThinkSNS +
//
//  Created by 小唐 on 18/12/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//
//  审核消息列表

import UIKit

class ReceivePendingController: TSViewController {

    public enum ShowType: String {
        /// 动态评论置顶
        case momentCommentTop
        /// 资讯评论置顶
        case newsCommentTop
        /// 帖子评论置顶
        case postCommentTop
        /// 帖子置顶
        case postTop
    }

    // MARK: - Internal Property
    // MARK: - Private Property

    var showType: ShowType = ShowType.momentCommentTop

    fileprivate weak var titleView: TSTitleSelectControl!
    fileprivate weak var typeSelectView: ReceivePendingTypeSelectPopView!

    /// childVC
    // TODO: -childVC需要进行优化，太赶时间。 暂时先使用固定的childVC，之后提取父类或协议
    fileprivate let momentCommentTopVC = ReceivePendingCommentTopController(commentTopType: .moment)
    fileprivate let newsCommentTopVC = ReceivePendingCommentTopController(commentTopType: .news)
    fileprivate var currentShowVC: UIViewController?

    // MARK: - Initialize Function

    /// 默认的展示类型
    init(showType: ShowType = .momentCommentTop) {
        self.showType = showType
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Internal Function
    // MARK: - Override Function

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialUI()
        self.initialDataSource()
    }

}

// MARK: - UI

extension ReceivePendingController {
    /// 页面布局
    fileprivate func initialUI() -> Void {
        // 1. navigationbar
        let titleView = TSTitleSelectControl()
        titleView.addTarget(self, action: #selector(titleViewClick), for: .touchUpInside)
        self.navigationItem.titleView = titleView
        self.titleView = titleView
        // 2. popView
        let popView = ReceivePendingTypeSelectPopView()
        popView.selectedType = showType
        popView.isHidden = true
        self.view.addSubview(popView)
        popView.delegate = self
        popView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.typeSelectView = popView
        // 3. childVC
        self.addChild(self.momentCommentTopVC)
        self.addChild(self.newsCommentTopVC)
        self.view.addSubview(self.momentCommentTopVC.view)
        self.momentCommentTopVC.view.isHidden = true
        self.momentCommentTopVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.view.addSubview(self.newsCommentTopVC.view)
        self.newsCommentTopVC.view.isHidden = true
        self.newsCommentTopVC.view.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.view.bringSubviewToFront( popView)
    }
}

// MARK: - 数据处理与加载

extension ReceivePendingController {
    /// 根据类型设置标题 - 需等自定义标题控件可用
    fileprivate func setupTitleWith(showType: ShowType) -> Void {
        self.currentShowVC?.view.isHidden = true

        var title = ""
        var childVC: UIViewController?
        switch showType {
        case .momentCommentTop:
            title = "stick_type_group_commnet".localized
            childVC = self.momentCommentTopVC
            (childVC as! ReceivePendingCommentTopController).initialDataSource()
        case .newsCommentTop:
            title =  "stick_type_news_commnet".localized
            childVC = self.newsCommentTopVC
            (childVC as! ReceivePendingCommentTopController).initialDataSource()
        case .postCommentTop: break
//            title = "pin_post_comment".localized
//            childVC = self.postCommentTopVC
//            (childVC as! ReceivePendingCommentTopController).initialDataSource()
        case .postTop: break
//            title =  "pin_post".localized
//            childVC = self.postTopVC
//            (childVC as! ReceivePendingPostTopController).initialDataSource()
        }
        self.titleView.title = title
        self.showType = showType

        childVC?.view.isHidden = false
        self.currentShowVC = childVC
    }
}

extension ReceivePendingController {
    /// 默认数据加载
    fileprivate func initialDataSource() -> Void {
        self.setupTitleWith(showType: self.showType)
    }
}

// MARK: - 事件响应

extension ReceivePendingController {
    @objc fileprivate func titleViewClick() -> Void {
        self.typeSelectView.selectedType = showType
        self.typeSelectView.show()
    }
}

// MARK: - Delegate Function

// MARK: - ReceivePendingTypeSelectPopViewProtocol

extension ReceivePendingController: ReceivePendingTypeSelectPopViewProtocol {
    /// 选项 选中回调
    func popView(_ popView: ReceivePendingTypeSelectPopView, didSelectedType type: ReceivePendingController.ShowType) -> Void {
        if self.showType == type {
            return
        } else {
            self.setupTitleWith(showType: type)
        }
    }
}
