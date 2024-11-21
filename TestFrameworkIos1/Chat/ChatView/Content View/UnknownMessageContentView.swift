//
//  UnknownMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 06/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import ActiveLabel

class UnknownMessageContentView: BaseContentView {
    lazy var downloadView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var downloadImage: UIImageView = {
        let view = UIImageView()
        view.image = UIImage.set_image(named: "ic_version_update")
        return view
    }()
    
    lazy var contentLabel: UILabel = {
        let infoLbl = UILabel()
        infoLbl.textColor = AppTheme.UIColorFromRGB(red: 51, green: 51, blue: 51)
        infoLbl.text = "rw_viewholder_defcustom_unknown_msg".localized
        infoLbl.textAlignment = .left
        infoLbl.font = UIFont(name: "PingFang-SC-Regular", size: 12)
        infoLbl.transform = CGAffineTransform(a: 1, b: 0, c: -0.2, d: 1, tx: 0, ty: 0)
        infoLbl.numberOfLines = 0
        return infoLbl
    }()
    
    lazy var updateLabel: UILabel = {
        let infoLbl = UILabel()
        infoLbl.textColor = .black
        infoLbl.text = ""
        infoLbl.textAlignment = .left
        infoLbl.numberOfLines = 1
        infoLbl.setUnderlinedText(text: "rw_update_new_version".localized)
        infoLbl.setFontSize(with: 12, weight: .norm)
        return infoLbl
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
        return view
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        let showLeft = messageModel.type == .incoming
        
        let wholeStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
        }
        self.addSubview(wholeStackView)
        
        wholeStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 14:5)
            make.right.equalToSuperview().offset(showLeft ? -5:-14)
        }
        
        let contentStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 3
            stack.alignment = .fill
        }
        
        wholeStackView.addArrangedSubview(contentLabel)
        wholeStackView.addArrangedSubview(contentStackView)
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        contentStackView.addArrangedSubview(downloadView)
        contentStackView.addArrangedSubview(updateLabel)
        contentStackView.addArrangedSubview(spacer)
        contentStackView.addArrangedSubview(timeTickStackView)
        
        downloadView.snp.makeConstraints { make in
            make.width.equalTo(18)
        }
        
        downloadView.addSubview(downloadImage)
        downloadImage.snp.makeConstraints { make in
            make.height.width.equalTo(18)
            make.center.equalToSuperview()
        }
        
        updateLabel.addTap(action: { _ in
            self.delegate?.unknownTapped()
        })
        
        self.layoutIfNeeded()
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.unknownTapped()
    }
}
