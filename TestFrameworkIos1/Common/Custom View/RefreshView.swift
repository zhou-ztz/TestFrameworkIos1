//
// Created by Francis Yeap on 25/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import Lottie

class RefreshView: UIView {
    private let label = UILabel().configure { v in
        v.textColor = .white
        v.font = UIFont.systemFont(ofSize: 14)
    }

    private var propertyAnimator = UIViewPropertyAnimator(duration: 0.35, curve: .easeIn)
    
    private(set) lazy var lottieView: AnimationView = {
        let view = AnimationView(name: "feed-loading")
        view.contentMode = .scaleAspectFit
        view.pause()
        view.animationSpeed = 1.5
        view.loopMode = .loop
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    deinit {
        propertyAnimator.stopAnimation(true)
        propertyAnimator.finishAnimation(at: .end)
        self.isHidden = true
    }

    private func commonInit() {
        addSubview(label)
        addSubview(lottieView)
        label.snp.makeConstraints { v in
            v.centerX.equalToSuperview()
            v.top.bottom.equalToSuperview()
            v.left.lessThanOrEqualTo(lottieView.snp.right)
        }

        lottieView.snp.makeConstraints { v in
            v.right.equalToSuperview().inset(16)
            v.top.bottom.equalToSuperview()
            v.height.width.equalTo(45)
        }

        propertyAnimator.addAnimations { () -> () in
            self.alpha = 1
        }
        propertyAnimator.pauseAnimation()

        self.alpha = 0
        self.isHidden = true
        layoutIfNeeded()
    }

    func reset() {
        propertyAnimator.finishAnimation(at: .start)
        UIView.animate(withDuration: 0.25, animations: { () -> () in
            self.alpha = 0
        }, completion: { _ in
            self.isHidden = true
        })
    }

    func setProgress(percentage: CGFloat) {
        self.isHidden = percentage == 0
        label.text = "pull_for_refresh".localized

        self.alpha = percentage
        propertyAnimator.fractionComplete = percentage
        self.lottieView.currentProgress = percentage
        propertyAnimator.stopAnimation(true)
        propertyAnimator.finishAnimation(at: .current)
    }
}
