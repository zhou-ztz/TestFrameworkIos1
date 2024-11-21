//
//  IMMeetingMember.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/11.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit


enum IMMeetingMemberState: Int {
    case IMMeetingMemberStateConnecting //连接中
    case IMMeetingMemberStateTimeout    //未连接
    case IMMeetingMemberStateConnected  //已连接
    case IMMeetingMemberStateDisconnected //已挂断
}

class IMMeetingMember: NSObject {
    
    var userId: String = ""
    var mute: Bool = false
    var state: IMMeetingMemberState = .IMMeetingMemberStateDisconnected
    
    var isJoined: Bool = false// 是否进入频道
    var uid: UInt64 = 0
    var isMutedVoice: Bool = false
    var volume: Int32 = 0
    var isOpenLocalVideo: Bool = false //是否开启本端视频

}
