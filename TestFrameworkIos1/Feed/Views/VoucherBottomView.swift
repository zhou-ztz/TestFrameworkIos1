//
//  VoucherBottomView.swift
//  RewardsLink
//
//  Created by Wong Jin Lun on 17/07/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class VoucherBottomView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var voucherLabel: UILabel!
    
    var voucherOnTapped: EmptyClosure?
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        Bundle.main.loadNibNamed(String(describing: VoucherBottomView.self), owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(voucherAction))
        contentView.addGestureRecognizer(tap)
    }
    
    @objc func voucherAction() {
        self.voucherOnTapped?()
    }

}
