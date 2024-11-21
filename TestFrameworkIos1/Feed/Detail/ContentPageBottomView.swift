//
// Created by Francis Yeap on 26/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

import Lottie

class ContentPageBottomView: UIView {

    let bgView = UIView()
    let stackview = UIStackView().configure { v in
        v.spacing = 3
        v.axis = .horizontal
        v.distribution = .fill
        v.alignment = .fill
    }
    let progressLoader = AnimationView(name: "feed-loading")
    let textLabel = UILabel().configure { t in
        t.font = UIFont.systemFont(ofSize: 14)
    }

    deinit {
        self.progressLoader.stop()
    }

    init(bgColor: UIColor, textColor: UIColor, text: String) {
        super.init(frame: .zero)

        bgView.backgroundColor = bgColor
        addSubview(bgView)
        bgView.addSubview(stackview)

        progressLoader.contentMode = .scaleAspectFit
        stackview.addArrangedSubview(textLabel)
        stackview.addArrangedSubview(progressLoader)

        stackview.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview().inset(3)
            v.left.right.equalToSuperview().inset(12)
        }

        bgView.snp.makeConstraints { v in
            v.top.greaterThanOrEqualToSuperview().inset(8)
            v.centerX.equalToSuperview()
            v.left.greaterThanOrEqualToSuperview().inset(20)
            v.bottom.equalToSuperview().inset(TSUserInterfacePrinciples.share.getTSBottomSafeAreaHeight() + 24)
        }

        progressLoader.snp.makeConstraints { v in
            v.width.height.equalTo(32)
        }

        stackview.backgroundColor = .clear
        self.textLabel.textColor = textColor
        self.textLabel.text = text
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bgView.roundCorner(self.bgView.height / 2)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func start() {
        progressLoader.loopMode = .loop
        progressLoader.play()
    }

    func stop() {
        progressLoader.loopMode = .loop
        progressLoader.stop()
    }
}
