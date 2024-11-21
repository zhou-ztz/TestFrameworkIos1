//
//  IMMigrateProgressView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/23.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

class IMMigrateProgressView: UIView {
    
    var tip: String = ""
    var progress: CGFloat = 0
    var stopButton: UIButton!
    var tipLabel: UILabel!
    var progressView: UIProgressView!
    var progressLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(white: 0.3, alpha: 1)
        tipLabel = UILabel()
        tipLabel.textColor = .white
        tipLabel.textAlignment = .center
        self.addSubview(tipLabel)
    
        progressLabel = UILabel()
        progressLabel.text = "0%"
        progressLabel.textColor = .white
        progressLabel.textAlignment = .center
        self.addSubview(progressLabel)
        
        progressView = UIProgressView()
        self.addSubview(progressView)
      
        stopButton = UIButton(type: .custom)
        stopButton.setTitle("  X  ", for: .normal)
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        stopButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.addSubview(stopButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bounds = self.bounds
        var y = bounds.size.height * 0.4
        self.tipLabel.frame = CGRect(x: 10, y: y, width: bounds.size.width - 20, height: 30)
        y += 60
        self.stopButton.center = CGPoint(x: bounds.size.width - 40, y: y)
        
        var x = self.stopButton.frame.origin.x - 56
        self.progressLabel.frame = CGRect(x: x, y: y - 15, width: 50, height: 28)
        x = 30
        self.progressView.frame = CGRect(x: x, y: y, width: self.progressLabel.frame.origin.x - 28, height: 30)
    }
    
    func setProgress(progress: CGFloat){
        self.progress = progress
        self.progressView.progress = Float(progress)
        self.progressLabel.text = String(Int(progress * 100))
        
    }
    
    func setTip(tip: String){
        self.tip = tip
        self.tipLabel.text = tip
    }
    

}
