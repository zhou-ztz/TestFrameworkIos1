//
//  VideoPlayerPopLayer.swift
//  Yippi
//
//  Created by CC Teoh on 26/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

@objc enum ALYPVOrientation : Int {
    case unknow = 0
    case horizontal
    case vertical
}

@objc enum ALYPVPlayerPopCode : Int {
    case unKnown = 0
    case playFinish = 1
    case stop = 2
    case serverError = 3
    case networkTimeOutError = 4
    case unreachableNetwork = 5
    case loadDataError = 6
    case useMobileNetwork = 7
    case securityTokenExpired = 8
}

protocol VideoPlayerPopLayerDelegate: NSObjectProtocol {
    func showPopViewWith(type: ALYPVErrorType)
}

private let AliyunPlayerViewErrorViewWidth: CGFloat = 220
private let AliyunPlayerViewErrorViewHeight: CGFloat = 120

class VideoPlayerPopLayer: UIView, VideoPlayerErrorViewDelegate {
    
    weak var delegate: VideoPlayerPopLayerDelegate?
        
    lazy var errorView: VideoPlayerErrorView = {
        let errorView = VideoPlayerErrorView.init(frame: CGRect(x: 0, y: 0, width: AliyunPlayerViewErrorViewWidth, height: AliyunPlayerViewErrorViewHeight))
        return errorView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        backgroundColor = UIColor.black
        errorView.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.errorView.center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)

    }
        
    func onErrorViewClickedWith(type: ALYPVErrorType?) {
        if delegate != nil {
            delegate?.showPopViewWith(type: type ?? .replay)
        }
    }
    
    func showPopViewWithCode(code: ALYPVPlayerPopCode, popMsg:String) {
        if errorView.isShowing() {
            errorView.dismiss()
        }
        var tempString = "unkown"
        var type: ALYPVErrorType = .retry
        
        switch (code) {
            case .playFinish:
            
                tempString = "Watch again, please click replay"
                type = .replay
                backgroundColor = UIColor.black.withAlphaComponent(0.5)

            case .networkTimeOutError :
            
                tempString = "The current network is not good. Please click replay later"
                type = .replay
            

            case .unreachableNetwork:
            
                tempString = "No network connection, check the network, click replay"
                type = .replay
            

            case .loadDataError :
            
                tempString = "Video loading error, please click replay"
                type = .retry
            

            case .serverError:
            
                tempString = popMsg
                type = .retry

            case .useMobileNetwork:
            
                tempString = "For mobile networks, click play"
                type = .pause
            
            
            case .securityTokenExpired:
            
                tempString = popMsg
                type = .stsExpired
            
            default:
                break
        }
        
        if popMsg != "" {
            tempString = popMsg
        }
        
        self.errorView.setMessage(message: tempString)
        self.errorView.setType(type: type)
        
        errorView.showWithParentView(parent: self)
    }
}
