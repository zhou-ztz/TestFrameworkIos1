//
//  FeedPlayerView.swift
//  Yippi
//
//  Created by Yong Tze Ling on 30/08/2021.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
    
    var ready:Bool {
        let timeRange = currentItem?.loadedTimeRanges.first as? CMTimeRange
        guard let duration = timeRange?.duration else { return false }
        let timeLoaded = Int(duration.value) / Int(duration.timescale) // value/timescale = seconds
        let loaded = timeLoaded > 0

        return status == .readyToPlay && loaded
    }
}

class FeedPlayerView: UIView {
    lazy var miniVideoIcon = UIImageView(image: UIImage.set_image(named: "ic_mini_video"))
    lazy var playIcon = UIImageView(image: UIImage.set_image(named: "ico_video_play_list"))
    
    lazy var videoView = FeedVideoPlayer()
    lazy var thumbnail = UIImageView().configure {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.isHidden = false
    }
    
    var checkPreparationTimer : DispatchSourceTimer?
    
    init() {
        super.init(frame: .zero)
        self.addSubViews([thumbnail, playIcon, videoView])
        thumbnail.bindToEdges()
        playIcon.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        videoView.bindToEdges()
        
        self.startPreparationTimer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startPreparationTimer() {
        checkPreparationTimer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
        
        checkPreparationTimer!.scheduleRepeating(deadline: .now(), interval: .seconds(1))
        checkPreparationTimer!.setEventHandler
        {
            if self.isPlayerReady(player: self.videoView.player) {
                self.thumbnail.isHidden = true
                self.stopPreparationTimer()
            }
        }
        checkPreparationTimer!.resume()
    }
    
    func stopPreparationTimer() {
        checkPreparationTimer = nil
    }
    
    func isPlayerReady(player: AVPlayer?) -> Bool {
        guard let player = player else { return false }
        
        let ready = player.status == .readyToPlay
        return ready
    }

    
    func setPlayer(_ player: AVPlayer?, at time: CMTime) {
        guard !UserDefaults.isAutoPlayVideoDisable else {
            return
        }
        videoView.player?.pause()
        videoView.player = nil
        videoView.player = player
        videoView.player?.seek(to: time)
        videoView.play()
    }
    
    func change(to time: CMTime) {
        guard !UserDefaults.isAutoPlayVideoDisable else {
            return
        }
        videoView.player?.seek(to: time)
        videoView.play()
    }
    
    func pause() {
        guard !UserDefaults.isAutoPlayVideoDisable else {
            return
        }
        videoView.pause()
    }
    func play() {
        guard !UserDefaults.isAutoPlayVideoDisable else {
            return
        }
        thumbnail.isHidden = true
        videoView.play()
    }
    
    func prepareForReuse() {
        guard !UserDefaults.isAutoPlayVideoDisable else {
            return
        }
        videoView.prepareForReuse()
    }
    
    func showMiniVideoIcon(_ show: Bool) {
        guard show else {
            miniVideoIcon.removeFromSuperview()
            return
        }
        self.addSubview(miniVideoIcon)
        miniVideoIcon.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(10)
        }
    }
    
    func updateMuteStatus() {
        videoView.updateMuteStatus()
    }
    
    func disableAutoPlay() {
        videoView.updateDisableAutoPlayStatus()
    }
}

class FeedVideoPlayer: PlayerView {
    
    private lazy var muteButton = UIButton(type: .custom).configure {
        $0.setImage(UIImage.set_image(named: "ic_video_unmute"), for: .normal)
        $0.setImage(UIImage.set_image(named: "ic_video_mute"), for: .selected)
        $0.backgroundColor = .black.withAlphaComponent(0.8)
        $0.addTarget(self, action: #selector(didMuteVideo(_:)), for: .touchUpInside)
        $0.isSelected = !UserDefaults.isVideoSoundEnabled
    }
    
    private lazy var durationLabel = TSLabel().configure {
        $0.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .white
        $0.text = self.totalDuration.toFormat()
        $0.backgroundColor = .black.withAlphaComponent(0.8)
        $0.textInsets = UIEdgeInsets(top: 6, left: 11, bottom: 6, right: 11)
    }
    
    override init() {
        super.init()
        self.addSubViews([muteButton, durationLabel])
        
        muteButton.snp.makeConstraints {
            $0.bottom.right.equalToSuperview().inset(10)
            $0.height.width.equalTo(30)
        }
        muteButton.roundCorner(15)
        durationLabel.snp.makeConstraints {
            $0.centerY.equalTo(muteButton)
            $0.trailing.equalTo(muteButton.snp.leading).offset(-8)
            $0.height.equalTo(30)
        }
        durationLabel.roundCorner(15)
        self.countDownBlock = { [weak self] time in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let timeLeft = self.totalDuration - time
                self.durationLabel.text = timeLeft > 3600 ? TimeInterval(timeLeft).toFormat(units: [.hour, .minute, .second]) : TimeInterval(timeLeft).toFormat()
            }
        }
        self.onGetTotalDuration = { [weak self] in
            DispatchQueue.main.async {
                self?.durationLabel.text = self?.totalDuration.toFormat()
            }
        }
        updateDisableAutoPlayStatus()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMuteStatus() {
        guard player != nil else {
            return
        }
        muteButton.isSelected = !UserDefaults.isVideoSoundEnabled
        isMute = !UserDefaults.isVideoSoundEnabled
        player?.isMuted = !UserDefaults.isVideoSoundEnabled
    }
    
    @objc func didMuteVideo(_ sender: UIButton) {
        sender.isSelected.toggle()
        isMute = sender.isSelected
        player?.isMuted = sender.isSelected
        UserDefaults.isVideoSoundEnabled = !sender.isSelected
        NotificationCenter.default.post(name: Notification.Name.Video.muteAll, object: nil)
    }
    
    func updateDisableAutoPlayStatus() {
        self.isHidden = UserDefaults.isAutoPlayVideoDisable
        self.muteButton.isHidden = UserDefaults.isAutoPlayVideoDisable
        self.muteButton.isSelected = !UserDefaults.isVideoSoundEnabled
        self.durationLabel.isHidden = UserDefaults.isAutoPlayVideoDisable
        self.isMute = !UserDefaults.isVideoSoundEnabled
        player?.isMuted = !UserDefaults.isVideoSoundEnabled
    }
    
    override func play() {
        guard checkNetworkAvailable() && autoPlayEnable() else {
            return
        }
        super.play()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.updateDisableAutoPlayStatus()
    }
}

class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer?
    
    var player: AVPlayer? {
        get {
            return playerLayer?.player
        }
        set {
            playerLayer?.removeFromSuperlayer()
            
            guard newValue != nil else {
                currentTime = .zero
                return
            }
            playerLayer = AVPlayerLayer(player: newValue)
            //playerLayer?.videoGravity = .resizeAspectFill
            self.layer.insertSublayer(playerLayer!, at: 0)
            playerLayer?.frame = self.bounds
            
            if currentTime > .zero {
                player?.seek(to: currentTime)
            }
            if let player = self.player, let asset = player.currentItem?.asset {                
                progressObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: .main, using: { [weak self] time in
                    self?.countDownBlock?(time.seconds)
                })
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                player.isMuted = self.isMute
                
                let key = "duration"
                asset.loadValuesAsynchronously(forKeys: [key]) { [weak self] in
                    var error: NSError? = nil
                    switch asset.statusOfValue(forKey: key, error: &error) {
                    case .loaded:
                        self?.totalDuration = asset.duration.seconds
                    default:
                        self?.totalDuration = 0.0
                        break
                    }
                    self?.onGetTotalDuration?()
                }
            }
        }
    }
    var totalDuration: TimeInterval = 0.0
    var currentTime: CMTime = .zero
    var progressObserver: Any?
    var isMute: Bool = false
    var countDownBlock: ((_ current: Double) -> Void)?
    var onGetTotalDuration: EmptyClosure?
    
    init() {
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        player?.pause()
        player?.currentItem?.cancelPendingSeeks()
        player?.currentItem?.asset.cancelLoading()
        player = nil
        playerLayer?.removeFromSuperlayer()
        print("deinit \(self.className())")
    }
    
    func play() {
        guard player != nil && player?.timeControlStatus != .playing else {
            return
        }
        player?.play()
    }
    
    func pause() {
        guard player != nil && player?.timeControlStatus != .paused else {
            return
        }
        currentTime = player?.currentTime() ?? .zero
        player?.pause()
    }
    
    func prepareForReuse() {
        player?.pause()
        player?.removeTimeObserver(progressObserver)
        progressObserver = nil
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func playerItemDidReachEnd(_ notification: Notification) {
        guard let playerItem = notification.object as? AVPlayerItem, let urlAsset = playerItem.asset as? AVURLAsset, let currentAsset = player?.currentItem?.asset as? AVURLAsset else { return }
        
        if urlAsset.url.absoluteString == currentAsset.url.absoluteString {
            self.player?.seek(to: .zero)
            self.player?.play()
        }
    }
    
    func checkNetworkAvailable() -> Bool {
        if UserDefaults.isPlayVideoUsingWifiOnly {
            return TSReachability.share.reachabilityStatus != .Cellular
        }
        return TSReachability.share.isReachable()
    }
    
    func autoPlayEnable() -> Bool {
        return !UserDefaults.isAutoPlayVideoDisable
    }
}

