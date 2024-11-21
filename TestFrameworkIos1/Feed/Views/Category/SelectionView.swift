//
//  SelectionView.swift
//  Yippi
//
//  Created by Francis Yeap on 02/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation

import SnapKit

private struct ViewStyles {
    var selectedTextColor: UIColor = .white
    var notSelectedTextColor: UIColor = .lightGray
    
    var containerHeight: CGFloat = 25.0
    var cornerRadius: CGFloat { return containerHeight / 2 }
    
    var selectedBgColor: UIColor = TSColor.main.theme
    var notSelectBgColor: UIColor = UIColor(red: 249, green: 249, blue: 249)
}

class SelectionView: UIView {
    
    private let style = ViewStyles()
    private let borderView = UIView()
    var selected = false {
        didSet {
            if selected == true { animateSelect() }
            else {  animateDeselect() }
        }
    }
    private let selectionLabel = UILabel().configure {
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.minimumScaleFactor = 0.7
        $0.textAlignment = .center
    }
    
    var onTap: ((SelectionView) -> ())? {
        didSet {
            self.addTap(action: { [unowned self] _ in
                self.onTap?(self)
            })
        }
    }
    
    init(with text: String) {
        super.init(frame: .zero)
        
        selectionLabel.text = text
        
        addSubview(borderView)
        addSubview(selectionLabel)
        
        borderView.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview().inset(3)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.style.containerHeight)
        }
        
        selectionLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(borderView).inset(3)
            make.left.right.equalTo(borderView).inset(6)
        }
        
        borderView.roundCorner(style.cornerRadius)
        self.borderView.backgroundColor = self.style.notSelectBgColor
    }
    
    private func animateSelect() {
        UIView.transition(with: selectionLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.selectionLabel.textColor = self.style.selectedTextColor
        }
        
        UIView.animate(withDuration: 0.15) {
            self.borderView.backgroundColor = self.style.selectedBgColor
        }

    }
    
    private func animateDeselect() {
        UIView.transition(with: selectionLabel, duration: 0.15, options: .transitionCrossDissolve) {
            self.selectionLabel.textColor = self.style.notSelectedTextColor
        }
        
        UIView.animate(withDuration: 0.15) {
            self.borderView.backgroundColor = self.style.notSelectBgColor
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}
