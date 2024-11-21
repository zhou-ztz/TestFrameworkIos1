// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit

class MarkableProgressView: UIProgressView {
    private var markedProgresses: [NSNumber] = []

    private var markLayers: [CALayer] = []

    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    func commonInit() {
        progressTintColor = TSColor.main.theme //UIColor(red: 255.0 / 255.0, green: 204.0 / 255.0, blue: 0.0 / 255.0, alpha: 1.0)
        trackTintColor = UIColor(white: 1, alpha: 0.3)
        progress = 0
    }

    func addPlaceholder(_ progress: CGFloat, markWidth: CGFloat) -> CALayer? {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        let width = bounds.width
        let height = bounds.height
        layer.frame = CGRect(x: width * progress, y: 0, width: markWidth, height: height)
        self.layer.addSublayer(layer)

        return layer
    }

    func pushMark() {
        markedProgresses.append(NSNumber(value: self.progress))
        let layer: CALayer? = addPlaceholder(CGFloat(progress), markWidth: bounds.height / 2)
        if let layer = layer {
            markLayers.append(layer)
        }
    }

    func popMark() {
        if markedProgresses.count == 0 {
            return
        }
        markedProgresses.removeLast()
        markLayers.removeLast()
        progress = markedProgresses.last?.floatValue ?? 0.0
        layer.sublayers?.last?.removeFromSuperlayer()
    }

    func reset() {
        for layer in markLayers {
            layer.removeFromSuperlayer()
        }
        markedProgresses = []
        markLayers = []
        progress = 0
    }
    
    var hasProgress: Bool {
        return progress > 0
    }
}
