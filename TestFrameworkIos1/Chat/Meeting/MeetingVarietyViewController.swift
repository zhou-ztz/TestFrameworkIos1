//
//  MeetingVarietyViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/6/13.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit

class MeetingVarietyViewController: UIViewController {
    
    var starBackCall: ((Int)->())?
    
    //付费信息
    var payInfo:PayInfo?
    
    lazy var baseView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.bounces = false
        scroll.backgroundColor = .white
        return scroll
    }()
    let stackView: UIStackView = UIStackView().configure {
        $0.spacing = 16
        $0.axis = .vertical
        //$0.distribution = .fill
    }
    var freeView: UIView?
    var priceView: UIView?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    var parentVc: MeetingListViewController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    func setUI(){
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        
        
        self.view.addSubview(baseView)
        baseView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight - TSNavigationBarHeight - 5)
//        baseView.snp_makeConstraints { make in
//            make.left.bottom.right.equalToSuperview()
//            make.top.equalTo(TSNavigationBarHeight + 5)
//        }
        baseView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.bottom.right.top.equalToSuperview()
            
        }
        
        freeView = setUpFreeView(isFree: true, title: "meeting_basic_plan".localized, content1: String(format: "meeting_maximum_members_ios".localized, self.payInfo?.freeMemberLimit ?? ""), content2: String(format: "meeting_45_mins_per_meeting_ios".localized, self.payInfo?.freeTimeLimit ?? ""), price: "meeting_free".localized, tag: 100)
        stackView.addArrangedSubview(freeView!)
        priceView = setUpFreeView(isFree: false, title: "meeting_premium_plan".localized, content1: String(format: "meeting_premium_plan_total_members_desc_ios".localized, "\(self.payInfo?.vipMeetingMemberLimit ?? "")"), content2: "meeting_unlimited_time_ios".localized, price: "\(self.payInfo?.meetingPrice ?? "")", tag: 101)
        stackView.addArrangedSubview(priceView!)
        
        freeView!.snp.makeConstraints({ make in
            make.height.equalTo(290)
            make.left.equalTo(16)
            make.width.equalTo(ScreenWidth - 32)
            //make.right.equalTo(-16)
            make.top.equalTo(48)
        })
        priceView!.snp.makeConstraints({ make in
            make.height.equalTo(306)
            make.left.equalTo(16)
            make.width.equalTo(ScreenWidth - 32)
            make.bottom.equalTo(-20)
        })
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xD9D9D9)
        line.layer.cornerRadius = 2.5
        line.clipsToBounds = true
        baseView.addSubview(line)
        line.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(5)
            make.width.equalTo(60)
            make.top.equalTo(7)
        }
        baseView.layer.cornerRadius = 10
        baseView.clipsToBounds = true
        self.view.addAction { [weak self] in
            self?.dismiss()
        }
        UIView.animate(withDuration: 0.3) {
            var frame = self.baseView.frame
            frame.origin.y = TSNavigationBarHeight + 5
            self.baseView.frame = frame
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
    }
    
    func dismiss(){

        self.removeFromParent()
        self.view.removeFromSuperview()
        
    }
    
    func setUpFreeView(isFree: Bool = true, title: String, content1: String, content2: String, price: String, tag: Int) -> UIView{
        let view = UIView()
        view.layer.cornerRadius = 16
        if isFree {
            view.backgroundColor = UIColor(hex: 0xF6F6F6)
        }else{
            view.backgroundColor = UIColor(hex: 0xE5E6Eb)
        }
        

        let titleL = UILabel()
        titleL.textColor = .black
        titleL.font = UIFont.boldSystemFont(ofSize: 14.0)
        titleL.text = title
        view.addSubview(titleL)
        titleL.snp.makeConstraints { make in
            make.left.equalTo(17)
            make.top.equalTo(isFree ? 48 : 63)
        }
        
        let priceL = UILabel()
        priceL.text = price
        priceL.textColor = AppTheme.red
        priceL.font = UIFont.boldSystemFont(ofSize: 34)
        priceL.textAlignment = .right
        view.addSubview(priceL)
        priceL.snp.makeConstraints { make in
            make.right.equalTo(-17)
            make.height.equalTo(52)
            if isFree {
                make.centerY.equalTo(titleL.snp_centerY)
            }else{
                make.top.equalTo(32)
            }
            
        }
        
        if !isFree {
            let yippisL = UILabel()
            yippisL.text = "rw_meeting_yipps_annually".localized
            yippisL.textColor = .black
            yippisL.font = UIFont.systemFont(ofSize: 14)
            yippisL.textAlignment = .right
            yippisL.attributedText = ("rw_meeting_yipps_annually".localized).toHTMLString(size: "14.0", color: "#242424")
            view.addSubview(yippisL)
            yippisL.snp.makeConstraints { make in
                make.right.equalTo(-17)
                make.top.equalTo(priceL.snp_bottom).offset(8)
            }
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xD9D9D9, alpha: 0.8)
        view.addSubview(line)
        line.snp.makeConstraints { make in
            make.left.equalTo(37)
            make.right.equalTo(-37)
            make.top.equalTo(isFree ? 106 : 135)
            make.height.equalTo(1)
        }
        
        let img1 = UIImageView()
        img1.image = UIImage.set_image(named: "meeting_select")
        view.addSubview(img1)
        img1.snp.makeConstraints { make in
            make.left.equalTo(19)
            make.top.equalTo(line.snp_bottom).offset(18)
            make.height.width.equalTo(20)
        }
        
        let contentL1 = UILabel()
       // contentL1.text = content1
        contentL1.textColor = UIColor(hex: 0x212121)
        contentL1.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(contentL1)
        contentL1.attributedText = content1.toHTMLString(size: "14.0", color: "#212121")
        contentL1.snp.makeConstraints { make in
            make.left.equalTo(img1.snp_right).offset(14)
            make.centerY.equalTo(img1.snp_centerY)
        }
        
        let img2 = UIImageView()
        img2.image = UIImage.set_image(named: "meeting_select")
        view.addSubview(img2)
        img2.snp.makeConstraints { make in
            make.left.equalTo(19)
            make.top.equalTo(img1.snp_bottom).offset(28)
            make.height.width.equalTo(20)
        }
        
        let contentL2 = UILabel()
        //contentL2.text = content2
        contentL2.textColor = UIColor(hex: 0x212121)
        contentL2.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(contentL2)
        contentL2.attributedText = content2.toHTMLString(size: "14.0", color: "#212121")
        contentL2.snp.makeConstraints { make in
            make.left.equalTo(img2.snp_right).offset(14)
            make.centerY.equalTo(img2.snp_centerY)
        }
        
        let startBtn = UIButton()
        startBtn.layer.cornerRadius = 10
        startBtn.backgroundColor = UIColor(hex: 0xE5E6EB)
        startBtn.setTitle("meeting_start_now".localized, for: .normal)
        startBtn.setTitleColor(.black, for: .normal)
        startBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        view.addSubview(startBtn)
        if !isFree {
            startBtn.backgroundColor = AppTheme.red
            startBtn.setTitle("rw_subscribe_now".localized, for: .normal)
            startBtn.setTitleColor(.white, for: .normal)
        }
        startBtn.snp.makeConstraints { make in
            make.left.equalTo(24)
            make.right.equalTo(-24)
            make.height.equalTo(50)
            make.top.equalTo(img2.snp_bottom).offset(18)
        }
        startBtn.tag = tag
        startBtn.addTarget(self, action: #selector(startAction(_:)), for: .touchUpInside)
        return view
    }
    
    @objc func startAction(_ sender: UIButton){
//        if sender.tag == 100{
//            self.dismiss()
//        }
        self.starBackCall?(sender.tag)
        
    }

}

extension String {
    //给html string 添加<span style="font-family: -apple-system; font-size: 18.0px; color: #000000;">Hello, <b>World</b>!</span>
    func toHTMLString(size: String, color: String = "#000000") -> NSMutableAttributedString?{
        
        let text = "<span style=\"font-family: -apple-system; font-size: \(size)px; color: \(color);\">" + self + "</span>"
        print("HTMLString = \(text)")
        if let data = text.data(using: .utf8) {
            let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
                return attributedString
        }else{
            return nil
        }
    }
    
    //移除<b> <\b>
    func toRemoveHTMLString(size: CGFloat, color: String = "#000000") -> NSMutableAttributedString?{
        // 设置字体、字体颜色和大小
        let font = UIFont.systemFont(ofSize: size)
        let fontColor = UIColor(hex: color, alpha: 1)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: fontColor
        ]
        if let data = self.data(using: .utf8) {
            let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)], documentAttributes: nil)
            attributedString?.addAttributes(attributes,range: NSRange(location: 0, length: attributedString?.length ?? 0))
            return attributedString
        }else{
            return nil
        }
    }

}
