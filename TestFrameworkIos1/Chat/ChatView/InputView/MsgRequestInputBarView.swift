//
//  MsgRequestInputBarView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/31.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import InputBarAccessoryView

class MsgRequestInputBarView: InputBarAccessoryView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
    
        inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 5)
        inputTextView.placeholder = "rw_placeholder_comment".localized
        inputTextView.layer.borderWidth = 1.0
        inputTextView.layer.cornerRadius = 18
        inputTextView.layer.masksToBounds = true
        inputTextView.layer.borderColor = UIColor(red: 245 / 255.0, green: 245 / 255.0, blue: 245 / 255.0, alpha: 1).cgColor
        inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        sendButton.setImage(UIImage.set_image(named: "icASendBlue"), for: .normal)
        sendButton.setTitle("", for: .normal)
        
    }

}
