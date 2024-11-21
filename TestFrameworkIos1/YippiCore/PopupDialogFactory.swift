// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

public typealias DidEnterPasswordClosure = (String?) -> Void

@objc public protocol PopupDialogFactoryType {
    @objc func makeEnterPasswordDialog(buttonAction: DidEnterPasswordClosure?) -> UIViewController
}
