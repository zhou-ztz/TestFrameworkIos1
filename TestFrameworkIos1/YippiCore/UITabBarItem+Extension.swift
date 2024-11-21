// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import UIKit

public extension UITabBarItem {
    
    convenience init(image: UIImage, selectedImage: UIImage) {
        self.init(title: nil, image: image.withRenderingMode(.alwaysOriginal), selectedImage: selectedImage.withRenderingMode(.alwaysOriginal))
        self.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
}
