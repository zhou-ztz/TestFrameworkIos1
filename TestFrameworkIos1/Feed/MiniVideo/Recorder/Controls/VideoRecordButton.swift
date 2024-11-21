//
//  VideoRecordButton.swift
//  Yippi
//
//  Created by Yong Tze Ling on 06/10/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

protocol RecordButtonDelegate: class {
    func buttonDidTapped()
    func buttonDidLongPressed(state: UIGestureRecognizer.State)
    func capture()
}

extension RecordButtonDelegate {
    func buttonDidTapped() {}
    func buttonDidLongPressed(state: UIGestureRecognizer.State) {}
    func capture() {}
}

class CameraButton: BaseRecordButton {
    
    override var buttonColor: UIColor {
        return .white
    }
    
    override func setupRecordButtonView() {
        super.setupRecordButtonView()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapToCapture)))
    }
    
    @objc func tapToCapture(_ sender: UITapGestureRecognizer) {
        delegate?.capture()
    }
}

class VideoRecordButton: BaseRecordButton {
    
    override func setupRecordButtonView() {
        super.setupRecordButtonView()
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedView(_:))))
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressView(_:))))
    }
    
    @objc func tappedView(_ sender: UITapGestureRecognizer) {
        delegate?.buttonDidTapped()
    }
    
    deinit {
        print("Deinit Video Recordbutton")
    }
}

@IBDesignable open class BaseRecordButton: UIView {
    var isRecording = false
    private var roundView: UIView?
    
    private var squareSide: CGFloat?

    private var shapeLayer: CAShapeLayer?
    
    private let externalCircleFactor: CGFloat = 0.1
    private let roundViewSideFactor: CGFloat = 0.8

    var buttonColor: UIColor {
        return TSColor.main.theme
    }

    weak var delegate: RecordButtonDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        setupRecordButtonView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.clear
        setupRecordButtonView()
    }

    func setupRecordButtonView() {
        drawExternalCircle()
        drawRoundedButton()
    }
    
    private func drawExternalCircle() {

        let radius = min(self.bounds.width, self.bounds.height)/2
        let lineWidth = externalCircleFactor*radius
        shapeLayer = CAShapeLayer()
        shapeLayer?.path = UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width/2,
                                                          y: self.bounds.size.height/2),
                                       radius: radius-lineWidth/2,
                                       startAngle: 0,
                                       endAngle: 2*CGFloat(Float.pi),
                                       clockwise: true).cgPath
        shapeLayer?.lineWidth = lineWidth
        shapeLayer?.fillColor = UIColor.clear.cgColor
        shapeLayer?.strokeColor = buttonColor.cgColor
        shapeLayer?.opacity = 0.45
        self.layer.addSublayer(shapeLayer!)
    }
    
    private func drawRoundedButton() {

        squareSide = roundViewSideFactor*min(self.bounds.width, self.bounds.height)

        roundView = UIView(frame: CGRect(x: self.frame.size.width/2-squareSide!/2,
                                         y: self.frame.size.height/2-squareSide!/2,
                                         width: squareSide!,
                                         height: squareSide!))
        roundView?.backgroundColor = buttonColor
        roundView?.layer.cornerRadius = squareSide!/2

        self.addSubview(roundView!)
    }
    
    private func recordButtonAnimation() -> CAAnimationGroup {

        let transformToStopButton = CABasicAnimation(keyPath: "cornerRadius")

        transformToStopButton.fromValue = !isRecording ? squareSide!/2: 10
        transformToStopButton.toValue = !isRecording ? 10:squareSide!/2

        let toSmallCircle = CABasicAnimation(keyPath: "transform.scale")

        toSmallCircle.fromValue = !isRecording ? 1: 0.65
        toSmallCircle.toValue = !isRecording ? 0.65: 1

        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [transformToStopButton, toSmallCircle]
        animationGroup.duration = 0.25
        animationGroup.fillMode = .both
        animationGroup.isRemovedOnCompletion = false

        return animationGroup
    }
    
    private func externalCircleAnimation() -> CABasicAnimation {
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = isRecording ? bigRingPath().cgPath : smallRingPath().cgPath
        animation.toValue = isRecording ? smallRingPath().cgPath : bigRingPath().cgPath
        animation.duration = 0.4
        
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        return animation
    }
    
    private func loopAnimation() -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "lineWidth")
        animation.duration = 0.7
        animation.fromValue = 4
        animation.toValue = 20
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.fillMode = .forwards
        return animation
    }
    
    private func bigRingPath() -> UIBezierPath {
        let radius = min(self.bounds.width, self.bounds.height)/2
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width/2,
                                               y: self.bounds.size.height/2),
                            radius: radius * 2,
                            startAngle: 0,
                            endAngle: 2*CGFloat(Float.pi),
                            clockwise: true)
    }
    
    private func smallRingPath() -> UIBezierPath {
        let radius = min(self.bounds.width, self.bounds.height)/2
        let lineWidth = externalCircleFactor*radius
        return UIBezierPath(arcCenter: CGPoint(x: self.bounds.size.width/2,
                                               y: self.bounds.size.height/2),
                            radius: radius-lineWidth/2,
                            startAngle: 0,
                            endAngle: 2*CGFloat(Float.pi),
                            clockwise: true)
    }
    
    @objc func longPressView(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began, .ended:
            self.roundView?.layer.add(self.recordButtonAnimation(), forKey: "")
            self.shapeLayer?.add(self.externalCircleAnimation(), forKey: "")
            if !isRecording {
                self.shapeLayer?.add(self.loopAnimation(), forKey: "ringAnimation")
            } else {
                self.shapeLayer?.removeAnimation(forKey: "ringAnimation")
            }
            isRecording = !isRecording
            delegate?.buttonDidLongPressed(state: sender.state)
        default:
            break
        }
    }

    // To be used when app goes to background
    // Advance animation and save recording
    public func endRecordingAnimation() {
        guard isRecording else {
            return
        }
        self.roundView?.layer.add(self.recordButtonAnimation(), forKey: "")
        self.shapeLayer?.add(self.externalCircleAnimation(), forKey: "")
        self.shapeLayer?.removeAnimation(forKey: "ringAnimation")
        isRecording = !isRecording
    }
    
    public func startRecordingAnimation() {
        self.roundView?.layer.add(self.recordButtonAnimation(), forKey: "")
        
        self.shapeLayer?.add(self.externalCircleAnimation(), forKey: "")
        
        if !isRecording {
            self.shapeLayer?.add(self.loopAnimation(), forKey: "ringAnimation")
        } else {
            self.shapeLayer?.removeAnimation(forKey: "ringAnimation")
        }
        
        isRecording = !isRecording
    }
    public func tapRecordingAnimationWithDuration(duration: TimeInterval) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { _ in
            UIView.animate(withDuration: 1.0, animations: {
                self.transform = CGAffineTransform.identity
            })
        }
    }
    override open func prepareForInterfaceBuilder() {
        self.backgroundColor = UIColor.clear
        setupRecordButtonView()
    }

}
