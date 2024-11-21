//
//  VideoPlayerBottomView.swift
//  Yippi
//
//  Created by francis on 15/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation

import SnapKit

private let ALYPVBottomViewTextSizeFont: CGFloat = 12.0
private let ALYPVBottomViewDefaultTime = "00:00" //默认时间样式

class VideoPlayerControlBottomView: UIView, VideoPlayerProgressViewDelegate {
    
    // MARK: action
    var onFullScreenTapped: EmptyClosure?
    var onDragProgressSliderValue: ((_ value: Float, _ event: UIControl.Event) -> Void)?
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    private(set) lazy var progressView: VideoPlayerProgressView = {
        let progressView = VideoPlayerProgressView()
        return progressView
    }()
    
    var qualityButton: UIButton?
    var progress: Float = 0.0
    var loadTimeProgress: Float = 0.0
    var isPortrait = false
    
    private(set) var leftTimeLabel: UILabel = {
        let leftTimeLabel = UILabel()
        leftTimeLabel.font = UIFont.systemFont(ofSize: CGFloat(ALYPVBottomViewTextSizeFont))
        leftTimeLabel.minimumScaleFactor = 0.6
        leftTimeLabel.adjustsFontSizeToFitWidth = true
        leftTimeLabel.textColor = UIColor.white
        leftTimeLabel.text = ALYPVBottomViewDefaultTime
        leftTimeLabel.textAlignment = .center
        return leftTimeLabel
    }()
    
    private(set) var rightTimeLabel: UILabel = {
        let rightTimeLabel = UILabel()
        rightTimeLabel.font = UIFont.systemFont(ofSize: CGFloat(ALYPVBottomViewTextSizeFont))
        rightTimeLabel.minimumScaleFactor = 0.6
        rightTimeLabel.adjustsFontSizeToFitWidth = true
        rightTimeLabel.textColor = UIColor.white
        rightTimeLabel.text = ALYPVBottomViewDefaultTime
        rightTimeLabel.textAlignment = .center
        return rightTimeLabel
    }()
    
    
    private(set) var fullScreenButton: UIButton = {
        let fullScreenButton = UIButton()
        fullScreenButton.contentEdgeInsets = UIEdgeInsets(top:3, left:3, bottom:3, right:3)
        fullScreenButton.imageView?.contentMode = .scaleToFill
        fullScreenButton.setImage(UIImage.set_image(named: "ic_full_screen"), for: .normal)
        fullScreenButton.setImage(UIImage.set_image(named: "ic_minimize_screen"), for: .selected)
        
        return fullScreenButton
    }()
    
    var fullScreenTimeLabel: UILabel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    
    private func commonInit() {
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        
        leftTimeLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightTimeLabel.setContentHuggingPriority(.required, for: .horizontal)
        rightTimeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(leftTimeLabel)
        stackView.addArrangedSubview(progressView)
        stackView.addArrangedSubview(rightTimeLabel)
        stackView.addArrangedSubview(fullScreenButton)
        addSubview(stackView)
        progressView.progressDelegate = self
        
        fullScreenButton.snp.makeConstraints { (make) in
            make.width.equalTo(self.fullScreenButton.snp.height)
        }
        
        leftTimeLabel.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(45)
        }
        
        rightTimeLabel.snp.makeConstraints { (make) in
            make.height.equalToSuperview()
            make.width.equalTo(45)
        }
        
        stackView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(5)
            make.bottom.equalToSuperview()
            make.height.equalTo(40)
        }
        
        fullScreenButton.addTap { [weak self] _ in
            self?.onFullScreenTapped?()
        }
    }
    
    
    func setProgress(_ progress: Float) {
        progressView.setProgress(progress)
    }
    
    
    func videoProgress() -> Float {
        return self.progressView.videoProgress()
    }
    
    
    func getSliderValue() -> CGFloat {
        return progressView.getSliderValue()
    }
    
    func setLoadTimeProgress(_ loadTimeProgress: Float) {
        self.loadTimeProgress = loadTimeProgress
        progressView.setLoadTimeProgress(loadTimeProgress)
    }

    func aliyunVodProgressView(_ progressView: VideoPlayerProgressView?, dragProgressSliderValue value: CGFloat, event: UIControl.Event) {
        onDragProgressSliderValue?(Float(value),event)
    }
    
    func timeformat(fromSeconds seconds: Int) -> String? {
        var seconds = seconds
        seconds = seconds / 1000
        let str_hour = String(format: "%02ld", seconds / 3600)
        let str_minute = String(format: "%02ld", (seconds % 3600) / 60)
        let str_second = String(format: "%02ld", seconds % 60)
        var format_time: String? = nil
        if seconds / 3600 <= 0 {
            format_time = "\(str_minute):\(str_second)"
        } else {
            format_time = "\(str_hour):\(str_minute):\(str_second)"
        }
        return format_time
    }
    
    
    func updateProgress(withCurrentTime currentTime: Float, durationTime: Float) {
        
        //左右全屏时间
        let curTimeStr = timeformat(fromSeconds: Int(roundf(currentTime)))
        let totalTimeStr = timeformat(fromSeconds: Int(roundf(durationTime)))
        rightTimeLabel.text = totalTimeStr
        leftTimeLabel.text = curTimeStr
        progressView.updateProgressWithCurrentTime(currentTime: currentTime, durationTime: durationTime)
    }
    
    func updateCurrentTime(_ currentTime: Float, durationTime: Float) {
        //左右全屏时间
        let curTimeStr = timeformat(fromSeconds: Int(roundf(currentTime)))
        let totalTimeStr = timeformat(fromSeconds: Int(roundf(durationTime)))
        rightTimeLabel.text = totalTimeStr
        leftTimeLabel.text = curTimeStr
    }
    
    func updateFullscreenStatus(fullscreen: Bool) {
        fullScreenButton.isSelected = fullscreen
    }
    
}
