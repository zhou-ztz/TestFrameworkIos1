//
//  SegmentedControlScrollView.swift
//  Yippi
//
//  Created by Jerry Ng on 03/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class SegmentedControlScrollView: UIScrollView {
    
    public static let defaultControlHeight: CGFloat = 50
    var titleStyle: TitledPageTitleStyle = .centerScrolling
    
    public var selectedTitleColor: UIColor = TSColor.main.content
    public var selectedTitleFont: UIFont = UIFont.systemFont(ofSize: 15)
    
    public var normalTitleColor: UIColor = TSColor.normal.minor
    public var normalTitleFont: UIFont = UIFont.systemFont(ofSize: 14)
    
    public var lineColor: UIColor = TSColor.main.theme {
        didSet {
            segmentSelectionLine.backgroundColor = lineColor
        }
    }
    
    public var segmentedControlHeight: CGFloat = SegmentedControlScrollView.defaultControlHeight
    public var titleSidePadding: CGFloat = 10
    
    let segmentedControlContainer: UIView = UIView()
    let segmentSelectionLine: UIView = UIView().configure {
        $0.backgroundColor = TSColor.main.theme
    }
    
    let segmentsStackView: UIStackView = UIStackView().configure {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 14
    }
    let segmentedControlScrollView: UIScrollView = UIScrollView().configure {
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .white
        $0.isScrollEnabled = true
    }
    
    var onSegmentTap: ((Int) -> ())?
    var onSegmentDidChanged: ((Int) -> ())?
    var segments: [UIView] = [] {
        didSet {
            loadSegments()
        }
    }
    var selectedSegmentIndex: Int {
        set {
            guard _selectedSegmentIndex != newValue else { return }
            _selectedSegmentIndex = newValue
            guard newValue < segments.count else { return }
            setSelectedSegment(atIndex: newValue)
            onSegmentDidChanged?(newValue)
        }
        get {
            return _selectedSegmentIndex
        }
    }
    var _selectedSegmentIndex: Int = 0
    private var indicatorType: SegmentScrollIndicatorType = .scroll
    
    convenience init(indicatorType: SegmentScrollIndicatorType = .scroll, initialIndex: Int = 0) {
        self.init(frame: .zero)
        
        self.indicatorType = indicatorType
        self._selectedSegmentIndex = initialIndex
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(segmentedControlContainer)
        segmentedControlContainer.addSubview(segmentsStackView)
        segmentedControlContainer.addSubview(segmentSelectionLine)
        segmentSelectionLine.roundCorner(1.5)
        segmentSelectionLine.snp.makeConstraints {
            $0.height.equalTo(3)
            $0.bottom.equalToSuperview()
            $0.width.equalTo(0)
            $0.centerX.equalTo(0)
        }
        
        switch titleStyle {
        case .leftScrolling:
            segmentsStackView.distribution = .equalSpacing
            segmentsStackView.bindToEdges()
            segmentedControlContainer.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(segmentedControlHeight)
                $0.width.equalTo(segmentsStackView.snp.width)
            }
            
        default:
            segmentsStackView.distribution = .fill
            segmentsStackView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview()
                $0.centerX.equalTo(segmentedControlContainer.snp.centerX)
            }
            segmentedControlContainer.snp.makeConstraints {
                $0.edges.equalToSuperview()
                $0.height.equalTo(segmentedControlHeight)
            }
        }
    }
    
    private func loadSegments() {
        guard segments.count > 0 else { return }
        segmentsStackView.removeAllArrangedSubviews()
        for index in 0..<segments.count {
            let segmentView = segments[index]
            segmentView.addAction { [weak self] in
                guard let self = self else { return }
                self.selectedSegmentIndex = index
                self.onSegmentTap?(index)
            }
            if let titleView = segmentView as? UILabel {
                let stringWidth: CGFloat = titleView.text?.sizeOfString(usingFont: titleView.font).width ?? 0.0
                titleView.snp.makeConstraints {
                    $0.width.equalTo(stringWidth + (titleSidePadding * 2))
                    $0.height.equalTo(segmentedControlHeight)
                }
            }
            segmentsStackView.addArrangedSubview(segmentView)
        }
        segmentsStackView.setNeedsLayout()
        segmentsStackView.layoutIfNeeded()
        switch titleStyle {
        case .leftScrolling:
            segmentedControlContainer.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                $0.width.equalTo(segmentsStackView.snp.width)
                $0.height.equalTo(segmentedControlHeight)
            }
        default:
            segmentedControlContainer.snp.remakeConstraints {
                $0.edges.equalToSuperview()
                if segmentsStackView.frame.width > self.frame.width {
                    $0.width.equalTo(segmentsStackView.snp.width)
                } else {
                    $0.width.equalTo(self.snp.width)
                }
                $0.height.equalTo(segmentedControlHeight)
            }
            
        }
        segmentedControlContainer.setNeedsLayout()
        segmentedControlContainer.layoutIfNeeded()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        setSelectedSegment(atIndex: _selectedSegmentIndex)
    }
    
    public func setSelectedSegment(atIndex index:Int, animationDuration: TimeInterval = 0.3) {
        guard index < self.segmentsStackView.arrangedSubviews.count else { return }
        let selectedSegment = self.segmentsStackView.arrangedSubviews[index]
        let realFrame = segmentsStackView.convert(selectedSegment.frame, to: segmentedControlContainer)
        var offsetX = realFrame.center.x
        if offsetX < (self.frame.width / 2) {
            offsetX = 0
        } else {
            offsetX  -= (self.frame.width / 2)
        }
        
        offsetX = min(offsetX, ((contentSize.width + 10) - self.frame.width))
        offsetX = max(0, offsetX)
        
        
        
        switch indicatorType {
        case .scroll:
            segmentSelectionLine.isHidden = false
            UIView.animate(withDuration: animationDuration, animations: { [weak self] in
                guard let self = self else {
                    return
                }
                self.segmentSelectionLine.snp.updateConstraints {
                    $0.width.equalTo(selectedSegment.width)
                    $0.centerX.equalTo(realFrame.center.x)
                }
                self.segmentedControlContainer.setNeedsLayout()
                self.segmentedControlContainer.layoutIfNeeded()
                self.contentOffset.x = offsetX
            }) { [weak self] (_) in
                guard let self = self else {
                    return
                }
                for segmentIndex in 0..<self.segments.count {
                    if let view = self.segments[segmentIndex] as? UILabel {
                        view.textColor = segmentIndex == index ? self.selectedTitleColor : self.normalTitleColor
                        view.font = segmentIndex == index ? self.selectedTitleFont : self.normalTitleFont
                    }
                    if let view = self.segments[segmentIndex] as? UIImageView {
                        view.isHighlighted = segmentIndex == index
                    }
                }
            }
            
        case .highlight(let highlightColor, let isSemibold):
            segmentSelectionLine.isHidden = true
            self.contentOffset.x = offsetX
            for (i, segment) in segments.enumerated() {
                if i == index, let label = segment as? UILabel {
                    UIView.animate(withDuration: 0.2) { () -> () in
                        label.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                    }
                    UIView.transition(with: label, duration: 0.2, animations: {
                        label.textColor = highlightColor
                        label.font = isSemibold ? UIFont.systemFont(ofSize: 15, weight: .semibold) : self.selectedTitleFont
                        label.snp.updateConstraints {
                            let stringWidth: CGFloat = label.text?.sizeOfString(usingFont: label.font).width ?? 0.0
                            $0.width.equalTo(stringWidth + (self.titleSidePadding * 2))
                        }
                    }, completion: nil)
                } else if let label = segment as? UILabel {
                    UIView.animate(withDuration: 0.2) { () -> () in
                        label.transform = .identity
                    }
                    UIView.transition(with: label, duration: 0.2, animations: {
                        label.textColor = self.normalTitleColor
                        label.font =  self.normalTitleFont
                        label.snp.updateConstraints {
                            let stringWidth: CGFloat = label.text?.sizeOfString(usingFont: label.font).width ?? 0.0
                            $0.width.equalTo(stringWidth + (self.titleSidePadding * 2))
                        }
                    }, completion: nil)
                }
            }
        }
    }
}
