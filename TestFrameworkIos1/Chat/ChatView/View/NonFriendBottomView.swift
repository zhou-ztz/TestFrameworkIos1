//
//  NonFriendBottomView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/09/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import ActiveLabel

class NonFriendBottomView: UIView {

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppTheme.black
        label.font = UIFont.systemFont(ofSize: FontSize.defaultFontSize)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var messageRequestLabel: UILabel = {
        let label = UILabel()
        label.setUnderlinedText(text: "im_send_message_request".localized)
        label.textColor = UIColor(hex: 0x4a90e2)
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: FontSize.defaultFontSize)
        return label
    }()
    
    private lazy var stackview: UIStackView = {
        let stackview = UIStackView()
        stackview.axis = .vertical
        stackview.alignment = .center
        stackview.distribution = .fill
        stackview.spacing = 16
        return stackview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: 0xe1e1e1)
        self.addSubview(stackview)
        stackview.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalToSuperview().offset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
        
        stackview.addArrangedSubview(descriptionLabel)
        stackview.addArrangedSubview(messageRequestLabel)
    }
    
    func setName(_ name: String) {
        descriptionLabel.text = String(format: "im_not_friend_message_request".localized, name)
    }
}

class LeaveGroupBottomView: UIView {
    
    lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = "team_no_longer_in_group".localized
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    private func setup() {
        self.backgroundColor = UIColor(hex: 0xe1e1e1)
        
        self.addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
}
