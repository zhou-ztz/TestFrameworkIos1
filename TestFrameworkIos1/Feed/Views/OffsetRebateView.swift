//
//  OffsetRebateView.swift
//  RewardsLink
//
//  Created by Kit Foong on 10/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class OffsetRebateView: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var rebateView: UIView!
    @IBOutlet weak var rebateLabel: UILabel!
    @IBOutlet weak var offsetLabel: UILabel!
    
    var rebate: String? {
        didSet {
            let temp = Float(rebate ?? "0") ?? 0
            self.rebateLabel.text = "\("text_rebate_value".localized.replacingFirstOccurrence(of: "%1$s", with: temp.cleanValue))%"
        }
    }
    
    var offset: String? {
        didSet {
            let temp = Float(offset ?? "0") ?? 0
            self.offsetLabel.text = "\("text_offset_value".localized.replacingFirstOccurrence(of: "%1$s", with: temp.cleanValue))%"
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentView.frame.height / 2
        
        rebateView.clipsToBounds = true
        rebateView.layer.masksToBounds = true
        rebateView.layer.cornerRadius = rebateView.frame.height / 2
    }
    
    private func setupUI() {
        Bundle.main.loadNibNamed(String(describing: OffsetRebateView.self), owner: self, options: nil)
        contentView.frame = self.bounds
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(contentView)
        
        contentView.clipsToBounds = true
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = contentView.frame.height / 2
        contentView.backgroundColor = AppTheme.red
        
        rebateView.clipsToBounds = true
        rebateView.layer.masksToBounds = true
        rebateView.layer.cornerRadius = rebateView.frame.height / 2
        
        rebateLabel.textColor = AppTheme.red
    }
}
