// 
// Copyright © 2018 Toga Capital. All rights reserved.
//

import Foundation
import UIKit

public typealias ShareEmptyClosure = () -> Void

@objc public protocol ShareActionSheetFactoryType {
    
    func makeShareActionSheet(thumbnail: String,
                              contentBody: String,
                              contentOwner: String?,
                              contentDesc: String?,
                              shareUrl: String,
                              id: String?,
                              externalSharingItems: [Any],
                              newPostAction: ShareEmptyClosure?,
                              owner: UIViewController) -> UIAlertController
}
