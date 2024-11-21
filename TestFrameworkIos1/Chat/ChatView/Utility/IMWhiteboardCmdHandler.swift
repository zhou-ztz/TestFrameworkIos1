//
//  IMWhiteboardCmdHandler.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2021/3/3.
//  Copyright © 2021 Toga Capital. All rights reserved.
//

import UIKit

protocol IMWhiteboardCmdHandlerDelegate {
//    func onReceivePoint(point: NTESWhiteboardPoint!, sender: String)
//
//    func onReceiveCmd(type: NTESWhiteBoardCmdType, sender: String)
//
//    func onReceiveSyncRequestFrom(sender: String)
//
//    func onReceiveSyncPoints(points: [NTESWhiteboardPoint], owner: String)
//
//    func onReceiveLaserPoint(point: NTESWhiteboardPoint!, sender: String)

    func onReceiveHiddenLaserfrom(sender: String)
}

class IMWhiteboardCmdHandler: NSObject, TimerHolderDelegate {
    
    let NTESSendCmdIntervalSeconds = 0.06
    let NTESSendCmdMaxSize = 30000
    
    var sendCmdsTimer: TimerHolder!
    var cmdsSendBuffer: String!
    var refPacketID: Int = 0
    var delegate: IMWhiteboardCmdHandlerDelegate?
   // var syncPoints: [String: [[NTESWhiteboardPoint]]] = [:]
    
    
    init(delegate: IMWhiteboardCmdHandlerDelegate?) {
        super.init()
        self.delegate = delegate
        sendCmdsTimer = TimerHolder()
        sendCmdsTimer.startTimer(seconds: NTESSendCmdIntervalSeconds, delegate: self, repeats: true)
        
    }
    

//    func sendMyPoint(point: NTESWhiteboardPoint!){
//        let cmd = NTESWhiteboardCommand.pointCommand(point)
//        cmdsSendBuffer = cmdsSendBuffer + cmd!
//        
//        if (cmdsSendBuffer.count > NTESSendCmdMaxSize) {
//            self.doSendCmds()
//        }
//    }

//    func sendPureCmd(type: NTESWhiteBoardCmdType, uid: String?){
//        
//        let cmd = NTESWhiteboardCommand.pureCommand(type)
//    
//        if uid == nil {
//            cmdsSendBuffer = cmdsSendBuffer + cmd!
//            self.doSendCmds()
//        }
//        else {
//            let data = try cmd!.data(using: .utf8)
////            MeetingRTSManager.shared.sendRTSData(data: data!, toUser: uid!)
//        }
//        
//    }
//
//    func sync(allLines: [String: [[NTESWhiteboardPoint]]] , targetUid: String) {
//        for uid in allLines.keys {
//            
//            var pointsCmd = ""
//            guard let lines = allLines[uid] else {
//                return
//            }
//            for line in lines {
//                for  point in line {
//                    pointsCmd  = pointsCmd + NTESWhiteboardCommand.pointCommand(point)!
//                }
//                
//                let end = line == lines.last ? 1 : 0;
//                if (pointsCmd.count > NTESSendCmdMaxSize || end > 0 ) {
//                    let syncHeadCmd = NTESWhiteboardCommand.syncCommand(uid, end: Int32(end))
//                    let syncCmds = syncHeadCmd! + pointsCmd
//                    let data = syncCmds.data(using: .utf8)
////                    MeetingRTSManager.shared.sendRTSData(data: data!, toUser: targetUid)
//                    pointsCmd = ""
//                 
//                }
//            }
//        }
//    }
    
    func doSendCmds()
    {
//        if  cmdsSendBuffer.count > 0 {
//            let cmd = NTESWhiteboardCommand.packetIdCommand(UInt64(refPacketID + 1))
//            
//            cmdsSendBuffer = cmdsSendBuffer + cmd!
//            let data = try cmdsSendBuffer.data(using: .utf8)
////            MeetingRTSManager.shared.sendRTSData(data: data!, toUser: nil)
//            cmdsSendBuffer = ""
//           
//        }
    }
    
    func onTimerFired(holder: TimerHolder) {
        self.doSendCmds()
    }
    
//    func handleReceivedData(data: Data, sender: String)
//    {
//        let cmdsString = String(data: data, encoding: .utf8)
//
//        let cmdsArray =  cmdsString?.components(separatedBy: ";")
//        
//        for string in cmdsArray as! [String] {
//
//            if string.count == 0 {
//                continue
//            }
//            let cmd = string.components(separatedBy: CharacterSet.init(charactersIn: ":,"))
//            
//            let type = NTESWhiteBoardCmdType(rawValue: NTESWhiteBoardCmdType.RawValue(Int(cmd[0])!))
//           
//            switch (type) {
//            case .pointStart, .pointMove, .pointEnd:
//                if cmd.count == 4 {
//                    let point = NTESWhiteboardPoint()
//                    
//                    point.type = NTESWhiteboardPointType(rawValue: 1)!
//                    point.xScale = Float(cmd[1])!
//                    point.yScale = Float(cmd[2])!
//                    point.colorRGB = Int32(cmd[3])!
//                    self.delegate?.onReceivePoint(point: point, sender: sender)
//                    
//                }
//                break
//            case .cancelLine, .clearLines, .clearLinesAck, .syncPrepare:
//                self.delegate?.onReceiveCmd(type: type!, sender: sender)
//                break
//            case .syncRequest:
//                self.delegate?.onReceiveSyncRequestFrom(sender: sender)
//                break
//            case .sync:
//                let linesOwner = cmd[1] as! String
//                let end = Int(cmd[2])
//                // [self handleSync:cmdsArray linesOwner:linesOwner end:end sender:sender];
//                break
//            case .laserPenMove:
//                let point = NTESWhiteboardPoint()
//                point.type = NTESWhiteboardPointType(rawValue: 2)!
//                point.xScale = Float(cmd[1])!
//                point.yScale = Float(cmd[2])!
//                point.colorRGB = Int32(cmd[3])!
//                self.delegate?.onReceiveLaserPoint(point: point, sender: sender)
//                break
//            case .laserPenEnd:
//                self.delegate?.onReceiveHiddenLaserfrom(sender: sender)
//                break
//            default: break
//               
//            }
//        }
//        
//    }
//    
//    
//    func handleSync(cmdsArray: [String], linesOwner: String, end: Int, sender: String)
//    {
//        var points: [NTESWhiteboardPoint] = []
//        var i = 1
//        for cmdString in cmdsArray {
//            if cmdString.count == 0 {
//                continue
//            }
//            let cmd = cmdString.components(separatedBy: CharacterSet.init(charactersIn: ":,"))
//            let type = NTESWhiteBoardCmdType(rawValue: NTESWhiteBoardCmdType.RawValue(Int(cmd[0])!))
//            switch (type) {
//            case .pointStart, .pointMove, .pointEnd:
//                if (cmd.count == 4) {
//                    let point = NTESWhiteboardPoint()
//                    point.type = NTESWhiteboardPointType(rawValue: 2)!
//                    point.xScale = Float(cmd[1])!
//                    point.yScale = Float(cmd[2])!
//                    point.colorRGB = Int32(cmd[3])!
//                    points.append(point)
//                }
//                break
//            case .packetID:
//                    break
//
//                default: break
//            }
//        }
//       
//        
//        let allPoints = syncPoints[linesOwner]
//        
////        if (!allPoints) {
////            allPoints = [[NSMutableArray alloc] init];
////        }
////
////        [allPoints addObjectsFromArray:points];
////
////        if (end) {
////            if (_delegate) {
////                [_delegate onReceiveSyncPoints:allPoints owner:linesOwner];
////            }
////
////            [_syncPoints removeObjectForKey:linesOwner];
////        }
////        else {
////            [_syncPoints setObject:allPoints forKey:linesOwner];
////        }
//    }
//

}




