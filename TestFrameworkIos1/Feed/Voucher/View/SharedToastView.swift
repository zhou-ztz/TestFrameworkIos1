//
//  SharedToastView.swift
//  RewardsLink
//
//  Created by Kit Foong on 24/06/2024.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

class SharedToastView: UIView {
    @IBOutlet var view: UIView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var infoButton: UIImageView!
    @IBOutlet weak var toastLabel: UILabel!
    
    var title: String = "" {
        didSet {
            toastLabel.text = title
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
        Bundle.main.loadNibNamed(String(describing: SharedToastView.self), owner: self, options: nil)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(view)
        
        backgroundColor = .clear
        view.backgroundColor = .clear
        
        view.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview().inset(10)
        })
        
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
    }
}
