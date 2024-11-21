//
//  MeetingPayView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/6/25.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MeetingPayView: UIView {
    
    var isSucceed: Bool = true
    var expiredTime: String = ""
    
    let imageView = UIImageView().configure {
        $0.image = UIImage.set_image(named: "paySucceed")
    }
    
    let stackView: UIStackView = UIStackView().configure {
        $0.spacing = 16
        $0.axis = .vertical
        $0.distribution = .fill
        
    }
    
    //custom("Poppins", size: 16)
        //.weight(.bold)
    let titleL = UILabel().configure {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = UIColor.black
        $0.textAlignment = .center
    }
    let contentL = UILabel().configure {
        $0.font = UIFont.systemRegularFont(ofSize: 16)
        $0.textColor = UIColor(hex: "#808080", alpha: 1)
        $0.textAlignment = .center
    }
    let tipL = UILabel().configure {
        $0.font = UIFont.systemRegularFont(ofSize: 14)
        $0.textColor = UIColor(hex: "#ED2121", alpha: 1)
    }
    
    var okBtnClosure: (()->())?

    init(frame: CGRect, isSucceed: Bool, time: String) {
        super.init(frame: frame)
        self.backgroundColor = TSColor.main.white
        self.isSucceed = isSucceed
        self.expiredTime = time
        setUI()
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = TSColor.main.white
        setUI()
    }
    
    func setUI(){
        contentL.numberOfLines = 0
        contentL.sizeToFit()
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(66)
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.bottom.equalToSuperview()
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        stackView.addArrangedSubview(titleL)
        stackView.addArrangedSubview(contentL)
        stackView.addArrangedSubview(tipL)
     
        if self.isSucceed {
            imageView.image = UIImage.set_image(named: "paySucceed")
            titleL.text = "meeting_payment_successful".localized
            contentL.text = "meeting_premium_active_congrats_message".localized
        }else{
            imageView.image = UIImage.set_image(named: "payFail")
            titleL.text = "meeting_payment_failed".localized
            contentL.text = "meeting_payment_failed_desc".localized
        }
        tipL.text = String(format: "meeting_will_expired_string_ios".localized, "\(self.expiredTime)")
        tipL.attributedText = String(format: "meeting_will_expired_string_ios".localized, "\(self.expiredTime)").toHTMLString(size: "14.0", color: "#ED2121")
        tipL.isHidden = !isSucceed
        let startBtn = UIButton()
        startBtn.layer.cornerRadius = 8
        //startBtn.clipsToBounds = true
        startBtn.layer.shadowColor = UIColor(red: 0.231, green: 0.702, blue: 1, alpha: 0.1).cgColor
        startBtn.layer.shadowOffset = CGSize(width: 0, height: 4)
        startBtn.layer.shadowOpacity = 1
        startBtn.layer.shadowRadius = 20
       
        startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        startBtn.backgroundColor = AppTheme.red
        isSucceed == true ? startBtn.setTitle("meeting_okay".localized, for: .normal) : startBtn.setTitle("meeting_okay".localized, for: .normal)
        
        startBtn.setTitleColor(.white, for: .normal)
        stackView.addArrangedSubview(startBtn)
        
        tipL.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        startBtn.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(70)
        }
        startBtn.addTarget(self, action: #selector(okAction), for: .touchUpInside)
    }
    
    @objc func okAction(){
        self.okBtnClosure?()
    }
}
