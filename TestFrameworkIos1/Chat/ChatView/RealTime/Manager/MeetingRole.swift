//
//  MeetingRole.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2020/11/20.
//  Copyright © 2020 Toga Capital. All rights reserved.
//

import UIKit

class MeetingRole: NSObject {
    
    var uid: String?
    var isManager: Bool //会议管理者
    var isJoined: Bool  //已经加入音视频会议
    var isRaisingHand: Bool  //已举手
    var isActor: Bool    //有发言权限
    var audioOn: Bool    //开启声音
    var videoOn: Bool  //开启画面
    var whiteboardOn: Bool //开启白板绘制
    var audioVolume: Int16? //声音音量
    var roomAvatar: String? //头像
    
    public init (uid: String?, isManager: Bool, isJoined: Bool, isRaisingHand: Bool, isActor: Bool, audioOn: Bool, videoOn: Bool , whiteboardOn: Bool, audioVolume: Int16?, roomAvatar: String?){
        self.uid = uid
        self.isManager = isManager
        self.isJoined = isJoined
        self.isRaisingHand = isRaisingHand
        self.isActor = isActor
        self.audioOn = audioOn
        self.videoOn = videoOn
        self.whiteboardOn = whiteboardOn
        self.audioVolume = audioVolume
        self.roomAvatar = roomAvatar
    }

}
