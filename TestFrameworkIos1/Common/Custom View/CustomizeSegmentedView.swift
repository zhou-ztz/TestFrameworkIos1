//
//  CustomizeSegmentedView.swift
//  Yippi
//
//  Created by CC Teoh on 05/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

import SnapKit

@IBDesignable public class CustomizeSegmentedView: UIControl {
    
    private let selectedBackgroundColor = AppTheme.red
    private let unselectedBackgroundColor = UIColor.white
    fileprivate var labels = [UILabel]()
    private var thumbView = UIView()
    private var itemLeadingConstraint: Constraint?
    private var itemWidthConstraint: Constraint?
    
    public var items: [String] = ["Item 1", "Item 2", "Item 3"] {
        didSet {
            if items.count > 0 { setupLabels() }
        }
    }
    
    public var selectedIndex: Int = 0 {
        didSet { displayNewSelectedIndex() }
    }
    
    @IBInspectable public var selectedLabelColor: UIColor = UIColor.black {
        didSet { setSelectedColors() }
    }
    
    @IBInspectable public var unselectedLabelColor: UIColor = UIColor.white {
        didSet { setSelectedColors() }
    }
    
    @IBInspectable public var thumbColor: UIColor = UIColor.white {
        didSet { setSelectedColors() }
    }
    
    @IBInspectable public var borderColor: UIColor = UIColor.white {
        didSet { layer.borderColor = borderColor.cgColor }
    }
    
    @IBInspectable public var font: UIFont? = UIFont.systemFont(ofSize: 12) {
        didSet { setFont() }
    }
    
    public var padding: CGFloat = 0 {
        didSet { setupLabels() }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .clear
        setupLabels()
//        insertSubview(thumbView, at: 0)
    }
    
    private func setupLabels() {
        for label in labels {
            label.removeFromSuperview()
        }
        
        labels.removeAll(keepingCapacity: true)
        for index in 1...items.count {
            let label = UILabel()
            label.text = items[index - 1]
            label.textAlignment = .center
            label.font = font
            label.textColor = index == 1 ? selectedLabelColor : unselectedLabelColor
            label.backgroundColor = index == 1 ? selectedBackgroundColor : unselectedBackgroundColor
            label.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(label)
            labels.append(label)
        }
        
        addIndividualItemConstraints(labels, mainView: self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for item in labels {
            item.layer.cornerRadius = item.frame.height / 2
            item.clipsToBounds = true
            item.backgroundColor = unselectedBackgroundColor
        }
        
        if labels.count > 0 {
            let label = labels[selectedIndex]
            label.textColor = selectedLabelColor
            label.layer.cornerRadius = label.frame.height / 2
            label.backgroundColor = selectedBackgroundColor
//            thumbView.frame = label.frame
//            thumbView.backgroundColor = thumbColor
//            thumbView.layer.cornerRadius = thumbView.frame.height / 2
            displayNewSelectedIndex()
        }
    }
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        var calculatedIndex : Int?
        for (index, item) in labels.enumerated() {
            if item.frame.contains(location) {
                calculatedIndex = index
            }
        }
        
        if calculatedIndex != nil {
            selectedIndex = calculatedIndex!
            sendActions(for: .valueChanged)
        }
        
        return false
    }
    
    private func displayNewSelectedIndex() {
        for (_, item) in labels.enumerated() {
            item.textColor = unselectedLabelColor
            item.backgroundColor = unselectedBackgroundColor
        }
        
        let label = labels[selectedIndex]
        label.textColor = selectedLabelColor
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, animations: {
            label.backgroundColor = self.selectedBackgroundColor

//            self.thumbView.frame = label.frame
        }, completion: nil)
    }
    
    private func addIndividualItemConstraints(_ items: [UIView], mainView: UIView) {
        for (index, button) in items.enumerated() {
            
//            button.snp.makeConstraints { (make) in
//                make.top.equalTo(mainView.snp.top).offset(padding)
//                make.bottom.equalTo(mainView.snp.bottom).offset(-padding)
//            }
            button.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 0).isActive = true
            button.bottomAnchor.constraint(equalTo: mainView.bottomAnchor, constant: 0).isActive = true

            ///set leading constraint
            if index == 0 {
                /// set first item leading anchor to mainView
//                button.snp.remakeConstraints { (make) in
//                    make.top.equalTo(mainView.snp.top).offset(padding)
//                    make.bottom.equalTo(mainView.snp.bottom).offset(-padding)
//                    self.itemLeadingConstraint = make.leading.equalTo(mainView.snp.leading).offset(padding).constraint
//                }

                button.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: padding).isActive = true
            } else {
                let prevButton: UIView = items[index - 1]
                let firstItem: UIView = items[0]
                
                /// set remaining items to previous view and set width the same as first view
//                button.snp.remakeConstraints { (make) in
//                    make.top.equalTo(mainView.snp.top).offset(padding)
//                    make.bottom.equalTo(mainView.snp.bottom).offset(-padding)
//                    make.leading.equalTo(prevButton.snp.trailing).offset(padding)
//                    self.itemWidthConstraint = make.width.equalTo(firstItem.snp.width).constraint
//                }

                button.leadingAnchor.constraint(equalTo: prevButton.trailingAnchor, constant: padding).isActive = true
                button.widthAnchor.constraint(equalTo: firstItem.widthAnchor).isActive = true
            }

            ///set trailing constraint
            if index == items.count - 1 {
                /// set last item trailing anchor to mainView
//                self.itemWidthConstraint?.activate()
//                self.itemLeadingConstraint?.activate()
//                button.snp.remakeConstraints { (make) in
//                    make.top.equalTo(mainView.snp.top).offset(padding)
//                    make.bottom.equalTo(mainView.snp.bottom).offset(-padding)
//                    make.trailing.equalTo(mainView.snp.trailing).offset(-padding)
//                }

                button.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -padding).isActive = true
            } else {
                /// set remaining item trailing anchor to next view
                let nextButton: UIView = items[index + 1]
//                self.itemWidthConstraint?.activate()
//                self.itemLeadingConstraint?.activate()
//                button.snp.remakeConstraints { (make) in
//                    make.top.equalTo(mainView.snp.top).offset(padding)
//                    make.bottom.equalTo(mainView.snp.bottom).offset(-padding)
//                    make.trailing.equalTo(nextButton.snp.leading).offset(-padding)
//                }

                button.trailingAnchor.constraint(equalTo: nextButton.leadingAnchor, constant: -padding).isActive = true
            }
        }
    }
    
    private func setSelectedColors() {
        for item in labels {
            item.textColor = unselectedLabelColor
        }
        
        if labels.count > 0 {
            labels[0].textColor = selectedLabelColor
        }
        
        thumbView.backgroundColor = thumbColor
    }
    
    private func setFont() {
        for item in labels {
            item.font = font
        }
    }
}
