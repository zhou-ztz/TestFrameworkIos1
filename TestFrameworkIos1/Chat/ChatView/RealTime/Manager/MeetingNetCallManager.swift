//
//  MeetingNetCallManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/1/22.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit
//import NIMPrivate

protocol MeetingNetCallManagerDelegate: class {

    func onJoinMeetingFailed(name: String, error: Error?)
    func onMeetingContectStatus(connected: Bool)
}

class MeetingNetCallManager: NSObject {
    
    static let shared = MeetingNetCallManager()
//    var meeting: NIMNetCallMeeting?
    var isInMeeting: Bool = false
    weak var delegate: MeetingNetCallManagerDelegate?
    var myVolume: UInt16 = 1
    
    public func joinMeeting(name: String, delegate: MeetingNetCallManagerDelegate?){
//        if (meeting != nil) {
//            self.leaveMeeting()
//        }
//        
//        NIMAVChatSDK.shared().netCallManager.add(self)
//        meeting = NIMNetCallMeeting()
//        meeting!.name = name
//        meeting!.type = .video
//        meeting!.actor = true
//        fillNetCallOption(meeting: meeting!)
//        self.delegate = delegate
//
//
//        NIMAVChatSDK.shared().netCallManager.join(meeting!, completion: { [weak self] (meet, error) in
//
//            if (error != nil) {
//                self?.meeting = nil
//                self?.delegate?.onJoinMeetingFailed(name: name, error: error)
//            }else{
//
//                self?.isInMeeting = true
//                let myRole = MeetingRolesManager.shared.myRole()
//                NIMAVChatSDK.shared().netCallManager.setMute(!myRole!.audioOn)
//                self?.delegate?.onMeetingContectStatus(connected: true)
//                let myUid = myRole!.uid
//                if let myUid = myUid {
//                    MeetingRolesManager.shared.updateMeetingUser(user: myUid, isJoined: true)
//                }
//
//
//            }
//
//
//
//        })
       
    }
    
    public func leaveMeeting(){
        
//        if (meeting != nil) {
//            NIMAVChatSDK.shared().netCallManager.leave(meeting!)
//            meeting = nil
//        }
//        NIMAVChatSDK.shared().netCallManager.remove(self)
//        isInMeeting = false
        
    }
    
    
//    func fillNetCallOption(meeting: NIMNetCallMeeting!){

//        let option = NIMNetCallOption()
//        option.autoRotateRemoteVideo = NTESBundleSetting.sharedConfig().videochatAutoRotateRemoteVideo()
//
//        let serverRecord = NIMNetCallServerRecord()
//        serverRecord.enableServerAudioRecording  = NTESBundleSetting.sharedConfig().serverRecordAudio()
//        serverRecord.enableServerVideoRecording  = NTESBundleSetting.sharedConfig().serverRecordVideo()
//        serverRecord.enableServerHostRecording   = NTESBundleSetting.sharedConfig().serverRecordHost()
//        serverRecord.serverRecordingMode         = NIMNetCallServerRecordMode(rawValue: NIMNetCallServerRecordMode.RawValue(NTESBundleSetting.sharedConfig().serverRecordMode()))!
//        option.serverRecord = serverRecord
//
//        let socks5Info =  NIMNetCallSocksParam()
//        socks5Info.useSocks5Proxy    =  NTESBundleSetting.sharedConfig().useSocks()
//        socks5Info.socks5Addr        =  NTESBundleSetting.sharedConfig().socks5Addr()
//        socks5Info.socks5Username    =  NTESBundleSetting.sharedConfig().socksUsername()
//        socks5Info.socks5Password    =  NTESBundleSetting.sharedConfig().socksPassword()
//        socks5Info.socks5Type        =  NIMSocksType(rawValue: NIMSocksType.RawValue(NTESBundleSetting.sharedConfig().socks5Type()!) ?? 0)!
//        option.socks5Info            =  socks5Info
//        option.preferredVideoEncoder = NTESBundleSetting.sharedConfig().perferredVideoEncoder()
//        option.preferredVideoDecoder = NTESBundleSetting.sharedConfig().perferredVideoDecoder()
//        option.videoMaxEncodeBitrate = UInt(NTESBundleSetting.sharedConfig().videoMaxEncodeKbps() * 1000)
//
//        option.autoDeactivateAudioSession = NTESBundleSetting.sharedConfig().autoDeactivateAudioSession()
//        option.audioDenoise = NTESBundleSetting.sharedConfig().audioDenoise()
//        option.voiceDetect = NTESBundleSetting.sharedConfig().voiceDetect()
//        option.preferHDAudio = NTESBundleSetting.sharedConfig().preferHDAudio()
//        option.scene = NTESBundleSetting.sharedConfig().scene()
//    //    option.videoCaptureParam = [self videoCaptureParam];
//        meeting.option = option
//    }
    
    
    
    func volumeLevel(volume: UInt16)-> NSNumber
    {
        var volumeLevel = 0
        var tem = volume / 40
        while (volume > 0) {
            volumeLevel = volumeLevel + 1
            tem = tem / 2
        }
        if (volumeLevel > 8) {
            volumeLevel = 8
        }
           
        return NSNumber(value: volumeLevel)
    }
    
//    func videoCaptureParam() -> NIMNetCallVideoCaptureParam
//    {
//        let param = NIMNetCallVideoCaptureParam()
//
//        param.videoCrop = BundleSetting.sharedConfig().videochatVideoCrop()
//
//        param.startWithBackCamera   = BundleSetting.sharedConfig().startWithBackCamera()
//        param.preferredVideoQuality = BundleSetting.sharedConfig().preferredVideoQuality()
//
//        let isManager = MeetingRolesManager.shared.myRole()!.isManager
//
//        //会议的观众这里默认用低清发送视频
//        if (param.preferredVideoQuality == .qualityDefault) {
//
//            if (!isManager) {
//                param.preferredVideoQuality = .qualityLow
//            }
//        }
//        return param
//    }

}


//extension MeetingNetCallManager: NIMNetCallManagerDelegate {
//    
//    func onUserJoined(_ uid: String, meeting: NIMNetCallMeeting) {
//        if meeting.name == self.meeting!.name {
//            MeetingRolesManager.shared.updateMeetingUser(user: uid, isJoined: true)
//        }
//        
//    }
//    
//    func onUserLeft(_ uid: String, meeting: NIMNetCallMeeting) {
//        if meeting.name == self.meeting!.name {
//            MeetingRolesManager.shared.updateMeetingUser(user: uid, isJoined: false)
//        }
//    }
//    
//    func onMeetingError(_ error: Error, meeting: NIMNetCallMeeting) {
//        self.isInMeeting = false
//        self.delegate?.onMeetingContectStatus(connected: false)
//    }
//    
//    func onMyVolumeUpdate(_ volume: UInt16) {
//        myVolume = volume
//    }
//    
//    func onSpeakingUsersReport(_ report: [NIMNetCallUserInfo]?) {
//        let uid = NIMSDK.shared().loginManager.currentAccount()
//        
//        var volums: [String: NSNumber] = [uid : self.volumeLevel(volume: myVolume)]
//        guard let report = report else {
//            return
//        }
//        for info in report {
//            volums[info.uid] = self.volumeLevel(volume: info.volume)
//        }
//        
//        MeetingRolesManager.shared.updateVolumes(volumes: volums)
//    }
//}

