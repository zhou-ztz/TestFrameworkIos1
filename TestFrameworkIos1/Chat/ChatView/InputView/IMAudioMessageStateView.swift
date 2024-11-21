//
//  IMAudioMessageStateView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/23.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class IMAudioMessageStateView: UIView {
    
    let levelWidth = 2
    
    let levelMargin = 3
    
    var levelViews = [UIView]()

    var isFirstLoad = false
    
    //当前播放动态进度条下标
    var levelProgressIndex: Int = 0

    //录音时长 /秒
    public var duration: Int = 0

    public var currentLevels: [Float] = [] {
        didSet {
            isFirstLoad = true
            self.setupLevelView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 更新level 播放颜色
    public func updateLevelColor(_ progressValue: CGFloat) {
        
        var progress  = (CGFloat(self.levelViews.count) / CGFloat(duration)) * progressValue
        if progress.isNaN || progress.isInfinite {
            return
        }
        
        self.levelProgressIndex = Int(progress)
        if self.levelProgressIndex < self.levelViews.count {
            let view = self.levelViews[self.levelProgressIndex]
            view.backgroundColor = TSColor.small.outgoingBubble
        }
        if isFirstLoad{
            isFirstLoad = false
            updateLevelView()
        }
    }
    // MARK: - 播放结束，还原所有进度条颜色
    public func resetLevelColor() {
        self.levelViews.forEach { $0.backgroundColor = .clear }
        self.levelProgressIndex = 0
    }
    // MARK: - 加载level进度条views
    func setupLevelView() {
        
        levelViews = []
        let height = CGRectGetHeight(self.frame)
        for (index,level) in self.currentLevels.enumerated() {
            let x = index * (levelWidth + levelMargin) + 3
            let pathH = CGFloat(level) * height
            let startY = height / 3.0 - pathH / 2.0 + 1
            let endY = height / 2.0 + pathH / 2.0
            let startPoint = CGPoint(x: Double(x), y: startY)
            let endPoint = CGPoint(x: Double(x), y: endY)
            
            var finalHeight = endY - startY
            
            let levelView = UIView(frame: CGRect(x: startPoint.x, y: startY, width: CGFloat(levelWidth), height: finalHeight))
            levelView.backgroundColor = .black
            levelView.layer.cornerRadius = 1.5
            levelView.layer.masksToBounds = true
            self.addSubview(levelView)
            
            let progressLevelView = UIView(frame: CGRectMake(levelView.frame.origin.x - 0.2, levelView.frame.origin.y - 0.2, levelView.frame.width + 0.2, levelView.frame.height + 0.2))
            
            progressLevelView.backgroundColor = .clear
            progressLevelView.layer.cornerRadius = 1.5
            progressLevelView.layer.masksToBounds = true
            self.addSubview(progressLevelView)
            levelViews.append(progressLevelView)
            
        }
    }
    // MARK: - 更新进度条颜色（处理用户滑动后再次load view）
    func updateLevelView() {
        for (index,progressLevelView) in self.levelViews.enumerated(){
            if index < self.levelProgressIndex {
                progressLevelView.backgroundColor = TSColor.small.outgoingBubble
            }else{
                progressLevelView.backgroundColor = .clear
            }
        }

    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
