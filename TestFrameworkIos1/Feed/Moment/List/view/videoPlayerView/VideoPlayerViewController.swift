//
//  VideoPlayerViewController.swift
//  Yippi
//
//  Created by francis on 18/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import UIKit
import AVFoundation
import AliyunVideoSDKPro
import AliyunPlayer

extension VideoPlayerViewController: VideoPlayerVODDelegate {
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onResume currentPlayTime: TimeInterval) { }
    @objc func onFinish(with playerView: VideoPlayerVODView?) { }
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onStop currentPlayTime: TimeInterval) { }
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onSeekDone seekDoneTime: TimeInterval) { }
    @objc func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, fullScreen: Bool) {
        if fullScreen == true {
            dismiss()
        }
    }
}

class VideoPlayerViewController: TSViewController, UIGestureRecognizerDelegate {
    
    /// 判断是否有图片查看器正在显示
    static var isShowing = false
    private(set) weak var videoPlayerView: VideoPlayerVODView! 
    private var transitionAnimationTimeInterval: TimeInterval = 0.3
    private var isAppHiddenStatusbar = false
    
    override public var shouldAutorotate: Bool {
        return true
    }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    var initialFrame: CGRect = CGRect.zero
    var onDismiss: (() -> Void)?
    private var  initalPlayStatus: VideoCenterControlButtonState = .loading

    override var prefersStatusBarHidden: Bool { return true }
    
    init(player: VideoPlayerVODView) {
        videoPlayerView = player
        super.init(nibName: nil, bundle: nil)

        videoPlayerView.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func panRecognized(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .ended, .cancelled, .failed, .began: break
        default:
            let panOffset = recognizer.translation(in: view)
            let eligiblePanOffsetX = panOffset.x
            let eligiblePanOffsetY = panOffset.y

            let eligiblePanOffset = sqrt((pow(eligiblePanOffsetY, 2) + pow(eligiblePanOffsetX, 2))) > 100

            if eligiblePanOffset {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                if let recognizerview = recognizer.view {
                    recognizerview.center = CGPoint(x: recognizerview.center.x + panOffset.x, y: recognizerview.center.y + panOffset.y);
                }
                self.dismiss()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotificationObservers()
        VideoPlayerViewController.isShowing = true
        view.backgroundColor = UIColor.black
        
        view.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints { $0.edges.equalToSuperview() }
        videoPlayerView.playerView = videoPlayerView.playerView
        videoPlayerView.aliPlayerView.redraw()
        
        videoPlayerView.controlView.centerControl.onPanUpdate = { [weak self] recognizer in
            self?.panRecognized(recognizer: recognizer)
        }
        
        view.layoutIfNeeded()
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    @objc func willResignActive() {
        guard let playerView = videoPlayerView, playerView.playerViewState() == AVPStatusStarted else {
            return
        }
        playerView.pause()
    }
    
    @objc func becomeActive() {
        guard let playerView = videoPlayerView else {
            return
        }
        playerView.resume()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // to restore previous status bar state
        isAppHiddenStatusbar = UIApplication.shared.isStatusBarHidden
        /// 默认不显示状态栏
        setNeedsStatusBarAppearanceUpdate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func dismiss() {
        VideoPlayerViewController.isShowing = false
        
        onDismiss?()
        self.dismiss(animated: true, completion: nil)
    }
}

