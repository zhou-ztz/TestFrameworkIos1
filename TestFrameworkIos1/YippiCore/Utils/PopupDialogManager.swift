// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

@objcMembers
public class PopupDialogManager: NSObject {
    public static func presentEnterPasswordDialog(viewController: UIViewController, animated: Bool, completion: DidEnterPasswordClosure?) {
        let popup = DependencyContainer.shared.resolvePopupDialogFactory().makeEnterPasswordDialog(buttonAction: completion)
        viewController.present(popup, animated: true, completion: nil)
    }
}
