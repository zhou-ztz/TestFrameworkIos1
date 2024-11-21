//
//  LocationView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 09/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class LocationView: UIView {
    
    private let icon = UIImageView().configure {
        $0.image = UIImage.set_image(named: "ic_location")
    }
    
    private let stackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.spacing = 5.0
    }

    private let label = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .white))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        self.addSubview(stackView)
        stackView.addArrangedSubview(icon)
        stackView.addArrangedSubview(label)
        
        stackView.bindToEdges()
        
        icon.snp.makeConstraints { make in
            make.width.equalTo(20)
        }
        
        label.snp.makeConstraints { make in
            make.height.equalTo(14)
        }
    }
    
    func set(_ location: TSPostLocationModel) {
        label.text = location.locationName
    }
}
