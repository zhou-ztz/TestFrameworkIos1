//
//  CustomerStickerPopView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/1/27.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD

class CustomerStickerPopView: UIView {
    // int 0 关闭弹窗  1 保存成功+ 关闭弹窗 2跳转自定义贴图页面+关闭弹窗 3 弹出数量限制弹出 + 关闭原弹出
    var okBtnClosure: ((Int)->())?
    var isDelete = false
    var isMaxNum = false
    var stickerId = ""
    let saveBtn = UIButton()
    private let contentStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = 10
        
    }
    
    init(frame: CGRect, imageUrl: String? = nil, isDelete: Bool = false, stickerId: String, isMaxNum: Bool = false) {
        super.init(frame: frame)
        self.frame = frame
        self.stickerId = stickerId
        self.setupUI(imageUrl: imageUrl, isDelete: isDelete, isMaxNum: isMaxNum)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(imageUrl: String? = nil, isDelete: Bool = false, isMaxNum: Bool = false){
        self.backgroundColor = .white
        self.isDelete = isDelete
        self.isMaxNum = isMaxNum
        let imageview = UIImageView()
        imageview.sd_setImage(with: URL(string: imageUrl ?? ""), completed: nil)
        imageview.contentMode = .scaleAspectFit
        self.addSubview(imageview)
        imageview.snp.makeConstraints { (make) in
            make.width.height.equalTo(110)
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
        }
        if let url = imageUrl, isMaxNum == false{
            
            if URL(string: url)!.pathExtension == "gif" {
                DispatchQueue.global().async {
                    let image = UIImage.gif(url: url)
                    DispatchQueue.main.async {
                        imageview.image = image
                    }
                    
                }
                
            }else{
                imageview.sd_setImage(with: URL(string: url), completed: nil)
            }
            
            
        }
        
        let message = UILabel()
        message.text = "text_max_custom_sticker".localized
        message.setFontSize(with: 17, weight: .bold)
        message.textColor = .black
        message.numberOfLines = 0
        message.textAlignment = .center
        self.addSubview(message)
        message.snp.makeConstraints { (make) in
            make.left.equalTo(22)
            make.top.equalTo(20)
            make.right.equalTo(-22)
        }
        message.isHidden = true
        if isMaxNum {
            message.isHidden = false
            imageview.isHidden = true
        }
        
        
        saveBtn.titleLabel?.setFontSize(with: 16, weight: .medium)
        saveBtn.setTitleColor(.white, for: .normal)
        self.addSubview(saveBtn)
        if isDelete { // 删除
            saveBtn.backgroundColor = UIColor(red: 230, green: 35, blue: 35)
            saveBtn.setTitle("    " + "custom_sticker_remove".localized + "    ", for: .normal)
        }else{
            if isMaxNum {//
                saveBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
                saveBtn.setTitle("    " + "button_manage_sticker".localized + "    ", for: .normal)
            }else{ //保存
                saveBtn.backgroundColor = UIColor(red: 59, green: 179, blue: 255)
                saveBtn.setTitle("    " + "custom_sticker_save".localized + "    ", for: .normal)
            }
            
        }
        saveBtn.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.top.equalTo(imageview.snp.bottom).offset(27)
            make.centerX.equalToSuperview()
        }
        saveBtn.layer.cornerRadius = 22.5
        saveBtn.layer.masksToBounds = true
        saveBtn.addTarget(self, action: #selector(saveBtnAction), for: .touchUpInside)
        
        let closeBtn = UIButton()
        closeBtn.titleLabel?.setFontSize(with: 16, weight: .medium)
        closeBtn.setTitleColor(UIColor(red: 165, green: 165, blue: 165), for: .normal)
        closeBtn.setTitle("cancel".localized, for: .normal)
        self.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.height.equalTo(45)
            make.top.equalTo(saveBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
        }
        
        closeBtn.addTarget(self, action: #selector(closeBtnAction), for: .touchUpInside)
        
    }
    
    @objc func saveBtnAction(){
        saveBtn.isUserInteractionEnabled = false
        if self.isDelete {
            //删除服务器贴图
            StickerManager.shared.removeCustomerSticker(stickerId: self.stickerId) { [weak self] (complete) in
                DispatchQueue.main.async {
                    self?.saveBtn.isUserInteractionEnabled = true
                }
                if complete {
                    //删除本地
                    StickerManager.shared.deleteLocalWithStickerId(sticlerId: self?.stickerId ?? "")
                    DispatchQueue.main.async {
                        UIViewController.topMostController?.showTopFloatingToast(with: "text_remove_sticker_success".localized, desc: "")
                        self?.okBtnClosure?(0)
                    }
                }else{
                    DispatchQueue.main.async {
                        UIViewController.topMostController?.showTopFloatingToast(with: "text_remove_sticker_failed".localized, desc: "")
                    }
                }
            }
            
        }else{
            
            if isMaxNum {
                self.okBtnClosure?(2)
                
            }else{
                //没有就下载该贴图
                StickerManager.shared.downloadCustomerSticker(stickerId: stickerId) { [weak self] (complete, error, msg) in
                    DispatchQueue.main.async {
                        self?.saveBtn.isUserInteractionEnabled = true
                        if complete {
                            if msg != nil {
                                self?.okBtnClosure?(3)
                                
                            }else{
                                self?.okBtnClosure?(1)
                            }
                        }else{
                            if let msg = msg {
                                UIViewController.topMostController?.showTopFloatingToast(with: msg, desc: "")
                            } else {
                                UIViewController.topMostController?.showTopFloatingToast(with: "text_add_sticker_failed".localized, desc: "")
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    @objc func closeBtnAction() {
        self.okBtnClosure?(0)
    }
}
