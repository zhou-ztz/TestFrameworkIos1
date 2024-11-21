//
//  WhiteboardContentView.swift
//  RewardsLink
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/15.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class WhiteboardContentView: BaseContentView {

    lazy var whiteboardView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppTheme.Font.regular(FontSize.defaultTextFontSize)
        label.textColor = .black
        label.text = ""
        label.numberOfLines = 0
        return label
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
            stack.alignment = .center
        }
    
        wholeStackView.addArrangedSubview(whiteboardView)
        wholeStackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 184, height: 10)))
        wholeStackView.addArrangedSubview(titleLabel)
        wholeStackView.addArrangedSubview(UIView(frame: CGRect(x: 0, y: 0, width: 184, height: 10)))
        wholeStackView.addArrangedSubview(timeTickStackView)
        
        whiteboardView.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
        whiteboardView.image = UIImage.set_image(named: "whiteboard_bg")
        if showLeft {
            titleLabel.text = "whiteboard_right".localized
        }else{
            titleLabel.text = "whiteboard_left".localized
        }
        
        
        whiteboardView.snp.makeConstraints { make in
            make.height.equalTo(180)
            make.width.equalTo(180)
            make.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.width.equalTo(184)
        }
      
        timeTickStackView.snp.makeConstraints { make in
            make.width.equalTo(184)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(wholeStackView)
        wholeStackView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.left.equalToSuperview().offset(showLeft ? 9:0)
            make.right.equalToSuperview().offset(showLeft ? 0:-9)
        }
    }
    
    @objc override func contentViewDidTap(_ gestureRecognizer: UIGestureRecognizer) {
        self.delegate?.whiteboardTapped(self.model)
    }
}
