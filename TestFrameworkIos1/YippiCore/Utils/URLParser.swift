// 
// Copyright © 2018 Toga Capital. All rights reserved.
//


import Foundation
import SwiftLinkPreview

@objcMembers
public class URLParser: NSObject {
 
    public static func parse(_ url: String, completion: ((String, String, String) -> Void)?) {
        SwiftLinkPreview().preview(url, onSuccess: { response in
            if let title = response.title, let desc = response.description, let image = response.image {
                completion?(title, desc, image)
            } else {
                completion?("", url, "")
            }
        }) { error in
            completion?("", url, "")
        }
    }
}
