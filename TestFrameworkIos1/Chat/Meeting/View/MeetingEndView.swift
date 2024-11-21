//
//  MeetingEndView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/7/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MeetingEndView: UIView, TimerHolderDelegate {
    
    var okAction: (()->())?
    
    var timer: TimerHolder?
    
    let btn = UIButton(type: .custom)
    var count: Int = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setUI(){

        self.timer = TimerHolder()
        
        self.backgroundColor = .black.withAlphaComponent(0.2)
        let pop = UIView()
        pop.backgroundColor = .white
        self.addSubview(pop)
        pop.snp.makeConstraints { make in
            //make.height.equalTo(200)
            make.width.equalTo(322)
            make.center.equalToSuperview()
        }
        pop.layer.cornerRadius = 20
        pop.clipsToBounds = true
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 18
        stackView.alignment = .center
        stackView.distribution = .fill
        pop.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(33)
            make.bottom.equalTo(-34)
        }
        
        let titleL = UILabel()
        titleL.text = "meeting_ended_meeting_desc".localized
        titleL.textColor = UIColor(hex: "#212121")
        titleL.font = UIFont.boldSystemFont(ofSize: 17)
        titleL.textAlignment = .center
        stackView.addArrangedSubview(titleL)
        
        let contentL = UILabel()
        contentL.text = "rw_meeting_thanks_desc".localized
        contentL.textColor = UIColor(hex: "#212121")
        contentL.font = UIFont.systemFont(ofSize: 14)
        contentL.textAlignment = .center
        stackView.addArrangedSubview(contentL)
        
        
        btn.setTitle(String(format: "meeting_close_in_number_ios".localized, "\(count)"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = AppTheme.red
        btn.layer.cornerRadius = 10
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.clipsToBounds = true
        stackView.addArrangedSubview(btn)
        titleL.snp.makeConstraints { make in
            make.height.equalTo(27)
            //make.top.equalTo(33)
            
        }
        contentL.snp.makeConstraints { make in
            make.height.equalTo(21)
        
        }
        btn.snp.makeConstraints { make in
            make.height.equalTo(48)
            make.width.equalTo(130)
            
        }
        
        btn.addAction {
            self.okAction?()
        }
        self.timer?.startTimer(seconds: 1, delegate: self, repeats: true)
    }
    
    func onTimerFired(holder: TimerHolder) {
        count = count - 1
        btn.setTitle(String(format: "meeting_close_in_number_ios".localized, "\(count)"), for: .normal)
        if count < 0 {
            self.okAction?()
            self.timer?.stopTimer()
        }
    }
    
    

}
