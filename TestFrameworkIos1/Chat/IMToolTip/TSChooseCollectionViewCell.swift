//
//  TSChooseCollectionViewCell.swift
//  Yippi
//
//  Created by Kit Foong on 27/04/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class TSChooseCollectionViewCell: UICollectionViewCell {
    public static let cellIdentifier = "TSChooseCollectionViewCell"
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var iconTitleLabel: UILabel!
}

class TSChooseFooterView: UICollectionReusableView {
    public static let cellIdentifier = "TSChooseFooterView"
    
    let separatorView = UIView().configure {
        $0.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
            
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .clear
        alpha = 0.2
        
        addSubview(separatorView)
        separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(1)
            make.width.equalToSuperview()
        }
    }
}

