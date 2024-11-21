//
//  NoContentController.swift
//  Yippi
//
//  Created by Wong Jin Lun on 04/01/2023.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class NoContentController: UIViewController {
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.bold(size: 17, color: .black))
        label.textAlignment = .center
        label.text =  "rw_error_title_no_content_found".localized
        return label
    }()
    
    lazy var descLabel: UILabel = {
        let label = UILabel()
        label.applyStyle(.regular(size: 14, color: .black))
        label.textAlignment = .center
        label.text =  "placeholder_delete".localized
        return label
    }()
    
    lazy var contentImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage.set_image(named: "placeholder_no_result")
        return img
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "pic_video".localized
        
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(descLabel)
        view.addSubview(contentImage)
        
        contentImage.snp.makeConstraints {
            $0.width.equalTo(240)
            $0.height.equalTo(200)
            $0.bottom.equalTo(titleLabel.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.height.equalTo(25)
            $0.centerX.equalToSuperview()
        }
    }
    
}
