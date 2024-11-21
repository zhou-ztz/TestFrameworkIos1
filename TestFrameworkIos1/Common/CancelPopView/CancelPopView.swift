//
//  CancelPopView.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 10/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class CancelPopView: UIView {

    @IBOutlet var alertView: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var descLabel: UILabel!
    
    var alertButtonClosure: (()->())?
    var cancelButtonClosure: (()->())?
    
    var isVoucherPop: Bool = false

    
    @IBAction func cancelAction(_ sender: Any) {
        cancelButtonClosure?()
    }
    
    @IBAction func alertAction(_ sender: Any) {
        alertButtonClosure?()
    }
    
    init(isVoucherPop: Bool) {
        self.isVoucherPop = isVoucherPop
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        Bundle.main.loadNibNamed(String(describing: CancelPopView.self), owner: self, options: nil)
        alertView.frame = self.bounds
        alertView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.addSubview(alertView)
        alertView.roundCorner(10)
        
        if isVoucherPop {
            titleLabel.text = "rw_text_mark_as_redeemed".localized + "?"
            descLabel.text = "rw_text_voucher_redeem_desc".localized
        } else {
            titleLabel.text = "rw_text_cancel_transaction".localized
            descLabel.text = "rw_text_cancel_transaction_description".localized
        }
        
        cancelButton.applyStyle(.custom(text: "rw_text_no".localized, textColor: TSColor.normal.blackTitle, backgroundColor: TSColor.normal.keyboardTopCutLine, cornerRadius: 10))
        confirmButton.applyStyle(.custom(text: "rw_text_yes".localized, textColor: TSColor.main.white, backgroundColor: TSColor.main.theme, cornerRadius: 10))

    }
    
}
