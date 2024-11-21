//
//  MiniVideoCoverPickerViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 05/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import Photos

protocol MiniVideoCoverPickerDelegate: class {
    func coverImageDidPicked(_ image: UIImage)
}

class MiniVideoCoverPickerViewController: TSViewController {

    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var selectorView: UIView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    private(set) var asset: AVAsset

    weak var delegate: MiniVideoCoverPickerDelegate?
    
    private lazy var selectorThumbView = ThumbSelectorView().configure {
        $0.thumbBorderColor = TSColor.main.theme
    }
    private var playerLayer: AVPlayerLayer?
    private var player: AVPlayer?
    
    init(asset: AVAsset) {
        self.asset = asset
        super.init(nibName: "MiniVideoCoverPickerViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .black
        
        selectorThumbView.frame = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 60))
        selectorView.addSubview(selectorThumbView)
        selectorThumbView.bindToEdges()
        selectorThumbView.asset = asset
        selectorThumbView.delegate = self

        doneBtn.applyStyle(.custom(text: "done".localized, textColor: .white, backgroundColor: .clear, cornerRadius: 0, fontWeight: .regular))
        cancelBtn.applyStyle(.custom(text: "cancel".localized, textColor: .white, backgroundColor: .clear, cornerRadius: 0, fontWeight: .regular))
        
        let avplayerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: avplayerItem)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspect
        previewView.layer.addSublayer(playerLayer!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = previewView.bounds
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectorThumbView.regenerateThumbnails()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneBtnTapped(_ sender: Any) {
        guard let selectedTime = selectorThumbView.selectedTime else {
            return
        }
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.appliesPreferredTrackTransform = true
        var actualTime = CMTime.zero
        let image = try? generator.copyCGImage(at: selectedTime, actualTime: &actualTime)
        if let image = image {
            let selectedImage = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .up)
            self.delegate?.coverImageDidPicked(selectedImage)
            self.dismiss(animated: true)
        }
    }
}

extension MiniVideoCoverPickerViewController: ThumbSelectorViewDelegate {
    
    func didChangeThumbPosition(_ imageTime: CMTime) {
        player?.seek(to: imageTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
}
