//
//  LoadingHUD.swift
//  YippiCore
//
//  Created by Yong Tze Ling on 24/08/2021.
//  Copyright © 2021 Chew. All rights reserved.
//

import UIKit
import Lottie

@objcMembers
public class LoadingHUD: UIView {

    private lazy var animationView: AnimationView = {
        let view = AnimationView(name: self.lottieName)
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    private var lottieName: String
    
    public init(name: String) {
        self.lottieName = name
        super.init(frame: .zero)
        
        self.backgroundColor = .black.withAlphaComponent(0.7)
        self.addSubview(animationView)
        self.addSubview(progressLabel)
        animationView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(100)
        }
        progressLabel.snp.makeConstraints {
            $0.top.equalTo(animationView.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        self.animationView.play()
    }
    
    public func play() {
        self.animationView.play()
    }
    
    public func setProgress(_ value: String) {
        progressLabel.text = value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objcMembers
public class EditorLoadingHUD: NSObject {
    
    static let hud = LoadingHUD(name: "loading(old)")
    
    static public func show() {
        hud.play()
        UIViewController.topMostController?.view.addSubview(hud)
        hud.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    static public func setProgress(_ value: String) {
        hud.setProgress(value)
    }
    
    static public func dismiss() {
        hud.removeFromSuperview()
    }
}
