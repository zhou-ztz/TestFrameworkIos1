//
//  MiniVideoPlayer.swift
//  Yippi
//
//  Created by Yong Tze Ling on 02/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import AVFoundation

class MiniVideoPlayer: PlayerView {
    
    var playerStatusObserver: NSKeyValueObservation?
    var progressBlock: ((CGFloat) -> Void)?
    var currentPlaybackTime: ((Double) -> Void)?
    
    var isPause: Bool = false
    
    override init() {
        super.init()
        
        self.countDownBlock = { [weak self] time in
            guard let self = self else { return }
            self.currentPlaybackTime?(time/self.totalDuration)
        }
    }
    deinit {
        self.stop()
        self.player?.currentItem?.cancelPendingSeeks()
        self.player?.currentItem?.asset.cancelLoading()
    }
    
    // By Kit Foong (Update video full screen by checking video height and width)
    func setVideoFrame(videoHeight: Double = 0, videoWidth: Double = 0, completion: (() -> Void)?) {
        var aspectRatio = videoHeight / videoWidth
        if aspectRatio >= 1.25 {
            self.playerLayer?.videoGravity = .resizeAspectFill
        } else {
            self.playerLayer?.videoGravity = .resizeAspect
        }
        
        completion?()
    }
    
    // By Kit Foong (Added video height and width parameter)
    func setUrl(_ url: String, videoHeight: Double = 0, videoWidth: Double = 0, completion: ((Bool)->())? = nil) {
        
        guard let url = URL(string: url) else {
            return
        }
        let asset = AVURLAsset(url: url)
        //        asset.loadValuesAsynchronously(forKeys: ["playable"]) {
        //            defer{
        //                self.player?.pause()
        //            }
        //            var error: NSError? = nil
        //            let status = asset.statusOfValue(forKey: "playable", error: &error)
        //
        //            switch status {
        //            case .loaded:
        DispatchQueue.main.async {
            let playerItem = AVPlayerItem(asset: asset)
            self.player?.automaticallyWaitsToMinimizeStalling = false
            
            //self.playerLayer?.videoGravity = .resizeAspect
            self.player = AVPlayer(playerItem: playerItem)
            
            self.setVideoFrame(videoHeight: videoHeight, videoWidth: videoWidth, completion: {
                completion?(true)
            })
        }
        //            case .failed:
        //                print("Mini Video Initialization failed")
        //                completion?(false)
        //                break
        //            default:
        //                completion?(false)
        //                break
        //            }
        //        }
    }
    
    func setObservers() {
        if let player = player {
            playerStatusObserver = player.observe(\.currentItem?.status, changeHandler: { [weak self] player, change in
                switch player.status {
                case .readyToPlay:
                    DispatchQueue.main.async {
                        self?.play()
                    }
                default: break
                }
            })
            NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    func removeObservers() {
        if let progressObserver = progressObserver, player?.rate == 1.0 {
            player?.removeTimeObserver(progressObserver)
            player?.pause()
        }
        playerStatusObserver = nil
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    func isPlaying() -> Bool {
        return player?.timeControlStatus == .playing
    }
    
    func seek(to time: TimeInterval) {
        player?.seek(to: CMTime(seconds: time, preferredTimescale: 1000000))
        player?.play()
    }
}
