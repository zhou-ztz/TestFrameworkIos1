//
//  MiniVideoListPlayerManager.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2022/4/26.
//  Copyright © 2022 Toga Capital. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AliyunVideoSDKPro
import AliyunPlayer

class MiniVideoListPlayerManager: NSObject, AVPDelegate,AliMediaLoaderStatusDelegate {
    
    static let shared = MiniVideoListPlayerManager()
    
    //用来做列表播放的list对象
    private var listPlayer: AliListPlayer = AliListPlayer()
    // 播放状态
    private var playerStatus: AVPStatus = AVPStatusIdle
    
    //播放进度回调
    var onCurrentPositionUpdateHandler: ((Int64,Int64) -> Void)?
    //播放状态回调
    var onCurrentPlayStatusUpdateHandler: ((AVPStatus) -> Void)?
    
    // 播放总时长
    var playerDuration: Int64 = 0
    
    //记录所有播放数据
    var allVideos: [FeedListCellModel] = []
    //记录当前播放数据
    var curVideo: FeedListCellModel?
    override init() {
        super.init()
        
        self.checkAliLicense()
        self.setupPlayer()
    }
    // MARK: - 初始化阿里云播放器证书服务
    func checkAliLicense() {
        AliPrivateService.initLicense()
    }
    func setupPlayer() {
        
        self.listPlayer = AliListPlayer.init()
        self.listPlayer.setTraceID(Device.currentUDID)
        self.listPlayer.isLoop = true
        self.listPlayer.isAutoPlay = true
        self.listPlayer.scalingMode = AVP_SCALINGMODE_SCALEASPECTFIT
        self.listPlayer.delegate = self
        self.listPlayer.preloadCount = 3
        self.listPlayer.setFastStart(true)

        let config = self.listPlayer.getConfig()
        config?.networkTimeout = 5000
        config?.maxBufferDuration = 1000
        config?.networkRetryCount = 3
        config?.startBufferDuration = 100
        config?.enableLocalCache = true
        self.listPlayer.setConfig(config)
        
        let cacheConfig = AVPCacheConfig()
        cacheConfig.enable = true
    
        let documentsPath =  NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        
        self.listPlayer.setCacheConfig(cacheConfig)
        
        AliPlayerGlobalSettings.enableNetworkBalance(false)
        AliPlayerGlobalSettings.enableLocalCache(true, maxBufferMemoryKB: 1024, localCacheDir: documentsPath)
    }
    // MARK: - 暂停播放
    func pause() {
        self.listPlayer.pause()
    }
    // MARK: - 停止播放
    func stop() {
        self.listPlayer.stop()
    }
    // MARK: - 开始播放
    func play() {
        self.listPlayer.start()
    }
    // MARK: - 设置播放源视图
    func setPlayerView(_ view: UIView){
        self.listPlayer.playerView = view
    }
    // MARK: - 设置播放器数据源
    func initPlayerSource(_ videos: [FeedListCellModel]) {

        //清空播放列表重新加载，避免重复播放资源
        if allVideos.count > 0 {
            self.clearPlayerSource()
        }
        allVideos.append(contentsOf: videos)
        //去重
        let filter_videos =  allVideos.filterDuplicates({ $0.videoURL })
        //添加资源到播放列表中
        for model in filter_videos {
            self.listPlayer.addUrlSource(model.videoURL, uid: "\(model.videoURL)")
            AliMediaLoader.shareInstance().load(model.videoURL, duration: 1000)
            AliMediaLoader.shareInstance().setAliMediaLoaderStatusDelegate(self)
            
        }
        //处理被清理掉的当前播放对象
        if let video = self.curVideo {
            self.listPlayer.move(to: "\(video.videoURL)")
            self.listPlayer.start()
        }
    }
    // MARK: - 清理播放器列表
    func clearPlayerSource() {
        self.listPlayer.clear()
    }
    
    // MARK: - 设置播放对象
    func playWithVideo(_ video: FeedListCellModel) {
        curVideo = video
        self.listPlayer.move(to: "\(video.videoURL)")
        self.listPlayer.start()
    }
    // MARK: - 设置
    func setSeek(_ toTime: Int64) {
        self.listPlayer.seek(toTime: toTime, seekMode: AVP_SEEKMODE_INACCURATE)
    }
    // MARK: - 获取视频播放状态
    func getPlayStatus() -> AVPStatus{
        return self.playerStatus
    }
    
    func onCurrentPositionUpdate(_ player: AliPlayer!, position: Int64) {
        if self.playerDuration > 0 {
            self.onCurrentPositionUpdateHandler?(position/1000, self.playerDuration)
        }
    }
    // MARK: - AVPDelegate
    func onPlayerEvent(_ player: AliPlayer!, eventType: AVPEventType) {
        switch eventType {
        case AVPEventPrepareDone:
            if self.listPlayer.duration >= 0 {
                self.playerDuration = self.listPlayer.duration / 1000
            }
        case AVPEventAutoPlayStart:
            if self.listPlayer.duration >= 0 {
                self.playerDuration = self.listPlayer.duration / 1000
            }
        case AVPEventFirstRenderedStart:
            print("首帧显示")
            self.onCurrentPlayStatusUpdateHandler?(AVPStatusStarted)
        case AVPEventCompletion:
            print("播放完成")
        case AVPEventLoadingStart:
            print("缓冲开始")
        default:
            break
        }
    }
    func onPlayerStatusChanged(_ player: AliPlayer!, oldStatus: AVPStatus, newStatus: AVPStatus) {
        
        switch newStatus {
        case AVPStatusIdle:
            print("空转，闲时，静态")
        case AVPStatusInitialzed:
            print("初始化完成")
        case AVPStatusPrepared:
            print("准备完成")
            self.playerStatus = newStatus
            self.onCurrentPlayStatusUpdateHandler?(newStatus)
        case AVPStatusStarted:
            print("正在播放")
            self.playerStatus = newStatus
            self.onCurrentPlayStatusUpdateHandler?(newStatus)
        case AVPStatusPaused:
            print("播放暂停")
            self.playerStatus = newStatus
            self.onCurrentPlayStatusUpdateHandler?(newStatus)
        case AVPStatusStopped:
            print("播放停止")
        case AVPStatusError:
            print("播放错误")
            if self.playerStatus != AVPStatusError {
                self.playerStatus = newStatus
                self.onCurrentPlayStatusUpdateHandler?(newStatus)
            }
        default:
           
            break
        }
    }
    
    func onError(_ url: String!, code: Int64, msg: String!) {
//        print("视频缓存失败 url: \(url)")
    }
    func onCompleted(_ url: String!) {
//        print("视频缓存完成 url:\(url)")
    }
}
