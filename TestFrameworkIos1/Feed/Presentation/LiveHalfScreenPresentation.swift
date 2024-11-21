//
//  LiveHalfScreenPresentation.swift
//  Yippi
//
//  Created by Yong Tze Ling on 15/04/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class HalfScreenPresentationController: UIPresentationController {
    var heightPercentage: CGFloat = 0.55
    var customStaticHeight: CGFloat? = nil
    var onDismiss: EmptyClosure? = nil
    
    private let background = UIView().configure {
        $0.backgroundColor =  UIColor.darkGray.withAlphaComponent(0.8)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        get {
            guard let parentView = containerView else {
                return .zero
            }
            
            if parentView.frame.width > parentView.frame.height {
                return CGRect(x: parentView.bounds.width - parentView.bounds.height, y: 0, width: parentView.bounds.height, height: parentView.bounds.height)
            } else {
                if let customHeight = customStaticHeight {
                    return CGRect(x: 0, y: parentView.bounds.height - customHeight, width: parentView.bounds.width, height: customHeight)
                } else {
                    return CGRect(x: 0, y: parentView.bounds.height * (1 - heightPercentage), width: parentView.bounds.width, height: parentView.bounds.height * heightPercentage)
                }
            }
        }
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if let frame = containerView?.frame, completed {
            background.frame = frame
            background.addTap { [weak self] _ in
                self?.onDismiss?()
                self?.presentedViewController.dismiss(animated: true, completion: nil)
            }
//            if presentedViewController is BEStickersViewController || presentedViewController is BEBaseViewController {
//                background.backgroundColor = .clear
//            }
            containerView?.insertSubview(background, at: 0)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            background.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }
    
    override var presentedView: UIView? {
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
        return presentedViewController.view
    }
}

class HalfScreenTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    private let duration: TimeInterval = 0.3
    var onDismissal: EmptyClosure?
    var heightPercentage: CGFloat = 0.55
    var customStaticHeight: CGFloat? = nil
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let halfScreenPresentationController = HalfScreenPresentationController(presentedViewController: presented, presenting: presenting)
        halfScreenPresentationController.heightPercentage = heightPercentage
        halfScreenPresentationController.customStaticHeight = customStaticHeight
        return halfScreenPresentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        switch interfaceOrientation {
        case .landscapeLeft, .landscapeRight:
            return LandscapePresentAnimator(duration: duration)
        default:
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        defer { onDismissal?() }
        let interfaceOrientation = UIApplication.shared.statusBarOrientation
        
        switch interfaceOrientation {
        case .landscapeLeft, .landscapeRight:
            return LandscapeDismissAnimator(duration: duration)
        default:
            return nil
        }
    }
}

class LandscapePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toView = transitionContext.viewController(forKey: .to) else {
            return
        }
        toView.view.frame = transitionContext.finalFrame(for: toView)
        
        let container = transitionContext.containerView
        container.addSubview(toView.view)
        
        let moveDistanceX = container.width - toView.view.width

        toView.view.frame.origin = CGPoint(x: container.width, y: 0)
        
        UIView.animate(withDuration: duration, delay: 0, animations: {
            toView.view.frame.origin = CGPoint(x: moveDistanceX, y: 0)
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}

class LandscapeDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let duration: TimeInterval
    
    init(duration: TimeInterval) {
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.viewController(forKey: .from) else {
            return
        }
        fromView.view.frame = transitionContext.finalFrame(for: fromView)
        let container = transitionContext.containerView
        container.addSubview(fromView.view)
        
        UIView.animate(withDuration: duration, delay: 0, animations: {
            fromView.view.frame.origin = CGPoint(x: container.width, y: 0)
        }) { finished in
            fromView.view.removeFromSuperview()
            transitionContext.completeTransition(finished)
        }
    }
}
