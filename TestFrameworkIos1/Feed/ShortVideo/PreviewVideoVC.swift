//
// Created by lip on 2018/3/29.
// Copyright (c) 2018 ZhiYiCX. All rights reserved.
//

import UIKit
import SCRecorder
import AVKit

protocol PreviewVideoVCDelegate: NSObjectProtocol {
    func previewDeleteVideo()
}

class PreviewVideoVC: TSViewController {
    var avasset: AVAsset?
    @IBOutlet weak var playerView: SCVideoPlayerView!
    @IBOutlet weak var playIcon: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: PreviewVideoVCDelegate?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.statusBarStyle = .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        playerView.tapToPauseEnabled = true
        playerView.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
        playerView.player?.setItemBy(avasset)
        playerView.delegate = self
        playerView.player?.loopEnabled = true
        self.backBtn.setEnlargeResponseAreaEdge(size: 15)
        self.deleteBtn.setEnlargeResponseAreaEdge(size: 15)
        
        self.titleLabel.text = "photo_select_preview".localized
        self.deleteBtn.setTitle("delete".localized, for: .normal)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerView.player?.pause()
        self.navigationController?.isNavigationBarHidden = false
        if #available(iOS 13.0, *) {
            UIApplication.shared.statusBarStyle = .darkContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
    }

    @IBAction func backBtnAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func deleteBtnAction(_ sender: Any) {
        // 删除文件 关掉页面 掉用代理
        self.delegate?.previewDeleteVideo()
        navigationController?.popViewController(animated: true)
    }
}

extension PreviewVideoVC: SCVideoPlayerViewDelegate {
    func videoPlayerViewTapped(toPlay videoPlayerView: SCVideoPlayerView) {
        playIcon.isHidden = true
    }

    func videoPlayerViewTapped(toPause videoPlayerView: SCVideoPlayerView) {
        playIcon.isHidden = false
    }

}
