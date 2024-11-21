//
//  NIMPageView.swift
//  Yippi
//
//  Created by Khoo on 06/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
@objc protocol PageViewDataSource: NSObjectProtocol {
    func numberOfPages(_ pageView: PageView?) -> Int
    func pageView(_ pageView: PageView?, viewInPage index: Int) -> UIView?
}

@objc protocol PageViewDelegate: NSObjectProtocol {
    @objc optional func pageViewScrollEnd(
        _ pageView: PageView?,
        currentIndex index: Int,
        totolPages pages: Int
    )
    @objc optional func pageViewDidScroll(_ pageView: PageView?)
    @objc optional func needScrollAnimation() -> Bool
}

class PageView: UIView, UIScrollViewDelegate {
    var scrollView: UIScrollView?
    weak var dataSource: PageViewDataSource?
    weak var pageViewDelegate: PageViewDelegate?
    
    var currentPage: Int = 0

    var currentPageForRotation: Int = 0
    
    var pages: [UIView]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupControls()
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToPage(page: Int) {
        if currentPage != page || page == 0 {
            currentPage = page
            self.reloadData()
        }
    }
    
    func reloadData() {
        self.calculatePageNumbers()
        self.reloadPage()
    }
    
    func setupControls() {
        if scrollView == nil {
            scrollView = UIScrollView(frame: bounds)
            scrollView!.autoresizingMask = .flexibleWidth
            addSubview(scrollView!)
            scrollView!.isPagingEnabled = true
            scrollView!.showsVerticalScrollIndicator = false
            scrollView!.showsHorizontalScrollIndicator = false
            scrollView!.delegate = self
            scrollView!.scrollsToTop = false
        }
    }
    
    // MARK: 对外接口
    func view(at index: Int) -> UIView? {
        var view: UIView? = nil
        if index >= 0 && index < pages?.count ?? 0 {
            let obj = pages?[index]
                view = obj
        }
        return view
    }
    
    func page(inBound value: Int, min: Int, max: Int) -> Int {
        var max = max
        if max < min {
            max = min
        }
        var bounded = value
        if bounded > max {
            bounded = max
        }
        if bounded < min {
            bounded = min
        }
        return bounded
    }
    
   // MARK : Page载入和销毁
    func loadPagesForCurrentPage(currentPage: Int) {
        let count = pages?.count ?? 0
        if count == 0 {
            return
        }
        let first = page(inBound: currentPage - 1, min: 0, max: count - 1)
        let last = page(inBound: currentPage + 1, min: 0, max: count - 1)
        let range = NSRange(location: first, length: last - first + 1)
        
        for index in 0..<count {
            if NSLocationInRange(index, range) {
                let obj = pages?[index]
                if !(obj == nil) {
                    let view = dataSource?.pageView(self, viewInPage: index)
                    if let view = view {
                        pages?[index] = view
                        scrollView?.addSubview(view)
                    }
                    let size = bounds.size
                    view?.frame = CGRect(x: size.width * CGFloat(index), y: 0, width: size.width, height: size.height)
                }
            } else {
                let obj = pages?[index]
                if let obj = obj {
                    obj.removeFromSuperview()
                    pages?.remove(at: index)
                }
            }
        }
    }
    
    func calculatePageNumbers () {
        var numberOfPages = 0
        if let pages = pages {
            for obj in pages {
                obj.removeFromSuperview()
            }
        }
        
        if (dataSource != nil) && ((dataSource?.responds(to: #selector(dataSource?.pageView(_:viewInPage:)))) != nil) {
            numberOfPages = dataSource?.numberOfPages(self) ?? 0
        }
    
        self.pages = [UIView]()

        for i in 0..<numberOfPages {
            self.pages?.append(UIView())
        }
        
        //注意，这里设置delegate是因为计算contentsize的时候会引起scrollViewDidScroll执行，修改currentpage的值，这样在贴图（举个例子）前面的分类页数比后面的分类页数多，前面的分类滚动到最后面一页后，再显示后面的分类，会显示不正确
        scrollView?.delegate = nil
        let size = bounds.size
        scrollView?.contentSize = CGSize(width: size.width * CGFloat(numberOfPages), height: size.height)
        scrollView?.delegate = self
    }
    
    func reloadPage () {
        //reload的时候尽量记住上次的位置
        if currentPage >= pages?.count ?? 0 {
            currentPage = pages?.count ?? 0 - 1
        }
        if currentPage < 0 {
            currentPage = 0
        }

        loadPagesForCurrentPage(currentPage: currentPage)
        raisePageIndexChangedDelegate()
        setNeedsLayout()
    }
    
    // MARK: ScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let offsetX = scrollView.contentOffset.x
        let page = Int(abs(offsetX / width))
        if page >= 0 && page < (pages?.count ?? 0) {
            if currentPage == page {
                return
            }
            currentPage = page
            loadPagesForCurrentPage(currentPage: currentPage)
        }

        if (pageViewDelegate != nil) && ((pageViewDelegate?.responds(to: #selector(pageViewDelegate?.pageViewDidScroll(_:)))) != nil) {
            pageViewDelegate?.pageViewDidScroll?(self)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.raisePageIndexChangedDelegate()
    }
    
    // MARK: -  辅助方法
    func raisePageIndexChangedDelegate() {
        if (pageViewDelegate != nil) && ((pageViewDelegate?.responds(to: #selector(pageViewDelegate?.pageViewScrollEnd(_:currentIndex:totolPages:)))) != nil) {
            
            pageViewDelegate?.pageViewScrollEnd?(self, currentIndex: currentPage, totolPages: pages?.count ?? 0)
        }
    }
    
    //旋转相关方法,这两个方法必须配对调用,否则会有问题
    func willRotate( to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        scrollView?.delegate = nil
        currentPageForRotation = currentPage
    }
    
    func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        let size = bounds.size
        scrollView?.contentSize = CGSize(width: size.width * CGFloat(pages?.count ?? 0), height: size.height)
        for i in 0..<(pages?.count ?? 0) {
            let obj = pages?[i]
            obj?.frame = CGRect(x: size.width * CGFloat(i), y: 0, width: size.width, height: size.height)
        }
        
        scrollView?.contentOffset = CGPoint(x: currentPageForRotation * Int(bounds.size.width), y: 0)
        scrollView?.delegate = self
    }
}
