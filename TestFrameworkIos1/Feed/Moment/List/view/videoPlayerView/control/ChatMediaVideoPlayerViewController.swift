//
//  ChatMediaVideoPlayerViewController.swift
//  Yippi
//
//  Created by ChuenWai on 08/11/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import AliyunVideoSDKPro
import AliyunPlayer

class ChatMediaVideoPlayerViewController: TSViewController {

    private var url: String = ""
    private var videoPlayerView: VideoPlayerVODView!
    private var isFullScreen: Bool = false

    override public var shouldAutorotate: Bool {
        return false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }

    init(url: String) {
        self.url = url

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        videoPlayerView.aliPlayerView.stop()
        videoPlayerView.aliPlayerView.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        videoPlayerView = VideoPlayerVODView(frame: self.view.bounds)
        self.view.addSubview(videoPlayerView)
        videoPlayerView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        videoPlayerView.delegate = self
        videoPlayerView.aliPlayerView.isAutoPlay = false
        if self.url.isEmpty == false {
            let videoUrl = URL(string: self.url)
            videoPlayerView.playViewPrepare(with: videoUrl)
        }

        addNotiObserver()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if videoPlayerView.playerViewState() == AVPStatusStarted {
            videoPlayerView.pause()
        }
    }

    private func addNotiObserver() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    @objc private func orientationChanged() {
        guard isFullScreen == false &&
            ((UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight)) else {
                return
        }
        maximizePlayer(with: UIDevice.current.orientation)
    }

    @objc func willResignActive() {
        if videoPlayerView != nil && videoPlayerView.playerViewState() == AVPStatusStarted {
            videoPlayerView.pause()
        }
    }

    @objc func becomeActive() {
        if videoPlayerView != nil && videoPlayerView.playerViewState() == AVPStatusPaused {
            videoPlayerView.resume()
        }
    }

    @objc func resignActive() {
        if videoPlayerView != nil && videoPlayerView.playerViewState() == AVPStatusStarted {
            videoPlayerView.pause()
        }
    }

    private func maximizePlayer(with orientation: UIDeviceOrientation) {
        guard let playerView = videoPlayerView else { return }
        self.isFullScreen = true

        let originalFrame = playerView.frame
        let videoPlayerVC = VideoPlayerViewController(player: playerView)

        videoPlayerVC.onDismiss = { [weak self] in
            guard let self = self else { return }
            self.isFullScreen = false
            self.view.addSubview(playerView)
            playerView.frame = originalFrame
            playerView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            playerView.delegate = self

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }

        videoPlayerVC.modalTransitionStyle = .crossDissolve

        self.present(videoPlayerVC.fullScreenRepresentation, animated: true, completion: nil)
    }
}

//MARK: Video player delegate
extension ChatMediaVideoPlayerViewController: VideoPlayerVODDelegate {
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onResume currentPlayTime: TimeInterval) { }

    func onFinish(with playerView: VideoPlayerVODView?) { }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onStop currentPlayTime: TimeInterval) { }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onSeekDone seekDoneTime: TimeInterval) { }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, fullScreen: Bool) {
        if isFullScreen == false {
            self.maximizePlayer(with: UIDevice.current.orientation)
        }
    }
}
