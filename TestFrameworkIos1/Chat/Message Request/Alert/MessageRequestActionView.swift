//
//  MessageRequestActionView.swift
//  Yippi
//
//  Created by Kit Foong on 22/02/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class MessageRequestActionView: UIView {
    
    var alertButtonClosure: (()->())?
    var cancelButtonClosure: (()->())?
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var alertButton: UIButton!
    
    @IBAction func cancelAction(_ sender: Any) {
        cancelButtonClosure?()
    }
    
    @IBAction func alertAction(_ sender: Any) {
        alertButtonClosure?()
    }
    
    init(isAccept: Bool, isGroup: Bool, name: String) {
        super.init(frame: .zero)
        setupUI(isAccept: isAccept, isGroup: isGroup, name: name)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(isAccept: false, isGroup: false, name: "")
    }
    
    private func setupUI(isAccept: Bool, isGroup: Bool, name: String) {
        Bundle.main.loadNibNamed(String(describing: MessageRequestActionView.self), owner: self, options: nil)
        alertView.frame = self.bounds
        alertView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.addSubview(alertView)
        alertView.roundCorner(10)
        
        cancelButton.applyStyle(.custom(text: "cancel".localized, textColor: TSColor.normal.blackTitle, backgroundColor: TSColor.normal.keyboardTopCutLine, cornerRadius: 10))
        
        if isAccept {
            alertTitle.text = isGroup ? "title_accept_group_request".localized : "title_accept_message_request".localized
            alertMessage.text = isGroup ? String(format:"desc_accept_group_request".localized, name) : String(format: "desc_accept_message_request".localized, name)
            alertButton.applyStyle(.custom(text: "accept_session".localized, textColor: TSColor.main.white, backgroundColor: TSColor.main.theme, cornerRadius: 10))
        } else {
            alertTitle.text = isGroup ? "title_reject_group_request".localized : "title_reject_message_request".localized
            alertMessage.text = isGroup ? String(format:"desc_reject_group_request".localized, name) : String(format:"desc_reject_message_request".localized, name)
            alertButton.applyStyle(.custom(text: "reject_session".localized, textColor: TSColor.main.white, backgroundColor: TSColor.main.theme, cornerRadius: 10))
        }
    }
}
