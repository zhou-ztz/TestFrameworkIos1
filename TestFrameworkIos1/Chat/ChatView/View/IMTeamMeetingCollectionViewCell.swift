//
//  IMTeamMeetingCollectionViewCell.swift
//  Yippi
//
//  Created by 深圳壹艺科技有限公司 on 2023/1/12.
//  Copyright © 2023 Toga Capital. All rights reserved.
//

import UIKit
import NERtcSDK
import NIMSDK

class IMTeamMeetingCollectionViewCell: UICollectionViewCell {
    
    var team: NIMTeam?

    var user: IMMeetingMember?
    var localCanvas: NERtcVideoCanvas?
    var remoteCanvas: NERtcVideoCanvas?
    var glView: UIView?
    var cameraView: UIView = UIView()
    var model: IMMeetingMember!

    var overlayView: UIView = UIView().configure {
        $0.backgroundColor = UIColor.init(white: 0.2, alpha: 0.5)
        $0.isHidden = true
    }

    //var avatarImageView: AvatarView = AvatarView()
    var avatarImageView: UIImageView = UIImageView().configure {
        $0.contentMode = .scaleToFill
    }

    var tipLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 13, color: .white))
        $0.textAlignment = .center
        $0.autoresizingMask = .flexibleWidth
        $0.lineBreakMode = .byWordWrapping
        $0.shadowColor = UIColor(hex: "0x000000",alpha: 0.3)
        $0.shadowOffset = CGSize(width: 2, height: 2)
    }

    let nameLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 12, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.autoresizingMask = .flexibleWidth
        $0.lineBreakMode = .byTruncatingTail
        $0.backgroundColor = UIColor(hex: "0x000000",alpha: 0.3)
    }

    let connectingLabel: UILabel = UILabel().configure {
        $0.applyStyle(.regular(size: 17, color: .white))
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.text = "connecting".localized
    }

    let muteButton: UIButton = UIButton().configure {
        $0.setImage(UIImage.set_image(named: "btn_mute_normal"), for: .normal)
        $0.setImage(UIImage.set_image(named: "btn_mute_pressed"), for: .selected)
        $0.isHidden = true
    }

    let progressView: UIProgressView = UIProgressView().configure {
        $0.progressTintColor = UIColor(hex: 0x168cf6)
        $0.trackTintColor = .clear
        $0.isHidden = true
    }
    let connectingImageView: UIImageView = UIImageView().configure {
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .darkGray
        self.setUI()

    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI(){
        self.contentView.addSubview(self.cameraView)
        self.cameraView.isHidden = true
        self.cameraView.bindToEdges()
        self.contentView.addSubview(self.overlayView)
        self.overlayView.bindToEdges()
        self.contentView.addSubview(self.avatarImageView)
        self.avatarImageView.bindToEdges()
        avatarImageView.layer.cornerRadius = 0
        avatarImageView.clipsToBounds = true
        
        self.contentView.addSubview(self.connectingLabel)
        connectingLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.center.equalToSuperview()
        }
        self.contentView.addSubview(self.tipLabel)
        tipLabel.bindToEdges()
        
        self.contentView.addSubview(self.nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
        }
        
        self.contentView.addSubview(self.progressView)
        progressView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.right.left.bottom.equalToSuperview()
        }
        let path = Bundle.main.path(forResource: "icon_meeting_connect", ofType: "gif")
        let data = NSData.init(contentsOfFile: path ?? "")
        let image = UIImage.sd_image(withGIFData: data as Data?)
        connectingImageView.image = image
        self.contentView.addSubview(self.connectingImageView)
        connectingImageView.snp.makeConstraints { make in
            //make.left.right.equalToSuperview().offset(10)
            make.center.equalToSuperview()
           // make.height.equalTo(20)
        }
        
        
        self.contentView.addSubview(self.muteButton)
        muteButton.snp.makeConstraints { make in
            make.height.width.equalTo(20)
            make.right.top.equalToSuperview()
        }
        muteButton.addTarget(self, action: #selector(muteUser), for: .touchUpInside)
        

    }
    
    @objc func muteUser(){
        muteButton.isSelected = !muteButton.isSelected
        
        if let model = self.model {
            NERtcEngine.shared().subscribeRemoteAudio(!muteButton.isSelected, forUserID: model.uid)
        }
    }
    
    override func prepareForReuse() {
        self.muteButton.isHidden = true
        self.avatarImageView.isHidden = false
    }
    
    func refreshWithEmpty(){
        self.cameraView.isHidden = true
        self.avatarImageView.isHidden = true
        self.progressView.isHidden = true
        self.connectingImageView.stopAnimating()
        self.connectingImageView.isHidden = true
        self.tipLabel.isHidden = true
        self.nameLabel.isHidden = true
        self.connectingLabel.isHidden  = true
        self.muteButton.isHidden  = true
        self.overlayView.isHidden  = true
    }
    
    func refrehWithConnecting(user: String){

        self.refreshWithDefaultAvatar(user: user)
        self.connectingImageView.isHidden  = true
        self.contentView.bringSubviewToFront(self.overlayView)
        //self.contentView.bringSubviewToFront(self.connectingImageView)
        self.contentView.bringSubviewToFront(self.connectingLabel)
       // connectingImageView.startAnimating()
        self.connectingLabel.isHidden  = false
        self.overlayView.isHidden  = false
        self.setNeedsLayout()
    }
    
    func refreshWithDefaultAvatar(user: String){
        self.cameraView.isHidden = true
        self.avatarImageView.isHidden = false
        self.progressView.isHidden = false
        self.muteButton.isHidden = true
        self.connectingLabel.isHidden  = true
        self.connectingImageView.isHidden  = true
        self.overlayView.isHidden  = true
        connectingImageView.stopShimmering()
        
        self.overlayView.isHidden  = true
        
        let nick = SessionUtil.showNick(user, in: nil)
        self.nameLabel.isHidden = false
        self.nameLabel.text = nick
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: user)
        avatarImageView.sd_setImage(with: URL(string: avatarInfo.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"))
        self.contentView.bringSubviewToFront(self.nameLabel)
        self.contentView.bringSubviewToFront(self.progressView)
        self.setNeedsLayout()
    }
    
    func refreshWidthVolume(volume: Int32){
        self.progressView.isHidden = volume > 0 ? false : true
        var volumeMax: Int32 = 400
        let volume1 = volumeMax > (volume * 4) ? (volume * 4) : volumeMax
        
        var vo = Float(volume1) / Float(volumeMax)
        if vo >= 1.0 {
            vo = 0.99
        }
        self.progressView.setProgress(vo, animated: true)
        self.contentView.bringSubviewToFront(self.progressView)
    }
    
    func canvasViewMueted(enable: Bool, model: IMMeetingMember ){
        self.cameraView.isHidden = enable
        
        self.avatarImageView.isHidden = !enable
        let nick = SessionUtil.showNick(model.userId, in: nil)
        self.nameLabel.isHidden = false
        self.nameLabel.text = nick
        self.contentView.bringSubviewToFront(self.nameLabel)
        self.connectingLabel.isHidden = true
        self.connectingImageView.isHidden  = true
        connectingImageView.stopAnimating()
        let avatarInfo = NIMSDKManager.shared.getAvatarIcon(userId: model.userId)
        avatarImageView.sd_setImage(with: URL(string: avatarInfo.avatarURL ?? ""), placeholderImage: UIImage.set_image(named: "IMG_pic_default_secret"))

        self.overlayView.isHidden  = true
        self.setNeedsLayout()
    }
    
    
    func setLocalVideo(enable: Bool, model: IMMeetingMember?){
        
        if localCanvas == nil {
            localCanvas = NERtcVideoCanvas()
            localCanvas?.container = cameraView
            localCanvas?.renderMode = .cropFill
            localCanvas?.mirrorMode = .enabled
        }
        
        NERtcEngine.shared().setupLocalVideoCanvas(localCanvas)
        //以开启本地视频主流采集并发送
        //NERtcEngine.shared().enableLocalVideo(enable, streamType: .mainStream)
    }
    func setRemoteView(enable: Bool, model: IMMeetingMember ){
        if remoteCanvas == nil {
            remoteCanvas = NERtcVideoCanvas()
            remoteCanvas?.container = cameraView
            remoteCanvas?.renderMode = .cropFill
            remoteCanvas?.mirrorMode = .enabled
            
        }
        NERtcEngine.shared().setupRemoteVideoCanvas(remoteCanvas, forUserID: model.uid)
    }
    
    
    //订阅远端视频
    func subscribeRemoteVideo(userID: UInt64){
        NERtcEngine.shared().subscribeRemoteVideo(true, forUserID: userID, streamType: .high)
    }
    
    func refreshWithModel(model: IMMeetingMember){
        self.model = model
        self.refreshWithDefaultAvatar(user: model.userId)
        //本端
        if model.userId == NIMSDK.shared().loginManager.currentAccount() {
            
            self.setLocalVideo(enable: model.isOpenLocalVideo, model: model)
            
            self.canvasViewMueted(enable: !model.isOpenLocalVideo, model: model)
        }else{//远端
            self.setRemoteView(enable: true, model: model)
            
            self.canvasViewMueted(enable: !model.isOpenLocalVideo, model: model)
            
        }
        
        self.muteButton.isHidden = model.userId == NIMSDK.shared().loginManager.currentAccount()
        self.contentView.bringSubviewToFront(self.muteButton)
    }
}
