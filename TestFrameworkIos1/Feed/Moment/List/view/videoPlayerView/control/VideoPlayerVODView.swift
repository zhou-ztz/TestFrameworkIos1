//
//  VideoPlayerVODView.swift
//  Yippi
//
//  Created by CC Teoh on 17/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import AliyunVideoSDKPro
import AliyunPlayer

@objc protocol VideoPlayerVODDelegate: NSObjectProtocol {
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onResume currentPlayTime: TimeInterval)
    @objc func onFinish(with playerView: VideoPlayerVODView?)
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onStop currentPlayTime: TimeInterval)
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onSeekDone seekDoneTime: TimeInterval)
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, fullScreen: Bool)
}

class VideoPlayerVODView: UIView, AVPDelegate {
    
    var videoUrl: URL?
    weak var delegate: VideoPlayerVODDelegate?
    
    lazy var aliPlayerView: AliPlayer = {
        let player = AliPlayer()!
        player.playerView = self.playerView        
        return player
    }()
    
    var controlView: VideoPlayerControlView = VideoPlayerControlView()
    
    var playerView: UIView = UIView()
    
    weak var timer: Timer?
    var saveCurrentTime: Float = 0.0
    var mProgressCanUpdate = false
    var keyFrameTime: TimeInterval = 0.0
    var currentPlayStatus: AVPStatus?
    var startPlaytime: CMTime = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("deinit \(self.className())")
    }
    
    func seekMode() -> AVPSeekMode {
        if (aliPlayerView.duration < 300000) {
            return AVP_SEEKMODE_ACCURATE;
        }
        return AVP_SEEKMODE_INACCURATE;
    }
    
    private func configurePlayer() {
        aliPlayerView.isAutoPlay = true
        aliPlayerView.isLoop = false
        aliPlayerView.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
        aliPlayerView.rate = 1.0
    }

    private func commonInit() {
        self.mProgressCanUpdate = true
        self.keyFrameTime = 0.0
        configurePlayer()
        
        aliPlayerView.delegate = self
        addSubview(playerView)
        
        controlView.playerControlViewDelegate = self
        addSubview(controlView)
        
        backgroundColor = .black
        
        playerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        controlView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        layoutIfNeeded()
    }
    
    func currentPlayTime() -> CMTime {
        return CMTime(seconds: TimeInterval(aliPlayerView.currentPosition / 1000), preferredTimescale: CMTimeScale(1000000))
    }
    
    func playViewPrepare(with url: URL?, isFinal: Bool = false, onComplete: EmptyClosure? = nil) {
        controlView.centerControl.state = .loading
        
        guard let url = url else {
            return
        }
        
        let playForUrl = { [weak self] (url: URL) -> Void in
            guard let self = self else { return }
            self.videoUrl = url
            let urlSource = AVPUrlSource()
            urlSource.url(with: url.absoluteString)
            
            self.aliPlayerView.setUrlSource(urlSource)
            self.aliPlayerView.setCacheConfig(self.cacheConfig())
            self.aliPlayerView.prepare()
            
            guard self.aliPlayerView.isAutoPlay == true else { return }
            
            if self.startPlaytime > .zero {
                let time = Int64(self.startPlaytime.seconds * 1000)
                self.aliPlayerView.seek(toTime: time, seekMode: self.seekMode())
            }
            self.aliPlayerView.start()
            onComplete?()
        }
        
        guard isFinal == false else {
            playForUrl(url)
            return
        }
        
        // in case of redirection
        TSDownloadNetworkNanger.share.getFinalUrl(for: url.absoluteString) { (finalUrl) in
            guard let _url = URL(string: finalUrl) else { return }
            playForUrl(_url)
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // update view
        controlView.updateView(withPlayerState: currentPlayStatus ?? AVPStatusIdle,
                               isScreenLocked: false,
                               fixedPortrait: false)
    }
    
    private func cacheConfig() -> AVPCacheConfig {
        let cacher = Cacher.init(with: "com.yippiweb.cache.video", cacheType: .video)
        let config = AVPCacheConfig()
        config.enable = true
        config.maxDuration = 100
        config.path = cacher.cacheDir()
        config.maxSizeMB = 200
        return config
    }
    
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        let currentTime = TimeInterval(position)
        let durationTime = aliPlayerView.duration
        
        saveCurrentTime = Float(currentTime) / 1000
        
        if mProgressCanUpdate == true {
            if Double(keyFrameTime) > 0.0 && position < Int(keyFrameTime) {
                // 屏蔽关键帧问题
                return
            }
            controlView.updateProgress(withCurrentTime: currentTime, durationTime: TimeInterval(durationTime))
            keyFrameTime = 0.0
        }
        
    }
    
    func onBufferedPositionUpdate(_ player: AliPlayer!, position: Int64) {
        guard let player = player else { return }
        let progressValue = Float(position) / Float(player.duration)
        controlView.setLoadTimeProgress(progressValue)
    }
    
    func onPlayerStatusChanged(_ player: AliPlayer?, oldStatus: AVPStatus, newStatus: AVPStatus) {
        guard let player = player else { return }
        
        currentPlayStatus = newStatus
        
        //更新UI状态
        controlView.updateView(withPlayerState: currentPlayStatus ?? AVPStatusIdle,
                               isScreenLocked: false,
                               fixedPortrait: false)
    }
    

    func playerViewState() -> AVPStatus {
        return currentPlayStatus ?? AVPStatusIdle
    }
    
    func pause() {
        aliPlayerView.pause()
        currentPlayStatus = AVPStatusPaused // 快速的前后台切换时，播放器状态的变化不能及时传过来
    }
    
    func resume() {
        aliPlayerView.start()
        currentPlayStatus = AVPStatusStarted
    }
    
    func stop() {
        aliPlayerView.stop()
    }
    
    func replay() {
        aliPlayerView.start()
    }
    
    func reset() {
        aliPlayerView.reset()
        aliPlayerView.playerView = playerView
    }
    
    func onError(_ player: AliPlayer!, errorModel: AVPErrorModel!) {
        // TODO: ADD ERROR HANDLING
    }
   
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        switch eventType {
        case AVPEventPrepareDone:
            mProgressCanUpdate = true
            
        case AVPEventFirstRenderedStart:
            UIApplication.shared.isIdleTimerDisabled = true
            
        case AVPEventCompletion:
            
            if delegate != nil && (delegate?.responds(to: #selector(delegate?.onFinish(with:))))! {
                delegate?.onFinish(with: self)
            }
            
        case AVPEventLoadingStart:
            controlView.centerControl.state = .loading
            
        case AVPEventLoadingEnd:
            controlView.centerControl.state = .pause
            
        case AVPEventSeekEnd:
            mProgressCanUpdate = true
            resume()
            
        case AVPEventLoopingStart, AVPEventAutoPlayStart: break
            
        default: break
        }
    }
}


extension VideoPlayerVODView: VideoPlayerControlViewDelegate {
    func onClickedPlayButton(withAliyunControlView controlView: VideoPlayerControlView?) {
        resume()
    }
    
    func onClickedPauseButton(withAliyunControlView controlView: VideoPlayerControlView?) {
        pause()
    }
    
    func onClickedReplayButton(withAliyunControlView controlView: VideoPlayerControlView?) {
        aliPlayerView.seek(toTime: 0, seekMode: seekMode())
        resume()
    }
    
    func onClickedfullScreenButton(withAliyunControlView controlView: VideoPlayerControlView?) {
        guard let delegate = delegate else { return }
        delegate.aliyunVodPlayerView(self, fullScreen: VideoPlayerViewController.isShowing)
    }
    
    func aliyunControlView(_ controlView: VideoPlayerControlView?, dragProgressSliderValue progressValue: Float, event: UIControl.Event) {
        var totalTime = 0
        totalTime = Int(self.aliPlayerView.duration)
        
        switch (event) {
        case UIControl.Event.touchDown:
            controlView?.updateCurrentTime(TimeInterval(progressValue * Float(totalTime)), durationTime: TimeInterval(totalTime))
            self.mProgressCanUpdate = false
        case UIControl.Event.valueChanged:
            self.mProgressCanUpdate = false
            controlView?.updateCurrentTime(TimeInterval(progressValue * Float(totalTime)), durationTime: TimeInterval(totalTime))
        case UIControl.Event.touchUpInside:
            self.aliPlayerView.seek(toTime: Int64(progressValue * Float(totalTime)), seekMode: seekMode())
            let state = playerViewState()
            if (state == AVPStatusPaused) {
                self.aliPlayerView.start()
            }
            self.mProgressCanUpdate = true
        //                })
        case UIControl.Event.touchUpOutside:
            self.aliPlayerView.seek(toTime: Int64(progressValue * Float(totalTime)), seekMode: seekMode())
            let state = playerViewState()
            
            if (state == AVPStatusPaused) {
                self.aliPlayerView.start()
            }
            self.mProgressCanUpdate = true
            
        //点击事件
        case UIControl.Event.touchDownRepeat:
            self.mProgressCanUpdate = false
            self.aliPlayerView.seek(toTime: Int64(progressValue * Float(totalTime)), seekMode: seekMode())
            self.mProgressCanUpdate = true
            
        default:  self.mProgressCanUpdate = true
        }
        
        
    }
    
}
