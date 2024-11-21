//
//  UserReactionView.swift
//  Yippi
//
//  Created by ChuenWai on 18/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class UserReactionView: UIView {

    private let containerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 3
        stack.backgroundColor = .clear

        return stack
    }()

    private let iconStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = 1.5
        stack.backgroundColor = .clear

        return stack
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.applyStyle(.regular(size: 12, color: AppTheme.warmGrey))

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.backgroundColor = .clear
//        self.bindToEdges()
        self.addSubview(containerStack)
        containerStack.addArrangedSubview(iconStack)
        containerStack.addArrangedSubview(label)

        containerStack.bindToEdges()
    }

    func setData(reactionIcon: [ReactionTypes?], totalReactionCount: Int, labelTextColor: UIColor? = nil) {
        let maxIcon = 3
        iconStack.removeAllArrangedSubviews()
        let count = (reactionIcon.count > 0) ? min(reactionIcon.count, maxIcon) : 1
        for index in 0..<count {
            let imageView = UIImageView()
            imageView.image = (reactionIcon.count > 0) ? reactionIcon[index]?.image : UIImage.set_image(named: "red_heart")
            iconStack.addArrangedSubview(imageView)
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(18)
            }
        }
        if let color = labelTextColor {
            label.textColor = color
        }
        label.text = String(format: "number_of_people_reacted".localized, totalReactionCount.stringValue)
        label.sizeToFit()

        setNeedsLayout()
        layoutIfNeeded()
    }

}
