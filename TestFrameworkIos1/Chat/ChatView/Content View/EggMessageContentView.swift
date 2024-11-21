//
//  EggMessageContentView.swift
//  Yippi
//
//  Created by Tinnolab on 08/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import ActiveLabel

class EggContentView: BaseContentView {
    
    lazy var contentView: UIView = {
          let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 30, height: 30)))
          return view
      }()
    
    lazy var eggImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.set_image(named:"egg_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.semibold(12)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var clickToViewLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(10)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var redPacketLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(12)
        label.textColor = .gray
        label.text = "rw_yippi_red_packet".localized
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var contentStackView: UIStackView = {
        let stackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.distribution = .fill
        }
        return stackView
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xD9D9D9)

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
        
        if messageModel.message != ""{
            self.descriptionLabel.text = messageModel.message
        } else {
            self.descriptionLabel.text = "rw_red_packet_best_wishes".localized
        }
        self.clickToViewLabel.text = showLeft ? "viewholder_redpacket_open".localized : "viewholder_redpacket_detail".localized

        eggImage.snp.makeConstraints { make in
            make.width.equalTo(68)
            make.height.equalTo(80)
        }
        
        let eggStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
            stack.distribution = .fill
            stack.alignment = .center
        }
        
        let descriptionStackView = UIStackView().configure { (stack) in
            stack.axis = .vertical
            stack.spacing = 8
            stack.distribution = .fill
        }
        
        let timeStackView = UIStackView().configure { (stack) in
            stack.axis = .horizontal
            stack.spacing = 8
            stack.distribution = .fill
        }
         
        descriptionStackView.addArrangedSubview(descriptionLabel)
        descriptionStackView.addArrangedSubview(clickToViewLabel)
        eggStackView.addArrangedSubview(eggImage)
        eggStackView.addArrangedSubview(descriptionStackView)
        contentStackView.addArrangedSubview(eggStackView)
        contentStackView.addArrangedSubview(lineView)
        timeStackView.addArrangedSubview(redPacketLabel)
        timeStackView.addArrangedSubview(timeTickStackView)
        contentStackView.addArrangedSubview(timeStackView)
    
        lineView.snp.makeConstraints { make in
            make.height.equalTo(1)
          
        }
        
        descriptionStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(40)
        }
        
        eggStackView.snp.makeConstraints { make in
            make.width.equalTo(200)
        }
        
        contentView.addSubview(contentStackView)
        self.addSubview(contentView)
        contentStackView.bindToEdges()
        contentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 18:9)
            make.right.equalToSuperview().offset(showLeft ? -20: -10)
        }
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.eggTapped(self.model)
    }
}
