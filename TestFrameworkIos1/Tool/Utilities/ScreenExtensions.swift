//
//  ScreenExtensions.swift
//  Yippi
//
//  Created by Francis Yeap on 5/4/19.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}

extension UIScreen {
    var minEdge: CGFloat {
        return UIScreen.main.bounds.minEdge
    }
}
