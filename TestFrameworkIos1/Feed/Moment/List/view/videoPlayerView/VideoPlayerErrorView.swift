//
//  VideoPlayerErrorView.swift
//  Yippi
//
//  Created by CC Teoh on 26/09/2019.
//  Copyright © 2019 Toga Capital. All rights reserved.
//

import UIKit


enum ALYPVErrorType : Int {
    case unknown = 0
    case retry = 1
    case replay = 2
    case pause = 3
    case stsExpired = 4
}

protocol VideoPlayerErrorViewDelegate: NSObjectProtocol {
    func onErrorViewClickedWith(type: ALYPVErrorType?)
}


private let AliyunPlayerViewErrorViewWidth: CGFloat = 220
private let AliyunPlayerViewErrorViewHeight: CGFloat = 120
private let AliyunPlayerViewErrorViewTextMarginTop: CGFloat = 30
private let ALYPVErrorButtonWidth: CGFloat = 82
private let ALYPVErrorButtonHeight: CGFloat = 30
private let ALYPVErrorButtonMarginLeft: CGFloat = 68
private let AliyunPlayerViewErrorViewRadius: CGFloat = 4

class VideoPlayerErrorView: UIView {
    
    weak var delegate: VideoPlayerErrorViewDelegate?

    var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textColor = UIColor.white
        textLabel.setFontSize(with: 14.0, weight: .bold)
        textLabel.textAlignment = NSTextAlignment.center
        textLabel.numberOfLines = 999
        return textLabel
    }()
    
    var button: UIButton = {
        let button = UIButton.init(type: .custom)
        button.setBackgroundImage(UIImage.set_image(named: "ic_error_btn"), for: .normal)
        button.setImage(UIImage.set_image(named: "ic_btn_refresh"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        button.titleLabel?.textAlignment = NSTextAlignment.center
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        button.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    var replayButton: UIButton = {
        let replayButton = UIButton()
        replayButton.setBackgroundImage(UIImage.set_image(named: "ic_btn_refresh"), for: .normal)
        replayButton.addTarget(self, action: #selector(onClick(sender:)), for: .touchUpInside)
        return replayButton
    }()

    var errorButtonEventType: String?
    var message: String?
    var type: ALYPVErrorType = .unknown
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private func commonInit() {
        addSubview(textLabel)
        addSubview(replayButton)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = AliyunPlayerViewErrorViewRadius
        let height = AliyunPlayerViewErrorViewHeight
        replayButton.frame = CGRect(x: 0, y: 0, width: Constants.VideoPlayerPlayButtonWidth, height: Constants.VideoPlayerPlayButtonHeight)
        replayButton.centerX = frame.size.width/2
        replayButton.centerY = frame.size.height/2

        textLabel.frame = CGRect(x: 0, y: AliyunPlayerViewErrorViewTextMarginTop, width: width, height: height)

    }
    
    func setMessage(message: String) {
        //TODO: add error message
//        print("message *** : \(message)")
//        textLabel.text = message
//        let infoRect = UIFont.sizeOfString(string: message, textLabelFont: textLabel.font, constrainedToWidth: AliyunPlayerViewErrorViewWidth)
//        textLabel.frame = CGRect(x: 0, y: frame.size.width / 2.0, width: width, height: infoRect.height)
        setNeedsLayout()
    }
    
    func setType(type: ALYPVErrorType) {
        self.type = type
        var string = ""
        switch(type) {
            case .unknown: string = "Retry"
            case .retry: string = "Retry"
            case .replay: string = "Replay"
            case .pause: string = "Play"
            case .stsExpired: string = "Retry"
            default: break
        }
        button.setTitle(string, for: .normal)
    }
    
    func showWithParentView(parent: UIView) {
        parent.isHidden = false
        parent.addSubview(self)
        
        center = CGPoint(x: parent.frame.size.width / 2, y: parent.frame.size.height / 2 )
        backgroundColor = UIColor.clear
    }
    
    func isShowing() -> Bool {
        return superview != nil
    }
    
    func dismiss() {
        removeFromSuperview()
    }
    
    @objc func onClick(sender: UIButton) {
        dismiss()
        if delegate != nil {
            delegate?.onErrorViewClickedWith(type: self.type)
        }
    }
    
}

extension UIFont {
    class func sizeOfString (string: String, textLabelFont: UIFont, constrainedToWidth width: CGFloat) -> CGSize {
        
        var dic: [NSAttributedString.Key : UIFont?]? = nil
        
        dic = [NSAttributedString.Key.font: textLabelFont]

        return NSString(string: string).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: dic,
            context: nil).size
    }
}
