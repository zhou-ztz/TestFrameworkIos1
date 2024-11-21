//
//  VideoViewItem.swift
//  Yippi
//
//  Created by Khoo on 18/08/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import NIMSDK

class VideoViewItem: NSObject {
    let itemId: String = ""
    
    let path: String
    let url: String
    let coverUrl: String
    let session: NIMSession? = nil
    
    init(videoObject: NIMVideoObject) {
        self.path = videoObject.path!
        self.url = videoObject.url!
        self.coverUrl = videoObject.coverUrl!
    }
    
    init(videoObject: MediaPreviewObject) {
        self.path = videoObject.path!
        self.url = videoObject.url!
        self.coverUrl = videoObject.thumbUrl!
    }
}
