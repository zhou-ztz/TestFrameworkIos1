//
//  LocationMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 08/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK
import ActiveLabel

class LocationContentView: BaseContentView {
    
    lazy var locationImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named:"ic_map_default")
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultLocationDefaultFontSize)
        label.textColor = .gray
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.distribution = .fill
            stack.alignment = .trailing
        }
        return stackView
    }()
    
    override init(messageModel: MessageData) {
        super.init(messageModel: messageModel)
        dataUpdate(messageModel: messageModel)
        UISetup(messageModel: messageModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UISetup(messageModel: MessageData) {
        
        let showLeft = messageModel.type == .incoming
        
        let greyView = UIView()
        greyView.backgroundColor = UIColor(white: 0, alpha: 0.8)
        greyView.addSubview(locationLabel)
        let view = UIView()
        view.roundCorner(12)
        view.addSubview(locationImage)
        view.addSubview(greyView)
        
        locationImage.snp.makeConstraints { make in
            make.left.right.top.bottom.equalToSuperview()
        }
        greyView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        locationLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(8)
            make.top.bottom.equalToSuperview().inset(5)
        }
        
        contentStackView.addArrangedSubview(view)
        contentStackView.addArrangedSubview(timeTickStackView)
        view.snp.makeConstraints { make in
            make.width.equalTo(160)
            make.height.equalTo(125)
        }
        
        self.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.left.equalToSuperview().offset(showLeft ? 8:8)
            make.right.equalToSuperview().offset(showLeft ? -8:-8)
        }
    }
    
    func dataUpdate(messageModel: MessageData) {
        guard let message = messageModel.nimMessageModel else { return }
        let locationObject = message.messageObject as! NIMLocationObject
        self.locationLabel.text = locationObject.title
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.locationTapped(self.model)
    }
}
