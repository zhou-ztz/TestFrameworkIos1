//
//  MeetingPayinfoView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/6/30.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MeetingPayinfoView: UIView {
    
    var payInfo: PayInfo!
    
    let titleL = UILabel().configure {
        $0.font = UIFont.systemRegularFont(ofSize: 14)
        $0.textColor = UIColor(hex: "#212121", alpha: 1)
    }
    
    let downBtn = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "down"), for: .normal)
        $0.setImage(UIImage.set_image(named: "up"), for: .selected)
    }
    
    let stackView: UIStackView = UIStackView().configure {
        $0.spacing = 10
        $0.axis = .vertical
        $0.distribution = .fill
        
    }
    
    
    let topview = UIView()
    var view1 = UIView()
    var view2 = UIView()
    

    init(frame: CGRect, payInfo: PayInfo) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: 0xF6F6F6)
        self.payInfo = payInfo
        setUI()
        
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func setUI(){
        self.addSubview(stackView)
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.left.right.equalToSuperview()
        }
        stackView.addArrangedSubview(topview)
        topview.snp.makeConstraints { make in
            make.height.equalTo(37)
            make.left.right.equalToSuperview()
        }
        topview.addSubview(self.titleL)
        topview.addSubview(self.downBtn)
        titleL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(17)
            
        }
        downBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
            make.height.width.equalTo(24)
        }
        
        downBtn.addTarget(self, action: #selector(downAction), for: .touchUpInside)
        //meeting_premium_plan_total_members_desc_ios
        
        view1 = createView(content: String(format: "meeting_premium_plan_total_members_desc_ios".localized, "\(payInfo.vipMeetingMemberLimit)"))
        view2 = createView(content: "meeting_unlimited_time_ios".localized)
        stackView.addArrangedSubview(view1)
        stackView.addArrangedSubview(view2)
        view1.snp.makeConstraints { make in
            make.height.equalTo(21)
        }
        view2.snp.makeConstraints { make in
            make.height.equalTo(21)
        }
        view1.isHidden = true
        view2.isHidden = true
        let time = payInfo.meetingVipAt ?? ""
        titleL.text = String(format: "meeting_premium_plan_title_ios".localized, time)
        titleL.attributedText = String(format: "meeting_premium_plan_title_ios".localized, time).toHTMLString(size: "14.0", color: "#212121")

    }
    
    func createView(content: String) -> UIView {
        
        let payStackView = UIStackView()
        payStackView.spacing = 10
        payStackView.axis = .horizontal
        payStackView.distribution = .fill
        
        let img = UIImageView()
        img.image = UIImage.set_image(named: "MdDone")
        
        
        payStackView.addArrangedSubview(img)
        img.snp.makeConstraints { make in
            //make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.height.width.equalTo(24)
        }
        let contentL = UILabel()
        contentL.font = UIFont.systemRegularFont(ofSize: 14)
        contentL.textColor = UIColor(hex: "#212121", alpha: 1)
        //contentL.text = content
        contentL.attributedText = content.toRemoveHTMLString(size:14.0, color: "#212121")
        payStackView.addArrangedSubview(contentL)
        
        contentL.snp.makeConstraints { make in
            
            make.right.equalTo(-10)
        }
        
        return payStackView
        
    }
    
    
    @objc func downAction (){
        downBtn.isSelected = !downBtn.isSelected
        view1.isHidden = !downBtn.isSelected
        view2.isHidden = !downBtn.isSelected
        
    }
    
    func setTitleInfo(payInfo: PayInfo){
        let time = payInfo.meetingVipAt ?? ""
        titleL.attributedText = String(format: "meeting_premium_plan_title_ios".localized, time).toHTMLString(size: "14.0", color: "#212121")
    }
    

}
