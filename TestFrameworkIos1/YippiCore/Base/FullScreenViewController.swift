//
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

open class FullScreenViewController: UIViewController {
    private var isStatusBarHidden: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
            updateSafeArea()
        }
    }

    public func setStatusBarHidden(_ hidden: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
                self.isStatusBarHidden = hidden
                self.view.layoutIfNeeded()
            }
        } else {
            self.isStatusBarHidden = hidden
            view.layoutIfNeeded()
        }
    }

    private func updateSafeArea() {
        // Notes: Checking has displays safearea or not.
        if #available(iOS 11.0, *) {
            if UIApplication.shared.windows.first?.safeAreaInsets == UIEdgeInsets.zero {
                additionalSafeAreaInsets.top = -20.0
            }
        }
    }

    open override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }

    open override var prefersStatusBarHidden: Bool {
        return isStatusBarHidden || super.prefersStatusBarHidden
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarHidden(true, animated: animated)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        setStatusBarHidden(false, animated: animated)
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

}
