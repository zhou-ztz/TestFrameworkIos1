//
//  Configure.swift
//  Yippi
//
//  Created by Francis Yeap on 5/2/19.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

public protocol Then {}

extension Then {
    @discardableResult
    public func configure(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }

    @discardableResult
    public func build(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
    
}

extension NSObject: Then {}
extension UIView: Then {}
