//
//  TSFontExtension.swift
//  ThinkSNSPlus
//
//  Created by HeHuaJun on 2018/10/22.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    /// 自定义文字
    class func systemMediumFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Medium", size: ofSize)!
    }
    
    class func systemRegularFont(ofSize: CGFloat) -> UIFont {
        return UIFont(name: "PingFangSC-Regular", size: ofSize)!
    }
}
