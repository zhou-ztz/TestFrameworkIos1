//
// Created by Francis Yeap on 27/11/2020.
// Copyright (c) 2020 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit


enum HeadingSelectionViewStyles {
    case largeText(text: String, highlightColor: UIColor, unhighlightColor: UIColor, indicatorColor: UIColor)
    case icon(text: String, reaction: ReactionTypes?, highlightColor: UIColor, unhighlightColor: UIColor, indicatorColor: UIColor)
    
    var reaction: ReactionTypes? {
        switch self {
        case .icon(_, let type,_,_, _):
            return type
        default:
            return nil
        }
    }
}

private struct Styles {
    let margin: CGFloat = 5.0
    let animteDuration: TimeInterval = 0.3
}

class HeadingSelectionView: UIView {

    private var styles = Styles()

    private(set) var styleType: HeadingSelectionViewStyles = .largeText(text: "", highlightColor: AppTheme.aquaBlue, unhighlightColor: AppTheme.brownGrey, indicatorColor: AppTheme.aquaBlue)
    private let icon: UIImageView = UIImageView().configure { v in v.contentMode = .scaleAspectFit }
    let label = UILabel()

    let stackview = UIStackView().configure { v in
        v.spacing = 5
        v.distribution = .fill
        v.alignment = .fill
        v.axis = .horizontal
    }

    var onTap: ((HeadingSelectionView) -> Void)?

    init(styleType: HeadingSelectionViewStyles) {
        super.init(frame: .zero)

        self.styleType = styleType

        addSubview(stackview)
        
        stackview.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview().inset(3)
            v.left.right.equalToSuperview().inset(self.styles.margin)
        }

        switch styleType {
        case .largeText: setupLargeTextStyle()
        case .icon: setupIconStyle()
        }

    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupLargeTextStyle() {
        guard case let HeadingSelectionViewStyles.largeText(text, highlightColor, unhighlightColor, _) = styleType else { return }

        stackview.addArrangedSubview(label)
        label.text = text
        label.font = UIFont.systemMediumFont(ofSize: 14)
        label.highlightedTextColor = highlightColor
        label.textColor = unhighlightColor
        label.isHighlighted = false

        self.label.addTap(action: { [weak self] _ in
            guard let self = self else { return }
            self.onTap?(self)
        })
    }


    private func setupIconStyle() {
        guard case let HeadingSelectionViewStyles.icon(text, reaction, highlightColor, unhighlightColor, indicatorColor) = styleType else {
            return
        }

        stackview.addArrangedSubview(self.icon)
        icon.highlightedImage = reaction?.image
        icon.image = reaction?.image
        icon.snp.makeConstraints { v in
            v.width.height.equalTo(20)
        }
        icon.isHidden = reaction?.image == nil
        
        stackview.addArrangedSubview(label)
        label.text = text
        label.font = UIFont.systemMediumFont(ofSize: 12)
        label.isHighlighted = false
        
        label.textColor = unhighlightColor
        label.highlightedTextColor = highlightColor
        
        self.label.addTap(action: { [weak self] _ in
            guard let self = self else { return }
            self.onTap?(self)
        })

        self.icon.addTap(action: { [weak self] _ in
            guard let self = self else { return }
            self.onTap?(self)
        })
    }

    func select(_ value: Bool) {
        UIView.transition(with: label, duration: self.styles.animteDuration, animations: {
            self.label.isHighlighted = value
            self.icon.isHighlighted = value
        }, completion: nil)
    }
}


class SegmentView: UIView {

    let indicator = UIView()
    var selectorViews: [HeadingSelectionView] = []
    private(set) var segmentPreferredHeight: CGFloat = 30.0
    private var configs: [HeadingSelectionViewStyles] = []
    private(set) var currentIndex = 0

    var didSelectIndex: ((Int) -> Void)?

    let scroll = UIScrollView().configure { v in
        v.isDirectionalLockEnabled = true
    }

    let stack = UIStackView().configure { v in
        v.axis = .horizontal
        v.distribution = .fill
        v.alignment = .fill
        v.spacing = 8.0
    }

    init(configs: [HeadingSelectionViewStyles]) {
        super.init(frame: .zero)
        self.configs = configs
        setup()
        createView(configs: configs)
        
        scroll.showsHorizontalScrollIndicator = false
        scroll.showsVerticalScrollIndicator = false
    }

    func updateTexts(for index: Int, with texts: String) {
        guard index < selectorViews.count, index >= 0 else {
            assert(false, "invalid index asserted.")
            return
        }
        selectorViews[index].label.text = texts
    }

    private func createView(configs: [HeadingSelectionViewStyles]) {
        configs.enumerated().forEach { [unowned self] (index, config) in
            let selectorView = HeadingSelectionView(styleType: config)
            selectorView.onTap = { [weak self] v in
                guard let self = self else { return }
                self.didSelectIndex?(index)
                self.setActive(index: index)                
            }

            selectorViews.append(selectorView)
            stack.addArrangedSubview(selectorView)
            selectorView.select(index == 0 )
        }

        self.layoutIfNeeded()

        guard selectorViews.count > 0 else { return }
        moveIndicator(to: selectorViews.first!, config: configs.first!)
    }

    func setActive(index: Int) {
        guard index < selectorViews.count else { return }
        self.selectorViews.enumerated().forEach { (i, v) in v.select(i == index) }
        self.moveIndicator(to: selectorViews[index], config: self.configs[index])
        currentIndex = index
    }

    private func moveIndicator(to view: HeadingSelectionView, config: HeadingSelectionViewStyles) {
        // make sure added to view
        guard let superview = view.superview else { return }

        indicator.roundCorner(1)

        indicator.snp.remakeConstraints { v in
            v.centerX.equalTo(view)
            v.width.equalTo(view).multipliedBy(1.1)
            v.bottom.equalToSuperview()
            v.height.equalTo(2)
        }

        let indicatorColor: UIColor

        switch config {
        case let .icon(_, _, _, _, indicator):
            indicatorColor = indicator
        case let .largeText(_, _, _, _indicatorColor):
            indicatorColor = _indicatorColor
        }

        UIView.animate(withDuration: 0.25) { () -> () in
            self.layoutIfNeeded()
            self.indicator.backgroundColor = indicatorColor
        }
               
        let scrollWidth = scroll.contentSize.width
        let centerPoint = scroll.center.x
        let viewCenter = view.center.x
       
        if viewCenter < centerPoint {
            // scroll to origin
            scroll.setContentOffset(.zero, animated: true)
        } else if viewCenter > scrollWidth - centerPoint, scrollWidth >= self.frame.width {
            scroll.setContentOffset(CGPoint(x: scrollWidth - scroll.bounds.width, y: 0), animated: true)
        } else {
            scroll.setContentOffset(CGPoint(x: viewCenter - scroll.bounds.width / 2, y: 0), animated: true)
        }
        
    }

    private func setup() {
        addSubview(scroll)
        scroll.addSubview(stack)
        addSubview(indicator)

        addConstraints()
    }

    private func addConstraints() {
        let margin = CGFloat(3.0)
        scroll.snp.makeConstraints { v in
            v.top.bottom.left.right.equalToSuperview()
            v.height.equalTo(segmentPreferredHeight + margin*2)
            v.width.equalToSuperview()
        }

        stack.snp.makeConstraints { v in
            v.top.bottom.equalToSuperview().inset(margin)
            v.left.equalToSuperview().inset(15)
            v.right.lessThanOrEqualToSuperview().inset(15)
            v.height.equalTo(segmentPreferredHeight)
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
}
