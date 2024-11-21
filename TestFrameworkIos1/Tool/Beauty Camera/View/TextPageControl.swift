//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

class TextPageControl: UIControl {

    var titles: [String] = []
    var titleFont: UIFont?
    var normalColor: UIColor?
    var selectedColor: UIColor?
    var titleSpacing: CGFloat = 0.0
    var selectedIndex: Int = 1 {
        didSet {
            setSelectedIndex(selectedIndex, animated: false)
        }
    }

    private var contentView: UIView! = UIView()
    private var titleLabels: [UILabel] = []

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        backgroundColor = UIColor.clear

        titleSpacing = 20
        titleFont = UIFont.boldSystemFont(ofSize: 14)
        normalColor = UIColor(white: 1, alpha: 0.7)
        selectedColor = UIColor(white: 1, alpha: 1)
        contentView = UIView(frame: bounds)
        contentView.backgroundColor = UIColor.clear
        addSubview(contentView)

        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TextPageControl.swipeHander(_:)))
        leftSwipe.direction = .left
        addGestureRecognizer(leftSwipe)
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(TextPageControl.swipeHander(_:)))
        rightSwipe.direction = .right
        addGestureRecognizer(rightSwipe)

        setTitles(["photo".localized, "video".localized])
        setSelectedIndex(0, animated: false)
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.white.cgColor)
        let bottomMargin: CGFloat = 5
        let radius: CGFloat = 2
        context?.addArc(center: CGPoint(x: rect.midX, y: rect.size.height - bottomMargin - radius), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: false)
        context?.drawPath(using: .fill)
    }

    // MARK: - Layout

    override func layoutSubviews() {
        contentView.center = CGPoint(x: contentView.center.x, y: bounds.midY)
        updateLayout(withTargetLabel: titleLabels[selectedIndex])
    }

    func attributedString(with string: String?, font: UIFont?) -> NSAttributedString? {
        if let font = font {
            return NSMutableAttributedString(string: string ?? "", attributes:
                [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: normalColor as Any
                ])
        }
        return NSMutableAttributedString(string: string ?? "", attributes: nil)
    }

    func updateLayout(withTargetLabel label: UILabel?) {
        let targetRect = contentView.convert(label?.frame ?? CGRect.zero, to: self)
        let offsetX: CGFloat = center.x - targetRect.midX

        var contentFrame: CGRect? = contentView.frame
        contentFrame?.origin.x += offsetX
        contentView.frame = contentFrame ?? CGRect.zero
    }

    func setShadowSize(_ shadowSize: CGFloat, on layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = abs(shadowSize)
        layer.shadowOpacity = 0.6
    }

    // MARK: - Property

    func setTitles(_ titles: [String]) {
        self.titles = titles
        var titleLabels: [UILabel] = []

        var texts: [NSAttributedString] = []
        var textMaxHeight: CGFloat = 0
        for title in self.titles {
            let text: NSAttributedString? = attributedString(with: title, font: titleFont)
            if (text?.size().height ?? 0.0) > textMaxHeight {
                textMaxHeight = text?.size().height ?? 0.0
            }
            if let text = text {
                texts.append(text)
            }
        }

        var offsetX: CGFloat = 0
        for i in 0..<texts.count {
            let text: NSAttributedString = texts[i]

            let titleFrame = CGRect(x: offsetX + titleSpacing / 2, y: (textMaxHeight - text.size().height) / 2, width: text.size().width, height: text.size().height)
            let label = UILabel(frame: titleFrame)
            contentView.addSubview(label)
            titleLabels.append(label)
            label.attributedText = text
            setShadowSize(1.0, on: label.layer)

            offsetX += text.size().width + titleSpacing
            textMaxHeight = text.size().height
        }
        contentView.frame = CGRect(x: 0, y: 0, width: offsetX, height: textMaxHeight)
        self.titleLabels = titleLabels
    }

    func setSelectedIndex(_ selectedIndex: Int, animated: Bool) {
        if selectedIndex < 0 || selectedIndex >= titleLabels.count {
            return
        }

        let valueChange: Bool = self.selectedIndex != selectedIndex
        if !valueChange {
            return
        }
        let labelShouldDeselect = titleLabels[self.selectedIndex]
        let labelShouldSelect = titleLabels[selectedIndex]

        self.selectedIndex = selectedIndex
        sendActions(for: .valueChanged)

        let animationsHandler: (() -> Void)? = {
            labelShouldDeselect.textColor = self.normalColor
            labelShouldSelect.textColor = self.selectedColor
            self.updateLayout(withTargetLabel: labelShouldSelect)
        }
        if animated {
            UIView.setAnimationCurve(.easeInOut)
            if let animationsHandler = animationsHandler {
                UIView.animate(withDuration: 0.25, animations: animationsHandler)
            }
        } else {
            animationsHandler?()
        }
    }

    // MARK: - Touch & Gesture events

    @objc func swipeHander(_ swipe: UISwipeGestureRecognizer?) {
        var targetIndex: Int = selectedIndex
        if swipe?.direction == .left {
            targetIndex += 1
        } else if swipe?.direction == .right {
            targetIndex -= 1
        }
        if targetIndex < 0 || targetIndex >= titleLabels.count {
            return
        }
        setSelectedIndex(targetIndex, animated: true)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if touches.count > 1 {
            return
        }
        guard let location: CGPoint = touches.first?.location(in: contentView) else { return }
        (titleLabels as NSArray).enumerateObjects({ item, idx, stop in
            if let label = item as? UILabel {
                if label.frame.contains(location) {
                    self.setSelectedIndex(idx, animated: true)
                    stop.pointee = true
                }
            }
        })
    }
}
