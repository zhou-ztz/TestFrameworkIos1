//
//  CameraViewController.swift
//  Yippi
//
//  Created by Yong Tze Ling on 12/11/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit
import SVProgressHUD
import iOSPhotoEditor
import MobileCoreServices
import IQKeyboardManagerSwift
import PhotosUI
import TZImagePickerController

typealias CameraHandler = (([PHAsset], UIImage?, String?, Bool, Bool) -> Void)

class CameraViewController: TSBaseCameraViewController {
    var onSelectPhoto: CameraHandler? = nil
    var enableMultiplePhoto: Bool = false
    var allowPickingVideo: Bool = false
    var selectedAsset: [PHAsset] = []
    var selectedImage: [Any] = []
    var onDismiss: EmptyClosure? = nil
    var allowCrop: Bool = false //剪切
    var allowEdit: Bool = false //编辑
    
    override var mediaType: TSMediaType { return .camera }
    public override var shouldAutorotate: Bool { return false }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return [.portrait] }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { return .portrait }
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.view.backgroundColor = .black
        
        self.modalPresentationCapturesStatusBarAppearance = true
        
        self.setupAVFoundationSettings()
        
        self.view.addSubview(buttonsContainer)

        buttonsContainer.snp.makeConstraints {
            if TSUserInterfacePrinciples.share.hasNotch() {
                $0.top.equalTo(self.topLayoutGuide.snp.bottom)
                $0.height.equalTo(self.view.snp.width).multipliedBy(1.888)
            } else {
                $0.top.equalToSuperview()
            }
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.bottomLayoutGuide.snp.top).priority(.low)
        }
        self.buttonsContainer.flashButton.isHidden = false
    }
    

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var maxPhoto: Int {
        return enableMultiplePhoto ? 9 : 1
    }
    
    deinit {
        print("deinit CameraViewController")
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
        if self.buttonsContainer.isHidden == true {
            self.buttonsContainer.isHidden = false
        }
    }
    
    // MARK: - Variables
    
    fileprivate lazy var buttonsContainer: CameraContainer = {
        let container = CameraContainer()
        container.delegate = self
        return container
    }()
    
    
}

extension CameraViewController: MiniVideoRecordContainerDelegate {
    //退出
    func closebuttonDidTapped(_ isShowSheet: Bool) {
        self.dismiss(animated: true, completion: nil)
        self.onDismiss?()
    }
    //录制
    func recorderButtonDidTapped() {

    }
    //切换摄像头
    func flipButtonDidTapped() {
   
        self.flipCamera()
        self.buttonsContainer.flashButton.isHidden = self.isFront
    }

    //闪光灯按钮点击事件
    func flashButtonDidTapped() {
        self.buttonsContainer.flashButton.isSelected = !self.buttonsContainer.flashButton.isSelected
        self.flashOpen()
    }
    func durationButtonDidTapped() {
        
    }
    // MARK: - 相册
    func albumButtonDidTapped() {
        if #available(iOS 14.0, *) {
            var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
            phPickerConfig.selectionLimit = maxPhoto
            phPickerConfig.filter = allowPickingVideo ? PHPickerFilter.videos : .any(of: [.images, .livePhotos])
            let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
            phPickerVC.delegate = self
            present(phPickerVC, animated: true)
        } else {
            // Fallback on earlier versions
        }
        
//        guard let vc = TZImagePickerController(maxImagesCount: maxPhoto - self.selectedAsset.count - self.selectedImage.count, columnNumber: 4, delegate: self, mainColor: TSColor.main.theme) else { return }
//        vc.allowCrop = allowCrop
//        vc.allowTakePicture = false
//        vc.allowTakeVideo = false
//        vc.allowPickingImage = true
//        vc.allowPickingVideo = allowPickingVideo
//        vc.allowPickingGif = true
//        vc.allowPickingMultipleVideo = false
//        vc.photoSelImage =  UIImage.set_image(named: "ic_rl_checkbox_selected")
//        vc.previewSelectBtnSelImage = UIImage.set_image(named: "ic_rl_checkbox_selected")
//        vc.navigationBar.tintColor = .black
//        vc.navigationItem.titleView?.tintColor = .black
//        vc.navigationBar.barTintColor = .black
//        vc.barItemTextColor = .black
//        vc.backImage = UIImage.set_image(named: "iconsArrowCaretleftBlack")
//        vc.allowPreview = true
//        var dic = [NSAttributedString.Key: Any]()
//        dic[NSAttributedString.Key.foregroundColor] = UIColor.black
//        vc.navigationBar.titleTextAttributes = dic
//        self.present(vc.fullScreenRepresentation, animated: true, completion: nil)
    }
  
    func editButtonDidTapped() {
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func focusbuttonDidTapped(_ point: CGPoint) {

    }
}

extension CameraViewController: PHPickerViewControllerDelegate {
    @available(iOS 14.0, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        
        var photos: [UIImage] = []
        var imageAsset: [PHAsset] = []
        var isGifImage = false
        
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            // Check if the item is a GIF
            if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.gif.identifier) {
                isGifImage = true
            } else {
                isGifImage = false
            }
            
            // Handle UIImage extraction
            dispatchGroup.enter()
            result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                if let image = object as? UIImage {
                    photos.append(image)
                }
                dispatchGroup.leave()
            }
            
            // Handle PHAsset extraction
            if let assetIdentifier = result.assetIdentifier {
                let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil).firstObject
                if let phAsset = asset {
                    imageAsset.append(phAsset)
                }
            }
        }
        
        // After all images are loaded
        dispatchGroup.notify(queue: .main) {
            self.handleSelectedPhotos(photos: photos, imageAsset: imageAsset, isGifImage: isGifImage)
        }
        
    
    }
    
    func handleSelectedPhotos(photos: [UIImage], imageAsset: [PHAsset], isGifImage: Bool) {
        if photos.count == 1 && allowEdit && !isGifImage {
            let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
            editor.photoEditorDelegate = self
            editor.image = photos[0]
            self.present(editor.fullScreenRepresentation, animated: true, completion: nil)
            
        } else {
            self.selectedAsset.append(contentsOf: imageAsset)
            self.dismiss(animated: true, completion: {
                self.onSelectPhoto?(self.selectedAsset, photos.first, nil, false, false)
            })
        }
    }
    
}

extension CameraViewController: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        guard let imageAsset = assets as? [PHAsset] else {
            return
        }
        //在这里加上判断，如果选择的图片为gif图片，不需要进入图片编辑页面
        var isGifImage = false
        if imageAsset.count > 0 {
            let phAsset = imageAsset[0]
            if let imageType = phAsset.value(forKey: "uniformTypeIdentifier") as? String {
                if imageType == String(kUTTypeGIF) {
                    isGifImage = true
                }
            }
        }
        if photos.count == 1 && allowEdit && !isGifImage {
            let editor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
            editor.photoEditorDelegate = self
            editor.image = photos[0]
            self.present(editor.fullScreenRepresentation, animated: true, completion: nil)
            
        } else {
            self.selectedAsset.append(contentsOf: imageAsset)
            self.dismiss(animated: true, completion: nil)
            self.onSelectPhoto?(self.selectedAsset, photos.first, nil, false, false)
        }
        
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: PHAsset!) {
        self.selectedAsset.append(asset)
        self.dismiss(animated: true, completion: nil)
        self.onSelectPhoto?(self.selectedAsset, animatedImage, nil, true, false)
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishEditVideoCover coverImage: UIImage!, videoURL: Any!) {
        guard let videoURL = videoURL as? NSURL   else { return }
        
        let videoPath = videoURL.path ?? ""
        
        SVProgressHUD.show(withStatus: "processing".localized)
        
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: videoPath))
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
                            
                            if FileManager.default.fileExists(atPath: videoPath) {
                                do {
                                    try FileManager.default.removeItem(atPath: videoPath)
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            exportSession?.outputURL = url
                            exportSession?.outputFileType = .mp4
                            exportSession?.shouldOptimizeForNetworkUse = true
                            exportSession?.exportAsynchronously {
                                DispatchQueue.main.async {
                                    SVProgressHUD.dismiss()
                                    if exportSession?.status == AVAssetExportSession.Status.completed {
                                        self?.dismiss(animated: true, completion: nil)
                                        self?.onSelectPhoto?([result], nil, url.path, false, false)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self?.dismiss(animated: true, completion: nil)
                        self?.onSelectPhoto?([], nil, videoURL.path ?? "", false, false)
                    }
                }
            }
        })
    }
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingVideo asset: PHAsset!) {
        guard let asset = asset, asset.mediaType == .video else { return }
        
        SVProgressHUD.show(withStatus: "processing".localized)
        
        let option = PHVideoRequestOptions()
        option.version = .current
        option.deliveryMode = .automatic
        option.isNetworkAccessAllowed = true
        
        PHImageManager.default().requestExportSession(forVideo: asset, options: option, exportPreset: AVAssetExportPresetHighestQuality) { [weak self] (exportSession, info) in
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let date = String(dateFormatter.string(from: Date()))
            let fileName = String(date.filter { String($0).rangeOfCharacter(from: CharacterSet(charactersIn: "0123456789")) != nil })
            
            let url = URL(fileURLWithPath: documentDirectory).appendingPathComponent("\(fileName).mp4")
            
            exportSession?.outputURL = url
            exportSession?.outputFileType = .mp4
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.exportAsynchronously {
                DispatchQueue.main.async {
                    
                    SVProgressHUD.dismiss()
                    if exportSession?.status == AVAssetExportSession.Status.completed {
                        self?.dismiss(animated: true, completion: nil)
                        self?.onSelectPhoto?([asset], nil, url.path, false, false)
                    }
                }
            }
        }
    }
}

extension CameraViewController: PhotoEditorDelegate {
    public func doneEditing(image: UIImage) {
        
        DispatchQueue.global(qos: .default).async(execute: {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { (saved, error) in
                
                if saved {
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let result = PHAsset.fetchAssets(with: .image, options: fetchOptions).lastObject
                    if let result = result {
                        self.selectedAsset.append(result)
                    }
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {
                            self.onSelectPhoto?(self.selectedAsset, image, nil, false, true)
                        }
                    }
                }
            }
        })
    }
    
    public func canceledEditing() {
        
    }
}

//extension CameraViewController: UIViewControllerTransitioningDelegate {
//    
//    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
//        
//        buttonsContainer.isContainerHidden = true
//        
//        let controller = CustomSizePresentationController(presentedViewController: presented, presenting: presenting)
//        
//        if presented.isKind(of: MusicPickerViewController.self) {
//            controller.heightPercent = 0.5
//        }
//        
//        controller.dismissHandler = { [weak self] in
//            if self?.buttonsContainer.isContainerHidden == true {
//                self?.buttonsContainer.isContainerHidden = false
//            }
//        }
//        
//        return controller
//    }
//}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation(),
           let image = UIImage(data: imageData) {
            let watermarkImage = image.addWatermark()
            DispatchQueue.main.async {
                if let photoEditor = AppUtil.shared.createPhotoEditor(for: watermarkImage) {
                    photoEditor.photoEditorDelegate = self
                    self.navigationController?.pushViewController(photoEditor, animated: true)
                }
            }
            
        }
    }
}

class CameraContainer: BaseRecorderContainer {
    override init() {
        super.init()
        
        container.addSubview(recordButton)
        
        stackview.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
        }
        
        stackview.snp.makeConstraints {
            $0.top.equalToSuperview().offset(TSStatusBarHeight)
            $0.trailing.equalToSuperview()
        }
        
        stackview.addArrangedSubview(flipButton)
        stackview.addArrangedSubview(timerButton)
        stackview.addArrangedSubview(flashButton)
        
        stackview.arrangedSubviews.forEach { (view) in
            view.snp.makeConstraints {
                $0.width.equalTo(45)
                $0.height.equalTo(50)
            }
        }
        
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.top.equalToSuperview().offset(TSStatusBarHeight)
            $0.width.height.equalTo(40)
        }
        
        recordButton.snp.makeConstraints {
            $0.width.height.equalTo(73)
            $0.centerX.equalToSuperview()
            if TSUserInterfacePrinciples.share.hasNotch() {
                $0.bottom.equalToSuperview().offset(-30)
            } else {
                $0.bottom.equalToSuperview().offset(-60)
            }
        }

        albumButton.snp.makeConstraints {
            $0.leading.equalTo(recordButton.snp.trailing).offset(30)
            $0.centerY.equalTo(recordButton)
            $0.width.height.equalTo(60)
        }
        
        setupRecorder()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -
    
    public lazy var recordButton: CameraButton = { [weak self] in
        let button = CameraButton(frame: CGRect(origin: .zero, size: CGSize(width: 73, height: 73)))
        button.delegate = self
        return button
    }()
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        self.delegate?.recorderButtonDidTapped()
    }
}


extension CameraContainer: RecordButtonDelegate {
    
    func capture() {
        countdownTimerChecker { [weak self] in
            self?.container.isHidden = true
        } countDownEnd: { [weak self] in
            self?.container.isHidden = false
            self?.delegate?.editButtonDidTapped()
        }
    }
}

