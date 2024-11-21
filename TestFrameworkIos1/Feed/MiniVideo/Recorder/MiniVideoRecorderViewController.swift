//
//  MiniVideoRecorderViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 10/09/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD
import AVFoundation
import Photos
import TZImagePickerController
import PhotosUI

typealias MiniVideoRecorderHandler = ((URL) -> Void)

class MiniVideoRecorderViewController: TSBaseCameraViewController {
    
    var onSelectMiniVideo: MiniVideoRecorderHandler? = nil
    override var mediaType: TSMediaType { return .miniVideo }
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //设置代理
        self.delegate = self
        self.modalPresentationCapturesStatusBarAppearance = true
        self.view.backgroundColor = .black
        
        //  录制视频基本设置
        self.setupAVFoundationSettings()
        //  加载功能面板
        self.initContainer()
        //  预获取视频相册，解决录制完成权限弹窗异步问题
        PHAsset.fetchAssets(with: .video, options: nil)
    }
    
    func initContainer() {
        self.view.addSubview(self.videoButtonsContainer)
        self.videoButtonsContainer.delegate = self
        self.videoButtonsContainer.snp.makeConstraints {
            if TSUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.topLayoutGuide.snp.bottom)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.888)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top).priority(.low)
        }
        self.videoButtonsContainer.flashButton.isHidden = false
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        print("deinit MiniVideoRecorderViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addObserver()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func addObserver() {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.videoButtonsContainer.isHidden == true{
            self.videoButtonsContainer.isHidden = false
        }
    }
}


extension MiniVideoRecorderViewController: MiniVideoRecordContainerDelegate {
    func editButtonDidTapped() {
        
    }
    
    
    // MARK: - 关闭页面
    func closebuttonDidTapped(_ isShowSheet: Bool) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            self.dismiss(animated: true, completion: { [weak self] in
                guard let self = self else { return }
                self.stopRecord()
            })
        }
    }
    // MARK: - 录制按钮点击事件
    func recorderButtonDidTapped() {
        
        if self.videoButtonsContainer.timer > 0 && self.isRecording == false {
            self.videoButtonsContainer.countdownTimerChecker { [weak self] in
                guard let self = self else { return }
                self.videoButtonsContainer.recordButton.isHidden = true
                self.videoButtonsContainer.enterRecordingState()
            } countDownEnd: { [weak self] in
                guard let self = self else { return }
                self.videoButtonsContainer.recordButton.isHidden = false
                self.startRecord()
                DispatchQueue.global(qos: .background).async {
                    self.captureSession.startRunning()
                }
                
            }
            
        }else{
            self.startRecord()
        }
        
        
    }
    
    // MARK: - 切换摄像头
    func flipButtonDidTapped() {
        self.flipCamera()
        self.videoButtonsContainer.flashButton.isHidden = self.isFront
    }
    // MARK: - 闪光灯按钮点击事件
    func flashButtonDidTapped() {
        self.videoButtonsContainer.flashButton.isSelected = !self.videoButtonsContainer.flashButton.isSelected
        self.flashOpen()
    }
    // MARK: - 录制时长点击事件
    func durationButtonDidTapped() {
        print("设置录制时长 ： \(self.videoButtonsContainer.maxDuration)")
    }
    // MARK: - 相册
    func albumButtonDidTapped() {
        if #available(iOS 14.0, *) {
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = 1
            phPickerConfig.filter = .videos
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            phPickerVC.delegate = self
            present(phPickerVC, animated: true)
        } else {
            // Fallback on earlier versions
        }
        
//        guard let vc = TZImagePickerController(maxImagesCount: BEManager.maxVideo, columnNumber: 4, delegate: self, mainColor: TSColor.main.theme) else { return }
//        vc.allowCrop = false
//        vc.allowTakePicture = false
//        vc.allowTakeVideo = false
//        vc.allowPickingImage = false
//        vc.allowPickingVideo = true
//        vc.allowPickingGif = false
//        vc.allowPickingMultipleVideo = true
//        vc.showPhotoCannotSelectLayer = true
//        vc.maxImagesCount = 1
//        vc.photoSelImage =  UIImage.set_image(named: "ic_rl_checkbox_selected")
//        vc.previewSelectBtnSelImage = UIImage.set_image(named: "ic_rl_checkbox_selected")
//        vc.navigationBar.tintColor = .black
//        vc.navigationItem.titleView?.tintColor = .black
//        vc.navigationBar.barTintColor = .black
//        vc.barItemTextColor = .black
//        vc.backImage = UIImage.set_image(named: "iconsArrowCaretleftBlack")
//        var dic = [NSAttributedString.Key: Any]()
//        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
//        vc.navigationBar.titleTextAttributes = dic
//        
//        vc.didFinishPickingPhotosHandle = { photos, assets, isSelectOriginalPhoto in
//            if let assets = assets as? [PHAsset] {
//                SVProgressHUD.show()
//                self.getResource(asset: assets[0])
//            }
//        }
//        
//        vc.didFinishPickingVideoHandle = { coverImage, asset in
//            if let asset = asset {
//                SVProgressHUD.show()
//                self.getResource(asset: asset)
//            }
//        }
        
//        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
    
    func focusbuttonDidTapped(_ point: CGPoint) {
        
    }
}

extension MiniVideoRecorderViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        for result in results {
            // Handle PHAsset extraction
            if let assetIdentifier = result.assetIdentifier {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                if let phAsset = asset {
                    SVProgressHUD.show()
                    getResource(asset: phAsset)
                }
            }
        }
        
    }
}


extension MiniVideoRecorderViewController: TZImagePickerControllerDelegate {
    func getResource(asset: PHAsset) {
        DispatchQueue.main.async {
            
            PHImageManager.default().requestExportSession(forVideo: asset, options: self.getVideoRequestOptions(), exportPreset: AVAssetExportPresetMediumQuality) { [weak self] exportSession, info in
                let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                let date = dateFormatter.string(from: Date())
                let fileName = date.filter { "0123456789".contains($0) }
                
                let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
                
                exportSession?.outputURL = url
                exportSession?.outputFileType = .mp4
                exportSession?.shouldOptimizeForNetworkUse = true
            
                exportSession?.exportAsynchronously {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        guard let self = self else { return }
                        if exportSession?.status == .completed {
                            if self.onSelectMiniVideo != nil {
                                self.dismiss(animated: true) {
                                    self.onSelectMiniVideo?(url)
                                }
                            }else{
                                
                                let avAsset = AVURLAsset(url: url)
                                let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: avAsset)
                                let vc = DependencyContainer.shared.resolveViewControllerFactory().makePostShortVideoView(coverImage: coverImage, url: url)
                                self.navigationController?.pushViewController(vc, animated: true)
                            }
                        } else {
                            SVProgressHUD.dismiss()
                            self.showError(message: "Video export failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                            // 处理导出失败的情况
                            print("Video export failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                        }
                    }
                }
            }
        }
    }
    
    private func getVideoRequestOptions() -> PHVideoRequestOptions {
        let options = PHVideoRequestOptions()
        //        options.deliveryMode = .automatic
        options.version = .current
        options.isNetworkAccessAllowed = true
        return options
    }
}

extension MiniVideoRecorderViewController: TSBaseCameraViewControllerDelegate {
    func finishRecordingTo(outputFileURL: URL) {
        let avAsset = AVURLAsset(url: outputFileURL)
        let coverImage = TSUtil.generateAVAssetVideoCoverImage(avAsset: avAsset)
        //拍摄视频转换为MP4
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { [weak self] (saved, error) in
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    if let result = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject {
                        
                        let option = PHVideoRequestOptions()
                        option.version = .current
                        option.deliveryMode = .automatic
                        option.isNetworkAccessAllowed = true
                        
                        PHImageManager.default().requestExportSession(forVideo: result, options: option, exportPreset: AVAssetExportPresetHighestQuality) { [weak self] (exportSession, info) in
                            
                            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                            let date = String(dateFormatter.string(from: Date()))
                            let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
                            
                            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
                            
                            if FileManager.default.fileExists(atPath: outputFileURL.absoluteString) {
                                do {
                                    try FileManager.default.removeItem(atPath: outputFileURL.absoluteString)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            exportSession?.outputURL = url
                            exportSession?.outputFileType = .mp4
                            exportSession?.shouldOptimizeForNetworkUse = true
                            exportSession?.exportAsynchronously {
                                DispatchQueue.main.async {
                                    
                                    guard let self = self else { return }
                                    if exportSession?.status == .completed {
                                        if self.onSelectMiniVideo != nil {
                                            self.dismiss(animated: true) {
                                                self.onSelectMiniVideo?(url)
                                            }
                                        }else{
                                            let vc = DependencyContainer.shared.resolveViewControllerFactory().makePostShortVideoView(coverImage: coverImage, url: url)
                                            self.navigationController?.pushViewController(vc, animated: true)
                                        }} else {
                                            // 处理导出失败的情况
                                            print("Video export failed: \(exportSession?.error?.localizedDescription ?? "Unknown error")")
                                        }
                                }
                                
                            }
                        }
                    }
                }
            }
        })
    }
    
}
