//
//  LoadPlaceHolder.swift
//  Yippi
//
//  Created by Francis Yeap on 29/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

import SDWebImage
import Lottie

class PlaceHolderView: UIView {
    
    private let wrapper = UIView()
    private var theme: Theme = .white
    
    private let content: UIStackView = UIStackView().configure {
        $0.distribution = .fill
        $0.alignment = .center
        $0.axis = .vertical
        $0.spacing = 6
    }
    
    private lazy var headerLabel = {
        return UILabel().build {
            switch theme {
            case .white: $0.textColor = .black
            case .dark: $0.textColor = .white
            }
            
            $0.font = UIFont.boldSystemFont(ofSize: 18)
            $0.textAlignment = .center
        }
    }()
    
    private lazy var detailLabel = {
        return UILabel().build {
            switch theme {
            case .white: $0.textColor = AppTheme.darkGrey
            case .dark: $0.textColor = UIColor.white.withAlphaComponent(0.85)
            }
            $0.font = UIFont.systemFont(ofSize: 18)
            $0.textAlignment = .center
        }
    }()
    
    private let imageStackview = UIStackView().configure { v in
        v.distribution = .fill
        v.alignment = .fill
        v.axis = .vertical
        v.spacing = 0
    }

    private(set) var animationView = AnimationView()

    private let imageView = SDAnimatedImageView().configure { imageview in
        imageview.contentMode = .scaleAspectFit
    }

    init(offset: CGFloat, heading: String = "", detail: String = "", lottieName: String = "", theme: Theme = .white) {
        super.init(frame: .zero)
        commonInit(offset: offset)
        self.theme = theme

        headerLabel.isHidden = heading.isEmpty
        headerLabel.text = heading

        detailLabel.isHidden = detail.isEmpty
        detailLabel.text = detail

        animationView.animation = Animation.named(lottieName)
        animationView.loopMode = .loop

        animationView.makeVisible()
        imageView.makeHidden()

        switch theme {
        case .white: backgroundColor = .white
        case .dark: backgroundColor = AppTheme.materialBlack
        }

        headerLabel.startShimmering(background: false)
        detailLabel.startShimmering(background: false)

    }

    init(offset: CGFloat, heading: String = "", detail: String = "", image: UIImage = UIImage(), theme: Theme = .white) {
        super.init(frame: .zero)
        commonInit(offset: offset)
        self.theme = theme
        
        headerLabel.isHidden =  heading.isEmpty
        headerLabel.text = heading
        
        detailLabel.isHidden = detail.isEmpty
        detailLabel.text = detail

        animationView.makeHidden()
        imageView.makeVisible()
        imageView.image = image
        
        switch theme {
        case .white: backgroundColor = .white
        case .dark: backgroundColor = AppTheme.materialBlack
        }
        
        headerLabel.startShimmering(background: false)
        detailLabel.startShimmering(background: false)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if animationView.isHidden == false {
            animationView.play()
        }
    }

    func play() {
        animationView.play()
    }
    

    private func commonInit(offset: CGFloat = 0) {
        wrapper.addSubview(imageStackview)

        imageStackview.addArrangedSubview(imageView)
        imageStackview.addSubview(animationView)

        wrapper.addSubview(content)

        animationView.snp.makeConstraints { v in
            v.width.height.equalTo(80)
        }

        imageStackview.snp.makeConstraints {
            $0.width.height.equalTo(80)
            $0.top.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        content.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        content.addArrangedSubview(headerLabel)
        content.addArrangedSubview(detailLabel)
        
        addSubview(wrapper)
        wrapper.snp.makeConstraints {
            $0.top.greaterThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-offset)
            $0.left.right.equalToSuperview().inset(24)
        }
    }
    
}
