//
//  PreviewView.swift
//  Yippi
//
//  Created by Khoo on 26/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class PreviewView: NSObject , AVCaptureVideoDataOutputSampleBufferDelegate {
    var borderImage: UIImage?
    var isUsingFrontFacingCamera = false
    var videoDataOutput: AVCaptureVideoDataOutput?
    var videoDataOutputQueue: DispatchQueue?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var previewView: UIView?
    
    init(previewView: UIView?) {
        super.init()
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        self.previewView = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        previewView?.addSubview(self.previewView!)
    }

    func videoPreviewBoxForGravity(gravity: String, frameSize: CGSize, apertureSize: CGSize) -> CGRect {
        let apertureRatio: CGFloat = apertureSize.height / apertureSize.width
        let viewRatio: CGFloat = frameSize.width / frameSize.height
        
        var size = CGSize.zero
        if gravity == AVLayerVideoGravity.resizeAspectFill.rawValue {
            if viewRatio > apertureRatio {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            } else {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            }
        } else if gravity == AVLayerVideoGravity.resizeAspect.rawValue {
            if viewRatio > apertureRatio {
                size.width = apertureSize.height * (frameSize.height / apertureSize.width)
                size.height = frameSize.height
            } else {
                size.width = frameSize.width
                size.height = apertureSize.width * (frameSize.width / apertureSize.height)
            }
        } else if gravity == AVLayerVideoGravity.resize.rawValue {
            size.width = frameSize.width
            size.height = frameSize.height
        }

        var videoBox: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        videoBox.size = size
        if size.width < frameSize.width {
            videoBox.origin.x = (frameSize.width - size.width) / 2
        } else {
            videoBox.origin.x = (size.width - frameSize.width) / 2
        }

        if size.height < frameSize.height {
            videoBox.origin.y = (frameSize.height - size.height) / 2
        } else {
            videoBox.origin.y = (size.height - frameSize.height) / 2
        }

        return videoBox
    }
    
    func setupAVCapture(_ frontCamera: Bool) {
        let error: Error? = nil

        // Select device
        var session: AVCaptureSession? = AVCaptureSession()
        if UIDevice.current.userInterfaceIdiom == .phone {
            session!.sessionPreset = .vga640x480
        } else {
            session!.sessionPreset = .photo
        }

        var device: AVCaptureDevice?
        if frontCamera {
            device = findFrontCamera()
        }

        if nil == device {
            isUsingFrontFacingCamera = false
            device = AVCaptureDevice.default(for: .video)
        }
        
        var deviceInput: AVCaptureDeviceInput? = nil
        do {
            deviceInput = try AVCaptureDeviceInput(device: device!)
        } catch {
        }
        if error != nil {
            session = nil
            teardownAVCapture()
            return
        }


        // add the input to the session
        if let deviceInput = deviceInput {
            if session!.canAddInput(deviceInput) {
                session!.addInput(deviceInput)
            }
        }

        // Make a video data output
        videoDataOutput = AVCaptureVideoDataOutput()

        // We want RGBA, both CoreGraphics and OpenGL work well with 'RGBA'
        videoDataOutput!.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String :  Int(kCMPixelFormat_32BGRA)]
        videoDataOutput!.alwaysDiscardsLateVideoFrames = true // d
        
        videoDataOutputQueue = DispatchQueue(label: "VideoDataOutputQueue")
        videoDataOutput!.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        
        if (session?.canAddOutput(self.videoDataOutput!))! {
            session?.addOutput(self.videoDataOutput!)
        }

        videoDataOutput!.connection(with: .video)?.isEnabled = true

        previewLayer = AVCaptureVideoPreviewLayer(session: session!)
        previewLayer!.backgroundColor = UIColor.black.cgColor
        previewLayer!.videoGravity = .resizeAspectFill

        let rootLayer = previewView?.layer
        rootLayer?.masksToBounds = true
        previewLayer!.frame = previewView!.bounds
        rootLayer?.addSublayer(previewLayer!)
        session?.startRunning()
    }
    
    func findFrontCamera() -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devices(for: .video)
        for device in devices {
            if device.position == .front {
                isUsingFrontFacingCamera = true
                return device
            }
        }
        return nil
    }
    
    func teardownAVCapture() {
        videoDataOutput = nil
        if (videoDataOutputQueue != nil) {
            videoDataOutputQueue = nil
        }
        
        previewView!.removeFromSuperview()
        previewLayer!.removeFromSuperlayer()
        previewLayer = nil
    }
    
    func getBorderImage() -> UIImage? {
    #if (ENABLE_DEBUG_MODE)
        return getImageWith(UIColor.yellow)
    #else
        return borderImage
    #endif
    }

    // MARK: - Debug
    func getImageWith(_ color: UIColor?) -> UIImage? {
        let r = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(r.size)
        let context = UIGraphicsGetCurrentContext()

        if let cg = color?.cgColor {
            context?.setFillColor(cg)
        }
        context?.fill(r)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img
    }
}
