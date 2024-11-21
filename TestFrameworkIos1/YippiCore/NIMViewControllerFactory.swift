//
//  NIMViewControllerFactory.swift
//  YippiCore
//
//  Created by Yong Tze Ling on 01/05/2019.
//  Copyright © 2019 Chew. All rights reserved.
//

import Foundation
import UIKit

/// SNS

@objc public protocol NIMViewControllerProtocol: NSObjectProtocol { }
extension NIMViewControllerProtocol where Self: UIViewController { }


@objc public protocol NIMViewControllerType: NIMViewControllerProtocol {
}

@objc public protocol NIMViewControllerFactoryType {
    
    @objc func makeSingleChatDetailViewController() -> NIMViewControllerType!
}
