//
//  UIViewController+NavigationBar.swift
//  Yippi
//
//  Created by Francis Yeap on 5/2/19.
//  Copyright © 2019 ZhiYiCX. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // shadowColor  - 设置导航栏分割线的颜色，默认为灰色
    func setClearNavBar(tint: UIColor = .black, shadowColor: UIColor = UIColor(hex: 0xEAEAEA)) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.tintColor = tint
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = UIImage()
            appearance.shadowColor = shadowColor
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    // shadowColor  - 设置导航栏分割线的颜色，默认为灰色
    func setWhiteNavBar(tint: UIColor = .black, shadowColor: UIColor = UIColor(hex: 0xEAEAEA), normal: Bool = false) {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = normal ? UIImage() : getBackgroupImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.tintColor = tint
        
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.backgroundImage = UIImage()
            appearance.shadowImage = normal ? UIImage() : getBackgroupImage()
            appearance.shadowColor = nil
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    func getBackgroupImage() -> UIImage {
        let bgView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 1))
        bgView.backgroundColor = .white
        let line = UIView(frame: CGRect(x: 15, y: 0, width: ScreenWidth - 30, height: 1))
        line.backgroundColor = UIColor(red: 237, green: 237, blue: 237)
        bgView.addSubview(line)
        //开启图形上下文
        UIGraphicsBeginImageContextWithOptions(bgView.bounds.size, false, 1)
        //获取当前上下文
        let ctx = UIGraphicsGetCurrentContext()
        //渲染
        bgView.layer.render(in: ctx!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? UIImage()
    }
    
}
