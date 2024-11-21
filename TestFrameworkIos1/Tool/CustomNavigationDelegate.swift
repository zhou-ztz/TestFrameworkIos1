//
//  CustomNavigationDelegate.swift
//  Yippi
//
//  Created by Yong Tze Ling on 16/12/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationDelegate: NSObject, UINavigationControllerDelegate {
    
    var isActive = true
    var interactionController: UIPercentDrivenInteractiveTransition?
    weak var current: UIViewController?
    var pushDestination: (() -> UIViewController?)?
    
    var beginPoint: CGPoint = .zero
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomNavigationAnimator(transitionType: operation)
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactionController
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        current = viewController
    }
}

extension CustomNavigationDelegate {
    // MARK:- Push
    
    func addPushInteractionController(to view: UIView, delegate: UIGestureRecognizerDelegate?) {
        let swipe = UIPanGestureRecognizer(target: self, action: #selector(handlePushGesture(_:)))
        swipe.delegate = delegate
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func handlePushGesture(_ gesture: UIPanGestureRecognizer) {
        guard isActive == true else { return }
        guard let pushDestination = pushDestination else { return }

        let position = gesture.translation(in: nil)
        let percentComplete = min(-position.x / gesture.view!.bounds.width, 1.0)
        
        switch gesture.state {
        case .began:
            self.beginPoint = position
            interactionController = UIPercentDrivenInteractiveTransition()
            guard let controller = pushDestination() else { fatalError("No push destination") }
            guard current?.navigationController?.viewControllers.contains(controller) == false else {
                return
            }
            current?.navigationController?.pushViewController(controller, animated: true)
            interactionController?.pause()

        case .changed:
            let dx = abs(beginPoint.x - position.x)
            let dy = abs(beginPoint.y - position.y) * 1.2
            
            if dx > dy {
                interactionController?.update(percentComplete)
            }

        case .ended, .cancelled:
            let dx = abs(beginPoint.x - position.x)
            let dy = abs(beginPoint.y - position.y) * 1.2
            
            print("dx : \(dx)")
            print("dy : \(dy)")
            print("current : \(current)")
            print("interaction : \(interactionController)")
            
            let speed = gesture.velocity(in: gesture.view)
            if (speed.x < 0 || (speed.x == 0 && percentComplete > 0.5)) && dx > dy {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil

        default:
            break
        }
    }
    
    // MARK: - Pop
    
    func addPopInteractionController(to view: UIView) {
        let swipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePopGesture(_:)))
        swipe.edges = [.left]
        view.addGestureRecognizer(swipe)
    }
    
    @objc private func handlePopGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let position = gesture.translation(in: gesture.view)
        let percentComplete = min(position.x / gesture.view!.bounds.width, 1)
        
        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            current?.navigationController?.popViewController(animated: true)
            
            print(current?.navigationController)
            
        case .changed:
            interactionController?.update(percentComplete)
            
        case .ended, .cancelled:
            let speed = gesture.velocity(in: gesture.view)
            if speed.x > 0 || (speed.x == 0 && percentComplete > 0.5) {
                interactionController?.finish()
            } else {
                interactionController?.cancel()
            }
            interactionController = nil
            
            
        default:
            break
        }
    }
    
    // MARK: - Right Edge
    
    func addEdgePushInteractionController(to view: UIView, delegate: UIGestureRecognizerDelegate?) {
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleSwipeFromRight(_:)))
        gesture.edges = .right
        gesture.delegate = delegate
        view.addGestureRecognizer(gesture)
    }
    
    @objc func handleSwipeFromRight(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let gestureView = gesture.view else {
            return
        }
        
        let percent = -gesture.translation(in: gestureView).x / gestureView.bounds.size.width
        
        switch gesture.state {
        case .began:
            interactionController = UIPercentDrivenInteractiveTransition()
            guard let pushDestination = pushDestination, let controller = pushDestination() else { fatalError("No push destination") }
            current?.navigationController?.pushViewController(controller, animated: true)
            
        case .changed:
            if let interactionController = self.interactionController {
                interactionController.update(percent)
            }
            
        case .cancelled:
            if let interactionController = self.interactionController {
                interactionController.cancel()
            }
            
        case .ended:
            if let interactionController = self.interactionController {
                if percent > 0.5 {
                    interactionController.finish()
                } else {
                    interactionController.cancel()
                }
                self.interactionController = nil
            }
            
        default:
            break
        }
    }
}


class CustomNavigationAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let transitionType: UINavigationController.Operation
    
    init(transitionType: UINavigationController.Operation) {
        self.transitionType = transitionType
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let inView   = transitionContext.containerView
        let toView   = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        var frame = inView.bounds
        
        switch transitionType {
        case .push:
            frame.origin.x = frame.size.width
            toView.frame = frame
            
            inView.addSubview(toView)
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.frame = inView.bounds
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        case .pop:
            toView.frame = frame
            inView.insertSubview(toView, belowSubview: fromView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                frame.origin.x = frame.size.width
                fromView.frame = frame
            }, completion: { finished in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        case .none:
            break
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return TimeInterval(UINavigationController.hideShowBarDuration)
    }
}
