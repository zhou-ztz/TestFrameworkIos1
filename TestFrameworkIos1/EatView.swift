//
//  EatView.swift
//  Test-framework-ios
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/11/13.
//

import UIKit
import SnapKit
import SDWebImage
import Alamofire


public class EatView: UIView {

    
    public func setUI(){
        let imageview = UIImageView()
        imageview.backgroundColor = .blue
        self.addSubview(imageview)
        imageview.snp.makeConstraints { make in
            make.left.top.equalTo(100)
            make.width.height.equalTo(50)
        }
        
        imageview.sd_setImage(with: URL(string: ""))
        
//        let lab = ActiveLabel()
//        lab.text = "ActiveLabel"
//        lab.textColor = .black
//        self.addSubview(lab)
//        
//        lab.snp.makeConstraints { make in
//            make.left.top.equalTo(150)
//        }
    
    }
}


public class TestManager: NSObject {
 
    
    
    public static let shared = TestManager()
    
}
