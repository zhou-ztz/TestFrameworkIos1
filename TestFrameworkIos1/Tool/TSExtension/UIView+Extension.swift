//
//  UIView+Extension.swift
//  ThinkSNS +
//
//  Created by 小唐 on 12/07/2017.
//  Copyright © 2017 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import NIMSDK
import SwiftUI

extension View {
    
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
    
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
    
    func onAnimationCompleted<Value: VectorArithmetic>(for value: Value, completion: @escaping () -> Void) -> ModifiedContent<Self, AnimationCompletionObserverModifier<Value>> {
        return modifier(AnimationCompletionObserverModifier(observedValue: value, completion: completion))
    }
    
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

struct AnimationCompletionObserverModifier<Value>: AnimatableModifier where Value: VectorArithmetic {

    var animatableData: Value {
        didSet {
            notifyCompletionIfFinished()
        }
    }

    private var targetValue: Value

    private var completion: () -> Void

    init(observedValue: Value, completion: @escaping () -> Void) {
        self.completion = completion
        self.animatableData = observedValue
        targetValue = observedValue
    }

    private func notifyCompletionIfFinished() {
        guard animatableData == targetValue else { return }

        DispatchQueue.main.async {
            self.completion()
        }
    }

    func body(content: Content) -> some View {
        return content
    }
}


extension UIView {

    /// Returns transform for translation and scale difference from self and given view.
    func convertScaleAndTranslation(to view: UIView) -> CGAffineTransform {
        return CGAffineTransform.from(frame, to: convert(frame, to: view))
    }
    
    func addBottomRoundedEdge(desiredCurve: CGFloat?) {
        let offset: CGFloat = self.frame.width / desiredCurve!
        let bounds: CGRect = self.bounds
        
        let rectBounds: CGRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: bounds.size.height / 2)
        let rectPath: UIBezierPath = UIBezierPath(rect: rectBounds)
        let ovalBounds: CGRect = CGRect(x: bounds.origin.x - offset / 2, y: bounds.origin.y, width: bounds.size.width + offset, height: bounds.size.height)
        let ovalPath: UIBezierPath = UIBezierPath(ovalIn: ovalBounds)
        rectPath.append(ovalPath)
        
        // Create the shape layer and set its path
        let maskLayer: CAShapeLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = rectPath.cgPath
        
        // Set the newly created shape layer as the mask for the view's layer
        self.layer.mask = maskLayer
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor, view: UIView) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = view.bounds

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension CGAffineTransform {

    /// Returns transform for translation and scale difference from two given rects.
    static func from(_ from: CGRect, to: CGRect) -> CGAffineTransform {
        let sx  = to.size.width / from.size.width
        let sy  = to.size.height / from.size.height

        let scale = CGAffineTransform(scaleX: sx, y: sy)

        let heightDiff = from.size.height - to.size.height
        let widthDiff = from.size.width - to.size.width

        let dx = to.origin.x - widthDiff / 2 - from.origin.x
        let dy = to.origin.y - heightDiff / 2 - from.origin.y
        let trans = CGAffineTransform(translationX: dx, y: dy)

        return scale.concatenating(trans)
    }
}

extension UIView {
    /// 带背景色的初始化
    convenience init(bgColor: UIColor) {
        self.init(frame: CGRect.zero)
        self.backgroundColor = bgColor
    }

    /// 带圆角的普通视图(可附加边框border)
    @objc convenience init(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor = UIColor.clear) {
        self.init(frame: CGRect.zero)
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor.cgColor
    }
}

extension UIView {
    
    func addBottomRoundedEdge(curvedPercent: CGFloat = 0.0, width: CGFloat = UIScreen.main.bounds.width) {
        let arrowPath = UIBezierPath()
        let width = width
        let rect = self.bounds
        arrowPath.move(to: CGPoint(x:width, y:0))
        arrowPath.addLine(to: CGPoint(x:width, y:rect.maxY - curvedPercent))
        arrowPath.addQuadCurve(to: CGPoint(x:0, y:rect.maxY - curvedPercent), controlPoint: CGPoint(x:width/2, y:rect.maxY))
        arrowPath.addLine(to: CGPoint(x:0, y:0))
        arrowPath.close()
        
        let shapeLayer = CAShapeLayer(layer: self.layer)
        shapeLayer.path = arrowPath.cgPath
        shapeLayer.frame = self.bounds
        shapeLayer.masksToBounds = true
        self.layer.mask = shapeLayer
    }
    
    func bindToSafeEdges(inset: ConstraintInsetTarget = 0) {
        self.snp.makeConstraints {
            if #available(iOS 11.0, *) {
                $0.right.left.top.bottom.equalToSuperview().inset(inset)
            } else {
                $0.edges.equalToSuperview().inset(inset)
            }
        }
    }
        
    func bindToEdges(inset: ConstraintInsetTarget = 0) {
        self.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(inset)
        }
    }

    func getRootView() -> UIView {
        if let _superview = self.superview {
            return _superview.getRootView()
        } else {
            return self
        }
    }
    
    static func getRotationAngleOnCurrentOrientation() -> Double {
        let orientation = UIDevice.current.orientation
        
        let angle: Double
        switch(orientation) {
            case .landscapeRight:
                angle = -90 * Double.pi / 180
            
            case .landscapeLeft:
                angle = 90 * Double.pi / 180
            
        default: angle = 0
        }
        
        return angle
    }
    
    func hover(_ duration: CFTimeInterval = 0.45, value: CGFloat = 5.0) {
        let hover = CABasicAnimation(keyPath: "position")
        hover.isAdditive = true
        hover.fromValue = NSValue(cgPoint: CGPoint.zero)
        hover.toValue = NSValue(cgPoint: CGPoint(x: 0.0, y: -value))
        hover.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        hover.autoreverses = true
        hover.duration = duration
        hover.repeatCount = Float.infinity
        self.layer.add(hover, forKey: "hoverAnimation")
    }
    
    /// 移除所有子控件
    func removeAllSubViews() -> Void {
        for subView in self.subviews {
            subView.removeFromSuperview()
        }
    }
}

extension UIView {
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = type(of: self).description().components(separatedBy: ".").last!
        let nib = UINib(nibName: nibName, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    /// 获取付费占位图
    func getPayLockedImage() -> UIImage? {
        let isSquare = frame.width == frame.height
        let lockImage = UIImage.set_image(named: "IMG_ico_lock")!
        let backImage = UIImage.set_image(named: isSquare ? "IMG_pic_locked_square_bg" : "IMG_pic_locked_bg")!

        let scale = UIScreen.main.scale
        let size = CGSize(width: frame.width * scale, height: frame.height * scale)
        UIGraphicsBeginImageContext(size)
        backImage.draw(in: CGRect(origin: CGPoint.zero, size: size))
        lockImage.draw(in: CGRect(origin: CGPoint(x: (size.width - lockImage.size.width * scale) / 2, y: (size.height - lockImage.size.height * scale) / 2), size: CGSize(width: lockImage.size.width * scale, height: lockImage.size.height * scale)))
        let mixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return mixedImage
    }
}

// MARK: - 四周线条的简便添加

public enum LineViewSide {
    // in 内侧
    case inBottom   // 内底(线条在view内的底部)
    case inTop      // 内顶
    case inLeft     // 内左
    case inRight    // 内右
    // out 外侧
    case outBottom  // 外底(线条在view外的底部)
    case outTop     // 外顶
    case outLeft    // 外左
    case outRight   // 外右
}

@IBDesignable
extension UIView {
    /**
     给视图添加线条
     
     - parameter side:      线条在视图的哪侧(内外 + 上下左右)
     - parameter color:     线条颜色
     - parameter thickness: 线条厚度(水平方向为高度，竖直方向为宽度)
     - parameter margin1:   水平方向表示左侧间距，竖直方向表示顶部间距
     - parameter margin2:             右侧间距            底部间距
     */
    @discardableResult
    func addLineWithSide(_ side: LineViewSide, color: UIColor, thickness: CGFloat, margin1: CGFloat, margin2: CGFloat) -> UIView {
        let lineView = UIView()
        self.addSubview(lineView)
        // 配置
        lineView.backgroundColor = color
        lineView.snp.makeConstraints { (make) in
            var horizontalFlag = true    // 线条方向标记
            switch side {
            // 线条为水平方向
            case .inBottom:
                make.bottom.equalTo(self)
                break
            case .inTop:
                make.top.equalTo(self)
                break
            case .outBottom:
                make.top.equalTo(self.snp.bottom)
                break
            case .outTop:
                make.bottom.equalTo(self.snp.bottom)
                break
            // 线条方向为竖直方向
            case .inLeft:
                horizontalFlag = false
                make.left.equalTo(self)
                break
            case .inRight:
                horizontalFlag = false
                make.right.equalTo(self)
                break
            case .outLeft:
                horizontalFlag = false
                make.right.equalTo(self.snp.left)
                break
            case .outRight:
                horizontalFlag = false
                make.left.equalTo(self.snp.right)
                break
            }
            // 约束
            if horizontalFlag   // 线条方向 为 水平方向
            {
                make.left.equalTo(self).offset(margin1)
                make.right.equalTo(self).offset(-margin2)
                make.height.equalTo(thickness)
            } else                // 线条方向 为 竖直方向
            {
                make.top.equalTo(self).offset(margin1)
                make.bottom.equalTo(self).offset(-margin2)
                make.width.equalTo(thickness)
            }
        }
        return lineView
    }

    @IBInspectable
    var cornerRadiusXcode: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            clipsToBounds = true
        }
    }
    
    @IBInspectable
    var shadowRadiusXcode: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }
    @IBInspectable
    var shadowOffsetXcode : CGSize{
        
        get{
            return layer.shadowOffset
        }set{
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColorXcode : UIColor?{
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var shadowOpacityXcode : Float {
        
        get{
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable 
    var shadowOffsetWidthXcode: CGFloat {
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset.width = newValue
        }
    }
    
    @IBInspectable 
    var shadowOffsetHeightXcode: CGFloat {
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }
    
//    @IBInspectable
//    var shadowPathXcode: Bool {
//        get {
//            return layer.shadowPath != nil
//        }
//        set {
//            if newValue {
//                layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//            } else {
//                layer.shadowPath = nil
//            }
//        }
//    }
//    
//    // Automatically update shadow when bounds change
//    open override func layoutSubviews() {
//        super.layoutSubviews()
//        if shadowPath {
//            layer.shadowPath = UIBezierPath(rect: bounds).cgPath
//        }
//    }
}

// Handle DeepLinks
extension UIView {
    func deeplink(urlString: String, isDismiss: Bool = false) {
        guard let url = URL(string: urlString) else {
            return
        }
        guard let parentVC = self.parentViewController else {
            return
        }
        TSUtil.pushURLDetail(url: url, currentVC: parentVC, isDismiss: isDismiss)
   }
}

private var badgeKey: UInt8 = 0

public extension UIView {
    /// duration in seconds
    func pauseInteraction(for duration: Double) {
        
        self.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isUserInteractionEnabled = true
        }
    }

    func removeGestures() {
        guard let gestures = self.gestureRecognizers else { return }
        
        for gesture in gestures {
            self.removeGestureRecognizer(gesture)
        }
    }
    
    func dropShadow(shadowColor: UIColor = UIColor.black, opacity: Float = 0.3, height: CGFloat = 3.0, shadowRadius: CGFloat = 4.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowRadius = shadowRadius
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
    func makeHidden() {
        self.isHidden = true
    }
    
    func makeVisible() {
        self.isHidden = false
    }
    
    func applyBorder(color: UIColor = UIColor.clear, width: CGFloat = 0.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func borders(for edges:[UIRectEdge], width:CGFloat = 1, color: UIColor = .black) {
        if edges.contains(.all) {
            layer.borderWidth = width
            layer.borderColor = color.cgColor
        } else {
            let allSpecificBorders:[UIRectEdge] = [.top, .bottom, .left, .right]

            for edge in allSpecificBorders {
                if let v = viewWithTag(Int(edge.rawValue)) {
                    v.removeFromSuperview()
                }

                if edges.contains(edge) {
                    let v = UIView()
                    v.tag = Int(edge.rawValue)
                    v.backgroundColor = color
                    v.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(v)

                    var horizontalVisualFormat = "H:"
                    var verticalVisualFormat = "V:"

                    switch edge {
                    case UIRectEdge.bottom:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "[v(\(width))]-(0)-|"
                    case UIRectEdge.top:
                        horizontalVisualFormat += "|-(0)-[v]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v(\(width))]"
                    case UIRectEdge.left:
                        horizontalVisualFormat += "|-(0)-[v(\(width))]"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    case UIRectEdge.right:
                        horizontalVisualFormat += "[v(\(width))]-(0)-|"
                        verticalVisualFormat += "|-(0)-[v]-(0)-|"
                    default:
                        break
                    }

                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: horizontalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                    self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: verticalVisualFormat, options: .directionLeadingToTrailing, metrics: nil, views: ["v": v]))
                }
            }
        }
    }
    
    func roundCorner(_ radius: CGFloat = 5.0) {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = radius
    }
    
    func circleCorner() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func roundCornerWithCorner(_ corners: UIRectCorner, radius: CGFloat, fillColor: UIColor, shadow: Bool = true) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        mask.fillColor = fillColor.cgColor
        if shadow {
            mask.shadowColor = UIColor.darkGray.cgColor
            mask.shadowPath = mask.path
            mask.shadowOffset = CGSize(width: 1.0, height: 1.0)
            mask.shadowOpacity = 0.5
            mask.shadowRadius = 7
        }
        
        self.layer.mask = mask
        //        self.layer.insertSublayer(mask, at: 0)
    }
    
     func presentView(view: UIView, animated: Bool, complete: () -> ()) {
        if self.window == nil {
            return
        }
        
        self.window?.addSubview(view)
        if animated {
            self.doAlertAnimate(complete: nil)
        } else {
            view.center = self.window!.center
        }
     }
        
    func doAlertAnimate(complete: (() -> ())?) {
        let bounds = self.bounds
        let scaleAnimation = CABasicAnimation(keyPath: "bounds")
        scaleAnimation.duration = 0.25
        scaleAnimation.fromValue = CGRect(x: 0, y: 0, width: 1, height: 1)
        scaleAnimation.toValue = bounds
        
        let moveAnimation = CABasicAnimation(keyPath: "position")
        moveAnimation.duration = 0.25
        moveAnimation.fromValue = superview?.convert(center, to: nil)
        moveAnimation.toValue = window?.center
        
        let group = CAAnimationGroup()
        group.beginTime = CACurrentMediaTime()
        group.duration = 0.25
        group.animations = [scaleAnimation,moveAnimation]
        group.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        group.fillMode = CAMediaTimingFillMode.forwards
        group.isRemovedOnCompletion = false
        group.autoreverses = false
        
        hidAllSubView(view: self)
        
        layer.add(group, forKey: "groupAnimationAlert")
        
        weak var wself = self
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() +  .seconds(1), execute: {
            guard let self = wself else { return }
            self.layer.bounds = bounds
            self.layer.position = self.superview!.center
            self.showAllSubview(view: self)
            complete?()
        })
    }
    
    func hidAllSubView(view: UIView) {
        for subView in view.subviews {
            subView.isHidden = true
        }
    }
    
    func showAllSubview(view: UIView) {
        for subView in view.subviews {
            subView.isHidden = false
        }
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat = 8) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.frame = bounds
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    
    private static let kRotationAnimationKey = "rotationanimationkey"
    
    func rotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func counterRotate(duration: Double = 1) {
        if layer.animation(forKey: UIView.kRotationAnimationKey) == nil {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            
            rotationAnimation.fromValue = 0.0
            rotationAnimation.toValue = -Float.pi * 2.0
            rotationAnimation.duration = duration
            rotationAnimation.repeatCount = Float.infinity
            
            layer.add(rotationAnimation, forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func stopRotating() {
        if layer.animation(forKey: UIView.kRotationAnimationKey) != nil {
            layer.removeAnimation(forKey: UIView.kRotationAnimationKey)
        }
    }
    
    func getImage() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let ctx: CGContext = UIGraphicsGetCurrentContext()!
        self.layer.render(in: ctx)
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }
}

public extension UIStackView {
    func removeAllArrangedSubviews() {
        self.subviews.forEach { (view) in
            view.removeFromSuperview()
            self.removeArrangedSubview(view)
            
        }
    }
    
    func customize(color: UIColor = .clear, radiusSize: CGFloat = 0) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = radiusSize
        subView.layer.masksToBounds = true
        subView.clipsToBounds = true
        insertSubview(subView, at: 0)
    }
}

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    func saveImage(name: String) -> String {
        let fileManager: FileManager = FileManager.default
        let dir = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        guard let data: Data = self.jpegData(compressionQuality: 1.0) else { return String.empty }
        
        let fullPath = dir.appendingPathComponent("ImageCache")
        
        if fileManager.fileExists(atPath: fullPath.relativePath) == false {
            try! fileManager.createDirectory(atPath: fullPath.relativePath, withIntermediateDirectories: true, attributes: nil)
        }
        
        let filePath = fullPath.appendingPathComponent(name).appendingPathExtension("jpg")
        
        try! data.write(to: URL(fileURLWithPath: filePath.relativePath), options: .atomic)
        
        return filePath.relativePath
    }
    
    class func loadImageFromDocumentsDirectory(for path: String) -> UIImage? {
        guard let image = UIImage(contentsOfFile: path) else { return nil }
        return image
    }
    
    fileprivate func normalizedImage() -> UIImage {
        if (self.imageOrientation == UIImage.Orientation.up) {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        self.draw(in: rect)
        
        let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
}

extension UIButton {
    public var badge: UIView {
        get {
            return associatedObject(base: self, key: &badgeKey) {
                let badgeview = UIView()
                badgeview.backgroundColor = AppTheme.red
                return badgeview
            }
        }
        set {
            associateObject(base: self, key: &badgeKey, value: newValue)
        }
    }
    
    public func addBadge() {
        guard badge.superview == nil else {
            self.bringSubviewToFront(badge)
            self.badge.isHidden = false
            return
        }
        
        self.addSubview(badge)
        badge.snp.makeConstraints { (make) in
            make.height.width.equalTo(6)
            make.top.right.equalToSuperview().inset(5)
        }
        
        badge.roundCorner(3)
    }
    
    public func addBadgeProfile() {
        guard badge.superview == nil else {
            self.bringSubviewToFront(badge)
            self.badge.isHidden = false
            return
        }
        
        self.addSubview(badge)
        badge.snp.makeConstraints { (make) in
            make.height.width.equalTo(6)
            make.top.equalTo(5)
            make.right.equalTo(0)
        }
        
        badge.roundCorner(3)
    }
    
    public func removeBadge() {
        badge.removeFromSuperview()
    }
}

extension UIToolbar {
    func setToolbarHidden(_ hidden: Bool) {
        if hidden == false {
            self.isHidden = hidden
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 1.0
            }) { finished in
            }
        } else {
            UIView.animate(withDuration: 0.5, animations: {
                self.alpha = 0.0
            }) { finished in
                self.isHidden = hidden
            }
        }
    }
}

extension NIMMessage {
//    open override func isEqual(_ object: Any?) -> Bool {
//        guard let object = object as? NIMMessage else {
//            return false
//        }
//        return object.messageId == self.messageId
//    }
    
    var commentId: Int? {
        get {
            if let ext = self.remoteExt, let commentId = ext["comment_id"] as? Int {
                return commentId
            } else {
                return nil
            }
        }
    }
    
    var nickName: String {
        get {
            if let ext = self.remoteExt, let nickname = ext["nickname"] as? String {
                return nickname
            } else {
                return NIMSDKManager.shared.getDisplayName(from: self)
            }
        }
    }
    
    var liveCommentContent: String {
        get {
            switch self.messageType {
            case .custom:
                if let object = self.messageObject as? NIMCustomObject, let attachment = object.attachment as? IMStickerAttachment {
                    return attachment.chartletId
                } else {
                    return ""
                }
            default:
                return self.text ?? ""
            }
        }
    }
}


