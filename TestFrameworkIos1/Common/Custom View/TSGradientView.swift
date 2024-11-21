//
//  TSGradientView.swift
//  Yippi
//
//  Created by Francis Yeap on 29/01/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

enum GradientDirection {
    case horizontal, vertical, diagonal
}


@IBDesignable
class Gradient: UIView {
    
    override class var layerClass: AnyClass {
      return CAGradientLayer.self
    }

    // the gradient start colour
    @IBInspectable var startColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    // the gradient end colour
    @IBInspectable var endColor: UIColor? {
        didSet {
            updateGradient()
        }
    }

    // the gradient angle, in degrees anticlockwise from 0 (east/right)
    @IBInspectable var angle: CGFloat = 270 {
        didSet {
            updateGradient()
        }
    }

    // the gradient layer
    lazy var gradient: CAGradientLayer = {
        if let gradientLayer = self.layer as? CAGradientLayer {
            return gradientLayer
        }
        return CAGradientLayer()
    }()

    // initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        installGradient()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        installGradient()
    }
        
    // Create a gradient and install it on the layer
    private func installGradient() {
        // if there's already a gradient installed on the layer, remove it
//        if let gradient = self.gradient {
//            gradient.removeFromSuperlayer()
//        }
//        let gradient = createGradient()
//        self.layer.addSublayer(gradient)
//        self.gradient = gradient
    }

    // Update an existing gradient
    private func updateGradient() {
        let startColor = self.startColor ?? UIColor.clear
        let endColor = self.endColor ?? UIColor.clear
        gradient.colors = [startColor.cgColor, startColor.toColor(endColor, percentage: 30).cgColor, startColor.toColor(endColor, percentage: 60).cgColor, endColor.cgColor]
        gradient.locations = [0.0, 0.4, 0.75, 1]
        let (start, end) = gradientPointsForAngle(self.angle)
        gradient.startPoint = start
        gradient.endPoint = end
    }

    // create gradient layer
    private func createGradient() -> CAGradientLayer {
        
        gradient.frame = self.bounds
        return gradient
    }

    // create vector pointing in direction of angle
    private func gradientPointsForAngle(_ angle: CGFloat) -> (CGPoint, CGPoint) {
        // get vector start and end points
        let end = pointForAngle(angle)
        //let start = pointForAngle(angle+180.0)
        let start = oppositePoint(end)
        // convert to gradient space
        let p0 = transformToGradientSpace(start)
        let p1 = transformToGradientSpace(end)
        return (p0, p1)
    }

    // get a point corresponding to the angle
    private func pointForAngle(_ angle: CGFloat) -> CGPoint {
        // convert degrees to radians
        let radians = angle * .pi / 180.0
        var x = cos(radians)
        var y = sin(radians)
        // (x,y) is in terms unit circle. Extrapolate to unit square to get full vector length
        if (fabs(x) > fabs(y)) {
            // extrapolate x to unit length
            x = x > 0 ? 1 : -1
            y = x * tan(radians)
        } else {
            // extrapolate y to unit length
            y = y > 0 ? 1 : -1
            x = y / tan(radians)
        }
        return CGPoint(x: x, y: y)
    }

    // transform point in unit space to gradient space
    private func transformToGradientSpace(_ point: CGPoint) -> CGPoint {
        // input point is in signed unit space: (-1,-1) to (1,1)
        // convert to gradient space: (0,0) to (1,1), with flipped Y axis
        return CGPoint(x: (point.x + 1) * 0.5, y: 1.0 - (point.y + 1) * 0.5)
    }

    // return the opposite point in the signed unit square
    private func oppositePoint(_ point: CGPoint) -> CGPoint {
        return CGPoint(x: -point.x, y: -point.y)
    }

    // ensure the gradient gets initialized when the view is created in IB
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        installGradient()
        updateGradient()
    }
}

class TSGradientView: UIView, CAAnimationDelegate  {
    
    let gradientLayer = CAGradientLayer()
    var colors: [UIColor] = [.clear, .clear] {
        didSet {
            self.setGradientsAnimations()
            self.configureColors()
            self.layoutSubviews()
        }
    }
    
    var isLoading = false
    var direction: GradientDirection = .horizontal
    
    private var gradientSet: [[CGColor]] = []
    
    private var currentGradient: Int = 0
    private var animationDuration: CGFloat = 0.45
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init(colors: [UIColor], direction: GradientDirection = .horizontal) {
        super.init(frame: .zero)
        self.colors = colors
        self.direction = direction
        setGradientsAnimations()
        configureColors()
    }
    
    private func setGradientsAnimations() {
        guard colors.count > 0 else { return }
        gradientSet = []
        var currentGradient = colors
        for _ in 0..<colors.count {
            gradientSet.append(currentGradient.compactMap { $0.cgColor })
            currentGradient.shiftRight()
        }
    }
    
    func configureColors() {
        guard colors.count > 0 else { return  }
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors.compactMap { $0.cgColor }
        
        var locations = [NSNumber]()
        switch colors.count {
        case ...0: locations = []
        case 0, 1: locations = []
        default:
            let divider = 1.0 / Double(colors.count)
            var initialLocation = 0.0
            for _ in 0..<colors.count {
                locations.append(NSNumber(value: initialLocation))
                initialLocation += divider
            }
        }
        
        switch direction {
        case .horizontal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            
        case .vertical:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0, y: 1)
            
        case .diagonal:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        }
        
        gradientLayer.locations = locations
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        // resize your layers based on the view's new frame
        super.layoutSubviews()
        self.gradientLayer.frame = self.bounds
    }
    
    func animate() {
        layoutIfNeeded()
        
        if currentGradient < (gradientSet.count-1) {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = CFTimeInterval(animationDuration)
        animation.toValue = gradientSet[currentGradient]
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        gradientLayer.add(animation, forKey: "colorChange")
    }

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if isLoading == true, flag == true {
            gradientLayer.colors  = gradientSet[currentGradient]
            animate()
        }
    }
    func start(duration: CGFloat = 0.45)  {
        isLoading = true
        animationDuration = duration
        animate()
    }
    
    func stop()  {
        isLoading = false
        self.gradientLayer.removeAllAnimations()
    }
    
}


extension Array {
    mutating func shiftRight() {
        if let obj = self.popLast(){
            self.insert(obj, at: 0)
        }
    }
}
