//
//  ZTLevelView.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/8/14.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class ZTLevelView: UIView {

    var closeClosure: (()->())?
    var okBtnClosure: (()->())?
    
    private let contentStackView = UIStackView().configure {
        $0.axis = .vertical
        $0.spacing = (UIApplication.shared.keyWindow?.frame.height ?? UIScreen.main.bounds.height) * 0.02
        
    }
   
    init(frame: CGRect, image: UIImage?, title: String? = nil,
    descriptions: [String],  buttonName: String? = nil) {
        super.init(frame: frame)
        setupView(frame: frame, image: image, title: title, descriptions: descriptions, buttonName: buttonName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupView(frame: CGRect, image: UIImage?, title: String? = nil,
    descriptions: [String],  buttonName: String? = nil) {
        self.backgroundColor = UIColor.white
        self.roundCorner(15)
        guard let topWindow = UIApplication.shared.keyWindow else { return }

        self.addSubview(self.contentStackView)
        contentStackView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalToSuperview().offset(-32)
            
        }
        
        
        let imageView = UIImageView()
        imageView.image = image
        imageView.contentMode = .center
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.setFontSize(with: 20, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7
        titleLabel.sizeToFit()
        
        let okayButton = UILabel()
        okayButton.textAlignment = .center
        okayButton.text = buttonName
        okayButton.backgroundColor = TSColor.button.normal
        okayButton.textColor = .white
        okayButton.layer.masksToBounds = true
        okayButton.addAction { [weak self] in
            okayButton.isUserInteractionEnabled = false
            okayButton.backgroundColor = TSColor.button.disabled
            self?.okBtnClosure?()
        }
        okayButton.roundCorner(20)
        
        
        imageView.snp.makeConstraints { (make) in
            make.height.equalTo(120)
        }


        var contentViewsArray = [UIView]()
        contentViewsArray.append(imageView)
        contentViewsArray.append(titleLabel)
        for description in descriptions {
            let detailLabel = UILabel()
            detailLabel.preferredMaxLayoutWidth = self.contentStackView.frame.width
            detailLabel.text = description
            detailLabel.setFontSize(with: 16, weight: .norm)
            detailLabel.textAlignment = .center
            detailLabel.textColor = .gray
            detailLabel.numberOfLines = 0
            detailLabel.adjustsFontSizeToFitWidth = true
            detailLabel.minimumScaleFactor = 0.7
            detailLabel.sizeToFit()
            contentViewsArray.append(detailLabel)
            
        }
        
        for view in contentViewsArray {
            self.contentStackView.addArrangedSubview(view)
        }
        let actionButtons: [UIView] = [okayButton]
        let btnWrapper = UIView()
        btnWrapper.backgroundColor = .clear
        let buttonHeight: CGFloat = 40
        let buttonsTotalHeight = buttonHeight * CGFloat(actionButtons.count)
        let spacingTotalHeight = 8 * CGFloat(actionButtons.count - 1)
        let totalHeightNeeded = buttonsTotalHeight + spacingTotalHeight
        let topSpacing = topWindow.frame.height * 0.04
        btnWrapper.snp.makeConstraints { (make) in
            make.height.equalTo(totalHeightNeeded + topSpacing)
        }

        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 8
        buttonStackView.distribution = .fillEqually
        for button in actionButtons {
            buttonStackView.addArrangedSubview(button)
        }
        btnWrapper.addSubview(buttonStackView)

        buttonStackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(topWindow.frame.height * 0.04)
            make.leading.equalToSuperview().offset(topWindow.width * 0.05)
            make.trailing.equalToSuperview().offset(-(topWindow.width * 0.05))
        }

        self.contentStackView.addArrangedSubview(btnWrapper)
        

        
    }
    
  
    
    
}
