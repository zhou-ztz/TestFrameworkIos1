//
//  NMCWebLoginParam.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司-zhi on 2024/3/6.
//  Copyright © 2024 Toga Capital. All rights reserved.
//

import UIKit

class NMCWebLoginParam: NSObject {
    /// 房间名
    var channelName: String = ""

    /// app key
    var appKey: String = ""

    /// uid
    var uid: UInt = 0

    /// 是否服务端录制
    var record: Bool = false

    /// 是否开启 web 调试日志
    var debug: Bool = false

}

class NMCWhiteBoardParam: NSObject {
    /// 房间名
    var channelName: String = ""

    /// app key
    var appKey: String = ""

    /// uid
    var uid: UInt = 0

    /// web view url
    var webViewUrl: String = ""


}

