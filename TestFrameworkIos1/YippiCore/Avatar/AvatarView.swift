//
//  AvatarView.swift
//  ThinkSNS +
//
//  Created by GorCat on 2017/9/24.
//  Copyright © 2017年 ZhiYiCX. All rights reserved.
//
//  用户头像
/*
 
 ----------  1.初始化 ----------
 
 示例 1：使用默认构造器初始化 1
 let avatar = AvatarView(frame: CGRect(x: 10, y: 10, width: 38, height: 38))
 avatar.showBoardLine = false
 
 示例 2：使用默认构造器初始化 2
 let avatar = AvatarView()
 avatar.frame = CGRect(x: 10, y: 10, width: 38, height: 38)
 avatar.showBoardLine = false
 
 示例 3：使用 AvatarType 初始化 1
 let avatar = AvatarView(origin: CGPoint(x: 10, y: 10), type: .custom(avatarWidth: 38, showBorderLine: false))
 
 示例 4：使用 AvatarType 初始化 2
 let avatar = AvatarView(center: CGPoint(x: 29, y: 29), type: AvatarType.width38(showBorderLine: false))
 
 示例 5：使用 AvatarType 初始化 3
 let avatar = AvatarView(type: AvatarType.custom(avatarWidth: 38, showBorderLine: 38))
 avatar.showBoardLine = false

 示例 6：
 参见 ？？？，使用 sb 或者 xib 初始化
 
 以上所有示例的初始化效果都是一样的。
 
 ------------  2.设置显示内容  ------------
 // a.设置头像图片
 avatar.avatarUrl = "www.catAvatar.com"
 
 // b.设置认证图标
 avatar.verifiedInfo = TSUserVerifiedModel()
 
 // c.设置头像的用户 id，会有默认点击事件
 // 如果 userIdentity 为 nil，则头像没有默认点击事件；
 // 如果 userIdentity 不为 nil，则点击头像会 push 到对应用户的个人主页
 avatar.userIdentity = 1
 
 ----------  3.设置自定义内容内容  ----------
 a.如果想要自定义头像的图片
 AvatarView 的实例中 buttonForAvatar 就是头像按钮，直接对齐做操作即可
 
 b.如果想要自定义头像的点击事件
 将 AvatarView 的 userIdentity 设置成 nil，然后给 buttonForAvatar 添加点击事件即可
 
 c.如果想要自定义认证图标
 AvatarView 的实例中 buttonForVerified 就是认证图标，直接对齐做操作即可

 d.增加了对未知用户的显示与操作
 */

import UIKit
import SDWebImage
import SnapKit

// MARK: - 头像初始化方法
extension AvatarView {

    convenience init() {
        self.init(frame: CGRect(origin: .zero, size: AvatarType.width33(showBorderLine: false).size))
        setUI()
    }
    
    convenience init(origin: CGPoint = .zero, type: AvatarType, animation: Bool = false, isFromReactionList: Bool = false) {
        self.init(frame: CGRect(origin: origin, size: type.size))
        self.showBoardLine = type.showBorderLine
        self.showLiveIcon = animation
        self.isFromReactionList = isFromReactionList
        setUI()
    }
}

class AvatarView: UIView {

    var shouldAnimate = false
    enum PlaceholderType: String {

        case unknown = "IMG_pic_default_secret"
        case group = "ic_rl_default_group"
        case system = "ic_notification_default"
        case liveAvatar = "icLiveAvatarPlaceholder"
        case camera = "ic_rl_camera"
        
        init(sexNumber: Int?) {
            guard let number = sexNumber else {
                self = .unknown
                return
            }
            switch number {
            case 3:
                self = .group
            default:
                self = .unknown
            }
        }
    }

    /// 头像信息
    var avatarInfo = AvatarInfo() {
        didSet {
            if avatarInfo.avatarPlaceholderType != .unknown {
                    avatarPlaceholderType = avatarInfo.avatarPlaceholderType
            }
            // 加载头像
            loadAvatar()
            // 加载认证图标
            loadVerifiedIcon()
            // 加载点击事件
            loadTouchEvent()
            loadLiveAnimation()
            
            bringSubviewToFront(liveIcon)
            bringSubviewToFront(buttonForVerified)
        }
    }

    /// 头像边框
    var borderWidth: CGFloat = 2
    /// 头像边框颜色
    var borderColor = UIColor.white
    /// 是否显示边框
    var showBoardLine = false

    /// 头像按钮
    var buttonForAvatar = UIButton(type: .custom)
    /// 认证图标按钮
    var buttonForVerified = UIButton(type: .custom)

    /// 头像占位图类型
    var avatarPlaceholderType = PlaceholderType.unknown
    /// 头像占位图
    var avatarPlaceholderImage: UIImage {
        return UIImage.set_image(named: avatarPlaceholderType.rawValue)!
    }
    /// able to custom placeholder image
    var customAvatarPlaceholderImage: UIImage?
    
    /// 屏幕比例
    let scale = UIScreen.main.scale
    /// 重绘大小的配置
//    var resizeProcessor: ResizingImageProcessor {
//        let avatarImageSize = CGSize(width: avatarFrame.width * scale, height: avatarFrame.width * scale)
//        return ResizingImageProcessor(referenceSize: avatarImageSize, mode: .aspectFill)
//    }
    /// 头像 frame
    var avatarFrame: CGRect {
        return bounds
    }
    var showLiveIcon: Bool = false
    var isFromReactionList: Bool = false
    
    private var liveIcon: UIImageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: 1, height: 1))).configure {
        $0.contentMode = .scaleAspectFit
    }
    
    private var shapeLayer: CAShapeLayer?
    
    private let loadingProcessView = UILabel()

    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer?.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        buttonForAvatar.applyBorder(color: borderColor, width: showBoardLine ? borderWidth : 0)
        buttonForAvatar.circleCorner()
        if buttonForAvatar.frame.width == 0 {
            buttonForAvatar.layer.cornerRadius = frame.width / 2
        }
        buttonForAvatar.clipsToBounds = true
        buttonForAvatar.imageView?.contentMode = .scaleAspectFill
    }
     
    // MARK: - Public

    // MARK: - UI
    private func setUI() {
        addSubview(buttonForAvatar)
        addSubview(buttonForVerified)
        addSubview(liveIcon)
        liveIcon.isHidden = !showLiveIcon
        liveIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(-8)
            $0.width.equalToSuperview()
            $0.height.equalTo(bounds.height * 0.4)
        }
        
        buttonForAvatar.snp.makeConstraints {
            $0.width.height.equalTo(frame.width)
            $0.edges.equalToSuperview()
        }
        
        buttonForVerified.snp.makeConstraints { (make) in
            make.width.height.equalTo(frame.height * 0.35)
            make.right.bottom.equalToSuperview().offset(1.5)
        }
        
        loadingProcessView.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        loadingProcessView.isHidden = true
        loadingProcessView.isUserInteractionEnabled = false
        loadingProcessView.textColor = .white
        loadingProcessView.textAlignment = .center
        addSubview(loadingProcessView)
        loadingProcessView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bringSubviewToFront(buttonForVerified)
        bringSubviewToFront(liveIcon)
    }
}

// MARK: - 头像加载
extension AvatarView {
    /// 加载头像
    fileprivate func loadAvatar() {
        // 2.加载头像图片
        buttonForAvatar.sd_setImage(with: URL(string: avatarInfo.avatarURL.orEmpty), for: .normal, placeholderImage: avatarPlaceholderImage ?? UIImage.set_image(named: avatarPlaceholderType.rawValue), options: [.lowPriority, .scaleDownLargeImages])
    }
}

// MARK: - 认证图标加载
extension AvatarView {

    /// 加载认证图标
    fileprivate func loadVerifiedIcon() {
        // 1.判断是否显示认证图标，并配置显示设置
        buttonForVerified.isHidden = avatarInfo.verifiedType.isEmpty
        buttonForVerified.isUserInteractionEnabled = false // 暂不开放认证图标点击事件
        buttonForVerified.imageView?.contentMode = .scaleToFill
        
        buttonForVerified.clipsToBounds = true
        buttonForVerified.layer.cornerRadius = frame.height * 0.35 / 2

        // 2.根据认证 icon，加载认证图片
        guard !avatarInfo.verifiedType.isEmpty else {
            return
        }
        /*
         这里的逻辑为：
         1.后台返回了图标图片 url，就加载后台返回的图标图片。
         2.后台没有返回图标图片 url，就加载本地的图标图片。
         */
        // 使用本地图片
        if avatarInfo.verifiedIcon.isEmpty {
            // 使用本地图片
            var imageName: String?
            switch avatarInfo.verifiedType {
            case "user":
                imageName = "IMG_pic_identi_individual"
            case "org":
                imageName = "IMG_pic_identi_company"
            default:
                imageName = ""
            }
            if let name = imageName {
                let localImage = UIImage.set_image(named: name)
                buttonForVerified.setImage(localImage, for: .normal)
                buttonForVerified.imageView?.isHidden = false
            } else {
                buttonForVerified.imageView?.isHidden = true
            }
        } else {
            // 加载后台返回图标
            let iconURL = URL(string: avatarInfo.verifiedIcon)
            buttonForVerified.sd_setImage(with: iconURL, for: .normal, placeholderImage: nil, options: [.refreshCached,], completed: nil)
        }
    }
}

// MARK: - 头像点击事件
extension AvatarView {

    /// 设置点击事件
    func loadTouchEvent() {
        // 1. 清空所有点击事件
        buttonForAvatar.removeAllTargets()

        // 2. 根据头像类型，加载不同的头像
        switch avatarInfo.type {
        case .unknow:
            buttonForAvatar.addTarget(self, action: #selector(unknowUserTaped), for: .touchUpInside)
        case .normal(let userId):
            if avatarInfo.hasLive() && showLiveIcon {
                buttonForAvatar.addTarget(self, action: #selector(liveTapped), for: .touchUpInside)
                return
            }
            if userId != nil {
                buttonForAvatar.addTarget(self, action: #selector(normalUserTaped), for: .touchUpInside)
            }
        }
    }

    /// 点击了未知用户
    @objc func unknowUserTaped() {
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.UnknowDidClick, object: nil, userInfo: nil)
    }

    /// 点击了普通用户
    @objc func normalUserTaped() {
        // 如果没有设置 userId，就认为 coder 选择不使用默认点击事件
        //guard let userId = avatarInfo.type.userId, userId != CurrentUserSessionInfo?.userIdentity else {
        guard let userId = avatarInfo.type.userId else {
            return
        }
        NotificationCenter.default.post(name: NSNotification.Name.AvatarButton.DidClick, object: nil, userInfo: ["uid": userId, "isFromReactionList": isFromReactionList])
    }
    
    @objc func liveTapped() {
        guard let liveId = avatarInfo.liveId else {
            return
        }
        UIViewController.topMostController?.navigateLive(feedId: liveId)
    }
}

extension AvatarView {
    func showLoadingOverlay() {
        loadingProcessView.layer.masksToBounds = true
        loadingProcessView.roundCorner(frame.height / 2.0)
        loadingProcessView.text = "0%"
        loadingProcessView.isHidden = false
    }
    func hideLoading() {
        loadingProcessView.isHidden = true
    }
    func updateLoadingProcess(completedFraction:Double) {
        if completedFraction > 0.99 {
            loadingProcessView.isHidden = true
            return
        }
        let percentage = String(format: "%.0f", completedFraction * 100)
        loadingProcessView.text = "\(percentage)%"
    }
}

extension AvatarView {
    
    func loadLiveAnimation() {
        if self.shapeLayer != nil {
            self.shapeLayer?.removeFromSuperlayer()
            self.shapeLayer = nil
        }
        guard showLiveIcon && avatarInfo.hasLive() else {
            liveIcon.isHidden = true
            return
        }
        
        if let color = avatarInfo.frameColor {
            let halfSize = min(self.bounds.width, self.bounds.height)/2
            let lineWidth:CGFloat = 1.0
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
            shapeLayer.lineWidth = lineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor(hex: color).cgColor

            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.duration = 0.5
            scaleAnimation.fromValue = 1.05
            scaleAnimation.toValue = 1.2
            scaleAnimation.repeatCount = .infinity
            scaleAnimation.autoreverses = true
            scaleAnimation.isRemovedOnCompletion = false
            
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.duration = 0.5
            opacityAnimation.fromValue = 1
            opacityAnimation.toValue = 0.4
            opacityAnimation.repeatCount = .infinity
            opacityAnimation.autoreverses = true
            opacityAnimation.isRemovedOnCompletion = false
            
            shapeLayer.add(opacityAnimation, forKey: "opacity")
            shapeLayer.add(scaleAnimation, forKey: "scale")
            
            shapeLayer.bounds = self.bounds
            shapeLayer.frame = self.layer.bounds
            shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
            shapeLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

            self.layer.addSublayer(shapeLayer)
            self.shapeLayer = shapeLayer
        }
        
        if let icon = avatarInfo.frameIcon {
            liveIcon.sd_setImage(with: URL(string: icon), placeholderImage: nil, options: [.scaleDownLargeImages], completed: nil)
            liveIcon.isHidden = false
        } else {
            liveIcon.isHidden = true
        }
    }
}
