//
//  VideoPlayer.swift
//  Yippi
//
//  Created by Tinnolab on 13/05/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import MediaPlayer
import AVKit
import UIKit

class VideoPlayer {
    static let shared = VideoPlayer()
    
    var playerLayer: AVPlayerLayer?
    private(set) var player: AVPlayer?
    var videoReachEnd: EmptyClosure?
    var finished: EmptyClosure?
    var isLoop: Bool = false
    var title: String = ""
    var icon: UIImage?
    var currentTimeCallback: ((_ timeLeft: String) -> Void)?
    private(set) var currentFilePath: URL?
    private var timeObserver: Any?
    
    private var playCommandCache: Any?
    private var pauseCommandCache: Any?
    
    var isPlaying: Bool {
        guard let player = player else { return false }
        
        return (player.rate != 0.0)
    }
    
    var duration: String {
        guard let player = player else { return "" }
        
        var durationInSecs: Double = 0
        
        if let duration = player.currentItem?.asset.duration {
            durationInSecs = CMTimeGetSeconds(duration)
        }
        return durationInSecs.timeString
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func configure(with path: URL?, title: String? = "", icon: UIImage?, shouldLoop: Bool = false) {
        forceStopVideo()
        
        self.title = title ?? ""
        self.icon = icon ?? UIImage.set_image(named: "more_wave")
        
        if let path = path {
            self.currentFilePath = path
            player = AVPlayer(url: path)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resize
            
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            
            NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: .NSExtensionHostDidBecomeActive, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: .NSExtensionHostDidEnterBackground, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(self.enterBackgroundNotificationHandler), name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.resumeFromBackgroundNotificationHandler), name: UIApplication.didBecomeActiveNotification, object: nil)
            
            let interval = CMTimeMakeWithSeconds(1.0, preferredTimescale: Int32(NSEC_PER_SEC)) // 1 second
            
            var durationInSecs: Double = 0
            
            if let duration = player?.currentItem?.asset.duration {
                durationInSecs = CMTimeGetSeconds(duration)
            }
            
            timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: nil, using: { [weak self] (time) in
                let timeLeftInSecs = durationInSecs - time.seconds
                self?.currentTimeCallback?("\(timeLeftInSecs.timeString)")
            })
                        
            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
        }
    }
    
    func play() {

        setupCommandCenter()
        if #available(iOS 10.0, *) {
            if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
                player?.play()
            }
        } else {
            if player?.rate != 0.0 {
                player?.play()
            }
        }

    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    
    func forceStopVideo() {
        guard let player = player else { return }
        player.pause()
        
        if let timeObserver = timeObserver {
            player.removeTimeObserver(timeObserver)
        }
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
        
        self.player = nil
        
        NotificationCenter.default.removeObserver(self)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
    
    @objc private func appBecomeActive() {
        if let track = self.player?.currentItem?.tracks.first, track.assetTrack?.hasMediaCharacteristic(.visual) == true {
            track.isEnabled = true
        }
    }
    
    @objc private func appMovedToBackground() {
        if let track = self.player?.currentItem?.tracks.first, track.assetTrack?.hasMediaCharacteristic(.visual) == true {
            track.isEnabled = false
        }
    }
    
    @objc private func enterBackgroundNotificationHandler() {
        if let track = self.player?.currentItem?.tracks.first, track.assetTrack?.hasMediaCharacteristic(.visual) == true {
            track.isEnabled = false
        }
    }
    
    @objc private func resumeFromBackgroundNotificationHandler() {
        if let track = self.player?.currentItem?.tracks.first, track.assetTrack?.hasMediaCharacteristic(.visual) == true {
            track.isEnabled = true
        }
    }
    
    private func setupCommandCenter() {
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.isEnabled = false
        
        commandCenter.playCommand.removeTarget(playCommandCache)
        commandCenter.pauseCommand.removeTarget(pauseCommandCache)
        
        playCommandCache = commandCenter.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.player?.play()
            return .success
        }
        pauseCommandCache = commandCenter.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            self?.stop()
            return .success
        }

        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = self.title
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.player?.currentItem?.currentTime().seconds
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = self.player?.currentItem?.asset.duration.seconds
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
        
        if let image = self.icon {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
                MPMediaItemArtwork(boundsSize: image.size) { size in
                    return image
            }
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    @objc private func reachTheEndOfTheVideo(_ notification: Notification) {
        stop()
        
        if isLoop {
            self.play()
        } else {
            self.finished?()
        }
        self.videoReachEnd?()
    }
    
    @objc private func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let typeInt = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
            let type = AVAudioSession.InterruptionType(rawValue: typeInt) else {
            return
        }
        
        switch type {
        case .began:
            player?.pause()
            
        case .ended:
            if let optionInt = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionInt)
                if options.contains(.shouldResume) {
                    player?.play()
                }
            }
        }
    }
}

extension Double {
    
    var timeString: String {
        let hour = Int(self) / 3600
        let minute = Int(self) / 60 % 60
        let second = Int(self) % 60
        
        guard hour > 0 else {
            return String(format: "%02i:%02i", minute, second)
        }
        
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    }
    
    func inStyle(style: DateComponentsFormatter.UnitsStyle) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second, .nanosecond]
        formatter.unitsStyle = style
        guard let formattedString = formatter.string(from: self) else { return "" }
        return formattedString
    }
}
