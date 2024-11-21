//
//  VideoPlayerSliderView.swift
//  Yippi
//
//  Created by CC Teoh on 05/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol VideoPlayerSliderViewDelegate: NSObjectProtocol {
    @objc func aliyunPlayerViewSlider(_ slider: VideoPlayerSliderView?, event: UIControl.Event, clickedSlider sliderValue: CGFloat)
}

open class VideoPlayerSliderView: UISlider {
    var changedValue: CGFloat = 0.0
    var beginPressValue: CGFloat = 0.0
    weak var sliderDelegate: VideoPlayerSliderViewDelegate? = nil

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(press(_:)))
        pressGesture.minimumPressDuration = 0.01
        addGestureRecognizer(pressGesture)
    }
    
    @objc func press(_ press: UITapGestureRecognizer?) {

        let touchPoint = press?.location(in: self)
        let range: CGFloat = CGFloat(maximumValue - minimumValue)
        var value = range * ((touchPoint?.x ?? 0.0) / frame.size.width)
        if value < 0 {
            value = 0
        } else if value > 1 {
            value = 1
        }

        switch press?.state {
        case .began?:
            beginPressValue = CGFloat(self.value)

        case .changed?:
            changedValue = value
            if (sliderDelegate != nil && sliderDelegate!.responds(to: #selector(sliderDelegate?.aliyunPlayerViewSlider(_:event:clickedSlider:)))) {
                sliderDelegate?.aliyunPlayerViewSlider(self, event: UIControl.Event.touchDown, clickedSlider: value)
            }
        case .ended?:
            if (sliderDelegate != nil && sliderDelegate!.responds(to: #selector(sliderDelegate?.aliyunPlayerViewSlider(_:event:clickedSlider:)))) {
                sliderDelegate?.aliyunPlayerViewSlider(self, event: UIControl.Event.touchUpInside, clickedSlider: value)
            }
        case .failed?:
            break
        case .cancelled?:
            if (sliderDelegate != nil && sliderDelegate!.responds(to: #selector(sliderDelegate?.aliyunPlayerViewSlider(_:event:clickedSlider:)))) {
                sliderDelegate?.aliyunPlayerViewSlider(self, event: UIControl.Event.touchUpInside, clickedSlider: changedValue)
            }
        default:
            break
        }
    }
}
