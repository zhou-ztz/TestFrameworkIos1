//
//  NIMChatroomplayerViewController.swift
//  Yippi
//
//  Created by ChuenWai on 27/12/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import SnapKit
import SVProgressHUD
import AliyunVideoSDKPro
import AliyunPlayer

class NIMChatroomplayerViewController: TSViewController {

    private var url: String = ""
    private var playerView: VideoPlayerVODView!
    private var isFullscreen: Bool = false
    private var originalFrame = CGRect.zero
    private var closeButton: UIButton!
    private var downloadButton: UIButton!
    private lazy var fullScreenView: UIView = {
        let fullScreenView = UIView()
        let bounds = UIScreen.main.bounds
        fullScreenView.frame = bounds
        fullScreenView.backgroundColor = .black
        return fullScreenView
    }()

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.allButUpsideDown
    }

    init(url: String) {
        self.url = url

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        playerView = VideoPlayerVODView(frame: self.view.bounds)
        self.view.addSubview(playerView)
        playerView.snp_makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        playerView.delegate = self
        playerView.controlView.bottomView.fullScreenButton.makeHidden()

        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage.set_image(named: "icCloseShadow"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeTap), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.snp_makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalToSuperview()
            }
            make.left.equalTo(UIScreen.main.bounds.origin.x).offset(10)
            make.width.height.equalTo(40)
        }

        downloadButton = UIButton(type: .custom)
        downloadButton.setImage(UIImage.set_image(named: "ic_download_video"), for: .normal)
        downloadButton.addTarget(self, action: #selector(downloadTap), for: .touchUpInside)
        self.view.addSubview(downloadButton)
        downloadButton.snp_makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(5)
            } else {
                make.top.equalToSuperview()
            }
            make.right.equalTo(UIScreen.main.bounds.size.width).inset(10)
            make.width.height.equalTo(30)
        }

        addNotiObserver()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.url.isEmpty == false {
            let videoUrl = URL(string: self.url)
            playerView.playViewPrepare(with: videoUrl)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if playerView.playerViewState() == AVPStatusStarted {
            playerView.stop()
        }
        self.onBackViewClickWithAliyunVod(playerView)
    }

    private func addNotiObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resignActive), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        UIViewController.attemptRotationToDeviceOrientation()
    }

    @objc func willResignActive() {
        if playerView != nil && playerView.playerViewState() == AVPStatusStarted {
            playerView.pause()
        }
    }

    @objc func becomeActive() {
        if playerView != nil && playerView.playerViewState() == AVPStatusPaused {
            playerView.resume()
        }
    }

    @objc func resignActive() {
        if playerView != nil && playerView.playerViewState() == AVPStatusStarted {
            playerView.pause()
        }
    }

    @objc private func closeTap() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func downloadTap() {
        SVProgressHUD.show(withStatus: "downloading...".localized)

        DispatchQueue.global(qos: .background).async {
            if let url = URL(string: self.url), let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/tempFile.mp4"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath))
                    }) { completed, error in
                        if completed {
                            SVProgressHUD.showSuccess(withStatus: "success_save".localized)
                        }
                        if (error != nil) {
                            print("💢💢💢", error!.localizedDescription)
                            SVProgressHUD.showError(withStatus: "fail_save".localized)
                        }
                    }
                }
            }
        }
    }
}

extension NIMChatroomplayerViewController: VideoPlayerVODDelegate {
    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onResume currentPlayTime: TimeInterval) {

    }

    func onFinish(with playerView: VideoPlayerVODView?) {

    }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onStop currentPlayTime: TimeInterval) {

    }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, onSeekDone seekDoneTime: TimeInterval) {

    }

    func aliyunVodPlayerView(_ playerView: VideoPlayerVODView?, fullScreen: Bool) {
        let bounds = UIScreen.main.bounds
        if isFullscreen == true {
            isFullscreen = false
            fullScreenView.frame = originalFrame
            fullScreenView.top = self.view.top
             self.navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            originalFrame = self.playerView.frame
            isFullscreen = true
            fullScreenView = self.playerView ?? UIView()
            fullScreenView.frame = bounds
            self.navigationController?.setNavigationBarHidden(true, animated: true)

            self.view.addSubview(fullScreenView)
        }
    }

    func onBackViewClickWithAliyunVod(_ playerView: VideoPlayerVODView?) {
        if isFullscreen == true {
            isFullscreen = false
            fullScreenView.frame = originalFrame
            fullScreenView.top = self.view.top
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }


}
