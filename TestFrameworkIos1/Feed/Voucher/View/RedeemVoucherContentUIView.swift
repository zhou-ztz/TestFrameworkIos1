//
//  RedeemVoucherContentUIView.swift
//  RewardsLink
//
//  Created by Kit Foong on 21/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class RedeemVoucherContentUIView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var voucherBtnView: UIView!
    @IBOutlet weak var voucherBtn: UIButton!
    
    var isShare: Bool = false {
        didSet {
            var image = UIImage.set_image(named: "ic_copy")
            if isShare {
                image = UIImage.set_image(named: "rl_voucher_share")
            }
            voucherBtn.imageView?.image = image
            voucherBtn.setImageTintColor(AppTheme.primaryColor)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        Bundle.main.loadNibNamed(String(describing: RedeemVoucherContentUIView.self), owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)

        innerView.layer.cornerRadius = 5
        innerView.layer.masksToBounds = true
        
        voucherBtn.setImageTintColor(AppTheme.primaryColor)
        voucherBtn.setTitle("")
        
        voucherBtn.isUserInteractionEnabled = false
    }
}
