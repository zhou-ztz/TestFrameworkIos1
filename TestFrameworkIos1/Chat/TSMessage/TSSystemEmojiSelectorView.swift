//
//  TSSystemEmojiSelectorView.swift
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/9/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol TSSystemEmojiSelectorViewDelegate: class {
    func emojiViewDidSelected(emoji: String)
}

class TSSystemEmojiSelectorView: UIView, UIScrollViewDelegate {
    private var pageContrl = UIPageControl()
    private let scrollView = UIScrollView()
    /// 默认行数
    private var lines: Int = 3
    /// 默认单页列数
    private var columns: Int = 7
    /// 备注: emojiContentViewHeight + pageControlHeight 修改了就必须要修改 TSKeyboardToolbar 类里面 的 emojiHeight 和 toolBarHeight 两个属性里面的 145 (130+15)、以及 TSTextToolBarView 类里面 emojiViewHeight属性 和 scrollMaxHeight 属性 里面 145 (130+15) 的值
    private var emojiContentViewHeight: CGFloat = 130
    private let pageControlHeight: CGFloat = 15
    private var totalHeight: CGFloat = 0
    
    private let emojiLabWidth: CGFloat = 45
    private let emojiLabHeight: CGFloat = 30
    private var spaceX: CGFloat = 0
    private let spaceY: CGFloat = 11
    private var offsetX: CGFloat = 0
    /// emoji数据
    var emojis: [String] = []
    /// 是否在屏幕中显示
    var isShow: Bool = false
    
    /// 默认开启对底部安全区域的支持
    @objc var shouldKeepBottomSafeArea = true {
        didSet {
            // 关闭了安全区域调整高度
            if shouldKeepBottomSafeArea == false {
                if emojiContentViewHeight + pageControlHeight != self.height {
                    totalHeight = emojiContentViewHeight + pageControlHeight
                    self.height = totalHeight
                    self.updataUI()
                }
            }
        }
    }
    
    weak var delegate: TSSystemEmojiSelectorViewDelegate?
    @objc var didSelectedEmojiBlock: ((String) -> Void)?
    
    init(frame: CGRect, isPostFeed: Bool = true) {
        if isPostFeed == false {
            emojiContentViewHeight = 150
        }
        
        totalHeight = emojiContentViewHeight + pageControlHeight + TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight()
        
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController.supportedInterfaceOrientations.contains(.landscapeLeft) && UIDevice.current.orientation.isLandscape {
                super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: ScreenHeight, height: totalHeight))
            } else {
                super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: totalHeight))
            }
        } else {
            super.init(frame: CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: totalHeight))
        }
        
        initData()
        creatView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initData() {
        if let jsonData = try? Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "emoji", ofType: "json")!)), let d = try? JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers), let emojiArray = d as? NSArray {
            for item in emojiArray {
                if let itemDic = item as? NSDictionary {
                    emojis.append(itemDic.allKeys[0] as! String)
                }
            }
        }
    }
    
    func screenOrientationChanged() {
        scrollView.removeAllSubViews()
        
        columns = 7
        self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: totalHeight)
        pageContrl.numberOfPages = emojis.count / (lines * columns) + (emojis.count % (lines * columns) > 0 ? 1 : 0)
        pageContrl.frame = CGRect(x: (ScreenWidth - 120) / 2.0, y: self.height - pageControlHeight - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: 120, height: pageControlHeight)
        scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: self.emojiContentViewHeight)
        scrollView.contentSize = CGSize(width: ScreenWidth * CGFloat(pageContrl.numberOfPages), height: 0)
        
        spaceX = (ScreenWidth - emojiLabWidth * CGFloat(columns)) / CGFloat(columns + 1)
        offsetX = scrollView.width
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController.shouldAutorotate {
                // Live Audience
                if UIDevice.current.orientation.isLandscape {
                    columns = 13
                    self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: ScreenHeight, height: totalHeight)
                    pageContrl.numberOfPages = emojis.count / (lines * columns) + (emojis.count % (lines * columns) > 0 ? 1 : 0)
                    pageContrl.frame = CGRect(x: (ScreenHeight - 120) / 2.0, y: self.height - pageControlHeight - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: 120, height: pageControlHeight)
                    scrollView.frame = CGRect(x: 0, y: 0, width: ScreenHeight, height: self.emojiContentViewHeight)
                    scrollView.contentSize = CGSize(width: ScreenHeight * CGFloat(pageContrl.numberOfPages), height: 0)
                    
                    spaceX = (ScreenHeight - emojiLabWidth * CGFloat(columns)) / CGFloat(columns + 1)
                    offsetX = scrollView.width
                }
            } else {
                // Live Streamer and orientation support landscape
                if rootViewController.supportedInterfaceOrientations.contains(.landscapeLeft) {
                    columns = 13
                    self.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: ScreenHeight, height: totalHeight)
                    pageContrl.numberOfPages = emojis.count / (lines * columns) + (emojis.count % (lines * columns) > 0 ? 1 : 0)
                    pageContrl.frame = CGRect(x: (ScreenHeight - 120) / 2.0, y: self.height - pageControlHeight - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: 120, height: pageControlHeight)
                    scrollView.frame = CGRect(x: 0, y: 0, width: ScreenHeight, height: self.emojiContentViewHeight)
                    scrollView.contentSize = CGSize(width: ScreenHeight * CGFloat(pageContrl.numberOfPages), height: 0)
                    
                    spaceX = (ScreenHeight - emojiLabWidth * CGFloat(columns)) / CGFloat(columns + 1)
                    offsetX = scrollView.width
                }
            }
        } else {
            
        }
        
        for (index, emoji) in emojis.enumerated() {
            let emojiLab = UILabel()
            let tap = UITapGestureRecognizer(target: self, action: #selector(emojiDidTap(tap:)))
            emojiLab.isUserInteractionEnabled = true
            emojiLab.addGestureRecognizer(tap)
            emojiLab.textAlignment = .center
            emojiLab.font = UIFont.systemFont(ofSize: 28)
            emojiLab.text = emoji
            let xx: CGFloat = offsetX * CGFloat(index / (columns * lines)) + spaceX * CGFloat(index % columns + 1) + emojiLabWidth * CGFloat(index % columns)
            let yy: CGFloat = spaceY * CGFloat(index % (columns * lines) / columns + 1) + emojiLabHeight * CGFloat(index % (columns * lines) / columns)
            emojiLab.frame = CGRect(x: xx, y: yy, width: emojiLabWidth, height: emojiLabHeight)
            scrollView.addSubview(emojiLab)
        }
        
        layoutSubviews()
        layoutIfNeeded()
    }
    
    private func creatView() {
        let didTap = UITapGestureRecognizer(target: self, action: #selector(didTapSelf))
        self.addGestureRecognizer(didTap)
        //backgroundColor = UIColor(hex: 0xECEFF3)
        backgroundColor = .white
        pageContrl.pageIndicatorTintColor = UIColor.gray
        pageContrl.currentPageIndicatorTintColor = UIColor.white
        pageContrl.numberOfPages = emojis.count / (lines * columns) + (emojis.count % (lines * columns) > 0 ? 1 : 0)
        pageContrl.frame = CGRect(x: (ScreenWidth - 120) / 2.0, y: self.height - pageControlHeight - TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight(), width: 120, height: pageControlHeight)
        pageContrl.addTarget(self, action: #selector(pageControlDidChange), for: UIControl.Event.valueChanged)
        scrollView.isPagingEnabled = true
        scrollView.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: self.emojiContentViewHeight)
        scrollView.contentSize = CGSize(width: ScreenWidth * CGFloat(pageContrl.numberOfPages), height: 0)
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        let emojiLabWidth: CGFloat = 45
        let emojiLabHeight: CGFloat = 30
        let spaceX: CGFloat = (ScreenWidth - emojiLabWidth * CGFloat(columns)) / CGFloat(columns + 1)
        let spaceY: CGFloat = 11
        let offsetX: CGFloat = scrollView.width
        for (index, emoji) in emojis.enumerated() {
            let emojiLab = UILabel()
            let tap = UITapGestureRecognizer(target: self, action: #selector(emojiDidTap(tap:)))
            emojiLab.isUserInteractionEnabled = true
            emojiLab.addGestureRecognizer(tap)
            emojiLab.textAlignment = .center
            emojiLab.font = UIFont.systemFont(ofSize: 28)
            emojiLab.text = emoji
            let xx: CGFloat = offsetX * CGFloat(index / (columns * lines)) + spaceX * CGFloat(index % columns + 1) + emojiLabWidth * CGFloat(index % columns)
            let yy: CGFloat = spaceY * CGFloat(index % (columns * lines) / columns + 1) + emojiLabHeight * CGFloat(index % (columns * lines) / columns)
            emojiLab.frame = CGRect(x: xx, y: yy, width: emojiLabWidth, height: emojiLabHeight)
            scrollView.addSubview(emojiLab)
        }
        addSubview(scrollView)
        addSubview(pageContrl)
    }
    
    func updataUI() {
        pageContrl.frame = CGRect(x: (ScreenWidth - 120) / 2.0, y: self.height - 15, width: 120, height: 15)
    }
    
    @objc func pageControlDidChange() {
        scrollView.setContentOffset(CGPoint(x: CGFloat(pageContrl.currentPage) * scrollView.width, y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageContrl.currentPage = Int(scrollView.contentOffset.x / scrollView.width)
    }
    
    // 拦截自己的点击事件
    @objc func didTapSelf() {
    }
    
    @objc func emojiDidTap(tap: UITapGestureRecognizer) {
        let emojiLab = tap.view as? UILabel
        if let tapBlock = self.didSelectedEmojiBlock {
            tapBlock((emojiLab?.text)!)
        } else {
            delegate?.emojiViewDidSelected(emoji: (emojiLab?.text)!)
        }
    }
    
    // MARK: - Delegate
    func showEmojiView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: (self.superview?.height)! - self.height, width: ScreenWidth, height: self.height)
        }) { (success) in
            self.isShow = true
        }
        let userInfo = ["UIKeyboardAnimationDurationUserInfoKey": 0.25, "UIKeyboardFrameEndUserInfoKey": CGRect(x: 0, y: 0, width: ScreenWidth, height: self.height)] as [String : Any]
        NotificationCenter.default.post(name: UIResponder.keyboardWillShowNotification, object: nil, userInfo: userInfo)
    }
    
    func hidenEmojiView() {
        UIView.animate(withDuration: 0.25, animations: {
            self.frame = CGRect(x: 0, y: (self.superview?.height)!, width: ScreenWidth, height: self.height)
        }) { (success) in
            self.isShow = false
        }
        //        let userInfo = ["UIKeyboardAnimationDurationUserInfoKey": 0.25, "UIKeyboardFrameEndUserInfoKey": CGRect(x: 0, y: (self.superview?.height)!, width: self.width, height: self.height)] as [String : Any]
        //        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil, userInfo: userInfo)
    }
}
