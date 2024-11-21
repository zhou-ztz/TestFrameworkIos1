//
//  NetCallChatInfo.swift
//  Yippi
//
//  Created by Khoo on 17/06/2020.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import NIMSDK

class NetCallChatInfo: NSObject {
    var caller: String?
    var callee: String?
    var callID: UInt64?
    var channelId: String?
    var channelName: String?
    var requestId: String?
    var peerUid: String?
    var callType: NIMSignalingChannelType = .audio
    var startTime: TimeInterval?
    var isStart: Bool? = false
    var isMute: Bool? = false
    var useSpeaker: Bool? = false
    var disableCammera: Bool? = false
    var localRecording: Bool? = false
    var otherSideRecording: Bool? = false
    var audioConversation: Bool? = false
}
