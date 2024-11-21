//
//  PostFeedSelectionView.swift
//  Yippi
//
//  Created by ChuenWai on 10/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class PostFeedSelectionView: UIView {

    let maxHeight = UIScreen.main.bounds.height * 0.4
    private let container: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        return view
    }()
    private let closeWrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .white

        return view
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.set_image(named: "ic_post_view_close"))

        return button
    }()
    private let title: UILabel = {
        let label = UILabel()
        label.applyStyle(.semibold(size: 14, color: .black))
        label.textAlignment = .center
        label.text = "title_post_status".localized
        label.backgroundColor = .white

        return label
    }()
    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 20

        return stack
    }()
    private var buttons: [PostType] = [.photo, .text, .live, .miniVideo]
    private var animatable: Bool = false
    var notifyButtonTapped: ((PostType) -> Void)?

    init(animatable: Bool = true) {
        super.init(frame: .zero)

        self.animatable = animatable
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(container)
//        let path = UIBezierPath(roundedRect: container.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15))
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        container.layer.mask = mask
        container.snp.makeConstraints {
            $0.right.left.bottom.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview().offset(maxHeight)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        container.addSubview(title)
        container.addSubview(buttonStack)
        container.addSubview(closeWrapperView)
        closeWrapperView.addSubview(closeButton)

        title.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(20)
        }
        closeWrapperView.snp.makeConstraints {
            $0.right.left.equalToSuperview()
            $0.height.equalTo(25)
            if #available(iOS 11.0, *) {
                $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottomMargin).inset(20)
            } else {
                $0.bottom.equalToSuperview().inset(20)
            }
        }
        closeButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        buttonStack.snp.makeConstraints {
            $0.top.equalTo(title.snp.bottom).offset(20)
            $0.bottom.equalTo(closeWrapperView.snp.top).offset(-25)
            $0.width.equalToSuperview()
        }

        if CurrentUserSessionInfo?.isLiveEnabled == false && CurrentUserSessionInfo?.isMiniVideoEnabled == false {
            buttons = [.photo, .video, .text]
        } else if CurrentUserSessionInfo?.isLiveEnabled == true && CurrentUserSessionInfo?.isMiniVideoEnabled == false {
            buttons = [.photo, .video, .text, .live]
        } else if CurrentUserSessionInfo?.isLiveEnabled == false && CurrentUserSessionInfo?.isMiniVideoEnabled == true {
            buttons = [.photo, .video, .text, .miniVideo]
        }
        
        if CurrentUserSessionInfo?.verificationIcon == nil {
            buttons.removeAll(where: {
                switch $0 {
                case .video : return true
                default: return false
                }
            })
        }

        let maxColumn = 4
        let (noOfRows, remainder) = buttons.count.quotientAndRemainder(dividingBy: maxColumn)
        for index in 0..<(remainder > 0 ? noOfRows + 1 : noOfRows) {
            let row = UIStackView().configure {
                $0.axis = .horizontal
                $0.spacing = 0
                $0.distribution = .fillEqually
                $0.alignment = .fill
            }

            for column in 0..<maxColumn {
                let actualIndex = (index * maxColumn) + column
                if actualIndex >= buttons.count {
                    row.addArrangedSubview(VerticalView(title: "", image: nil))
                } else {
                    let button = buttons[actualIndex].postButton
                    button.addTap { [weak self] (_) in
                        guard let self = self else { return }
                        self.notifyButtonTapped?(self.buttons[actualIndex])
                        self.hide()
                    }

                    row.addArrangedSubview(button)
                }
            }
            buttonStack.addArrangedSubview(row)
        }

        closeButton.addTap { [weak self] (_) in
            self?.hide()
        }

        self.addTap { [weak self] (T) in
            guard T.superview != nil else { return }
            self?.hide()
        }
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        show()
    }

    private func show() {
        guard animatable == true else { return }
        let transformY = container.height < maxHeight ? UIScreen.main.bounds.height + container.height : UIScreen.main.bounds.height + maxHeight
        self.layoutIfNeeded()
        container.transform = CGAffineTransform(translationX: 0, y: transformY)
        UIView.animate(withDuration: 0.15, delay: 0, options: [.curveEaseOut], animations: {
            self.container.transform = .identity
            self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.container.backgroundColor = .white
        }, completion: nil)

    }


    func hide() {
        guard animatable == true else { return }
        let transformY = container.height < maxHeight ? UIScreen.main.bounds.height + container.height : UIScreen.main.bounds.height + maxHeight
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [.curveEaseOut]) {
            self.container.transform = CGAffineTransform(translationX: 0, y: transformY)
        } completion: { (_) in
            
        }
        UIView.animate(withDuration: 0.2, delay: 0.3, options: [.curveEaseOut]) {
            self.backgroundColor = .clear
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self.removeFromSuperview()
            }
        }
    }

}
