//
//  VideoPlayerProgressView.swift
//  Yippi
//
//  Created by CC Teoh on 06/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

@objc protocol VideoPlayerProgressViewDelegate: NSObjectProtocol {
    @objc func aliyunVodProgressView(_ progressView: VideoPlayerProgressView?, dragProgressSliderValue value: CGFloat, event: UIControl.Event)
}

open class VideoPlayerProgressView: UIView, VideoPlayerSliderViewDelegate {
    
    private let AliyunPlayerViewProgressViewLoadtimeViewHeight: CGFloat = 3
    private let AliyunPlayerViewProgressViewPlaySliderHeight: CGFloat = 24
    
    weak var progressDelegate: VideoPlayerProgressViewDelegate?
    
    private(set) var progress: Float = 0.0
    private(set) var loadTimeProgress: Float = 0.0
    private(set) var milliSeconds = 0
    private(set) var insertTimeArray: [Any] = []
    private(set) var duration: CGFloat = 0.0
    
    private(set) lazy var loadtimeView: UIProgressView = {
        let loadtimeView = UIProgressView(progressViewStyle: .default)
        loadtimeView.backgroundColor = UIColor.clear
        loadtimeView.progress = 0.0
        loadtimeView.trackTintColor = UIColor.darkGray
        loadtimeView.progressTintColor = UIColor.lightGray
        return loadtimeView
    }()

    
    private(set) lazy var playSlider: VideoPlayerSliderView = {
        let playSlider = VideoPlayerSliderView()
        let circleImage = makeCircleWith(size: CGSize(width: 10, height: 10),
                                         backgroundColor: UIColor.white)
        playSlider.minimumTrackTintColor = UIColor.white
        playSlider.maximumTrackTintColor = UIColor.clear
        playSlider.value = 0.0
        playSlider.setThumbImage(circleImage, for: UIControl.State.normal)
        playSlider.setThumbImage(circleImage, for: UIControl.State.highlighted)
        playSlider.addTarget(self, action: #selector(progressSliderDownAction(_:)), for: UIControl.Event.touchDown)
        playSlider.addTarget(self, action: #selector(progressSliderUpAction(_:)), for: UIControl.Event.touchUpInside)
        playSlider.addTarget(self, action: #selector(updateProgressSliderAction(_:)), for: UIControl.Event.valueChanged)
        playSlider.addTarget(self, action: #selector(cancelProgressSliderAction(_:)), for: UIControl.Event.touchCancel)
        playSlider.addTarget(self, action: #selector(updateProgressUpOUtsideSliderAction(_:)), for: UIControl.Event.touchUpOutside)
        return playSlider
    }()
    
    fileprivate func makeCircleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.setStrokeColor(UIColor.clear.cgColor)
        let bounds = CGRect(origin: .zero, size: size)
        context?.addEllipse(in: bounds)
        context?.drawPath(using: .fill)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    
    public func aliyunPlayerViewSlider(_ slider: VideoPlayerSliderView?, event: UIControl.Event, clickedSlider sliderValue: CGFloat) {
        if (progressDelegate != nil) {
            if event == .touchDown || event == .valueChanged {
                playSlider.setValue(Float(sliderValue), animated: true)
            }
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: sliderValue, event: event) //实际是点击事件
        }

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(loadtimeView)
        addSubview(playSlider)
        
        playSlider.sliderDelegate = self
        
        loadtimeView.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview().inset(1)
            make.centerY.equalToSuperview().offset(1)
            make.height.equalTo(AliyunPlayerViewProgressViewLoadtimeViewHeight)
        }
        
        playSlider.snp.makeConstraints { (make) in
            make.leading.trailing.centerY.equalToSuperview()
        }
    }
    
    func setProgress(_ progress: Float) {
        UIView.animate(withDuration: 0.3, animations: {
            self.playSlider.setValue(progress, animated: true)
        }, completion: nil)
    }
    
    func videoProgress() -> Float {
        return playSlider.value
    }
    
    func getSliderValue() -> CGFloat {
        return playSlider.beginPressValue
    }
    
    func setLoadTimeProgress(_ loadTimeProgress: Float) {
        self.loadTimeProgress = loadTimeProgress
        self.loadtimeView.setProgress(loadTimeProgress, animated: false)
    }
    
    func updateProgressWithCurrentTime(currentTime: Float, durationTime: Float) {
        progress = currentTime/durationTime
        self.setProgress(progress)
    }
    
    
    @objc func progressSliderDownAction(_ sender: UISlider?) {
        if (progressDelegate != nil) {
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: CGFloat(sender?.value ?? 0.0), event: UIControl.Event.touchDown)
        }
    }

    @objc func updateProgressSliderAction(_ sender: UISlider?) {
        if (progressDelegate != nil) {
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: CGFloat(sender?.value ?? 0.0), event: UIControl.Event.valueChanged)
        }
    }
    
    @objc func progressSliderUpAction(_ sender: UISlider?) {
        if (progressDelegate != nil) {
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: CGFloat(sender?.value ?? 0.0), event: UIControl.Event.touchUpInside)
        }
    }
    
    @objc func updateProgressUpOUtsideSliderAction(_ sender: UISlider?) {
        if (progressDelegate != nil) && (progressDelegate?.responds(to: #selector(progressDelegate?.aliyunVodProgressView(_:dragProgressSliderValue:event:))))! {
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: CGFloat(sender?.value ?? 0.0), event: UIControl.Event.touchUpOutside)
        }
    }
    
    @objc func cancelProgressSliderAction(_ sender: UISlider?) {
        if (progressDelegate != nil) && (progressDelegate?.responds(to: #selector(progressDelegate?.aliyunVodProgressView(_:dragProgressSliderValue:event:))))! {
            progressDelegate?.aliyunVodProgressView(self, dragProgressSliderValue: CGFloat(sender?.value ?? 0.0), event: UIControl.Event.touchCancel)
        }
    }

}
