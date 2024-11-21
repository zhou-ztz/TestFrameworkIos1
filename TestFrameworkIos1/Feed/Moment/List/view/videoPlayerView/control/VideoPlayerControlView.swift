//
//  VideoPlayerControlView.swift
//  Yippi
//
//  Created by CC Teoh on 05/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import AliyunVideoSDKPro
import AliyunPlayer
import Lottie

enum VideoCenterControlButtonState {
    case play, pause, replay, loading,error(msg: String)
}


@objc protocol VideoPlayerControlViewDelegate: NSObjectProtocol {
    func onClickedPlayButton(withAliyunControlView controlView: VideoPlayerControlView?)
    func onClickedPauseButton(withAliyunControlView controlView: VideoPlayerControlView?)
    func onClickedReplayButton(withAliyunControlView controlView: VideoPlayerControlView?)
    func onClickedfullScreenButton(withAliyunControlView controlView: VideoPlayerControlView?)
    func aliyunControlView(_ controlView: VideoPlayerControlView?, dragProgressSliderValue progressValue: Float, event: UIControl.Event)
}

class VideoPlayerControlView: UIView {
    weak var playerControlViewDelegate: VideoPlayerControlViewDelegate?
    
    private(set) var videoInfo: AVPMediaInfo?
    private(set) var state: AVPStatus?
    private(set) var title = ""
    private(set) var loadTimeProgress: Float = 0.0
    private(set) var lockButton: UIButton?
    private(set) var currentTime: TimeInterval = 0.0
    private(set) var duration: TimeInterval = 0.0
    
    let bottomBarBG: UIImageView = {
        let bottomBarBG = UIImageView()
        bottomBarBG.image = UIImage.set_image(named: "bottom_overlay")
        return bottomBarBG
    }()
    
    let centerControl: VideoPlayerCenterControl = VideoPlayerCenterControl(frame: .zero)
    private var centerControlTimer: Timer? = nil

    private let ALYControlViewBottomViewHeight: CGFloat = 48
    private let ALYControlViewLockButtonLeft: CGFloat = 20
    private let ALYControlViewLockButtonHeight: CGFloat = 40
    
    private var bottomControlViewWidth: CGFloat = 0

    lazy var bottomView: VideoPlayerControlBottomView = {
        let bottomView = VideoPlayerControlBottomView()
        return bottomView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func timerShowCenterControl() {
        let bottomViewAlwaysShow = (VideoPlayerViewController.isShowing == false)
        
        let animateToHide = { () -> Void in
            UIView.animate(withDuration: 0.3, animations: {
                self.centerControl.alpha = 0
                self.bottomView.alpha = bottomViewAlwaysShow ? 1 : 0
            })
        }
        
        
        bottomView.makeVisible()
        bottomView.alpha = 1
        centerControl.makeVisible()
        centerControl.alpha = 1
        
        centerControlTimer?.invalidate()
        centerControlTimer = nil
        
        switch centerControl.state {
        case .loading, .error, .replay, .play: // should not hide
            return // show hiding animation timer
            
        default: break
        }
        
        centerControlTimer = Timer.scheduledTimer(timeInterval: 0.8, action: { _ in
            DispatchQueue.main.async {
                animateToHide()
            }
        })
    }
    
    private func commonInit() {
        addSubview(bottomBarBG)
        addSubview(centerControl)
        addSubview(bottomView)
                
        self.addTap { [weak self] _ in
            self?.timerShowCenterControl()
        }

        centerControl.onTapControl = { [weak self] requestState in
            guard let self = self else { return }
            switch requestState {
            case .pause:
                self.playerControlViewDelegate?.onClickedPauseButton(withAliyunControlView: self)
            case .play:
                self.playerControlViewDelegate?.onClickedPlayButton(withAliyunControlView: self)
            case .replay:
                self.playerControlViewDelegate?.onClickedReplayButton(withAliyunControlView: self)
            case .error(let msg):
                break
            case .loading: break
            }
        }
        
        centerControl.onStateUpdate = { [weak self] _ in
            self?.timerShowCenterControl()
        }
        
        centerControl.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
            if #available(iOS 11, *) {
              make.bottom.equalTo(safeAreaLayoutGuide.snp.bottomMargin)
            } else {
              make.bottom.equalTo(self)
            }
        }
        
        bottomBarBG.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(self.bottomView.snp.top)
        }
        
        bottomView.onFullScreenTapped = { [weak self] in
            guard let self = self else { return }
            self.timerShowCenterControl()
            self.onClickedfullScreenButton(withAliyunPVBottomView: self.bottomView)
            self.bottomView.updateFullscreenStatus(fullscreen: VideoPlayerViewController.isShowing)
        }
        
        bottomView.onDragProgressSliderValue = { [weak self] (newValue, event) in
            guard let self = self else { return }
            self.timerShowCenterControl()
            self.playerControlViewDelegate?.aliyunControlView(self, dragProgressSliderValue: newValue, event: event)
        }
    }
    
    func onClickedfullScreenButton(withAliyunPVBottomView bottomView: VideoPlayerControlBottomView?) {
        if playerControlViewDelegate != nil {
            playerControlViewDelegate?.onClickedfullScreenButton(withAliyunControlView: self)
        }
    }
    
    func setLoadTimeProgress(_ loadTimeProgress: Float) {
        self.loadTimeProgress = loadTimeProgress
        bottomView.setLoadTimeProgress(loadTimeProgress)
    }

    private func hideControlView() {
        centerControl.alpha = 0
    }
    
    @objc private func showControlView() {
        centerControl.alpha = 1
    }
    
    func updateView(withPlayerState state: AVPStatus, isScreenLocked: Bool, fixedPortrait: Bool) {
        switch state {
        case AVPStatusStarted:
            centerControl.state = .pause
            
        case AVPStatusPaused, AVPStatusStopped, AVPStatusPrepared:
            centerControl.state = .play
            
        case AVPStatusError:
            centerControl.state = .replay
            
        case AVPStatusCompletion:
            centerControl.state = .replay
            
        case AVPStatusInitialzed, AVPStatusIdle:
            centerControl.state = .loading
            
        default:
            break
        }
    }
    
    func updateFullScreenView(with status: Bool, orientation: UIDeviceOrientation) {
        bottomView.updateFullscreenStatus(fullscreen: status)
        
        if status == true {
            switch(orientation) {
            case .landscapeLeft, .landscapeRight:
                bottomControlViewWidth = (TSBottomSafeAreaHeight * 2) + 20
                
            case .portrait:
                bottomControlViewWidth = 0
                
            case .faceDown, .faceUp, .portraitUpsideDown, .unknown: break
            }
        } else {
            bottomControlViewWidth = 0
        }
        
        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
    }
    
    
    func updateFullScreenView(with status: Bool) {
        bottomView.updateFullscreenStatus(fullscreen: status)
    }

    func updateProgress(withCurrentTime currentTime: TimeInterval, durationTime: TimeInterval) {
        self.currentTime = currentTime
        duration = durationTime
        bottomView.updateProgress(withCurrentTime: Float(currentTime), durationTime:  Float(durationTime))
    }
    
    func updateCurrentTime(_ currentTime: TimeInterval, durationTime: TimeInterval) {
        self.currentTime = currentTime
        duration = durationTime
        bottomView.updateCurrentTime(Float(currentTime), durationTime: Float(durationTime))
    }
    
    
}

class VideoPlayerCenterControl: UIView {
    
    var onTapControl: ((_ state: VideoCenterControlButtonState) -> Void)?
    var onStateUpdate: ((_ state: VideoCenterControlButtonState) -> Void)?
    var onPanUpdate: ((_ recognizer: UIPanGestureRecognizer) -> Void)?
    
    private(set) var mainControl: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private lazy var panGestureRecognizer = {
        return UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized))
    }()
    
    private let loadingView = AnimationView(name: "loading_white").configure {
        $0.contentMode = .scaleAspectFit
    }
    
    var state: VideoCenterControlButtonState = .loading {
        willSet {
            switch newValue {
            case .play:
                self.mainControl.image = UIImage.set_image(named: "ic_video_play")
                self.loadingView.makeHidden()
                self.mainControl.makeVisible()
                
            case .loading:
                self.loadingView.makeVisible()
                self.loadingView.loopMode = .loop
                self.loadingView.play()
                self.mainControl.makeHidden()
                
            case .pause:
                self.mainControl.image = UIImage.set_image(named: "ic_video_pause")
                self.loadingView.makeHidden()
                self.mainControl.makeVisible()
                
            case .replay:
                self.mainControl.image = UIImage.set_image(named: "ic_btn_refresh")
                self.loadingView.makeHidden()
                self.mainControl.makeVisible()
                
            case .error(let msg): break
            }
        }
        didSet {
            onStateUpdate?(self.state)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        addSubview(mainControl)
        addSubview(loadingView)
        
        mainControl.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(50)
        }
        
        loadingView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.width.equalTo(40)
        }
        
        mainControl.addTap { [weak self] (_) in
            guard let self = self else { return }
            self.onTapControl?(self.state)
        }
        
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc func panRecognized(recognizer: UIPanGestureRecognizer) {
        onPanUpdate?(recognizer)
    }
    
    
}
