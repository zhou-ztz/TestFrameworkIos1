//
//  ReactionView.swift
//  Yippi
//
//  Created by Francis Yeap on 08/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import Lottie

class ReactionSelectorView: UIView {
    
    var stackview = UIStackView().configure { v in
        v.axis = .vertical
        v.distribution = .fill
        v.alignment = .fill
        v.spacing = 5
    }
    
    var animatedView = AnimationView().configure { v in
        v.contentMode = .scaleAspectFit
        v.loopMode = .loop
    }
    
    var imageView = UIImageView().configure { v in
        v.contentMode = .scaleAspectFit
    }
    
    var nameContentView = UIView().configure { v in
        v.backgroundColor = AppTheme.materialBlack
    }
    
    var nameLabel = UILabel().configure { v in
        v.font = UIFont.systemFont(ofSize: 12)
        v.textColor = .white
    }
    
    init(reactionType: ReactionTypes) {
        super.init(frame: .zero)
        commonInit()
        
        imageView.addSubview(animatedView)
        animatedView.bindToEdges()
        
        imageView.image = nil
        animatedView.animation = reactionType.lottieAnimation
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(stackview)
        
        stackview.bindToEdges()
        
        nameContentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview()
            v.left.right.equalToSuperview().inset(5)
        }
        
        stackview.addArrangedSubview(imageView)
        addSubview(nameContentView)
        
        nameContentView.snp.makeConstraints { (v) in
            v.bottom.equalTo(self.snp.top).offset(-5)
            v.left.right.equalToSuperview()
        }
//        stackview.insertArrangedSubview(nameContentView, at: 0)
        nameContentView.isHidden = true
        
        self.isUserInteractionEnabled = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.point(inside: point, with: event) {
            return self
        } else { return nil }
    }
    
}

class ReactionView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameWrapper: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelBackgroundView: UIView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        UINib(nibName: "ReactionView", bundle: nil).instantiate(withOwner: self, options: nil)
        view.frame = bounds
        addSubview(view)
    }
}
