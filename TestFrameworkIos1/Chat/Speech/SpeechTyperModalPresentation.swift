//
//  SpeechTyperModalPresentation.swift
//  Yippi
//
//  Created by CC Teoh on 26/07/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

public final class Easing: UICubicTimingParameters {
    convenience init(_ c1x: CGFloat, _ c1y: CGFloat, _ c2x: CGFloat, _ c2y: CGFloat) {
        self.init(controlPoint1: CGPoint(x: c1x, y: c1y), controlPoint2: CGPoint(x: c2x, y: c2y))
    }

    public static let linear =         Easing(animationCurve: .linear)
    public static let easeIn =         Easing(animationCurve: .easeIn)
    public static let easeOut =        Easing(animationCurve: .easeOut)
    public static let easeInOut =      Easing(animationCurve: .easeInOut)
    public static let easeInSine =     Easing(0.47, 0, 0.745, 0.715)
    public static let easeOutSine =    Easing(0.39, 0.575, 0.565, 1)
    public static let easeInOutSine =  Easing(0.455, 0.03, 0.515, 0.955)
    public static let easeInQuad =     Easing(0.55, 0.085, 0.68, 0.53)
    public static let easeOutQuad =    Easing(0.25, 0.46, 0.45, 0.94)
    public static let easeInOutQuad =  Easing(0.455, 0.03, 0.515, 0.955)
    public static let easeInCubic =    Easing(0.55, 0.055, 0.675, 0.19)
    public static let easeOutCubic =   Easing(0.215, 0.61, 0.355, 1)
    public static let easeInOutCubic = Easing(0.645, 0.045, 0.355, 1)
    public static let easeInQuart =    Easing(0.895, 0.03, 0.685, 0.22)
    public static let easeOutQuart =   Easing(0.165, 0.84, 0.44, 1)
    public static let easeInOutQuart = Easing(0.77, 0, 0.175, 1)
    public static let easeInQuint =    Easing(0.755, 0.05, 0.855, 0.06)
    public static let easeOutQuint =   Easing(0.23, 1, 0.32, 1)
    public static let easeInOutQuint = Easing(0.86, 0, 0.07, 1)
    public static let easeInExpo =     Easing(0.95, 0.05, 0.795, 0.035)
    public static let easeOutExpo =    Easing(0.19, 1, 0.22, 1)
    public static let easeInOutExpo =  Easing(1, 0, 0, 1)
    public static let easeInCirc =     Easing(0.6, 0.04, 0.98, 0.335)
    public static let easeOutCirc =    Easing(0.075, 0.82, 0.165, 1)
    public static let easeInOutCirc =  Easing(0.785, 0.135, 0.15, 0.86)
    public static let easeInBack =     Easing(0.6, -0.28, 0.735, 0.045)
    public static let easeOutBack =    Easing(0.175, 0.885, 0.32, 1.275)
    public static let easeInOutBack =  Easing(0.68, -0.55, 0.265, 1.55)
}

public class Animator: UIViewPropertyAnimator {
    convenience init(duration: TimeInterval, easing: Easing) {
        self.init(duration: duration, timingParameters: easing)
    }
}


public class PopupContainerWindow: UIWindow {
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event), view != self {
            return view
        }
        return nil
    }
}

public class PopupWindowManager {
    public var popupContainerWindow: PopupContainerWindow?
    public static let shared = PopupWindowManager()

    public func changeKeyWindow(rootViewController: UIViewController?, height: CGFloat = 0.0, animated: Bool = true) {
        if let rootViewController = rootViewController {
            popupContainerWindow = PopupContainerWindow()
            guard let popupContainerWindow = popupContainerWindow, rootViewController is SpeechTyperViewController else { return }
            popupContainerWindow.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: height)
            popupContainerWindow.makeKeyAndVisible()
            popupContainerWindow.backgroundColor = .white
            popupContainerWindow.windowLevel = UIWindow.Level.statusBar + 1
            popupContainerWindow.rootViewController = rootViewController
            
            UIView.animate(withDuration: 0.2, animations: {
                popupContainerWindow.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - height, width: UIScreen.main.bounds.width, height: height)
            })
        } else {
            if animated == true {
                UIView.animate(withDuration: 0.2, animations: {
                    self.popupContainerWindow?.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: height)
                }, completion: { (completed) in
                    self.popupContainerWindow?.rootViewController = nil
                    self.popupContainerWindow = nil
                    UIApplication.shared.keyWindow?.makeKeyAndVisible()
                })
            } else {
                self.popupContainerWindow?.rootViewController = nil
                self.popupContainerWindow = nil
                UIApplication.shared.keyWindow?.makeKeyAndVisible()
            }
        }
    }
}

// MARK: - Customized UIViewController Presentation
protocol CustomPresentable: UIViewController {
    var dismissalHandlingScrollView: UIScrollView? { get }
    var transitionDelegate: UIViewControllerTransitioningDelegate? { set get }
}

extension CustomPresentable {
    
    typealias ScaleChangeHandler = (_ success:Bool) -> Void

    var dismissalHandlingScrollView: UIScrollView? { nil }
    
    func maximizeToFullScreen(completion: ScaleChangeHandler) {
        
        if let presentation = presentationController as? PresentationController {
            presentation.isCollapsed = false
            presentation.changeScale(to: .expanded)
            completion(true)
        }
        completion(false)
    }
    
    func minimizeToHalfScreen(completion: ScaleChangeHandler) {
        if let presentation = presentationController as? PresentationController {
            presentation.isCollapsed = true
            presentation.changeScale(to: .normal)
            completion(true)
        }
        completion(false)
    }
}

class PresentationController: UIPresentationController {
    
    var state: ModalScaleState = .normal
    var frameHeight: CGFloat = 0.0
    var collapsedFrameHeight: CGFloat = 0.0
    var isCollapsed: Bool = true
    
    func changeScale(to state: ModalScaleState) {

        if isCollapsed {
            collapsedFrameHeight = frameHeight
        }
        
        if let presentedView = UIApplication.shared.keyWindow, let containerView = UIApplication.shared.windows.first {
            UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlUp, animations: { () -> Void in
                presentedView.frame = containerView.frame
                let containerFrame = containerView.frame
                let halfFrame = CGRect(origin: CGPoint(x: 0, y: containerFrame.height - self.collapsedFrameHeight),
                                       size: CGSize(width: containerFrame.width, height: self.collapsedFrameHeight))
                let frame = state == .expanded ? containerView.frame : halfFrame
                presentedView.frame = frame
            }, completion: { (isFinished) in
                self.state = state
            })
        }
    }
}

class TransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewHeight: CGFloat = 0
    
    init(height: CGFloat) {
        self.viewHeight = height
        super.init()
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.frameHeight = self.viewHeight
        return presentationController
    }
}
