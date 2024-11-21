//
//  TSBaseCameraViewController.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/10/18.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import AVFoundation

enum TSMediaType {
    case camera
    case miniVideo
}
enum TSMediaPageType {
    case IMPage
    case feedPage
}
protocol TSBaseCameraViewControllerDelegate: class {
    func finishRecordingTo(outputFileURL: URL)
}
class TSBaseCameraViewController: TSViewController {
    
    var mediaType: TSMediaType {
        return .camera
    }
    var mediaPageType: TSMediaPageType {
        return .feedPage
    }
    weak var delegate: TSBaseCameraViewControllerDelegate?
    
    // MARK: - Variables
    lazy var videoButtonsContainer: MiniVideoRecorderContainer = {
        let container = MiniVideoRecorderContainer()
        return container
    }()
    
    //摄像头设置默认为后置
    var isFront: Bool = false
    
    //新版照片拍摄
    let captureSession = AVCaptureSession()
    var camera: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer!
    let stillImageOutput = AVCapturePhotoOutput()
    
    //  音频输入设备
    let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    
    //  将捕获到的视频输出到文件
    let fileOut = AVCaptureMovieFileOutput()
    //  录制时间Timer
    var timer: Timer?
    var totalDuration = 0.0
    //  表示当时是否在录像中
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    public func setupAVFoundationSettings() {
  
        camera = cameraWithPosition(position: AVCaptureDevice.Position.back)
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        if let camera = camera, let videoInput = try? AVCaptureDeviceInput(device: camera) {
            captureSession.addInput(videoInput)
        }
    
        if self.mediaType == .camera {
            captureSession.addOutput(stillImageOutput)
        } else {
            //  添加音频输出
            if audioDevice != nil,
                let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
                captureSession.addInput(audioInput)
            }
            captureSession.addOutput(fileOut)
        }
        
        let videoLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        videoLayer.frame = view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        view.layer.addSublayer(videoLayer)
        
        previewLayer = videoLayer
        
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    public func changeMediaType(mediaType: TSMediaType = .camera) {
        captureSession.beginConfiguration()
        
        // 先移除已有的 Output
        if captureSession.outputs.contains(fileOut) {
            captureSession.removeOutput(fileOut)
        }
        if captureSession.outputs.contains(stillImageOutput) {
            captureSession.removeOutput(stillImageOutput)
        }

        // 根据新的 mediaType 添加合适的 Output
        switch mediaType {
        case .camera:
            captureSession.addOutput(stillImageOutput)
        case .miniVideo:
            captureSession.addOutput(fileOut)
        }

        captureSession.commitConfiguration()  // 提交所有配置更改
    }
    // MARK: - 开始录制
    public func startRecord() {
        if !isRecording {
            //  开启计时器
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(videoRecordingTotolTime), userInfo: nil, repeats: true)
            //  记录状态： 录像中 ...
            self.videoButtonsContainer.recordButton.startRecordingAnimation()
            self.videoButtonsContainer.enterRecordingState()
            isRecording = true
            DispatchQueue.global(qos: .background).async {
                self.captureSession.startRunning()
            }
            //  设置录像保存地址
            let documentDirectory =  Utils.getDocumentsDirectory()
            let filePath = Utils.videoRecordCachePath()
            let fileUrl: URL? = URL(fileURLWithPath: filePath)
            //  启动视频编码输出
            fileOut.startRecording(to: fileUrl!, recordingDelegate: self)
        }else{
            self.endRecord()
        }
        
    }
    // MARK: - 结束录制
    public func endRecord() {
        //  关闭计时器
        timer?.invalidate()
        timer = nil
        totalDuration = 0
        self.videoButtonsContainer.recordButton.endRecordingAnimation()
        self.videoButtonsContainer.exitRecordingState()
        if isRecording {
            //  停止视频编码输出
            captureSession.stopRunning()
            
            //  记录状态： 录像结束 ...
            isRecording = false
        }
    }
    // MARK: - 结束录制
    public func stopRecord() {
        //  关闭计时器
        timer?.invalidate()
        timer = nil
        totalDuration = 0
        
        if isRecording {
            //  停止录制
            fileOut.stopRecording()
            
            //  记录状态： 录像结束 ...
            isRecording = false
        }
    }
    //闪光灯按钮点击事件
    public func flashOpen() {
        guard let device = camera else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = device.torchMode == .on ? .off : .on
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flash: \(error)")
            }
        }
    }
    //切换摄像头
    func flipCamera() {
   
        self.isFront = !self.isFront
        //  首先移除所有的 input
        if let  allInputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in allInputs {
                captureSession.removeInput(input)

            }
        }
        changeCameraAnimate()
        if self.mediaType == .miniVideo {
            //  添加音频输出
            if audioDevice != nil,
                let audioInput = try? AVCaptureDeviceInput(device: audioDevice!) {
                self.captureSession.addInput(audioInput)
            }
        }
     
        if self.isFront {
            camera = cameraWithPosition(position: .front)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
            
        } else {
            camera = cameraWithPosition(position: .back)
            if let input = try? AVCaptureDeviceInput(device: camera!) {
                captureSession.addInput(input)
            }
        }
    }
    public func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: AVMediaType.video)
        for item in devices {
            if item.position == position {
                return item
            }
        }
        return nil
    }
    
    // MARK: - 切换动画
    public func changeCameraAnimate() {
        let changeAnimate = CATransition()
        changeAnimate.delegate = self
        changeAnimate.duration = 0.4
        changeAnimate.type = CATransitionType(rawValue: "oglFlip")
        changeAnimate.subtype = CATransitionSubtype.fromRight
        previewLayer.add(changeAnimate, forKey: "changeAnimate")
    }
    
}
extension TSBaseCameraViewController {
    // MARK: - 录制时间
    @objc private func videoRecordingTotolTime() {
        totalDuration += 1
        
        let progress = totalDuration / self.videoButtonsContainer.maxDuration
        self.videoButtonsContainer.progressBar.progress = Float(progress)
        self.videoButtonsContainer.editStackView.isHidden = !self.videoButtonsContainer.progressBar.hasProgress

        //  判断是否录制超时
        if totalDuration >= self.videoButtonsContainer.maxDuration {
            timer?.invalidate()
            self.videoButtonsContainer.recordButton.endRecordingAnimation()
            self.endRecord()
        }
        self.videoButtonsContainer.videoDurationLabel.text = TimeInterval(totalDuration).toFormat()
    }
}
// MARK: - CAAnimationDelegate
extension TSBaseCameraViewController: CAAnimationDelegate {
    /// 动画开始
    func animationDidStart(_ anim: CAAnimation) {
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }
    
    /// 动画结束
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension TSBaseCameraViewController: AVCaptureFileOutputRecordingDelegate {
    /// 开始录制
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    /// 结束录制
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        let avAsset = AVURLAsset(url: outputFileURL)
        self.delegate?.finishRecordingTo(outputFileURL: outputFileURL)
    }
}
