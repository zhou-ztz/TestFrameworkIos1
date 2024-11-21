//
//  IMRecordStateView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/3/10.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NIMSDK
class VoiceDBBean: Codable {
    
    var dbList: [Int] = []
    
    init(dbList: [Int]) {
        self.dbList = dbList
    }
}

class IMRecordStateView: UIView {
    
    
    let levelWidth = 3
    
    let levelMargin = 4
    // 振幅layer
    private var levelLayer: CAShapeLayer = CAShapeLayer()
    
    public var currentLevels: [CGFloat] = []
    
    public var saveLevels: [CGFloat] = []
    // 画振幅的path
    private var levelPath: UIBezierPath!
    
    private var levelTimer: CADisplayLink?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLevelLayer()
        
        let levelCount = Int(levelLayer.frame.width) / (levelWidth + levelMargin)
        for _ in 1...levelCount {
            currentLevels.append(0.02)
        }
        for var level in currentLevels {
            self.updateLevelLayer()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func initLevelLayer() {
        
        levelLayer = CAShapeLayer()
        levelLayer.frame = CGRectMake(15 , 10, self.frame.size.width - 30, self.frame.size.height - 20)

        levelLayer.strokeColor = UIColor.white.cgColor
        levelLayer.lineWidth = CGFloat(levelWidth)
        levelLayer.lineCap = .round
        levelLayer.lineJoin = .round
        self.layer.addSublayer(levelLayer)
    }
    //结束录音
    func endRecord() {
        self.currentLevels = []
        self.saveLevels = []
        let levelCount = Int(levelLayer.frame.width) / (levelWidth + levelMargin)
        for _ in 1...levelCount {
            self.currentLevels.append(0.02)
        }
        if let sublayers = self.layer.sublayers {
            for layer in sublayers {
                layer.removeFromSuperlayer()
            }
        }
    }
    //开始用计时器记录波纹
    func startMeterTimer() {
        self.stopMeterTimer()
        self.initLevelLayer()
        
        self.levelTimer = CADisplayLink(target: self, selector: #selector(updateMeter))
        self.levelTimer?.preferredFramesPerSecond = 10
        self.levelTimer?.add(to: RunLoop.current, forMode: .common)
    }
    //结束计时器
    func stopMeterTimer() {
        self.levelTimer?.invalidate()
        self.endRecord()
        
    }
    //更新波纹状态
    @objc func updateMeter() {
        
        let level = NIMSDK.shared().mediaManager.recordAveragePower()
        let aveChannel = pow(10, (0.02 * level))
        
        if aveChannel > 0.01 && aveChannel < 1 {
            self.currentLevels.removeLast()
            self.currentLevels.insert(CGFloat(aveChannel), at: 0)
            self.saveLevels.append(CGFloat(aveChannel < 0.05 ? 0.05 : aveChannel))
            self.updateLevelLayer()
        }
    }
    // 更新 layer
    func updateLevelLayer() {
        
        self.levelPath = UIBezierPath()
        let height = CGRectGetHeight(self.levelLayer.frame)
        for (index,level) in self.currentLevels.enumerated() {
            let x = index * (levelWidth + levelMargin) + 5
            let pathH = level * height
            let startY = height / 2.0 - pathH / 2.0
            let endY = height / 2.0 + pathH / 2.0
            levelPath.lineCapStyle  = .round
            levelPath.lineJoinStyle = .round
            levelPath.move(to: CGPointMake(CGFloat(x), startY))
            levelPath.addLine(to: CGPointMake(CGFloat(x), endY))
        }
        self.levelLayer.path = levelPath.cgPath

    }

}
